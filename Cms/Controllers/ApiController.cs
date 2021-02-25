﻿using Cms.Models;
using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using System.Net.Http;
using System.Web.Http;
using System.Web.Http.Cors;


namespace Cms.Controllers
{
    public class ApiController : Controller
    {
        Entities db = new Entities();

        // GET: Api
        [EnableCors(origins: "*", headers: "*", methods: "*")]
        public JsonResult FetchProducts(string catslug, string subslug, string subslug2, string subslug3, bool brand, bool searchparam)
        {
            object result = null;

            if (brand)
            {
                result = new { data = FetchByBrand(catslug).ProductModel };
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

                result = new { data = SortByBrand(topcatId, id, catslug).ProductModel };
            }            

            return Json(result, JsonRequestBehavior.AllowGet);
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
                var Sql = "select * from `products` where category = " + id + "";

                foreach (var cats in topcatId)
                {
                    Sql += " or category = " + cats + "";
                }

                var products = db.Database.SqlQuery<products>(Sql);
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
            else if (catslug == "novinky")
            {
                model.ProductModel = db.products.OrderByDescending(x => x.id).ToList();
            }
            else if (catslug == "zlavy")
            {
                model.ProductModel = db.products.ToList().Where(c => c.discountprice != null && c.discountprice != "").OrderByDescending(x => x.id);
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

        private MultipleIndexModel FetchByBrand(string brand)
        {
            var categoryID = db.brands.Where(i => i.slug == brand).First().id;

            var model = new MultipleIndexModel();
            model.ProductModel = db.products.ToList().Where(c => c.custom3 == categoryID.ToString()).OrderByDescending(x => x.id);

            return model;
        }
       
    }
}