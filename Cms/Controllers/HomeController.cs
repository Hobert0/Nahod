using System;
using System.Collections;
using System.Collections.Generic;
using System.ComponentModel;
using System.Globalization;
using System.IO;
using System.Linq;
using System.Text.RegularExpressions;
using System.Threading.Tasks;
using System.Web;
using System.Web.Mvc;
using System.Web.UI.WebControls;
using System.Xml;
using System.Xml.Linq;
using Cms.Models;
using Newtonsoft.Json;
using PagedList;
using System.Security.Cryptography;
using System.Text;

namespace Cms.Controllers
{
    public class HomeController : Controller
    {
        Entities db = new Entities();
        public ActionResult Index()
        {
            var model = new MultipleIndexModel();

            if (Request.Cookies["userid"] != null)
            {
                var userToSend = Int32.Parse(Request.Cookies["userid"].Value);
                model.AllUsersMetaModel = db.usersmeta.Where(i => i.userid == userToSend).ToList();
            }
            else
            {
                model.AllUsersMetaModel = null;
            }

            model.ProductModel = db.products.Where(o => o.deleted == false && o.active == true).ToList();
            model.VariantModel = db.variants.Where(o => o.deleted == false).ToList();
            model.EsettingsModel = db.e_settings.ToList();
            model.SettingsModel = db.settings.ToList();
            model.PagesModel = db.pages.ToList();
            model.BlogModel = db.blog.ToList();
            model.BrandsModel = db.brands.Where(o => o.deleted == false).ToList();
            model.CategoriesModel = db.categories.Where(o => o.deleted == false).ToList();
            model.TypesModel = db.types.Where(o => o.deleted == false).ToList();
            model.SlideshowModel = db.slideshow.ToList();

            ViewData["countries"] = new AdminController().SelectionCountries();
            ViewData["Homepage"] = "true";
            return View(model);
        }

        [Route("cartsession")]
        public ActionResult CartSession(string cartValues)
        {
            var cartVal = JsonConvert.DeserializeObject<List<dynamic>>(cartValues);
            Session["cartitems"] = cartVal;

            decimal thisSum = 0;
            foreach (var item in cartVal)
            {

                decimal thisPrice = Convert.ToDecimal(item.price);
                decimal thisQuantity = Convert.ToDecimal(item.quantity);

                thisSum += thisQuantity * thisPrice;
            }
            Session["cartsum"] = thisSum;

            return Json(cartValues, JsonRequestBehavior.AllowGet);
        }

        [Route("blog")]
        public ActionResult Blog()
        {
            var model = new MultipleIndexModel();
            model.ProductModel = db.products.Where(o => o.deleted == false && o.active == true).ToList();
            model.EsettingsModel = db.e_settings.ToList();
            model.SettingsModel = db.settings.ToList();
            model.PagesModel = db.pages.ToList();
            model.BlogModel = db.blog.ToList();
            model.BrandsModel = db.brands.Where(o => o.deleted == false).ToList();
            model.CategoriesModel = db.categories.Where(o => o.deleted == false).ToList();
            model.SlideshowModel = db.slideshow.ToList();
            ViewData["Homepage"] = "true";

            ViewData["countries"] = new AdminController().SelectionCountries();

            return View(model);
        }

        [Route("wishsession")]
        public ActionResult WishSession(string wishValues)
        {
            var wishVal = JsonConvert.DeserializeObject<List<dynamic>>(wishValues);
            Session["wishitems"] = wishVal;

            var modelwish = new MultipleIndexModel();

            if (Request.Cookies["userid"] != null)
            {
                var usID = Int32.Parse(Request.Cookies["userid"].Value);
                var userdata = db.wishlist.Where(i => i.userid == usID).ToList();
                if (userdata.Count() == 0)
                {
                    wishlist insert = new wishlist();
                    insert.userid = usID;
                    insert.data = wishValues.ToString();

                    db.wishlist.Add(insert);
                    db.SaveChanges();
                }
                else
                {
                    var update = db.wishlist.Where(i => i.userid == usID).Single();
                    update.data = wishValues.ToString();

                    db.SaveChanges();
                }
            }

            return Json(wishValues, JsonRequestBehavior.AllowGet);
        }

        [Route("kat/{catslug}/{subslug?}/{subslug2?}/{subslug3?}")]
        public ActionResult Category(string catslug, string subslug, string subslug2, string subslug3, string sortOrder, string currentFilter, string searchString, int? page)
        {
            var id = "";

            if (subslug == null && catslug != "novinky" && catslug != "zlavy")
            {
                id = db.categories.Where(i => i.deleted == false && i.slug == catslug).First().id.ToString();
            }
            else if (subslug != null && subslug2 == null && catslug != "novinky" && catslug != "zlavy")
            {
                var topcatName = db.categories.Where(i => i.slug == catslug).First().id.ToString();
                id = db.categories.Where(i => i.deleted == false && i.slug == subslug && i.maincat == topcatName).First().id.ToString();
            }
            else if (subslug2 != null && subslug3 == null && catslug != "novinky" && catslug != "zlavy")
            {
                var topcatName = db.categories.Where(i => i.slug == catslug).First().id.ToString();
                var topcat2Name = db.categories.Where(i => i.slug == subslug).First().id.ToString();
                id = db.categories.Where(i => i.deleted == false && i.slug == subslug2 && i.maincat == topcatName && i.topcat == topcat2Name).First().id.ToString();
            }
            else if (subslug3 != null && catslug != "novinky" && catslug != "zlavy")
            {
                var maincatName = db.categories.Where(i => i.slug == catslug).First().id.ToString();
                var topcatName = db.categories.Where(i => i.slug == subslug).First().id.ToString();
                var topcat2Name = db.categories.Where(i => i.slug == subslug2).First().id.ToString();

                id = db.categories.Where(i => i.deleted == false && i.slug == subslug3 && i.maincat == maincatName && i.topcat == topcatName && i.topcat2 == topcat2Name).First().id.ToString();
            }

            var model = new MultipleIndexModel();

            model.ProductModel = db.products.Where(o => o.deleted == false && o.active == true && (o.category.Contains("[" + id.ToString() + ",") || o.category.Contains("," + id.ToString() + ",") || o.category.Contains("," + id.ToString() + "]"))).ToList();
            model.EsettingsModel = db.e_settings.ToList();
            model.SettingsModel = db.settings.ToList();
            model.PagesModel = db.pages.ToList();
            model.CategoriesModel = db.categories.Where(o => o.deleted == false).ToList();
            model.BrandsModel = db.brands.Where(o => o.deleted == false).ToList();
            model.SlideshowModel = db.slideshow.ToList();
            model.VariantModel = db.variants.ToList();

            if (Request.Cookies["userid"] != null)
            {
                var userToSend = Int32.Parse(Request.Cookies["userid"].Value);
                model.AllUsersMetaModel = db.usersmeta.Where(i => i.userid == userToSend).ToList();
            }
            else
            {
                model.AllUsersMetaModel = null;
            }

            var kategoria = db.categories.Where(i => i.slug == catslug).Select(o => o.name);
            var sub = db.categories.Where(i => i.slug == subslug).Select(o => o.name);
            ViewData["Category"] = kategoria;
            ViewData["Sub"] = sub;
            ViewData["CatId"] = id;
            ProductModel pm = new ProductModel();
            ProductsController pc = new ProductsController();
            ViewData["typ"] = pc.SelectionZaradenie();
            ViewData["znacka"] = pc.SelectionBrandFiltered(model.ProductModel);
            ViewData["pageType"] = "category";

            ViewData["catslug"] = catslug;
            ViewData["subslug"] = subslug;

            List<decimal?> prices = new List<decimal?>();
            List<int[]> ordersCount = new List<int[]>();

            foreach (var item in model.ProductModel)
            {
                prices.Add(item.price);
                prices.Add(item.discountprice);

                int[] arr = new int[] { item.id, db.ordermeta.Where(o => o.productid == item.id.ToString()).Count() };
                ordersCount.Add(arr);
            }
            prices.Sort();
            var ordersCountSorted = ordersCount.OrderByDescending(o => o[1]).Take(10);

            ViewData["minPrice"] = prices.FirstOrDefault();
            ViewData["maxPrice"] = prices.LastOrDefault();

            ViewData["countries"] = new AdminController().SelectionCountries();

            //najpredavanejsie
            ViewData["mostSold"] = ordersCountSorted;


            return View(model);
        }

        [Route("znacka/{brand}/{catslug?}/{subslug?}/{page?}/{id?}")]
        public ActionResult Brand(string brand, string catslug, string subslug)
        {

            var model = new MultipleIndexModel();
            model.ProductModel = db.products.Where(i => i.custom3 == brand && i.deleted == false && i.active == true).ToList();
            model.EsettingsModel = db.e_settings.ToList();
            model.SettingsModel = db.settings.ToList();
            model.PagesModel = db.pages.ToList();
            model.CategoriesModel = db.categories.Where(o => o.deleted == false).ToList();
            model.BrandsModel = db.brands.Where(o => o.deleted == false).ToList();
            model.TypesModel = db.types.Where(o => o.deleted == false).ToList();
            model.SlideshowModel = db.slideshow.ToList();
            var brnd = db.brands.Where(i => i.slug == brand).Select(o => o.name);
            var brndID = db.brands.Where(i => i.slug == brand).First().id;

            //2.level .. vsetky kategorie produktov ktore su v danom type a maju kategoriu
            if (catslug != null && subslug == null)
            {
                var catId = db.categories.Where(i => i.slug == catslug).First().id;
                model.ProductModel = db.products.Where(i => i.deleted == false && i.active == true && i.custom3 == brndID.ToString() && (i.category.Contains("[" + catId.ToString() + ",") || i.category.Contains("," + catId.ToString() + ",") || i.category.Contains("," + catId.ToString() + "]"))).ToList();
            }

            //3.level .. vsetky kategorie produktov ktore su v danom type a maju subkategoriu
            else if (catslug != null && subslug != null)
            {
                var catId = db.categories.Where(i => i.slug == subslug).First().id;
                model.ProductModel = db.products.Where(i => i.deleted == false && i.active == true && i.custom3 == brndID.ToString() && (i.category.Contains("[" + catId.ToString() + ",") || i.category.Contains("," + catId.ToString() + ",") || i.category.Contains("," + catId.ToString() + "]"))).ToList();
            }
            //1.level .. vsetky unikatne kategorie danych produktov v zaradeni
            else
            {
                model.ProductModel = db.products.Where(i => i.deleted == false && i.active == true && i.custom3 == brndID.ToString()).ToList();
            }

            ViewData["Category"] = brnd;
            ViewData["CatId"] = brndID;


            ViewData["catslug"] = catslug;
            ViewData["subslug"] = subslug;
            ProductModel pm = new ProductModel();
            ProductsController pc = new ProductsController();
            ViewData["typ"] = pc.SelectionZaradenie();
            //ViewData["znacka"] = pc.SelectionBrand();
            ViewData["pageType"] = "brand";

            List<decimal?> prices = new List<decimal?>();

            foreach (var item in model.ProductModel)
            {
                prices.Add(item.price);
                prices.Add(item.discountprice);
            }
            prices.Sort();

            ViewData["minPrice"] = prices.FirstOrDefault();
            ViewData["maxPrice"] = prices.LastOrDefault();

            ViewData["countries"] = new AdminController().SelectionCountries();

            return View(model);
        }

        [Route("typ/{typ}/{catslug?}/{subslug?}/{page?}/{id?}")]
        public ActionResult Type(string typ, string catslug, string subslug)
        {

            var model = new MultipleIndexModel();
            model.EsettingsModel = db.e_settings.ToList();
            model.SettingsModel = db.settings.ToList();
            model.PagesModel = db.pages.ToList();
            model.CategoriesModel = db.categories.Where(o => o.deleted == false).ToList();
            model.BrandsModel = db.brands.Where(o => o.deleted == false).ToList();
            model.TypesModel = db.types.Where(o => o.deleted == false).ToList();
            model.SlideshowModel = db.slideshow.ToList();
            var type = db.types.Where(i => i.slug == typ).Select(o => o.name);
            var typeId = db.types.Where(i => i.slug == typ).First().id;

            //2.level .. vsetky kategorie produktov ktore su v danom type a maju kategoriu
            if (catslug != null && subslug == null)
            {
                var catId = db.categories.Where(i => i.slug == catslug).First().id;
                model.ProductModel = db.products.Where(i => i.deleted == false && i.active == true && (i.type.Contains("[" + typeId.ToString() + ",") || i.type.Contains("," + typeId.ToString() + ",") || i.type.Contains("," + typeId.ToString() + "]")) && (i.category.Contains("[" + catId.ToString() + ",") || i.category.Contains("," + catId.ToString() + ",") || i.category.Contains("," + catId.ToString() + "]"))).ToList();
            }

            //3.level .. vsetky kategorie produktov ktore su v danom type a maju subkategoriu
            else if (catslug != null && subslug != null)
            {
                var catId = db.categories.Where(i => i.slug == subslug).First().id;
                model.ProductModel = db.products.Where(i => i.deleted == false && i.active == true && (i.type.Contains("[" + typeId.ToString() + ",") || i.type.Contains("," + typeId.ToString() + ",") || i.type.Contains("," + typeId.ToString() + "]")) && (i.category.Contains("[" + catId.ToString() + ",") || i.category.Contains("," + catId.ToString() + ",") || i.category.Contains("," + catId.ToString() + "]"))).ToList();
            }
            //1.level .. vsetky unikatne kategorie danych produktov v zaradeni
            else
            {
                model.ProductModel = db.products.Where(i => i.deleted == false && i.active == true && (i.type.Contains("[" + typeId.ToString() + ",") || i.type.Contains("," + typeId.ToString() + ",") || i.type.Contains("," + typeId.ToString() + "]"))).ToList();
            }

            ViewData["Category"] = type;
            ViewData["CatId"] = typeId;


            ViewData["catslug"] = catslug;
            ViewData["subslug"] = subslug;
            ProductModel pm = new ProductModel();
            ProductsController pc = new ProductsController();
            ViewData["typ"] = pc.SelectionZaradenie();
            ViewData["znacka"] = pc.SelectionBrandFiltered(model.ProductModel);
            ViewData["pageType"] = "type";

            List<decimal?> prices = new List<decimal?>();

            foreach (var item in model.ProductModel)
            {
                prices.Add(item.price);
                prices.Add(item.discountprice);
            }
            prices.Sort();

            ViewData["minPrice"] = prices.FirstOrDefault();
            ViewData["maxPrice"] = prices.LastOrDefault();

            ViewData["countries"] = new AdminController().SelectionCountries();

            return View(model);
        }


        [Route("s/{slug}")]
        public ActionResult Page(string slug)
        {
            MultipleIndexModel model = new MultipleIndexModel();
            if (slug == null)
            {
                return View();
            }
            var data = db.pages.Where(i => i.slug == slug).ToList();
            if (data == null)
            {
                return View();
            }

            model.SlideshowModel = db.slideshow.Where(o => o.page == slug).ToList();
            model.ProductModel = db.products.Where(o => o.deleted == false && o.active == true).ToList();
            model.EsettingsModel = db.e_settings.ToList();
            model.SettingsModel = db.settings.ToList();
            model.BrandsModel = db.brands.Where(o => o.deleted == false).ToList();
            model.PagesModel = db.pages.Where(i => i.slug == slug).ToList();
            model.CategoriesModel = db.categories.Where(o => o.deleted == false).ToList();

            List<decimal?> prices = new List<decimal?>();
            List<decimal> kw = new List<decimal>();
            List<decimal> room = new List<decimal>();

            foreach (var item in model.ProductModel)
            {
                prices.Add(item.price);
                prices.Add(item.discountprice);
                if (item.custom9 != null) kw.Add(decimal.Parse(item.custom9.Replace(".", ",")));
                if (item.custom10 != null) room.Add(decimal.Parse(item.custom10.Replace(".", ",")));
            }
            prices.Sort();
            kw.Sort();
            room.Sort();

            ViewData["minPrice"] = prices.FirstOrDefault();
            ViewData["maxPrice"] = prices.LastOrDefault();
            ViewData["minKw"] = kw.FirstOrDefault();
            ViewData["maxKw"] = kw.LastOrDefault();
            ViewData["minM2"] = room.FirstOrDefault();
            ViewData["maxM2"] = room.LastOrDefault();

            ViewData["countries"] = new AdminController().SelectionCountries();

            return View(model);
        }

        [Route("clanok/{slug}")]
        public ActionResult BlogPage(string slug)
        {
            MultipleIndexModel model = new MultipleIndexModel();
            if (slug == null)
            {
                return View();
            }

            var data = db.blog.Where(i => i.slug == slug).ToList();

            if (data == null)
            {
                return View();
            }

            model.SlideshowModel = db.slideshow.ToList();
            model.ProductModel = db.products.Where(o => o.deleted == false && o.active == true).ToList();
            model.EsettingsModel = db.e_settings.ToList();
            model.SettingsModel = db.settings.ToList();
            model.BrandsModel = db.brands.Where(o => o.deleted == false).ToList();
            model.BlogModel = db.blog.Where(i => i.slug == slug).ToList();
            model.PagesModel = db.pages.ToList();
            model.CategoriesModel = db.categories.Where(o => o.deleted == false).ToList();

            ViewData["countries"] = new AdminController().SelectionCountries();

            return View(model);
        }

        [Route("feed")]
        public ActionResult ProductsFeed()
        {
            MultipleIndexModel model = new MultipleIndexModel();
            MemoryStream ms = new MemoryStream();
            XmlWriterSettings xws = new XmlWriterSettings();
            xws.OmitXmlDeclaration = true;
            xws.Indent = true;
            var url_part1 = "";
            var url_part2 = "";
            var url_part3 = "";

            //model.ProductModel = db.products.Where(i => i.deleted == false && i.heureka == true).ToList();
            //var prods = db.products.Where(i => i.deleted == false && i.heureka == true).ToList();
            model.BrandsModel = db.brands.ToList();
            model.CategoriesModel = db.categories.Where(i => i.deleted == false).ToList();
            var cats = db.categories.Where(i => i.deleted == false && i.heureka == true).ToList();
            model.EsettingsModel = db.e_settings.ToList();

            List<products> finalProds = new List<products>();

            foreach (var cat in cats)
            {
                var catId = cat.id.ToString();

                var filteredProds = db.products.Where(i => i.deleted == false && i.active == true && i.heureka == true && (i.category.Contains("[" + catId + ",") || i.category.Contains("," + catId + ",") || i.category.Contains("," + catId + "]"))).ToList();
                finalProds.AddRange(filteredProds);
            }

            XDocument xdoc = new XDocument(
                new XDeclaration("1.0", "utf-8", "yes")
            );

            XElement xRoot = new XElement("SHOP");
            xdoc.Add(xRoot);

            foreach (var product in finalProds)
            {
                var prodDesc = Regex.Replace(product.description, "<.*?>", String.Empty);

                XElement xRoot2 = new XElement("SHOPITEM");
                XElement doc = new XElement("ITEM_ID", product.id);
                XElement doc2 = new XElement("PRODUCTNAME", product.title);
                XElement doc3 = new XElement("PRODUCT", product.title);
                XElement doc4 = new XElement("DESCRIPTION", prodDesc);
                XElement doc5 = new XElement("URL", "https://nahod.sk" + Url.Action("ProductDetail", "Home", new { id = product.id }));
                XElement doc6 = new XElement("IMGURL", "https://nahod.sk/Uploads/" + product.image);
                XElement doc7 = new XElement("IMGURL_ALTERNATIVE", "https://nahod.sk/Uploads/" + product.image);
                XElement doc8 = new XElement("VIDEO_URL", "");
                XElement doc9 = new XElement("PRICE_VAT", product.price);
                XElement doc10 = null;
                if (product.custom3 != null)
                {
                    foreach (var brand in model.BrandsModel.Where(i => i.id == Int32.Parse(product.custom3)))
                    {
                        doc10 = new XElement("MANUFACTURER", "<![CDATA[" + brand.name + "]]");
                    }
                }
                else
                {
                    doc10 = new XElement("MANUFACTURER", "<![CDATA[]]");
                }

                XElement doc17 = null;
                if (product.heurekadarcek)
                {
                    doc17 = new XElement("GIFT", product.heurekadarcektext);
                }

                XElement doc13 = new XElement("PRODUCTNO", product.number);
                XElement doc14 = new XElement("DELIVERY_DATE", "4");
                XElement doc12 = null;
                XElement doc15 = null;
                XElement doc16 = null;
                foreach (var item in model.EsettingsModel.OrderBy(x => x.id))
                {
                    if (item.transfer1_enbl && item.transfer1 != null)
                    {
                        doc12 = new XElement("DELIVERY",
                            new XElement("DELIVERY_ID", "DPD"),
                            new XElement("DELIVERY_PRICE", item.transfer1),
                            new XElement("DELIVERY_PRICE_COD", item.transfer1)
                            );
                    }
                    if (item.transfer2_enbl && item.transfer2 != null)
                    {
                        doc15 = new XElement("DELIVERY",
                            new XElement("DELIVERY_ID", "SLOVENSKA_POSTA"),
                            new XElement("DELIVERY_PRICE", item.transfer2),
                            new XElement("DELIVERY_PRICE_COD", item.transfer2)
                        );
                    }
                    if (item.transfer3_enbl && item.transfer3 != null)
                    {
                        doc16 = new XElement("DELIVERY",
                            new XElement("DELIVERY_ID", "VLASTNA_PREPRAVA"),
                            new XElement("DELIVERY_PRICE", item.transfer3),
                            new XElement("DELIVERY_PRICE_COD", item.transfer3)
                        );
                    }
                }

                xRoot.Add(xRoot2);
                xRoot2.Add(doc);
                xRoot2.Add(doc2);
                xRoot2.Add(doc3);
                xRoot2.Add(doc4);
                xRoot2.Add(doc5);
                xRoot2.Add(doc6);
                xRoot2.Add(doc7);
                xRoot2.Add(doc8);
                xRoot2.Add(doc9);
                xRoot2.Add(doc10);
                xRoot2.Add(doc17);

                dynamic cats2 = JsonConvert.DeserializeObject(product.category);
                XElement doc11 = null;
                List<int> orderedCats = new List<int>();
                foreach (var siglecat in cats2)
                {
                    int value = int.Parse(siglecat.Value.ToString());
                    orderedCats.Add(value);
                }
                orderedCats.Sort();

                foreach (var thisCatId in orderedCats.Take(1))
                {

                    url_part1 = "";
                    url_part2 = "";
                    url_part3 = "";
;
                    var cat = model.CategoriesModel.Where(o => o.id == thisCatId).FirstOrDefault();

                    if (cat.maincat != "Žiadna")
                    {
                        var catid = int.Parse(cat.maincat);
                        foreach (var topcat in model.CategoriesModel.Where(o => o.id == catid))
                        {
                            url_part1 = topcat.name;
                            if (cat.topcat != "Žiadna")
                            {
                                var topcatid = int.Parse(cat.topcat);

                                foreach (var subcat in model.CategoriesModel.Where(o => o.id == topcatid && o.topcat == cat.maincat))
                                {
                                    url_part2 = " | " + subcat.name;
                                    url_part3 = " | " + cat.name;
                                }
                            }
                        }
                    }
                    else
                    {
                        url_part1 = cat.name;
                    }

                    if (url_part1 == "PRÚTY")
                    {
                        url_part1 = "Rybárske prúty";
                    }

                    doc11 = new XElement("CATEGORYTEXT", "Hobby | Rybárčenie | " + url_part1 + url_part2 + url_part3);
                }
                xRoot2.Add(doc11);

                xRoot2.Add(doc13);
                xRoot2.Add(doc14);
                xRoot2.Add(doc12);
                xRoot2.Add(doc15);
                xRoot2.Add(doc16);
            }

            string strXml;
            using (var mss = new MemoryStream())
            {
                xdoc.Save(mss);
                mss.Position = 0;
                using (var sr = new StreamReader(mss))
                {
                    strXml = sr.ReadToEnd();
                }
            }
            return Content(strXml.ToString(), "application/xml");
        }

        [Route("kosik")]
        public ActionResult Basket()
        {
            var model = new MultipleIndexModel();
            model.EsettingsModel = db.e_settings.ToList();
            model.ProductModel = db.products.Where(o => o.deleted == false && o.active == true).ToList();
            model.VariantModel = db.variants.ToList();
            model.SettingsModel = db.settings.ToList();
            model.PagesModel = db.pages.ToList();
            model.BrandsModel = db.brands.Where(o => o.deleted == false).ToList();
            model.CouponsModel = db.coupons.ToList();
            model.CategoriesModel = db.categories.Where(o => o.deleted == false).ToList();
            model.SlideshowModel = db.slideshow.ToList();

            if (Request.Cookies["userid"] != null)
            {
                var usID = Int32.Parse(Request.Cookies["userid"].Value);
                var userdata = db.usersmeta.Where(i => i.userid == usID).ToList();
                foreach (var user in userdata)
                {
                    model.OrdersModel = new OrdersModel
                    {
                        Name = user.name,
                        Surname = user.surname,
                        Address = user.address,
                        City = user.city,
                        Zip = user.zip,
                        Country = user.country,
                        Phone = user.phone,
                        Email = user.email,
                        Companyname = user.companyname,
                        Ico = user.ico,
                        Dic = user.dic,
                        Icdph = user.icdph,
                    };
                }
            }

            if (Request.Cookies["userid"] != null)
            {
                var userToSend = Int32.Parse(Request.Cookies["userid"].Value);
                model.AllUsersMetaModel = db.usersmeta.Where(i => i.userid == userToSend).ToList();
            }
            else
            {
                model.AllUsersMetaModel = null;
            }

            ViewData["countries"] = new AdminController().SelectionCountries();

            return View(model);
        }

        [Route("wishlist")]
        public ActionResult Wishlist()
        {
            var model = new MultipleIndexModel();
            model.EsettingsModel = db.e_settings.ToList();
            model.ProductModel = db.products.Where(o => o.deleted == false && o.active == true).ToList();
            model.SettingsModel = db.settings.ToList();
            model.PagesModel = db.pages.ToList();
            model.BrandsModel = db.brands.Where(o => o.deleted == false).ToList();
            model.CategoriesModel = db.categories.Where(o => o.deleted == false).ToList();
            model.SlideshowModel = db.slideshow.ToList();

            if (Request.Cookies["userid"] != null)
            {
                var usID = Int32.Parse(Request.Cookies["userid"].Value);
                var userdata = db.usersmeta.Where(i => i.userid == usID).ToList();
                foreach (var user in userdata)
                {
                    model.OrdersModel = new OrdersModel
                    {
                        Name = user.name,
                        Surname = user.surname,
                        Address = user.address,
                        City = user.city,
                        Zip = user.zip,
                        Phone = user.phone,
                        Email = user.email,
                        Companyname = user.companyname,
                        Ico = user.ico,
                        Dic = user.dic,
                        Icdph = user.icdph,
                    };
                }
            }

            return View(model);
        }

        [Route("moj-ucet")]
        public ActionResult Account()
        {
            var model = new MultipleIndexModel();
            model.EsettingsModel = db.e_settings.ToList();
            model.ProductModel = db.products.Where(o => o.deleted == false && o.active == true).ToList();
            model.SettingsModel = db.settings.ToList();
            model.PagesModel = db.pages.ToList();
            model.BrandsModel = db.brands.Where(o => o.deleted == false).ToList();
            model.CategoriesModel = db.categories.Where(o => o.deleted == false).ToList();
            model.SlideshowModel = db.slideshow.ToList();

            if (Request.Cookies["userid"] != null)
            {
                var usID = Int32.Parse(Request.Cookies["userid"].Value);
                model.OrderDataModel = db.orders.Where(o => o.userid == usID).ToList();
                model.OrderMetaModel = db.ordermeta;
                var userdata = db.usersmeta.Where(i => i.userid == usID).ToList();
                foreach (var user in userdata)
                {
                    model.OrdersModel = new OrdersModel
                    {
                        Name = user.name,
                        Surname = user.surname,
                        Address = user.address,
                        City = user.city,
                        Zip = user.zip,
                        Country = user.country,
                        Phone = user.phone,
                        Email = user.email,
                        Companyname = user.companyname,
                        Ico = user.ico,
                        Dic = user.dic,
                        Icdph = user.icdph,
                    };
                }

                ViewData["countries"] = new AdminController().SelectionCountries();
                model.AllUsersMetaModel = db.usersmeta.Where(i => i.userid == usID).ToList();
            }
            return View(model);
        }

        [Route("detail-produktu/{id}/{slug?}")]
        public ActionResult ProductDetail(int? id)
        {
            var model = new MultipleIndexModel();
            if (Request.Cookies["userid"] != null)
            {
                var userToSend = Int32.Parse(Request.Cookies["userid"].Value);
                model.AllUsersMetaModel = db.usersmeta.Where(i => i.userid == userToSend).ToList();
            }
            else
            {
                model.AllUsersMetaModel = null;
            }

            model.EsettingsModel = db.e_settings.ToList();
            model.ProductModel = db.products.Where(o => o.deleted == false && o.active == true).ToList();
            model.SettingsModel = db.settings.ToList();
            model.PagesModel = db.pages.ToList();
            model.BrandsModel = db.brands.Where(o => o.deleted == false).ToList();
            model.CategoriesModel = db.categories.Where(o => o.deleted == false).ToList();
            model.VariantModel = db.variants.ToList();
            model.AttributesModel = db.attributes.ToList();
            model.SlideshowModel = db.slideshow.ToList();

            if (id == null)
            {
                return View(model);
            }

            var data = db.products.Where(i => i.id == id).ToList();
            if (data == null)
            {
                return View(model);
            }

            ViewData["countries"] = new AdminController().SelectionCountries();
            ViewData["Detaily"] = data;
            return View(model);
        }


        [Route("hladat")]
        [HttpGet]
        public JsonResult Search(string term)
        {
            var names = db.products.AsEnumerable().Where(p => p.title.ToLower().Contains(term.ToLower())).ToList();

            return Json(names, JsonRequestBehavior.AllowGet);
        }

        [HttpPost, Route("vyhladavanie")]
        public async Task<ActionResult> SearchProduct(string term, string sortOrder, string currentFilter, string searchString, int? page)
        {
            var id = "";
            ViewBag.CurrentSort = sortOrder;
            if (searchString != null)
            {
                page = 1;
            }
            else
            {
                searchString = currentFilter;
            }
            ViewBag.CurrentFilter = searchString;

            int pageSize = 12;
            int pageNumber = (page ?? 1);


            var model = new MultipleIndexModel();
            model.ProductModel = db.products.Where(o => o.deleted == false && o.active == true).ToList();
            model.EsettingsModel = db.e_settings.ToList();
            model.SettingsModel = db.settings.ToList();
            model.PagesModel = db.pages.ToList();
            model.CategoriesModel = db.categories.Where(o => o.deleted == false).ToList();
            model.BrandsModel = db.brands.Where(o => o.deleted == false).ToList();
            model.SlideshowModel = db.slideshow.ToList();
            model.ProductsPaged = db.products.ToList().Where(p => p.title.ToLower().Contains(term.ToLower())).OrderByDescending(x => x.id)
                     .ToPagedList(pageNumber, pageSize);

            ViewData["Search"] = term;

            return View(model);
        }

        [HttpPost, Route("aktualizovat-udaje")]
        public async Task<ActionResult> SaveCustomerDetails(MultipleIndexModel model)
        {
            if (Request.Cookies["userid"] != null)
            {
                var usID = Int32.Parse(Request.Cookies["userid"].Value);
                var o = db.usersmeta.Single(i => i.userid == usID);
                var u = db.users.Single(i => i.id == usID);

                o.name = model.OrdersModel.Name;
                o.surname = model.OrdersModel.Surname;
                o.address = model.OrdersModel.Address;
                o.city = model.OrdersModel.City;
                o.zip = model.OrdersModel.Zip;
                o.country = model.OrdersModel.Country;
                o.phone = model.OrdersModel.Phone;
                o.email = model.OrdersModel.Email;
                o.companyname = model.OrdersModel.Companyname;
                o.ico = model.OrdersModel.Ico;
                o.dic = model.OrdersModel.Dic;
                o.icdph = model.OrdersModel.Icdph;
                //u.email = model.OrdersModel.Email;
                //u.username = model.OrdersModel.Email;

                db.SaveChanges();
            }
            return RedirectToAction("Account");
        }

        public ActionResult DeleteAccount(int? userId, bool confirm)
        {
            var data = db.users.Find(userId);
            var metadata = db.usersmeta.Where(i => i.userid == userId).FirstOrDefault();

            data.deleted = true;
            if (metadata != null)
            {
                metadata.deleted = true;
            }

            ViewBag.Status = true;
            db.SaveChanges();

            return RedirectToAction("Users", "Admin");

            /*
            var data = db.users.Find(userId);
            var metadata = db.usersmeta.Where(i => i.userid == userId).FirstOrDefault();
            if (true)
            {
                ViewBag.Status = true;
                db.users.Remove(data);
                if (metadata != null)
                {
                    db.usersmeta.Remove(metadata);
                }
                db.SaveChanges();
            }
            else { ViewBag.Status = false; }

            return RedirectToAction("LogOut", "Admin");
            */
        }

        [HttpPost]
        public ActionResult CreateWatchdog(string watchdogEmail, int thisProdId, string returnUrl)
        {
            watchdog w = new watchdog();

            w.email = watchdogEmail;
            w.prod_id = thisProdId;
            w.sent = false;

            db.watchdog.Add(w);

            if (db.watchdog.Where(i => i.email == watchdogEmail && i.prod_id == thisProdId && i.sent == false).Count() == 0)
            {
                db.SaveChanges();
            }

            return Redirect(returnUrl);
        }

        [Route("obnovahesla")]
        public ActionResult ForgotPassword()
        {
            var model = new MultipleIndexModel();
            model.EsettingsModel = db.e_settings.ToList();
            model.SettingsModel = db.settings.ToList();
            model.PagesModel = db.pages.ToList();
            model.BlogModel = db.blog.ToList();
            model.BrandsModel = db.brands.Where(o => o.deleted == false).ToList();
            model.CategoriesModel = db.categories.Where(o => o.deleted == false).ToList();
            model.SlideshowModel = db.slideshow.ToList();

            ViewData["countries"] = new AdminController().SelectionCountries();

            return View(model);
        }

        [HttpPost]
        public ActionResult ForgotPasswordSendLink(string forgotPasswordEmail)
        {
            userstoken t = new userstoken();

            t.token = RandomString(8);
            t.time = DateTime.Now.ToString("d.M.yyyy HH:mm:ss");
            t.type = "default";
            t.email = forgotPasswordEmail;

            db.userstoken.Add(t);

            db.SaveChanges();

            //odosleme email o uspesnom zaregistrovani
            OrdersController oc = new OrdersController();
            string body = createForgotEmailBody(t.token);
            oc.SendHtmlFormattedEmail("Obnova hesla", body, forgotPasswordEmail, "forgotEmail", "");

            //odosleme email v ktorom bude linka na ktorej bude odkaz na controller funkciu ktora zavola view a overi sa token

            //nasledne v tej dalsej funkcii ktora bude vlastne submit form sa overi time a ak do 30 min tak to zmenime

            return RedirectToAction("Index");
        }

        public ActionResult ForgotPasswordSendLinkReset(string forgotPasswordEmail)
        {
            userstoken t = new userstoken();

            t.token = RandomString(8);
            t.time = DateTime.Now.ToString("d.M.yyyy HH:mm:ss");
            t.type = "reset";
            t.email = forgotPasswordEmail;

            db.userstoken.Add(t);

            db.SaveChanges();

            //odosleme email o uspesnom zaregistrovani
            OrdersController oc = new OrdersController();
            string body = createForgotEmailBody(t.token);
            oc.SendHtmlFormattedEmail("Obnova hesla", body, forgotPasswordEmail, "forgotEmail", "");

            //zobrazime stranku s oznamom
            var model = new MultipleIndexModel();
            model.EsettingsModel = db.e_settings.ToList();
            model.SettingsModel = db.settings.ToList();
            model.PagesModel = db.pages.ToList();
            model.BlogModel = db.blog.ToList();
            model.BrandsModel = db.brands.Where(o => o.deleted == false).ToList();
            model.CategoriesModel = db.categories.Where(o => o.deleted == false).ToList();
            model.SlideshowModel = db.slideshow.ToList();

            ViewData["countries"] = new AdminController().SelectionCountries();
            ViewData["info"] = "Je potrebná aktualizácia hesla na vašom konte. Na váš email sme zaslali odkaz na aktualizáciu hesla.";

            return View("ForgotPassword", model);
        }

        [Route("zmenahesla/{token}")]
        public ActionResult PasswordChange(string token)
        {

            //overime, ci token bol vygenerovany do 30m odteraz a ci vobec existuje
            var userstoken = db.userstoken.Where(i => i.token == token).FirstOrDefault();

            if (userstoken != null)
            {
                var email = userstoken.email;
                var now = DateTime.Now;
                var before = DateTime.Parse(userstoken.time).AddMinutes(30);

                if (DateTime.Compare(before, now) > 0)
                {

                    if (userstoken.type == "reset")
                    {
                        ViewData["info"] = "Po prihlásení si prosím doplňte vaše fakturačné údaje v sekcii <strong>Môj účet.</strong>";
                    }

                    ViewData["validToken"] = true;
                    ViewData["token"] = token;
                    ViewData["email"] = email;
                }
                else
                {
                    ViewData["validToken"] = false;
                }
            }
            else
            {
                ViewData["validToken"] = false;
            }

            var model = new MultipleIndexModel();
            model.EsettingsModel = db.e_settings.ToList();
            model.SettingsModel = db.settings.ToList();
            model.PagesModel = db.pages.ToList();
            model.BlogModel = db.blog.ToList();
            model.BrandsModel = db.brands.Where(o => o.deleted == false).ToList();
            model.CategoriesModel = db.categories.Where(o => o.deleted == false).ToList();
            model.SlideshowModel = db.slideshow.ToList();

            ViewData["countries"] = new AdminController().SelectionCountries();

            return View(model);
        }

        [HttpPost]
        public ActionResult PasswordChangeAction(string Password, string Email, string Token)
        {

            var user = db.users.Where(i => i.email == Email).FirstOrDefault();

            MD5CryptoServiceProvider md5provider = new MD5CryptoServiceProvider();
            md5provider.ComputeHash(ASCIIEncoding.ASCII.GetBytes(Password));
            byte[] overHeslo = md5provider.Hash;
            StringBuilder hesloDb = new StringBuilder();

            for (int i = 0; i < overHeslo.Length; i++)
            {
                hesloDb.Append(overHeslo[i].ToString("x2"));
            }
            string heslo = hesloDb.ToString();

            user.password = heslo;

            //zmazeme token
            var userstoken = db.userstoken.Where(i => i.token == Token).FirstOrDefault();
            db.userstoken.Remove(userstoken);

            db.SaveChanges();

            return RedirectToAction("Index");
        }

        private static Random random = new Random();
        public static string RandomString(int length)
        {
            const string chars = "abcdefghijklmnopqrstuvwxyABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
            return new string(Enumerable.Repeat(chars, length)
              .Select(s => s[random.Next(s.Length)]).ToArray());
        }

        private string createForgotEmailBody(string token)
        {

            string body = string.Empty;
            var ownerEmail = db.settings.Select(i => i.email).FirstOrDefault();
            //using streamreader for reading my htmltemplate   
            using (StreamReader rea = new StreamReader(Server.MapPath("~/Views/Shared/RegisterEmail.cshtml")))
            {
                body = rea.ReadToEnd();
            }

            var link = "<a href='https://www.nahod.sk/zmenahesla/" + token + "'>Obnova hesla</a>";

            var str = "Kliknite na naslednovný link do 30 minút:" + link;
            body = body.Replace("{Text}", str);
            body = body.Replace("{CompanyData}", CompanyDataInEmial());
            body = body.Replace("{CustomerService}", ownerEmail);

            return body;
        }

        private string CompanyDataInEmial()
        {
            var stringBuilder = new StringBuilder();
            foreach (var info in db.e_settings)
            {
                stringBuilder.Append("<p>So srdečným pozdravom, " + info.companyname + " <br>IČ DPH: " + info.icdph + " <br>IČ: " + info.ico + " <br>" + info.address + ", " + @info.city + " " + info.custom + "</p>");
            }
            return stringBuilder.ToString();
        }

    }
}