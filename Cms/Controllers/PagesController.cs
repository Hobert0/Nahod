using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using Cms.Models;

namespace Cms.Controllers
{
    public class PagesController : Controller
    {
        // GET: Pages
        Entities db = new Entities();

        public ActionResult DeletePage(int? id, bool confirm)
        {
            var data = db.pages.Find(id);
            if (true)
            {
                ViewBag.Status = true;
                db.pages.Remove(data);
                db.SaveChanges();
            }
            else { ViewBag.Status = false; }


            return RedirectToAction("Pages", "Admin");
        }

        [Route("editovat-stranku/{id}")]
        public ActionResult EditPage(int id)
        {
            if (Request.Cookies["username"] != null && Request.Cookies["role"].Value == "0")
            {
                var pages = db.pages.Where(item => item.id == id).ToList();
                PagesModel model = new PagesModel();
                foreach (var page in pages)
                {
                    model.Id = page.id;
                    model.Title = page.title;
                    model.Content = page.content;
                }
                return View(model);
            }
            else
            {
                return RedirectToAction("Admin", "Admin");
            }
        }

        [HttpPost]
        public ActionResult Edit(PagesModel model)
        {
            if (Request.Cookies["username"] != null && Request.Cookies["role"].Value == "0")
            {
                var data = db.pages.Single(i => i.id == model.Id);
                data.content = model.Content ?? "";
                data.title = model.Title;
                data.date = DateTime.Now.ToString();

                db.SaveChanges();
                return RedirectToAction("EditPage", new { model.Id });
            }
            else
            {
                return RedirectToAction("Admin", "Admin");
            }
        }
    }
}