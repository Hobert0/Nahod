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
        public ActionResult Index(string changePassInfo)
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
            model.SlideshowModel = db.slideshow.Where(o => o.active == 1).ToList();

            //ViewData["countries"] = new AdminController().SelectionCountries();
            ViewData["Homepage"] = "true";
            ViewData["changePassInfo"] = changePassInfo;

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
                int prodId = int.Parse(item.product.Value.ToString());
                var thisProd = db.products.Where(i => i.id == prodId && i.deleted == false && i.active == true).SingleOrDefault();

                if (thisProd != null)
                {

                    decimal thisPrice = Convert.ToDecimal(item.price);
                    decimal thisQuantity = Convert.ToDecimal(item.quantity);

                    thisSum += thisQuantity * thisPrice;
                }
            }
            Session["cartsum"] = thisSum;

            return Json(cartValues, JsonRequestBehavior.AllowGet);
        }

        [Route("checkCartDeletedInactive")]
        public string CheckCartDeletedInactive(string data)
        {
            var cartVal = JsonConvert.DeserializeObject<List<dynamic>>(data);

            var helpCounter = 0;
            List<int> toDeleteList = new List<int>();
            foreach (var item in cartVal)
            {
                int prodId = int.Parse(item.product.Value.ToString());
                var thisProd = db.products.Where(i => i.id == prodId && i.deleted == false && i.active == true).SingleOrDefault();

                if (thisProd == null)
                {
                    toDeleteList.Add(helpCounter);
                }
                helpCounter++;
            }

            //vymazeme prvky z jsonu, ktore tam nepatria
            var helpDeleted = 0;
            foreach (var toDeleteItem in toDeleteList)
            {
                cartVal.RemoveAt(toDeleteItem - helpDeleted);
                helpDeleted++;
            }

            return JsonConvert.SerializeObject(cartVal);
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

            //ViewData["countries"] = new AdminController().SelectionCountries();

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

            model.ProductModel = db.products.Where(o => o.deleted == false && o.active == true && (o.category.Contains("[" + id.ToString() + ",") || o.category.Contains("," + id.ToString() + ",") || o.category.Contains("," + id.ToString() + "]") || o.category.Contains("[" + id.ToString() + "]"))).ToList();
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
            ViewData["maxPrice"] = prices.LastOrDefault() + 1;

            //ViewData["countries"] = new AdminController().SelectionCountries();

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
                model.ProductModel = db.products.Where(i => i.deleted == false && i.active == true && i.custom3 == brndID.ToString() && (i.category.Contains("[" + catId.ToString() + ",") || i.category.Contains("," + catId.ToString() + ",") || i.category.Contains("," + catId.ToString() + "]") || i.category.Contains("[" + catId.ToString() + "]"))).ToList();
            }

            //3.level .. vsetky kategorie produktov ktore su v danom type a maju subkategoriu
            else if (catslug != null && subslug != null)
            {
                var catId = db.categories.Where(i => i.slug == subslug).First().id;
                model.ProductModel = db.products.Where(i => i.deleted == false && i.active == true && i.custom3 == brndID.ToString() && (i.category.Contains("[" + catId.ToString() + ",") || i.category.Contains("," + catId.ToString() + ",") || i.category.Contains("," + catId.ToString() + "]") || i.category.Contains("[" + catId.ToString() + "]"))).ToList();
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
            ViewData["maxPrice"] = prices.LastOrDefault() + 1;

            //ViewData["countries"] = new AdminController().SelectionCountries();

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
                model.ProductModel = db.products.Where(i => i.deleted == false && i.active == true && (i.type.Contains("[" + typeId.ToString() + ",") || i.type.Contains("," + typeId.ToString() + ",") || i.type.Contains("," + typeId.ToString() + "]") || i.type.Contains("[" + typeId.ToString() + "]")) && (i.category.Contains("[" + catId.ToString() + ",") || i.category.Contains("," + catId.ToString() + ",") || i.category.Contains("," + catId.ToString() + "]") || i.category.Contains("[" + catId.ToString() + "]"))).ToList();
            }

            //3.level .. vsetky kategorie produktov ktore su v danom type a maju subkategoriu
            else if (catslug != null && subslug != null)
            {
                var catId = db.categories.Where(i => i.slug == subslug).First().id;
                model.ProductModel = db.products.Where(i => i.deleted == false && i.active == true && (i.type.Contains("[" + typeId.ToString() + ",") || i.type.Contains("," + typeId.ToString() + ",") || i.type.Contains("," + typeId.ToString() + "]") || i.type.Contains("[" + typeId.ToString() + "]")) && (i.category.Contains("[" + catId.ToString() + ",") || i.category.Contains("," + catId.ToString() + ",") || i.category.Contains("," + catId.ToString() + "]") || i.category.Contains("[" + catId.ToString() + "]"))).ToList();
            }
            //1.level .. vsetky unikatne kategorie danych produktov v zaradeni
            else
            {
                model.ProductModel = db.products.Where(i => i.deleted == false && i.active == true && (i.type.Contains("[" + typeId.ToString() + ",") || i.type.Contains("," + typeId.ToString() + ",") || i.type.Contains("," + typeId.ToString() + "]") || i.type.Contains("[" + typeId.ToString() + "]"))).ToList();
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
            ViewData["maxPrice"] = prices.LastOrDefault() + 1;

            //ViewData["countries"] = new AdminController().SelectionCountries();

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
            ViewData["maxPrice"] = prices.LastOrDefault() + 1;
            ViewData["minKw"] = kw.FirstOrDefault();
            ViewData["maxKw"] = kw.LastOrDefault();
            ViewData["minM2"] = room.FirstOrDefault();
            ViewData["maxM2"] = room.LastOrDefault();

            //ViewData["countries"] = new AdminController().SelectionCountries();

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

            //ViewData["countries"] = new AdminController().SelectionCountries();

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
            model.CategoriesModel = db.categories.ToList();
            var cats = db.categories.Where(i => i.deleted == false && i.heureka == true).ToList();
            model.EsettingsModel = db.e_settings.ToList();

            List<products> finalProds = new List<products>();
            HashSet<products> allProds = new HashSet<products>();
            foreach (var cat in cats)
            {
                var catId = cat.id.ToString();

                var filteredProds = db.products.Where(i => i.deleted == false && i.active == true && i.heureka == true && (i.category.Contains("[" + catId + ",") || i.category.Contains("," + catId + ",") || i.category.Contains("," + catId + "]") || i.category.Contains("[" + catId + "]"))).ToList();
                finalProds.AddRange(filteredProds);
            }

            foreach (var hash in finalProds)
            {
                allProds.Add(hash);
            }

            XDocument xdoc = new XDocument(
                new XDeclaration("1.0", "utf-8", "yes")
            );

            XElement xRoot = new XElement("SHOP");
            xdoc.Add(xRoot);

            foreach (var product in allProds)
            {
                if (product.description == null)
                {
                    product.description = "";
                }
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

                if (product.discountprice != null && product.discountprice > 0)
                {
                    doc9 = new XElement("PRICE_VAT", product.discountprice);
                }

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

                var deliverydate = "0";
                XElement doc14 = new XElement("DELIVERY_DATE", "0");

                if (decimal.Parse(product.stock) <= 0)
                {
                    doc14 = new XElement("DELIVERY_DATE", "7");
                }

                XElement doc12 = null;
                XElement doc15 = null;
                XElement doc16 = null;
                foreach (var item in model.EsettingsModel.OrderBy(x => x.id))
                {
                    if (item.transfer1_enbl && item.transfer1 != null)
                    {
                        var finalDeliveryPrice = item.transfer1;
                        if (product.price >= Convert.ToDecimal(item.transfer5))
                        {
                            finalDeliveryPrice = "0.00";
                        }

                        doc12 = new XElement("DELIVERY",
                            new XElement("DELIVERY_ID", "DPD"),
                            new XElement("DELIVERY_PRICE", finalDeliveryPrice),
                            new XElement("DELIVERY_PRICE_COD", finalDeliveryPrice)
                            );
                    }
                    if (item.transfer2_enbl && item.transfer2 != null)
                    {
                        var finalDeliveryPrice = item.transfer2;
                        if (product.price >= Convert.ToDecimal(item.transfer5))
                        {
                            finalDeliveryPrice = "0.00";
                        }

                        doc15 = new XElement("DELIVERY",
                            new XElement("DELIVERY_ID", "SLOVENSKA_POSTA"),
                            new XElement("DELIVERY_PRICE", finalDeliveryPrice),
                            new XElement("DELIVERY_PRICE_COD", finalDeliveryPrice)
                        );
                    }
                    if (item.transfer3_enbl && item.transfer3 != null)
                    {
                        var finalDeliveryPrice = item.transfer3;
                        if (product.price >= Convert.ToDecimal(item.transfer5))
                        {
                            finalDeliveryPrice = "0.00";
                        }

                        doc16 = new XElement("DELIVERY",
                            new XElement("DELIVERY_ID", "VLASTNA_PREPRAVA"),
                            new XElement("DELIVERY_PRICE", finalDeliveryPrice),
                            new XElement("DELIVERY_PRICE_COD", finalDeliveryPrice)
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
                    if (value != 580 && value != 603 && value != 604 && value != 605 && value != 606 && value != 607 && value != 608 && value != 609)
                    {
                        orderedCats.Add(value);
                    }
                }
                orderedCats.Sort();
                orderedCats.Reverse();

                foreach (var thisCatId in orderedCats.Take(1))
                {

                    url_part1 = "";
                    url_part2 = "";
                    url_part3 = "";

                    var cat = model.CategoriesModel.Where(o => o.id == thisCatId).FirstOrDefault();

                    if (cat != null && cat.maincat != "Žiadna")
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
                    else if (cat != null)
                    {
                        url_part1 = cat.name;
                    }

                    if (url_part1 == "PRÚTY")
                    {
                        url_part1 = "Rybárske prúty";
                    }

                    if (cat.heurekacat == null)
                    {
                        doc11 = new XElement("CATEGORYTEXT", "Hobby | Rybárčenie | " + url_part1 + url_part2 + url_part3);
                    }
                    else
                    {
                        doc11 = new XElement("CATEGORYTEXT", cat.heurekacat);
                    }
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

        [Route("stockfeed")]
        public ActionResult StockFeed()
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
            //model.BrandsModel = db.brands.ToList();
            //model.CategoriesModel = db.categories.Where(i => i.deleted == false).ToList();
            var cats = db.categories.Where(i => i.deleted == false && i.heureka == true).ToList();
            //model.EsettingsModel = db.e_settings.ToList();

            List<products> finalProds = new List<products>();
            HashSet<products> allProds = new HashSet<products>();
            foreach (var cat in cats)
            {
                var catId = cat.id.ToString();

                var filteredProds = db.products.Where(i => i.deleted == false && i.active == true && i.heureka == true && (i.category.Contains("[" + catId + ",") || i.category.Contains("," + catId + ",") || i.category.Contains("," + catId + "]") || i.category.Contains("[" + catId + "]"))).ToList();
                finalProds.AddRange(filteredProds);
            }

            foreach (var hash in finalProds)
            {
                allProds.Add(hash);
            }

            XDocument xdoc = new XDocument(
                new XDeclaration("1.0", "utf-8", "yes")
            );

            XElement xRoot = new XElement("item_list");
            xdoc.Add(xRoot);

            foreach (var product in allProds)
            {
                //uvadzat len produkty, ktore maju sklad > 0
                if (product.stock != null && Int32.Parse(product.stock) > 0)
                {
                    XElement xRoot2 = new XElement("item");
                    xRoot2.SetAttributeValue("id", product.id);
                    XElement doc2 = new XElement("stock_quantity", product.stock);

                    var dnow = DateTime.ParseExact(DateTime.Now.ToString("MM/dd/yyyy 12:00:00"), "MM/dd/yyyy HH:mm:ss", null);

                    if (DateTime.Now > dnow)
                    {
                        //zajtra
                        dnow = dnow.AddDays(1);
                    }

                    XElement doc3 = new XElement("delivery_time", dnow.AddDays(3).ToString("yyyy-MM-dd hh:mm"));
                    doc3.SetAttributeValue("orderDeadline", dnow.ToString("yyyy-MM-dd hh:mm"));

                    XElement doc4 = new XElement("depot");
                    doc4.SetAttributeValue("id", 4383);

                    XElement doc5 = new XElement("pickup_time", dnow.AddDays(1).ToString("yyyy-MM-dd hh:mm"));
                    doc5.SetAttributeValue("orderDeadline", dnow.ToString("yyyy-MM-dd hh:mm"));

                    XElement doc6 = new XElement("stock_quantity", product.stock);

                    xRoot.Add(xRoot2);
                    xRoot2.Add(doc2);
                    xRoot2.Add(doc3);
                    xRoot2.Add(doc4);
                    doc4.Add(doc5);
                    doc4.Add(doc6);
                }
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

        [Route("googlefeed")]
        public ActionResult GoogleFeed()
        {
            MultipleIndexModel model = new MultipleIndexModel();
            MemoryStream ms = new MemoryStream();
            XmlWriterSettings xws = new XmlWriterSettings();
            xws.OmitXmlDeclaration = true;
            xws.Indent = true;
            var url_part1 = "";
            var url_part2 = "";
            var url_part3 = "";

            model.ProductModel = db.products.ToList();
            model.BrandsModel = db.brands.ToList();
            model.CategoriesModel = db.categories.ToList();
            model.EsettingsModel = db.e_settings.ToList();

            XDocument xdoc = new XDocument(
                new XDeclaration("1.0", "utf-8", "yes")
            );
            XNamespace g = "http://base.google.com/ns/1.0";

            XElement xRoot = new XElement("channel", new XAttribute(XNamespace.Xmlns + "g", g));
            xdoc.Add(xRoot);

            /*ZMENIT*/
            foreach (var product in model.ProductModel.Where(i => i.deleted != true))
            {
                if (product.price != null)
                {
                    XElement xRoot2 = new XElement("item");
                    XElement doc = new XElement(g + "id", product.id);
                    XElement doc2 = new XElement(g + "title", product.title);
                    XElement doc3 = new XElement(g + "condition", "new");

                    if (product.description == null)
                    {
                        product.description = "";
                    }

                    var shortdescription = Regex.Replace(product.description, "<.*?>", String.Empty);
                    XElement doc4 = new XElement(g + "description", shortdescription);
                    XElement doc5 = new XElement("link",
                        "https://nahod.sk" + Url.Action("ProductDetail", "Home",
                            new { id = product.id, slug = ToUrlSlug(product.title) }));
                    XElement doc6 = new XElement(g + "image_link", "https://nahod.sk/Uploads/" + product.image);
                    XElement doc7 = new XElement("additional_image_link",
                        "https://nahod.sk/Uploads/" + product.image);


                    var stock = "";
                    if (product.stock != null && product.stock != "")
                    {
                        if (decimal.Parse(product.stock) > 0)
                        {
                            stock = "in_stock";
                        }
                        else
                        {
                            stock = "out_of_stock";
                        }
                    }
                    else
                    {
                        stock = "in_stock";
                    }

                    XElement doc8 = new XElement(g + "availability", stock);

                    XElement doc9 = new XElement(g + "price", product.price + " EUR");

                    XElement doc19 = null;
                    if (product.discountprice != null)
                    {
                        doc19 = new XElement(g + "sale_price", product.discountprice + " EUR");
                    }

                    XElement doc10 = null;
                    if (product.custom3 != null)
                    {
                        foreach (var brand in model.BrandsModel.Where(i => i.id == Int32.Parse(product.custom3)))
                        {
                            doc10 = new XElement(g + "brand", brand.name);
                        }
                    }

                    if (product.category != null && product.category != "[]")
                    {
                        url_part1 = "";
                        url_part2 = "";
                        url_part3 = "";

                        dynamic cats = JsonConvert.DeserializeObject(product.category);

                        //
                        //Ak je viacero kategorii, tak zoberieme tu, ktora ma nadradenu kategoriu ... topcat2 nepouzivame
                        //
                        var choosenCatId = 0;
                        //Ak existuje kategoria, ktora ma vyplnenu topcat
                        foreach (var thisCat in cats)
                        {
                            var thisCatObj = model.CategoriesModel.Where(i => i.id == thisCat.Value).FirstOrDefault();
                            //if (thisCatObj != null && thisCatObj.topcat != "Žiadna" && thisCatObj.maincat != "580" && thisCatObj.maincat != "603" && thisCatObj.maincat != "604" && thisCatObj.maincat != "605" && thisCatObj.maincat != "606" && thisCatObj.maincat != "607" && thisCatObj.maincat != "608" && thisCatObj.maincat != "609") // zaroven ak sa nerovna kategoriam z AKCIE A NOVINKY a ostatnym
                            if (thisCatObj != null && thisCatObj.topcat != "Žiadna" && thisCatObj.maincat != "580") 
                            {
                                choosenCatId = thisCatObj.id;

                                break;
                            }
                        }
                        //Ak existuje kategoria, ktora ma vyplnenu maincat
                        if (choosenCatId == 0)
                        {
                            foreach (var thisCat in cats)
                            {
                                var thisCatObj = model.CategoriesModel.Where(i => i.id == thisCat.Value).FirstOrDefault();
                                //if (thisCatObj != null && thisCatObj.maincat != "Žiadna" && thisCatObj.maincat != "580" && thisCatObj.maincat != "603" && thisCatObj.maincat != "604" && thisCatObj.maincat != "605" && thisCatObj.maincat != "606" && thisCatObj.maincat != "607" && thisCatObj.maincat != "608" && thisCatObj.maincat != "609") // zaroven ak sa nerovna kategoriam z AKCIE A NOVINKY a ostatnym
                                if (thisCatObj != null && thisCatObj.maincat != "Žiadna" && thisCatObj.maincat != "580")
                                {
                                    choosenCatId = thisCatObj.id;

                                    break;
                                }
                            }
                        }
                        if (choosenCatId == 0)
                        {
                            choosenCatId = model.CategoriesModel.Where(i => i.id == cats[0].Value).FirstOrDefault().id;
                        }
                        var choosenCat = model.CategoriesModel.Where(i => i.id == choosenCatId).FirstOrDefault();

                        var categoryname = "";
                        var maincatslug = "";
                        var categoryslug = "";
                        if (choosenCat.maincat == "Žiadna")
                        {
                            categoryname = choosenCat.name;
                            categoryslug = choosenCat.slug;
                        }
                        else
                        {
                            var catId = int.Parse(choosenCat.maincat);
                            categoryname = model.CategoriesModel.Where(o => o.id == catId).FirstOrDefault().name;
                            categoryslug = model.CategoriesModel.Where(o => o.id == catId).FirstOrDefault().slug;

                        }
                        //< li class="breadcrumb-item" style="text-decoration: underline"><a href = "@Url.Action("Category", "HomeController", new {catslug = @Html.Raw(categoryslug)})">@categoryname</a></li>
                        url_part1 = categoryname;

                        if (choosenCat.maincat != "Žiadna")
                        {
                            if (choosenCat.topcat != "Žiadna")
                            {
                                var topCatId = Int32.Parse(choosenCat.topcat);
                                var topCatObj = model.CategoriesModel.Where(o => o.id == topCatId).FirstOrDefault();
                                //<li class="breadcrumb-item" style="text-decoration: underline"><a href = "@Url.Action("Category", "HomeController", new {catslug = @Html.Raw(topCatObj.slug)})">@topCatObj.name</a></li>
                                url_part2 = topCatObj.name;
                            }

                            //<li class="breadcrumb-item" style="text-decoration: underline"><a href = "@Url.Action("Category", "HomeController", new {catslug = @Html.Raw(choosenCat.slug)})">@choosenCat.name</a></li>
                            url_part3 = choosenCat.name;

                        }

                    }

                    //3334 - Sporting Goods > Outdoor Recreation > Fishing
                    XElement doc11 = new XElement(g + "google_product_category", "3334");
                    XElement doc12 = new XElement(g + "product_type", (url_part1 != "" ? url_part1 : "") + (url_part2 != "" ? (" > " + url_part2) : "") + (url_part3 != "" ? (" > " + url_part3) : ""));

                    XElement doc13 = new XElement(g + "mpn", product.number);

                    XElement doc14 = new XElement(g + "shipping");
                    XElement doc15 = new XElement(g + "country", "SK");

                    //cena dodania
                    var shippingPrice = model.EsettingsModel.FirstOrDefault().transfer1;
                    var prodPrice = product.price;

                    XElement doc16 = new XElement(g + "price", shippingPrice + " EUR");
                    XElement doc17 = new XElement(g + "identifier_exists", "no");
                    XElement doc18 = new XElement(g + "mobile_link", "https://nahod.sk" + Url.Action("ProductDetail", "Home", new { id = product.id, slug = ToUrlSlug(product.title) }));


                    xRoot.Add(xRoot2);
                    xRoot2.Add(doc);
                    xRoot2.Add(doc2);
                    xRoot2.Add(doc9);
                    xRoot2.Add(doc19);
                    xRoot2.Add(doc4);
                    xRoot2.Add(doc5);
                    xRoot2.Add(doc6);
                    xRoot2.Add(doc7);
                    xRoot2.Add(doc8);
                    xRoot2.Add(doc10);
                    xRoot2.Add(doc11);
                    xRoot2.Add(doc12);
                    xRoot2.Add(doc13);
                    xRoot2.Add(doc3);
                    xRoot2.Add(doc14);
                    xRoot2.Add(doc17);
                    xRoot2.Add(doc18);
                    doc14.Add(doc15);
                    doc14.Add(doc16);

                }
            }

            return Content(xdoc.ToString(), "application/xml");
        }

        public string ToUrlSlug(string value)
        {
            //First to lower case
            value = value.ToLowerInvariant();

            //Remove all accents
            var bytes = Encoding.GetEncoding("Cyrillic").GetBytes(value);
            value = Encoding.ASCII.GetString(bytes);

            //Replace spaces
            value = Regex.Replace(value, @"\s", "-", RegexOptions.Compiled);

            //Remove invalid chars
            value = Regex.Replace(value, @"[^a-z0-9\s-_]", "", RegexOptions.Compiled);

            //Trim dashes from end
            value = value.Trim('-', '_');

            //Replace double occurences of - or _
            value = Regex.Replace(value, @"([-_]){2,}", "$1", RegexOptions.Compiled);

            return value;
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

            //ViewData["countries"] = new AdminController().SelectionCountries();

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

                //ViewData["countries"] = new AdminController().SelectionCountries();
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

            //ViewData["countries"] = new AdminController().SelectionCountries();
            ViewData["Detaily"] = data;
            return View(model);
        }


        [Route("hladat")]
        [HttpGet]
        public JsonResult Search(string term)
        {
            List<products> Prods = db.products.Where(i => i.deleted == false && i.active == true).ToList();
            List<products> varProds = new List<products>();

            var termArr = term.ToLower().Split(' ');
            var counter = 0;
            IQueryable<products> filteredProds = null;
            IQueryable<variants> filteredVars = null;

            foreach (var termObj in termArr)
            {
                if (counter == 0)
                {
                    //products
                    filteredProds = db.products.Where(i => i.deleted == false && i.active == true).Where(p => p.title.ToLower().Contains(termObj) || (p.number != null && p.number.ToLower().Contains(termObj)));
                    //variants
                    filteredVars = db.variants.Where(p => p.number != null && p.deleted == false && p.number.ToLower().Contains(termObj));
                }
                else
                {
                    //products
                    filteredProds = filteredProds.Where(p => p.title.ToLower().Contains(termObj) || (p.number != null && p.number.ToLower().Contains(termObj)));
                    //variants
                    filteredVars = filteredVars.Where(p => p.number != null && p.deleted == false && p.number.ToLower().Contains(termObj));
                }
                counter++;
            }
            var names = filteredProds.OrderByDescending(x => x.id).ToList();

            foreach (var item in filteredVars)
            {
                varProds.Add(Prods.Where(i => i.id == item.prod_id).FirstOrDefault());
            }

            names.AddRange(varProds);

            List<products> newNames = new List<products>();
            //nasledne este musime raz prejst "names" pretoze momentalne obsahuje len cenu a discount cenu pre cely produkt ale ak ma varianty tak potrebujeme vybrat ceny z variant
            foreach (var name in names)
            {
                var prodVars = db.variants.Where(a => a.prod_id == name.id && a.deleted == false).ToList();
                if (prodVars.Count > 0)
                {
                    //najdeme najmensiu cenu
                    decimal min = 999999;
                    foreach (var nameVar in prodVars)
                    {
                        if (nameVar.discountprice == null)
                        {
                            if (nameVar.price < min)
                            {
                                min = (decimal)nameVar.price;
                            }
                        }
                        else
                        {
                            if (nameVar.discountprice < min)
                            {
                                min = (decimal)nameVar.discountprice;
                            }
                        }
                    }

                    name.price = min;
                    //vyuzijeme tento stlpec aby sme vedeli povedat ze to je varianta a aby sme pred cenu vedeli doplnit Od...
                    name.custom10 = "true";
                    newNames.Add(name);
                }
                else
                {
                    if (name.discountprice == null)
                    {
                        newNames.Add(name);
                    }
                    else
                    {
                        name.price = (decimal)name.discountprice;
                        newNames.Add(name);
                    }

                }
            }

            /*
            var names = Prods.AsEnumerable().Where(p => p.title.ToLower().Contains(term.ToLower()) || ( p.number != null && p.number.ToLower().Contains(term.ToLower()))).ToList();
            var allvariants = db.variants.AsEnumerable().Where(p => p.number != null && p.number.ToLower().Contains(term.ToLower())).ToList();
            */


            /*
            foreach (var item in allvariants) {
                varProds.Add(Prods.Where(i => i.id == item.prod_id).FirstOrDefault());
            }

            names.AddRange(varProds);
            */

            return Json(newNames, JsonRequestBehavior.AllowGet);
        }

        [Route("vyhladavanie")]
        public async Task<ActionResult> SearchProduct(string term, string sortOrder, string currentFilter, string searchString, int? page)
        {

            var id = "";
            /*ViewBag.CurrentSort = sortOrder;
            if (searchString != null)
            {
                page = 1;
            }
            else
            {
                searchString = currentFilter;
            }
            ViewBag.CurrentFilter = searchString;*/

            int pageSize = 20;
            int pageNumber = (page ?? 1);


            var model = new MultipleIndexModel();
            model.ProductModel = db.products.Where(o => o.deleted == false && o.active == true).ToList();
            model.EsettingsModel = db.e_settings.ToList();
            model.SettingsModel = db.settings.ToList();
            model.PagesModel = db.pages.ToList();
            model.CategoriesModel = db.categories.Where(o => o.deleted == false).ToList();
            model.BrandsModel = db.brands.Where(o => o.deleted == false).ToList();
            model.SlideshowModel = db.slideshow.ToList();
            model.VariantModel = db.variants.Where(a => a.deleted == false).ToList();

            if (Request.Cookies["userid"] != null)
            {
                var userToSend = Int32.Parse(Request.Cookies["userid"].Value);
                model.AllUsersMetaModel = db.usersmeta.Where(i => i.userid == userToSend).ToList();
            }
            else
            {
                model.AllUsersMetaModel = null;
            }

            List<products> Prods = db.products.Where(o => o.deleted == false && o.active == true).ToList();
            List<products> varProds = new List<products>();

            var termArr = term.ToLower().Split(' ');
            var counter = 0;
            IQueryable<products> filteredProds = null;
            IQueryable<variants> filteredVars = null;

            foreach (var termObj in termArr)
            {
                if (counter == 0)
                {
                    //products
                    filteredProds = db.products.Where(o => o.deleted == false && o.active == true).Where(p => p.title.ToLower().Contains(termObj) || (p.number != null && p.number.ToLower().Contains(termObj)));
                    //variants
                    filteredVars = db.variants.Where(p => p.number != null && p.deleted == false && p.number.ToLower().Contains(termObj));
                }
                else
                {
                    //products
                    filteredProds = filteredProds.Where(p => p.title.ToLower().Contains(termObj) || (p.number != null && p.number.ToLower().Contains(termObj)));
                    //variants
                    filteredVars = filteredVars.Where(p => p.number != null && p.deleted == false && p.number.ToLower().Contains(termObj));
                }
                counter++;
            }
            var names = filteredProds.OrderByDescending(x => x.id).ToList();

            foreach (var item in filteredVars)
            {
                varProds.Add(Prods.Where(i => i.id == item.prod_id).FirstOrDefault());
            }

            names.AddRange(varProds);

            var totalPages = names.Count() % pageSize == 0 ? names.Count() / pageSize : (names.Count() / pageSize) + 1;

            model.ProductsPaged = names.ToPagedList(pageNumber, pageSize);

            ViewData["Search"] = term;
            ViewData["PageSize"] = pageSize;
            ViewData["PageNumber"] = pageNumber;
            ViewData["TotalPages"] = totalPages;

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

            TempData["watchdogInfo"] = "Vážený zákazník, stráženie dostupnosti bolo aktivované.";

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

            //ViewData["countries"] = new AdminController().SelectionCountries();

            return View(model);
        }

        [HttpPost]
        public ActionResult ForgotPasswordSendLink(string forgotPasswordEmail)
        {
            //overime ci dany user existuje a ak ano, ci to nie je len subscribe ucet
            var user = db.users.Where(i => i.username == forgotPasswordEmail && i.role != 2).FirstOrDefault();

            var changePassInfoText = "";
            if (user != null)
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

                changePassInfoText = "Na váš email sme vám zaslali odkaz na zmenu hesla.";
            }
            else
            {
                changePassInfoText = "Zadaný email v databáze používateľov neexistuje.";
            }

            return RedirectToAction("Index", "Home", new { changePassInfo = changePassInfoText });
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

            //ViewData["countries"] = new AdminController().SelectionCountries();
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

            //ViewData["countries"] = new AdminController().SelectionCountries();

            return View(model);
        }

        [HttpPost]
        public ActionResult PasswordChangeAction(string Password, string Email, string Token)
        {
            string mail = Email;
            int index = mail.IndexOf("?");
            if (index >= 0)
                mail = mail.Substring(0, index);

            //nevytahujeme ucet subscribera (toto by sa nemalo stat kedze by ho to ako subscribera nemalo pustit editovat ucet)
            var user = db.users.Where(i => i.email == mail && i.role != 2).FirstOrDefault();

            if (user != null)
            {

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
                if (userstoken != null)
                {
                    db.userstoken.Remove(userstoken);
                }

                db.SaveChanges();
            }

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