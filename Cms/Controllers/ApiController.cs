using Cms.Models;
using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using System.Net.Http;
using System.Web.Http.Cors;
using System.Data.Entity.SqlServer;
using System.Globalization;
using System.IO;
using System.Xml.Serialization;
using System.Xml;
using System.Xml.Schema;
using System.Data;
using System.Xml.Linq;
using Newtonsoft.Json;
using System.Text.RegularExpressions;
using OfficeOpenXml;

namespace Cms.Controllers
{
    public class ApiController : Controller
    {
        Entities db = new Entities();

        // GET: Api
        [EnableCors(origins: "*", headers: "*", methods: "*")]
        public JsonResult FetchProducts(string catslug, string subslug, string subslug2, string subslug3, bool brand, bool searchparam, bool type)
        {
            object result = null;
            var variants = db.variants.OrderBy(o => o.num).ToList();
            if (brand)
            {
                //subslug - kategoria level 1
                //subslug2 - kategoria level 2
                result = new { data = FetchByBrand(catslug, subslug, subslug2).ProductModel, variants };
            }
            else if (type)
            {
                //subslug - kategoria level 1
                //subslug2 - kategoria level 2
                result = new { data = FetchByType(catslug, subslug, subslug2).ProductModel, variants };
            }
            else if (searchparam)
            {
            }
            else
            {
                int id = CategoryId(catslug, subslug, subslug2, subslug3);

                IEnumerable topcatId = null;
                if (catslug != "novinky" && catslug != "zlavy" && !brand && !searchparam)
                {
                    topcatId = TopCatID(id);
                }
                var prodData =
                result = new { data = SortByBrand(topcatId, id, catslug).ProductModel, variants };
            }

            return Json(result, JsonRequestBehavior.AllowGet);
        }

        [EnableCors(origins: "*", headers: "*", methods: "*")]
        public JsonResult FetchProductsAdminFilter(string catId, string brandId, decimal priceFrom, decimal priceTo, bool isDiscount, bool isInactive)
        {

            object result = null;
            if (catId != "" && brandId == "")
            {

                result = new
                {
                    data = isInactive ? isDiscount ? db.products.Where(i => (i.category.Contains("[" + catId + ",") || i.category.Contains("," + catId + ",") || i.category.Contains("," + catId + "]")) && i.deleted == false && i.price >= priceFrom && i.price <= priceTo && i.discountprice != null && i.active == false).ToList() : db.products.Where(i => (i.category.Contains("[" + catId + ",") || i.category.Contains("," + catId + ",") || i.category.Contains("," + catId + "]")) && i.deleted == false && i.price >= priceFrom && i.price <= priceTo && i.active == false).ToList() : isDiscount ? db.products.Where(i => (i.category.Contains("[" + catId + ",") || i.category.Contains("," + catId + ",") || i.category.Contains("," + catId + "]")) && i.deleted == false && i.price >= priceFrom && i.price <= priceTo && i.discountprice != null).ToList() : db.products.Where(i => (i.category.Contains("[" + catId + ",") || i.category.Contains("," + catId + ",") || i.category.Contains("," + catId + "]")) && i.deleted == false && i.price >= priceFrom && i.price <= priceTo).ToList(),
                    variants = db.variants.Where(x => x.deleted == false).Join(db.attributes, a => a.attribute_id, b => b.id, (a, b) => new VariantAttributesModel { Id = a.id, ProdId = a.prod_id, AttrName = b.name, AttrValue = a.value, Stock = a.stock }).OrderByDescending(o => o.ProdId).ThenBy(o => o.AttrName).ToList(),
                    categories = db.categories.Where(x => x.deleted == false).ToList()
                };
            }
            else if (catId == "" && brandId != "")
            {
                result = new
                {
                    data = isInactive ? isDiscount ? db.products.Where(i => i.custom3 == brandId && i.deleted == false && i.price >= priceFrom && i.price <= priceTo && i.discountprice != null && i.active == false).ToList() : db.products.Where(i => i.custom3 == brandId && i.deleted == false && i.price >= priceFrom && i.price <= priceTo && i.active == false).ToList() : isDiscount ? db.products.Where(i => i.custom3 == brandId && i.deleted == false && i.price >= priceFrom && i.price <= priceTo && i.discountprice != null).ToList() : db.products.Where(i => i.custom3 == brandId && i.deleted == false && i.price >= priceFrom && i.price <= priceTo).ToList(),
                    variants = db.variants.Where(x => x.deleted == false).Join(db.attributes, a => a.attribute_id, b => b.id, (a, b) => new VariantAttributesModel { Id = a.id, ProdId = a.prod_id, AttrName = b.name, AttrValue = a.value, Stock = a.stock }).OrderByDescending(o => o.ProdId).ThenBy(o => o.AttrName).ToList(),
                    categories = db.categories.Where(x => x.deleted == false).ToList()
                };
            }
            else if (catId != "" && brandId != "")
            {
                result = new
                {
                    data = isInactive ? isDiscount ? db.products.Where(i => i.custom3 == brandId && (i.category.Contains("[" + catId + ",") || i.category.Contains("," + catId + ",") || i.category.Contains("," + catId + "]")) && i.deleted == false && i.price >= priceFrom && i.price <= priceTo && i.discountprice != null && i.active == false).ToList() : db.products.Where(i => i.custom3 == brandId && (i.category.Contains("[" + catId + ",") || i.category.Contains("," + catId + ",") || i.category.Contains("," + catId + "]")) && i.deleted == false && i.price >= priceFrom && i.price <= priceTo && i.active == false).ToList() : isDiscount ? db.products.Where(i => i.custom3 == brandId && (i.category.Contains("[" + catId + ",") || i.category.Contains("," + catId + ",") || i.category.Contains("," + catId + "]")) && i.deleted == false && i.price >= priceFrom && i.price <= priceTo && i.discountprice != null).ToList() : db.products.Where(i => i.custom3 == brandId && (i.category.Contains("[" + catId + ",") || i.category.Contains("," + catId + ",") || i.category.Contains("," + catId + "]")) && i.deleted == false && i.price >= priceFrom && i.price <= priceTo).ToList(),
                    variants = db.variants.Where(x => x.deleted == false).Join(db.attributes, a => a.attribute_id, b => b.id, (a, b) => new VariantAttributesModel { Id = a.id, ProdId = a.prod_id, AttrName = b.name, AttrValue = a.value, Stock = a.stock }).OrderByDescending(o => o.ProdId).ThenBy(o => o.AttrName).ToList(),
                    categories = db.categories.Where(x => x.deleted == false).ToList()
                };
            }
            else
            {
                result = new
                {
                    data = isInactive ? isDiscount ? db.products.Where(x => x.deleted == false && x.price >= priceFrom && x.price <= priceTo && x.discountprice != null && x.active == false).ToList() : db.products.Where(x => x.deleted == false && x.price >= priceFrom && x.price <= priceTo && x.active == false).ToList() : isDiscount ? db.products.Where(x => x.deleted == false && x.price >= priceFrom && x.price <= priceTo && x.discountprice != null).ToList() : db.products.Where(x => x.deleted == false && x.price >= priceFrom && x.price <= priceTo).ToList(),
                    variants = db.variants.Where(x => x.deleted == false).Join(db.attributes, a => a.attribute_id, b => b.id, (a, b) => new VariantAttributesModel { Id = a.id, ProdId = a.prod_id, AttrName = b.name, AttrValue = a.value, Stock = a.stock }).OrderByDescending(o => o.ProdId).ThenBy(o => o.AttrName).ToList(),
                    categories = db.categories.Where(x => x.deleted == false).ToList()
                };
            }

            return Json(result, JsonRequestBehavior.AllowGet);
        }

        [EnableCors(origins: "*", headers: "*", methods: "*")]
        public JsonResult EditProductValues(string value, int id, string name)
        {
            var product = db.products.Where(a => a.id == id).SingleOrDefault();

            switch (name)
            {
                case "number":
                    product.number = value;
                    break;
                case "title":
                    product.title = value;
                    break;
                case "price":
                    product.price = Decimal.Parse(value, CultureInfo.InvariantCulture);
                    break;
                case "discountprice":
                    if (value != "")
                    {
                        product.discountprice = Decimal.Parse(value, CultureInfo.InvariantCulture);
                    }
                    else
                    {
                        product.discountprice = null;
                    }
                    break;
                case "active":
                    product.active = bool.Parse(value);
                    break;
                case "heureka":
                    product.heureka = bool.Parse(value);
                    break;
            }

            db.SaveChanges();

            return Json(true, JsonRequestBehavior.AllowGet);
        }

        [EnableCors(origins: "*", headers: "*", methods: "*")]
        public JsonResult EditOrderNote(string value, string ordNum)
        {
            var order = db.orders.Where(a => a.ordernumber == ordNum).SingleOrDefault();

            order.note = value;

            db.SaveChanges();

            return Json(true, JsonRequestBehavior.AllowGet);
        }
        private int CategoryId(string catslug, string subslug, string subslug2, string subslug3)
        {
            int id = 0;
            if (subslug == null && catslug != "novinky" && catslug != "zlavy")
            {
                id = db.categories.Where(i => i.slug == catslug).First().id;
            }
            else if (subslug != null && subslug2 == null && catslug != "novinky" && catslug != "zlavy")
            {
                var topcatName = db.categories.Where(i => i.slug == catslug).First().id.ToString();
                id = db.categories.Where(i => i.slug == subslug && i.maincat == topcatName).First().id;
            }
            else if (subslug2 != null && subslug3 == null && catslug != "novinky" && catslug != "zlavy")
            {
                var topcatName = db.categories.Where(i => i.slug == catslug).First().id.ToString();
                var topcat2Name = db.categories.Where(i => i.slug == subslug).First().id.ToString();
                id = db.categories.Where(i => i.slug == subslug2 && i.maincat == topcatName && i.topcat == topcat2Name).First().id;
            }
            else if (subslug3 != null && catslug != "novinky" && catslug != "zlavy")
            {
                var maincatName = db.categories.Where(i => i.slug == catslug).First().id.ToString();
                var topcatName = db.categories.Where(i => i.slug == subslug).First().id.ToString();
                var topcat2Name = db.categories.Where(i => i.slug == subslug2).First().id.ToString();

                id = db.categories.Where(i => i.slug == subslug3 && i.maincat == maincatName && i.topcat == topcatName && i.topcat2 == topcat2Name).First().id;
            }

            return id;
        }

        private IEnumerable TopCatID(int categoryID)
        {
            IEnumerable topcatId = null;

            foreach (var cat in db.categories.Where(i => i.id == categoryID))
            {
                if (cat.maincat == "Žiadna")
                {
                    topcatId = db.categories.Where(o => o.maincat == cat.name).Select(i => i.id);
                }
                else if (cat.topcat == "Žiadna" || cat.topcat == "")
                {
                    topcatId = db.categories.Where(o => o.topcat == cat.name && o.maincat == cat.maincat).Select(i => i.id);
                }
                else if (cat.topcat2 == "Žiadna" || cat.topcat2 == "")
                {
                    topcatId = db.categories.Where(o => o.topcat2 == cat.name && o.maincat == cat.maincat).Select(i => i.id);
                }

            }
            return topcatId;
        }

        private MultipleIndexModel SortByBrand(IEnumerable topcatId, int id, string catslug)
        {
            var model = new MultipleIndexModel();

            //zoraduje podla priority zo znaciek
            var sortId = db.brands.OrderBy(i => i.priority).Select(o => o.id.ToString()).ToList();
            if (topcatId != null)
            {
                var Sql = "select * from `products` where `category` like '%" + id + "%'";

                foreach (var cats in topcatId)
                {
                    Sql += " or `category` like '%" + cats + "%'";
                }

                var products = db.Database.SqlQuery<products>(Sql);
                //List<products> helperarray = new List<products>();

                //foreach (var sort in sortId)
                //{
                //    foreach (var prod in products.Where(c => c.custom3 == sort))
                //    {
                //        helperarray.Add(prod);
                //    }
                //}

                model.ProductModel = products.Where(i => i.deleted == false && i.active == true).ToList();
            }
            else if (catslug == "novinky")
            {
                model.ProductModel = db.products.Where(i => i.deleted == false && i.active == true).OrderByDescending(x => x.id).ToList();
            }
            else if (catslug == "zlavy")
            {
                model.ProductModel = db.products.Where(i => i.deleted == false && i.active == true).ToList().Where(c => c.discountprice != null).OrderByDescending(x => x.id);
            }
            else
            {
                var products = db.products.Where(c => c.deleted == false && c.active == true && c.category == id.ToString());
                List<products> helperarray = new List<products>();

                foreach (var sort in sortId)
                {
                    foreach (var prod in products.Where(c => c.custom3 == sort))
                    {
                        helperarray.Add(prod);
                    }
                }

                model.ProductModel = helperarray.ToList();
            }

            return model;
        }

        private MultipleIndexModel FetchByBrand(string brand, string catSlug1, string catSlug2)
        {
            var brandID = db.brands.Where(i => i.slug == brand).First().id.ToString();

            var model = new MultipleIndexModel();
            if (catSlug1 != null && catSlug2 == null)
            {

                var catId = db.categories.Where(i => i.slug == catSlug1).First().id.ToString();
                model.ProductModel = db.products.Where(i => i.deleted == false && i.active == true && i.custom3 == brandID && (i.category.Contains("[" + catId + ",") || i.category.Contains("," + catId + ",") || i.category.Contains("," + catId + "]"))).OrderByDescending(x => x.id).ToList();
            }
            else if (catSlug1 != null && catSlug2 != null)
            {

                var catId = db.categories.Where(i => i.slug == catSlug2).First().id.ToString();
                model.ProductModel = db.products.Where(i => i.deleted == false && i.active == true && i.custom3 == brandID && (i.category.Contains("[" + catId + ",") || i.category.Contains("," + catId + ",") || i.category.Contains("," + catId + "]"))).OrderByDescending(x => x.id).ToList();
            }
            else
            {
                model.ProductModel = db.products.Where(c => c.deleted == false && c.active == true && c.custom3 == brandID).OrderByDescending(x => x.id).ToList();
            }


            return model;
        }
        private MultipleIndexModel FetchByType(string type, string catSlug1, string catSlug2)
        {
            var typeID = db.types.Where(i => i.slug == type).First().id.ToString();
            var model = new MultipleIndexModel();

            if (catSlug1 != null && catSlug2 == null)
            {

                var catId = db.categories.Where(i => i.slug == catSlug1).First().id.ToString();
                model.ProductModel = db.products.Where(i => i.deleted == false && i.active == true && (i.type.Contains("[" + typeID + ",") || i.type.Contains("," + typeID + ",") || i.type.Contains("," + typeID + "]")) && (i.category.Contains("[" + catId + ",") || i.category.Contains("," + catId + ",") || i.category.Contains("," + catId + "]"))).OrderByDescending(x => x.id).ToList();
            }
            else if (catSlug1 != null && catSlug2 != null)
            {

                var catId = db.categories.Where(i => i.slug == catSlug2).First().id.ToString();
                model.ProductModel = db.products.Where(i => i.deleted == false && i.active == true && (i.type.Contains("[" + typeID + ",") || i.type.Contains("," + typeID + ",") || i.type.Contains("," + typeID + "]")) && (i.category.Contains("[" + catId + ",") || i.category.Contains("," + catId + ",") || i.category.Contains("," + catId + "]"))).OrderByDescending(x => x.id).ToList();
            }
            else
            {
                model.ProductModel = db.products.Where(c => c.deleted == false && c.active == true && (c.type.Contains("[" + typeID + ",") || c.type.Contains("," + typeID + ",") || c.type.Contains("," + typeID + "]"))).OrderByDescending(x => x.id).ToList();
            }

            return model;
        }

        [EnableCors(origins: "*", headers: "*", methods: "*")]
        public JsonResult FetchUser(string username, string userid)
        {
            object result = null;
            var id = int.Parse(userid);
            var user = db.usersmeta.Where(u => u.userid == id).FirstOrDefault();

            result = new { data = user };

            return Json(result, JsonRequestBehavior.AllowGet);
        }

        [Route("exportObjS3"), EnableCors(origins: "*", headers: "*", methods: "*")]
        public string ExportObjMoneyS3()
        {

            MultipleIndexModel model = new MultipleIndexModel();
            MemoryStream ms = new MemoryStream();
            XmlWriterSettings xws = new XmlWriterSettings();
            xws.OmitXmlDeclaration = true;
            xws.Indent = true;
            var url_part1 = "";
            var url_part2 = "";
            var url_part3 = "";

            var filemane = "test.xml";

            var order = db.orders.ToList();

            XDocument xdoc = new XDocument(
                new XDeclaration("1.0", "utf-8", "yes")
            );

            XElement xRoot = new XElement("MoneyData");
            xdoc.Add(xRoot);
            XElement xRoot2 = new XElement("SeznamObjPrij");
            xRoot.Add(xRoot2);

            foreach (var product in order)
            {
                //var prodDesc = Regex.Replace(product.description, "<.*?>", String.Empty);

                XElement xRoot3 = new XElement("ObjPrij");

                XElement doc = new XElement("Doklad", product.ordernumber);
                XElement doc2 = new XElement("Popis", product.name + " " + product.surname);
                XElement doc3 = new XElement("Vystaveno", product.date);
                XElement xRoot4 = new XElement("DodOdb");
                XElement doc4 = new XElement("ObchNazev", product.name + " " + product.surname);

                if (product.companyname != null)
                {
                    doc4 = new XElement("ObchNazev", product.companyname);
                }

                XElement xRoot5 = new XElement("ObchAdresa");

                XElement doc5 = new XElement("Ulice", product.address);
                XElement doc6 = new XElement("Misto", product.city);
                XElement doc7 = new XElement("PSC", product.zip);
                XElement doc8 = new XElement("Stat", product.country);
                XElement doc9 = new XElement("KodStatu", "SK");

                XElement doc10 = new XElement("FaktNazev", product.name + " " + product.surname);
                if (product.companyname != null)
                {
                    doc10 = new XElement("FaktNazev", product.companyname);
                }

                XElement doc11 = new XElement("ICO", product.ico);
                XElement doc12 = new XElement("DIC", product.icdph);

                XElement xRoot6 = new XElement("FaktAdresa");
                XElement doc13 = new XElement("Ulice", product.address);
                XElement doc14 = new XElement("Misto", product.city);
                XElement doc15 = new XElement("PSC", product.zip);
                XElement doc16 = new XElement("Stat", product.country);
                XElement doc17 = new XElement("KodStatu", "SK");

                XElement doc18 = new XElement("Nazev", product.name_shipp + " " + product.surname_shipp + "  " + product.companyname_shipp);
                XElement xRoot7 = new XElement("Adresa");
                XElement doc19 = new XElement("Ulice", product.address_shipp);
                XElement doc20 = new XElement("Misto", product.city_shipp);
                XElement doc21 = new XElement("PSC", product.zip_shipp);
                XElement doc22 = new XElement("Stat", product.country_shipp);

                // XElement doc23 = new XElement("GUID", product.ordernumber);

                XElement xRoot8 = new XElement("Tel");
                XElement doc24 = new XElement("Pred", "");
                XElement doc25 = new XElement("Cislo", product.phone);
                XElement doc26 = new XElement("EMail", product.email);
                XElement doc27 = new XElement("PlatceDPH", "0");

                if (product.icdph != null)
                {
                    doc27 = new XElement("PlatceDPH", "1");
                }

                XElement doc28 = new XElement("FyzOsoba", "");
                XElement doc29 = new XElement("Banka", "");
                XElement doc30 = new XElement("Ucet", "");
                XElement doc31 = new XElement("KodBanky", "");
                XElement doc32 = new XElement("DICSK", product.dic);

                XElement xRoot9 = new XElement("KonecPrij");

                XElement doc33 = new XElement("KPFromOdb", "0");
                XElement doc34 = new XElement("Celkem", product.finalprice);

                XElement doc35 = new XElement("PlatPodm", PaymentType(product.payment));
                XElement shipping = new XElement("Doprava", ShippingType(product.shipping));
                XElement doc36 = new XElement("CasVystave", product.date);
                XElement doc37 = new XElement("DatumVysta", product.date);
                XElement doc38 = new XElement("Nadpis", "Prijatá objednávka");
                XElement doc39 = new XElement("PrimDoklad", product.ordernumber);
                XElement doc40 = new XElement("SazbaDPH2", "20");
                XElement doc41 = new XElement("Sleva", "0");
                XElement doc42 = new XElement("Pojisteno", "0");


                xRoot2.Add(xRoot3);
                xRoot3.Add(doc);
                xRoot3.Add(doc2);
                xRoot3.Add(doc3);

                xRoot3.Add(xRoot4); //DodOdb

                xRoot4.Add(doc4);

                xRoot4.Add(xRoot5);//ObchodAdresa

                xRoot5.Add(doc5);
                xRoot5.Add(doc6);
                xRoot5.Add(doc7);
                xRoot5.Add(doc8);
                xRoot5.Add(doc9);

                xRoot4.Add(doc10);
                xRoot4.Add(doc11);
                xRoot4.Add(doc12);

                xRoot4.Add(xRoot6); //FaktAdresa
                xRoot6.Add(doc13);
                xRoot6.Add(doc14);
                xRoot6.Add(doc15);
                xRoot6.Add(doc16);
                xRoot6.Add(doc17);

                xRoot4.Add(doc18);

                xRoot4.Add(xRoot7); //Adresa
                xRoot7.Add(doc19);
                xRoot7.Add(doc20);
                xRoot7.Add(doc21);
                xRoot7.Add(doc22);

                //xRoot4.Add(doc23); //GUID

                xRoot4.Add(xRoot8); //Tel
                xRoot8.Add(doc24);
                xRoot8.Add(doc25);

                xRoot4.Add(doc26);
                xRoot4.Add(doc27);
                xRoot4.Add(doc28);
                xRoot4.Add(doc29);
                xRoot4.Add(doc30);
                xRoot4.Add(doc31);
                xRoot4.Add(doc32);

                xRoot3.Add(xRoot9); // KonecPrij

                xRoot3.Add(doc33);
                xRoot3.Add(doc34);
                xRoot3.Add(doc35);
                xRoot3.Add(shipping);
                xRoot3.Add(doc36);
                xRoot3.Add(doc37);
                xRoot3.Add(doc38);
                xRoot3.Add(doc39);
                xRoot3.Add(doc40);
                xRoot3.Add(doc41);
                xRoot3.Add(doc42);

                var ordermeta = db.ordermeta.Where(i => i.ordernumber == product.ordernumber).ToList();

                foreach (var item in ordermeta)
                {
                    XElement xRoot10 = new XElement("Polozka");
                    XElement doc43 = new XElement("Popis", item.product + " " + item.variant + " " + item.variant2);
                    XElement doc44 = new XElement("PocetMJ", item.pieces);
                    XElement doc45 = new XElement("Cena", item.price);
                    XElement doc46 = new XElement("SazbaDPH", "20");
                    XElement doc47 = new XElement("TypCeny", "0");
                    XElement doc48 = new XElement("Sleva", "0");
                    XElement doc49 = new XElement("Popis", item.product + " " + item.variant + " " + item.variant2);

                    XElement xRoot11 = new XElement("KmKarta");

                    XElement doc50 = new XElement("Popis", item.product + " " + item.variant + " " + item.variant2);
                    XElement doc51 = new XElement("Zkrat", item.product);
                    XElement doc52 = new XElement("MJ", "ks");

                    var prodId = int.Parse(item.productid);
                    var customId = db.products.Where(i => i.id == prodId).FirstOrDefault();

                    XElement doc53 = new XElement("UzivCode", "0");
                    //XElement doc54 = new XElement("GUID", "0");
                    XElement doc55 = new XElement("Katalog", "0");

                    if (customId != null)
                    {
                        if (item.variant != "" && item.variant != null)
                        {
                            var variant = db.variants.Where(i => i.prod_id == prodId && i.value == item.variant).FirstOrDefault();

                            if (variant != null)
                            {
                                doc53 = new XElement("UzivCode", variant.number);
                                //doc54 = new XElement("GUID", customId.number);
                                doc55 = new XElement("Katalog", variant.number);
                            }
                        }
                        else
                        {
                            doc53 = new XElement("UzivCode", customId.number);
                            //doc54 = new XElement("GUID", customId.number);
                            doc55 = new XElement("Katalog", customId.number);
                        }

                    }

                    xRoot9.Add(xRoot10); // Polozka

                    xRoot10.Add(doc43);
                    xRoot10.Add(doc44);
                    xRoot10.Add(doc45);
                    xRoot10.Add(doc46);
                    xRoot10.Add(doc47);
                    xRoot10.Add(doc48);
                    xRoot10.Add(doc49);

                    xRoot10.Add(xRoot11); // KmKarta

                    xRoot11.Add(doc50);
                    xRoot11.Add(doc51);
                    xRoot11.Add(doc52);
                    xRoot11.Add(doc53);
                    xRoot11.Add(doc55);
                }

            }

            using (Stream writer = new FileStream(Server.MapPath("~/export/" + filemane), FileMode.Create))
            {
                xdoc.Save(writer);
            }

            return "Oki";

        }

        [Route("importSKladS3"), EnableCors(origins: "*", headers: "*", methods: "*")]
        public string ImportMonS3(string ExpZasobyName)
        {
            var path = Server.MapPath("~/import/" + ExpZasobyName);
            XmlTextReader reader = new XmlTextReader(path);
            while (reader.Read())
            {
                // Do some work here on the data.
                Console.WriteLine(reader.Name);
                //string tempf = reader.Katalog;
                //string tempc = reader.Cena;
                //string feels = reader.StavZasoby;
            }

            XmlDocument doc1 = new XmlDocument();
            doc1.Load(path);
            XmlElement root = doc1.DocumentElement;
            XmlNodeList nodes = root.SelectNodes("/MoneyData/SeznamZasoba/Zasoba");

            // XmlNodeList nodes = oNode.SelectNodes("Katalog");

            foreach (XmlNode node in nodes)
            {
                var sklad = node.SelectSingleNode("StavZasoby/Zasoba").InnerText;
                var cislo = "";
                if (node.SelectSingleNode("KmKarta/Katalog") != null)
                {
                    cislo = node.SelectSingleNode("KmKarta/Katalog").InnerText;
                }

                var cena = node.SelectSingleNode("PC/Cena1/Cena").InnerText;
                var zlava = node.SelectSingleNode("Sleva").InnerText;
                decimal cenasdph = 0;
                decimal cenapozlave = 0;
                //vypocet ceny s DPH
                if (cena != null)
                {
                    cenasdph = decimal.Parse(cena.Replace(".", ","));
                }

                if (cislo != "")
                {
                    var product = db.products.Where(i => i.number == cislo).FirstOrDefault();
                    if (product != null)
                    {
                        product.stock = sklad;
                        product.price = cenasdph * decimal.Parse("1,2");

                        //ak je produkt v zlave
                        if (zlava != "0")
                        {
                            cenapozlave = product.price * (1 - (decimal.Parse(zlava.Replace(".", ",")) / 100));
                            product.discountprice = cenapozlave;
                        }
                        else
                        {
                            product.discountprice = null;
                        }

                        //odosleme emaily ak existuju watchdogy na dany produkt
                        var watchdogs = db.watchdog.Where(i => i.prod_id == product.id && i.sent == false).ToList();

                        foreach (var watchdog in watchdogs)
                        {

                            HelperController helper = new HelperController();
                            var slug = helper.ToUrlSlug(product.title);
                            var prodName = product.title;
                            var prodLink = "https://nahod.sk/detail-produktu/" + product.id + "/" + slug;

                            //odosleme email o uspesnom zaregistrovani
                            OrdersController oc = new OrdersController();
                            string body = createWatchdogEmailBody(prodName, prodLink);
                            oc.SendHtmlFormattedEmail("Požadovaný tovar je naskladnený!", body, watchdog.email, "watchdog", "");

                            watchdog.sent = true;
                        }

                        db.SaveChanges();
                    }
                    else
                    {
                        //poku3a sa najst hladany produkt medzi variantami
                        var productinvariants = db.variants.Where(i => i.number == cislo).FirstOrDefault();
                        if (productinvariants != null)
                        {
                            //var variantprice = cenasdph * decimal.Parse("1,2");

                            productinvariants.stock = sklad;
                            productinvariants.price = cenasdph;

                            //ak je produkt v zlave
                            if (zlava != "0")
                            {
                                cenapozlave = cenasdph * (1 - (decimal.Parse(zlava.Replace(".", ",")) / 100));
                                productinvariants.discountprice = cenapozlave;
                            }
                            else
                            {
                                productinvariants.discountprice = null;
                            }

                            db.SaveChanges();
                        }
                    }
                }
            }

            return "Oki";
        }
        static string RemoveInvalidXmlChars(string text)
        {
            if (text != null)
            {
                var validXmlChars = text.Where(ch => XmlConvert.IsXmlChar(ch)).ToArray();
                return new string(validXmlChars);
            }
            else
            {
                return "";
            }
        }

        private string createWatchdogEmailBody(string prodName, string prodLink)
        {

            string body = string.Empty;
            //using streamreader for reading my htmltemplate   
            using (StreamReader rea = new StreamReader(Server.MapPath("~/Views/Shared/WatchdogEmail.cshtml")))
            {
                body = rea.ReadToEnd();
            }

            var str = "Požadovaný tovar <a href='" + prodLink + "'>" + prodName + "</a> je na sklade.";

            body = body.Replace("{Text}", str);

            return body;
        }

        private string PaymentType(string payment)
        {
            switch (payment)
            {
                case "pay1":
                    return "V hotovosti pri osobnom odbere";
                case "pay2":
                    return "Kartou";
                case "pay3":
                    return "Bankovým prevodom";
                case "pay4":
                    return "Dobierkou";
                default:
                    return "";
            }

        }

        private string ShippingType(string shipping)
        {
            switch (shipping)
            {
                case "transfer1":
                    return "Kuriérska spoločnosť";
                case "transfer2":
                    return "Slovenská pošta";
                case "transfer3":
                    return "Osobný odber";
                default:
                    return "";
            }

        }

    }
}