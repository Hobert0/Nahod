using Cms.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;
using System.Web;
using System.Web.Mvc;

namespace Cms.Controllers
{
    public class HelperController : Controller
    {
        // GET: Helper
        Entities db = new Entities();


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

        public ViewResult Error()
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
            ViewData["Homepage"] = "false";

            return View(model);
        }
    }

    
}