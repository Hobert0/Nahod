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
        public JsonResult FetchProductsAdminFilter(string catId, string brandId, decimal priceFrom, decimal priceTo, bool isDiscount)
        {

            object result = null;
            if (catId != "" && brandId == "")
            {

                result = new
                {
                    data = isDiscount ? db.products.Where(i => (i.category.Contains("[" + catId + ",") || i.category.Contains("," + catId + ",") || i.category.Contains("," + catId + "]")) && i.deleted == false && i.price >= priceFrom && i.price <= priceTo && i.discountprice != null).ToList() : db.products.Where(i => (i.category.Contains("[" + catId + ",") || i.category.Contains("," + catId + ",") || i.category.Contains("," + catId + "]")) && i.deleted == false && i.price >= priceFrom && i.price <= priceTo).ToList(),
                    variants = db.variants.Where(x => x.deleted == false).Join(db.attributes, a => a.attribute_id, b => b.id, (a, b) => new VariantAttributesModel { Id = a.id, ProdId = a.prod_id, AttrName = b.name, AttrValue = a.value }).OrderByDescending(o => o.ProdId).ThenBy(o => o.AttrName).ToList(),
                    categories = db.categories.Where(x => x.deleted == false).ToList()
                };
            }
            else if (catId == "" && brandId != "")
            {
                result = new
                {
                    data = isDiscount ? db.products.Where(i => i.custom3 == brandId && i.deleted == false && i.price >= priceFrom && i.price <= priceTo && i.discountprice != null).ToList() : db.products.Where(i => i.custom3 == brandId && i.deleted == false && i.price >= priceFrom && i.price <= priceTo).ToList(),
                    variants = db.variants.Where(x => x.deleted == false).Join(db.attributes, a => a.attribute_id, b => b.id, (a, b) => new VariantAttributesModel { Id = a.id, ProdId = a.prod_id, AttrName = b.name, AttrValue = a.value }).OrderByDescending(o => o.ProdId).ThenBy(o => o.AttrName).ToList(),
                    categories = db.categories.Where(x => x.deleted == false).ToList()
                };
            }
            else if (catId != "" && brandId != "")
            {
                result = new
                {
                    data = isDiscount ? db.products.Where(i => i.custom3 == brandId && (i.category.Contains("[" + catId + ",") || i.category.Contains("," + catId + ",") || i.category.Contains("," + catId + "]")) && i.deleted == false && i.price >= priceFrom && i.price <= priceTo && i.discountprice != null).ToList() : db.products.Where(i => i.custom3 == brandId && (i.category.Contains("[" + catId + ",") || i.category.Contains("," + catId + ",") || i.category.Contains("," + catId + "]")) && i.deleted == false && i.price >= priceFrom && i.price <= priceTo).ToList(),
                    variants = db.variants.Where(x => x.deleted == false).Join(db.attributes, a => a.attribute_id, b => b.id, (a, b) => new VariantAttributesModel { Id = a.id, ProdId = a.prod_id, AttrName = b.name, AttrValue = a.value }).OrderByDescending(o => o.ProdId).ThenBy(o => o.AttrName).ToList(),
                    categories = db.categories.Where(x => x.deleted == false).ToList()
                };
            }
            else
            {
                result = new
                {
                    data = isDiscount ? db.products.Where(x => x.deleted == false && x.price >= priceFrom && x.price <= priceTo && x.discountprice != null).ToList() : db.products.Where(x => x.deleted == false && x.price >= priceFrom && x.price <= priceTo).ToList(),
                    variants = db.variants.Where(x => x.deleted == false).Join(db.attributes, a => a.attribute_id, b => b.id, (a, b) => new VariantAttributesModel { Id = a.id, ProdId = a.prod_id, AttrName = b.name, AttrValue = a.value }).OrderByDescending(o => o.ProdId).ThenBy(o => o.AttrName).ToList(),
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
                case "recommended":
                    product.recommended = bool.Parse(value);
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
                var topcatName = db.categories.Where(i => i.slug == catslug).First().name;
                id = db.categories.Where(i => i.slug == subslug && i.maincat == topcatName).First().id;
            }
            else if (subslug2 != null && subslug3 == null && catslug != "novinky" && catslug != "zlavy")
            {
                var topcatName = db.categories.Where(i => i.slug == catslug).First().name;
                var topcat2Name = db.categories.Where(i => i.slug == subslug).First().name;
                id = db.categories.Where(i => i.slug == subslug2 && i.maincat == topcatName && i.topcat == topcat2Name).First().id;
            }
            else if (subslug3 != null && catslug != "novinky" && catslug != "zlavy")
            {
                var maincatName = db.categories.Where(i => i.slug == catslug).First().name;
                var topcatName = db.categories.Where(i => i.slug == subslug).First().name;
                var topcat2Name = db.categories.Where(i => i.slug == subslug2).First().name;

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

                model.ProductModel = products.ToList();
            }
            else if (catslug == "novinky")
            {
                model.ProductModel = db.products.OrderByDescending(x => x.id).ToList();
            }
            else if (catslug == "zlavy")
            {
                model.ProductModel = db.products.ToList().Where(c => c.discountprice != null).OrderByDescending(x => x.id);
            }
            else
            {
                var products = db.products.Where(c => c.category == id.ToString());
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
                model.ProductModel = db.products.Where(i => i.custom3 == brandID && (i.category.Contains("[" + catId + ",") || i.category.Contains("," + catId + ",") || i.category.Contains("," + catId + "]"))).OrderByDescending(x => x.id).ToList();
            }
            else if (catSlug1 != null && catSlug2 != null)
            {

                var catId = db.categories.Where(i => i.slug == catSlug2).First().id.ToString();
                model.ProductModel = db.products.Where(i => i.custom3 == brandID && (i.category.Contains("[" + catId + ",") || i.category.Contains("," + catId + ",") || i.category.Contains("," + catId + "]"))).OrderByDescending(x => x.id).ToList();
            }
            else
            {
                model.ProductModel = db.products.Where(c => c.custom3 == brandID).OrderByDescending(x => x.id).ToList();
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
                model.ProductModel = db.products.Where(i => (i.type.Contains("[" + typeID + ",") || i.type.Contains("," + typeID + ",") || i.type.Contains("," + typeID + "]")) && (i.category.Contains("[" + catId + ",") || i.category.Contains("," + catId + ",") || i.category.Contains("," + catId + "]"))).OrderByDescending(x => x.id).ToList();
            }
            else if (catSlug1 != null && catSlug2 != null)
            {

                var catId = db.categories.Where(i => i.slug == catSlug2).First().id.ToString();
                model.ProductModel = db.products.Where(i => (i.type.Contains("[" + typeID + ",") || i.type.Contains("," + typeID + ",") || i.type.Contains("," + typeID + "]")) && (i.category.Contains("[" + catId + ",") || i.category.Contains("," + catId + ",") || i.category.Contains("," + catId + "]"))).OrderByDescending(x => x.id).ToList();
            }
            else
            {
                model.ProductModel = db.products.Where(c => (c.type.Contains("[" + typeID + ",") || c.type.Contains("," + typeID + ",") || c.type.Contains("," + typeID + "]"))).OrderByDescending(x => x.id).ToList();
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
            var filemane = DateTime.Now.Ticks.ToString() + ".xml";

            var order = db.orders.FirstOrDefault();

    
                objednavkaType obj = new objednavkaType
                {
                    //obj.CasVystave = DateTime.Parse(order.date,CultureInfo.InvariantCulture);
                    DruhDopravy = order.shipping,
                    Poznamka = order.comment,
                    TypTransakce = order.payment,
                    DCislo = decimal.Parse(order.ordernumber),
                };
        
        XmlSerializer serializer = new XmlSerializer(typeof(objednavkaType));
            using (StreamWriter writer = new StreamWriter(Server.MapPath("~/export/"+ filemane)))
            {
                serializer.Serialize(writer, obj);
            }

            return filemane;            
        }

        [Route("importSKladS3"), EnableCors(origins: "*", headers: "*", methods: "*")]
public string ImportMonS3(string ExpZasobyName)
{
    var path = "http://nahod.sk.amber.globenet.cz/import/" + ExpZasobyName;
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
    doc1.Load("http://nahod.sk.amber.globenet.cz/import/" + ExpZasobyName);
    XmlElement root = doc1.DocumentElement;
    XmlNodeList nodes = root.SelectNodes("/MoneyData/SeznamZasoba/Zasoba");

    // XmlNodeList nodes = oNode.SelectNodes("Katalog");

    foreach (XmlNode node in nodes)
    {
        var sklad = node.SelectSingleNode("StavZasoby/Zasoba").InnerText;
        var cislo = node.SelectSingleNode("KmKarta/Katalog").InnerText;
        var cena = node.SelectSingleNode("PC/Cena1/Cena").InnerText;
        var zlava = node.SelectSingleNode("Sleva").InnerText;
        decimal cenasdph = 0;
        decimal cenapozlave = 0;
        //vypocet ceny s DPH
        if (cena != null)
        {
            cenasdph = decimal.Parse(cena.Replace(".", ","));
        }

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

            db.SaveChanges();
        }
        else
        {
            //poku3a sa najst hladany produkt medzi variantami
            var productinvariants = db.variants.Where(i => i.number == cislo).FirstOrDefault();
            if (productinvariants != null)
            {
                var variantprice = cenasdph * decimal.Parse("1,2");

                productinvariants.stock = sklad;
                productinvariants.price = variantprice;

                //ak je produkt v zlave
                if (zlava != "0")
                {
                    cenapozlave = variantprice * (1 - (decimal.Parse(zlava.Replace(".", ",")) / 100));
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

    return "Oki";
}

    }
}