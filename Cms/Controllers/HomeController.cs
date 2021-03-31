using System;
using System.Collections;
using System.Collections.Generic;
using System.ComponentModel;
using System.Globalization;
using System.IO;
using System.Linq;
using System.Threading.Tasks;
using System.Web;
using System.Web.Mvc;
using System.Web.UI.WebControls;
using System.Xml;
using System.Xml.Linq;
using Cms.Models;
using Newtonsoft.Json;
using PagedList;

namespace Cms.Controllers
{
    public class HomeController : Controller
    {
        Entities db = new Entities();
        public ActionResult Index()
        {
            var model = new MultipleIndexModel();
            model.ProductModel = db.products.Where(o => o.deleted == false).ToList();
            model.EsettingsModel = db.e_settings.ToList();
            model.SettingsModel = db.settings.ToList();
            model.PagesModel = db.pages.ToList();
            model.BlogModel = db.blog.ToList();
            model.BrandsModel = db.brands.Where(o => o.deleted == false).ToList();
            model.CategoriesModel = db.categories.Where(o => o.deleted == false).ToList();
            model.TypesModel = db.types.Where(o => o.deleted == false).ToList();
            model.SlideshowModel = db.slideshow.ToList();
            ViewData["Homepage"] = "true";
            return View(model);
        }

        [Route("cartsession")]
        public ActionResult CartSession(string cartValues)
        {
            var cartVal = JsonConvert.DeserializeObject<List<dynamic>>(cartValues);
            Session["cartitems"] = cartVal;

            decimal thisSum = 0;
            foreach (var item in cartVal) {

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
            model.ProductModel = db.products.ToList();
            model.EsettingsModel = db.e_settings.ToList();
            model.SettingsModel = db.settings.ToList();
            model.PagesModel = db.pages.ToList();
            model.BlogModel = db.blog.ToList();
            model.BrandsModel = db.brands.ToList();
            model.CategoriesModel = db.categories.ToList();
            model.SlideshowModel = db.slideshow.Where(o => o.page == "default").ToList();
            ViewData["Homepage"] = "true";
            return View(model);
        }

        [Route("wishsession")]
        public ActionResult WishSession(string wishValues)
        {
            var wishVal = JsonConvert.DeserializeObject<List<dynamic>>(wishValues);
            Session["wishitems"] = wishVal;

            var modelwish = new MultipleIndexModel();

            if (Session["userid"] != null)
            {
                var usID = Int32.Parse(Session["userid"].ToString());
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
                id = db.categories.Where(i => i.slug == catslug).First().id.ToString();
            }
            else if (subslug != null && subslug2 == null && catslug != "novinky" && catslug != "zlavy")
            {
                var topcatName = db.categories.Where(i => i.slug == catslug).First().name;
                id = db.categories.Where(i => i.slug == subslug && i.maincat == topcatName).First().id.ToString();
            }
            else if (subslug2 != null && subslug3 == null && catslug != "novinky" && catslug != "zlavy")
            {
                var topcatName = db.categories.Where(i => i.slug == catslug).First().name;
                var topcat2Name = db.categories.Where(i => i.slug == subslug).First().name;
                id = db.categories.Where(i => i.slug == subslug2 && i.maincat == topcatName && i.topcat == topcat2Name).First().id.ToString();
            }
            else if (subslug3 != null && catslug != "novinky" && catslug != "zlavy")
            {
                var maincatName = db.categories.Where(i => i.slug == catslug).First().name;
                var topcatName = db.categories.Where(i => i.slug == subslug).First().name;
                var topcat2Name = db.categories.Where(i => i.slug == subslug2).First().name;

                id = db.categories.Where(i => i.slug == subslug3 && i.maincat == maincatName && i.topcat == topcatName && i.topcat2 == topcat2Name).First().id.ToString();
            }

            var model = new MultipleIndexModel();
            model.ProductModel = db.products.ToList();
            model.EsettingsModel = db.e_settings.ToList();
            model.SettingsModel = db.settings.ToList();
            model.PagesModel = db.pages.ToList();
            model.CategoriesModel = db.categories.ToList();
            model.BrandsModel = db.brands.ToList();
            model.SlideshowModel = db.slideshow.Where(o => o.page == "default").ToList();

            var kategoria = db.categories.Where(i => i.slug == catslug).Select(o => o.name);
            var sub = db.categories.Where(i => i.slug == subslug).Select(o => o.name);
            ViewData["Category"] = kategoria;
            ViewData["Sub"] = sub;
            ViewData["CatId"] = id;
            ProductModel pm = new ProductModel();
            ProductsController pc = new ProductsController();
            ViewData["typ"] = pm.SelectionTyp();
            ViewData["znacka"] = pc.SelectionBrand();

            List<decimal?> prices = new List<decimal?>();
            List<decimal> kw = new List<decimal>();
            List<decimal> room = new List<decimal>();

            foreach (var item in model.ProductModel)
            {
                prices.Add(item.price);
                prices.Add(item.discountprice);
                if(item.custom9 != null) kw.Add(decimal.Parse(item.custom9.Replace(".", ",")));
                if(item.custom10 != null) room.Add(decimal.Parse(item.custom10.Replace(".", ",")));
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

            return View(model);
        }

        [Route("znacka/{brand}/{page?}/{id?}")]
        public ActionResult Brand(string brand)
        {
           
            var model = new MultipleIndexModel();
            model.ProductModel = db.products.ToList();
            model.EsettingsModel = db.e_settings.ToList();
            model.SettingsModel = db.settings.ToList();
            model.PagesModel = db.pages.ToList();
            model.CategoriesModel = db.categories.ToList();
            model.BrandsModel = db.brands.ToList();
            model.TypesModel = db.types.ToList();
            model.SlideshowModel = db.slideshow.Where(o => o.page == "default").ToList();
            var kategoria = db.types.Where(i => i.slug == brand).Select(o => o.name);
            var categoryID = db.types.Where(i => i.slug == brand).First().id;

            ViewData["Category"] = kategoria;
            ViewData["CatId"] = categoryID;

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
            model.ProductModel = db.products.ToList();
            model.EsettingsModel = db.e_settings.ToList();
            model.SettingsModel = db.settings.ToList();
            model.BrandsModel = db.brands.ToList();
            model.PagesModel = db.pages.Where(i => i.slug == slug).ToList();
            model.CategoriesModel = db.categories.ToList();

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

            model.SlideshowModel = db.slideshow.Where(o => o.page == slug).ToList();
            model.ProductModel = db.products.ToList();
            model.EsettingsModel = db.e_settings.ToList();
            model.SettingsModel = db.settings.ToList();
            model.BrandsModel = db.brands.ToList();
            model.BlogModel = db.blog.Where(i => i.slug == slug).ToList();
            model.PagesModel = db.pages.ToList();
            model.CategoriesModel = db.categories.ToList();
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

            model.ProductModel = db.products.ToList();
            model.BrandsModel = db.brands.ToList();
            model.CategoriesModel = db.categories.ToList();
            model.EsettingsModel = db.e_settings.ToList();

            XDocument xdoc = new XDocument(
                new XDeclaration("1.0", "utf-8", "yes")
            );

            XElement xRoot = new XElement("SHOP");
            xdoc.Add(xRoot);

            /*ZMENIT*/
            foreach (var product in model.ProductModel)
            {
                XElement xRoot2 = new XElement("SHOPITEM");
                XElement doc = new XElement("ITEM_ID", product.id);
                XElement doc2 = new XElement("PRODUCTNAME", product.title);
                XElement doc3 = new XElement("PRODUCT", product.title);
                XElement doc4 = new XElement("DESCRIPTION", product.description);
                XElement doc5 = new XElement("URL", "https://shop.nahod.sk" + Url.Action("ProductDetail", "Home", new { id = product.id }));
                XElement doc6 = new XElement("IMGURL", "https://shop.nahod.sk/Uploads/" + product.image);
                XElement doc7 = new XElement("IMGURL_ALTERNATIVE", "https://shop.nahod.sk/Uploads/" + product.image);
                XElement doc8 = new XElement("VIDEO_URL", "");
                XElement doc9 = new XElement("PRICE_VAT", product.price);
                XElement doc10 = null;
                foreach (var brand in model.BrandsModel.Where(i => i.id == Int32.Parse(product.custom3)))
                {
                    doc10 = new XElement("MANUFACTURER", "<![CDATA[" + brand.name + "]]");
                }

                foreach (var cat in model.CategoriesModel.Where(i => i.id == Int32.Parse(product.category)))
                {
                    foreach (var topcat in model.CategoriesModel.Where(o => o.name == cat.topcat))
                    {
                        url_part1 = topcat.name;

                        foreach (var subcat in model.CategoriesModel.Where(o => o.name == cat.topcat2 && o.topcat == cat.topcat))
                        {
                            url_part2 = subcat.name;
                            url_part3 = cat.name;
                        }
                    }
                }

                XElement doc11 = new XElement("CATEGORYTEXT", url_part1 + " | " + url_part2 + " | " + url_part3);
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
                xRoot2.Add(doc11);
                xRoot2.Add(doc13);
                xRoot2.Add(doc14);
                xRoot2.Add(doc12);
                xRoot2.Add(doc15);
                xRoot2.Add(doc16);
            }

            return Content(xdoc.ToString(), "application/xml");
        }

        [Route("kosik")]
        public ActionResult Basket()
        {
            var model = new MultipleIndexModel();
            model.EsettingsModel = db.e_settings.ToList();
            model.ProductModel = db.products.ToList();
            model.SettingsModel = db.settings.ToList();
            model.PagesModel = db.pages.ToList();
            model.BrandsModel = db.brands.ToList();
            model.CategoriesModel = db.categories.ToList();
            model.SlideshowModel = db.slideshow.Where(o => o.page == "default").ToList();

            if (Session["userid"] != null)
            {
                var usID = Int32.Parse(Session["userid"].ToString());
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

        [Route("wishlist")]
        public ActionResult Wishlist()
        {
            var model = new MultipleIndexModel();
            model.EsettingsModel = db.e_settings.ToList();
            model.ProductModel = db.products.ToList();
            model.SettingsModel = db.settings.ToList();
            model.PagesModel = db.pages.ToList();
            model.BrandsModel = db.brands.ToList();
            model.CategoriesModel = db.categories.ToList();
            model.SlideshowModel = db.slideshow.Where(o => o.page == "default").ToList();

            if (Session["userid"] != null)
            {
                var usID = Int32.Parse(Session["userid"].ToString());
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
            model.ProductModel = db.products.ToList();
            model.SettingsModel = db.settings.ToList();
            model.PagesModel = db.pages.ToList();
            model.BrandsModel = db.brands.ToList();
            model.CategoriesModel = db.categories.ToList();
            model.SlideshowModel = db.slideshow.Where(o => o.page == "default").ToList();

            if (Session["userid"] != null)
            {
                var usID = Int32.Parse(Session["userid"].ToString());
                model.OrderDataModel = db.orders.Where(o => o.userid == usID).ToList();
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

        [Route("detail-produktu/{id}/{slug?}")]
        public ActionResult ProductDetail(int? id)
        {
            var model = new MultipleIndexModel();
            if (Session["userid"] != null)
            {
                var userToSend = Int32.Parse(Session["userid"].ToString());
                model.AllUsersMetaModel = db.usersmeta.Where(i => i.userid == userToSend).ToList();
            }
            else
            {
                model.AllUsersMetaModel = null;
            }

            model.EsettingsModel = db.e_settings.ToList();
            model.ProductModel = db.products.ToList();
            model.SettingsModel = db.settings.ToList();
            model.PagesModel = db.pages.ToList();
            model.BrandsModel = db.brands.ToList();
            model.CategoriesModel = db.categories.ToList();
            model.SlideshowModel = db.slideshow.Where(o => o.page == "default").ToList();

            if (id == null)
            {
                return View(model);
            }

            var data = db.products.Where(i => i.id == id).ToList();
            if (data == null)
            {
                return View(model);
            }

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
            model.ProductModel = db.products.ToList();
            model.EsettingsModel = db.e_settings.ToList();
            model.SettingsModel = db.settings.ToList();
            model.PagesModel = db.pages.ToList();
            model.CategoriesModel = db.categories.ToList();
            model.BrandsModel = db.brands.ToList();
            model.SlideshowModel = db.slideshow.Where(o => o.page == "default").ToList();
            model.ProductsPaged = db.products.ToList().Where(p => p.title.ToLower().Contains(term.ToLower())).OrderByDescending(x => x.id)
                     .ToPagedList(pageNumber, pageSize);

            ViewData["Search"] = term;

            return View(model);
        }

        [HttpPost, Route("aktualizovat-udaje")]
        public async Task<ActionResult> SaveCustomerDetails(MultipleIndexModel model)
        {
            if (Session["userid"] != null)
            {
                var usID = Int32.Parse(Session["userid"].ToString());
                var o = db.usersmeta.Single(i => i.userid == usID);
                var u = db.users.Single(i => i.id == usID);

                o.name = model.OrdersModel.Name;
                o.surname = model.OrdersModel.Surname;
                o.address = model.OrdersModel.Address;
                o.city = model.OrdersModel.City;
                o.zip = model.OrdersModel.Zip;
                o.phone = model.OrdersModel.Phone;
                o.email = model.OrdersModel.Email;
                o.companyname = model.OrdersModel.Companyname;
                o.ico = model.OrdersModel.Ico;
                o.dic = model.OrdersModel.Dic;
                o.icdph = model.OrdersModel.Icdph;
                u.email = model.OrdersModel.Email;
                u.username = model.OrdersModel.Email;

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
    }
}