using Cms.Models;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Threading.Tasks;
using System.Web;
using System.Web.Helpers;
using System.Web.Mvc;

namespace Cms.Controllers
{
    public class BlogController : Controller
    {
        // GET: Blog
        Entities db = new Entities();

        [Route("admin-blog")]
        public ActionResult Blog()
        {
            if (Session["username"] != null && Session["role"].ToString() == "0")
            {
                return View(db.blog.OrderByDescending(a => a.id).ToList());
            }
            else { return RedirectToAction("Admin"); }
        }

        [Route("blg/pridat-clanok")]
        public ActionResult AddArticle()
        {
            if (Session["username"] != null)
            {
                return View();
            }
            else { return RedirectToAction("Admin", "Admin"); }
        }

        public ActionResult DeleteArticle(int? id, bool confirm)
        {
        var data = db.blog.Find(id);
        if (true)
        {
            ViewBag.Status = true;
            db.blog.Remove(data);
            db.SaveChanges();
        }
        else { ViewBag.Status = false; }


        return RedirectToAction("Blog", "Blog");
    }

    [Route("editovat-blog/{id}")]
    public ActionResult EditArticle(int id)
    {
        if (Session["username"] != null)
        {
            var pages = db.blog.Where(item => item.id == id).ToList();
            BlogModel model = new BlogModel();
            foreach (var page in pages)
            {
                model.Id = page.id;
                model.Title = page.title;
                model.Content = page.content;
                    model.Excerpt = page.excerpt;
                    model.Gallery = page.gallery;
                    model.Slug = page.slug;
                    model.Image = page.image;
            }
            return View(model);
        }
        else
        {
            return RedirectToAction("Admin", "Admin");
        }
    }
        [HttpPost]
        public async Task<ActionResult> Add(BlogModel model)
        {
            blog o = new blog();
            var nazovSuboru = string.Empty;

            HttpPostedFileBase[] subor = model.TitleImage;
            if (model.TitleImage[0] != null)
            {
                foreach (HttpPostedFileBase file in subor)
                {
                    nazovSuboru = Path.GetFileName(file.FileName);
                }
            }
            var ulozObrazok = DateTime.Now.Date.ToString("dd.MM.yyyy") + "/" + DateTime.Now.ToString("HHmmss") + "/";

            if (nazovSuboru == "")
            {
                nazovSuboru = "avatar_blog.jpg";
            }


            o.title = model.Title;
            o.image = ulozObrazok + nazovSuboru;
         
            o.content = model.Content;
            o.excerpt = model.Excerpt;
            o.slug = model.Slug;
            o.date = DateTime.Now.ToString();
            o.gallery = ulozObrazok + "gallery/" ?? "";

            db.blog.Add(o);
            db.SaveChanges();

            if (model.TitleImage[0] != null)
            {
                await UploadFiles(model.TitleImage, ulozObrazok);
                await UploadFiles(model.ImageGallery, o.gallery);
            }
            else
            {
                var sourcePath = HttpContext.Server.MapPath("~/Uploads/avatar_product.jpg");
                var destinationPath = HttpContext.Server.MapPath("~/Uploads/" + o.image);
                var miestoUlozenia = "~/Uploads/" + ulozObrazok;
                var path = Directory.CreateDirectory(Server.MapPath(miestoUlozenia));
                if (System.IO.File.Exists(sourcePath))
                {
                    System.IO.File.Copy(sourcePath, destinationPath);
                }
                await UploadFiles(model.ImageGallery, o.gallery);

            }
            TempData["IsValid"] = true;
            ViewBag.IsValid = true;
            return RedirectToAction("Blog", "Blog");
        }
        [HttpPost, Route("blog/editovat-clanok/{id}")]
        public ActionResult EditBlog(BlogModel model)
    {
        if (Session["username"] != null)
        {
            var data = db.blog.Single(i => i.id == model.Id);
            data.content = model.Content ?? "";
            data.title = model.Title;
                data.excerpt = model.Excerpt;
                data.slug = model.Slug;
                data.id = model.Id;
            data.date = DateTime.Now.ToString();

            db.SaveChanges();
            return RedirectToAction("EditArticle", new { model.Id });
        }
        else
        {
            return RedirectToAction("Admin", "Admin");
        }
    }
        [HttpPost]
        public async Task<ActionResult> UploadFiles(HttpPostedFileBase[] files, string foto)
        {
            //Ensure model state is valid  
            //iterating through multiple file collection   
            var miestoUlozenia = "~/Uploads/" + foto;
            var path = Directory.CreateDirectory(Server.MapPath(miestoUlozenia));


            foreach (HttpPostedFileBase file in files)
            {

                //Checking file is available to save.  
                if (file != null)
                {
                    var InputFileName = Path.GetFileName(file.FileName);
                    var ServerSavePath = Path.Combine(Server.MapPath(miestoUlozenia) + InputFileName);

                    byte[] fileByte;
                    using (var reader = new BinaryReader(file.InputStream))
                    {
                        fileByte = reader.ReadBytes(file.ContentLength);
                    }
                    WebImage img = new WebImage(fileByte);
                    if (img.Width > 1000)
                    {
                        img.Resize(1000 + 1, 1000 + 1, true).Crop(1, 1);
                    }
                    img.Save(ServerSavePath);
                    //assigning file uploaded status to ViewBag for showing message to user.  
                    ViewBag.UploadStatus = files.Count().ToString() + " files uploaded successfully.";
                }

            }
            // ReSharper disable once Mvc.ViewNotResolved
            return View();
        }
        [HttpPost]
        public ActionResult UploadImages(BlogModel model)
        {
            //Zmena fotiek v galerii
            var id = model.Id;
            if (model.ImageGallery != null)
            {
                HttpPostedFileBase[] files = model.ImageGallery;
                //iterating through multiple file collection   
                var miestoUlozenia = "~/Uploads/" + model.Gallery;
                var path = Directory.CreateDirectory(Server.MapPath(miestoUlozenia));

                foreach (HttpPostedFileBase file in files)
                {

                    //Checking file is available to save.  
                    if (file != null)
                    {
                        var InputFileName = Path.GetFileName(file.FileName);
                        var ServerSavePath = Path.Combine(Server.MapPath(miestoUlozenia) + InputFileName);
                        //Save file to server folder  
                        byte[] fileByte;
                        using (var reader = new BinaryReader(file.InputStream))
                        {
                            fileByte = reader.ReadBytes(file.ContentLength);
                        }
                        WebImage img = new WebImage(fileByte);
                        if (img.Width > 1000)
                        {
                            img.Resize(1000 + 1, 1000 + 1, true).Crop(1, 1);
                        }
                        img.Save(ServerSavePath);
                        //assigning file uploaded status to ViewBag for showing message to user.  
                        ViewBag.UploadStatus = files.Count().ToString() + " files uploaded successfully.";
                    }

                }
                return RedirectToAction("EditArticle", new { id });
            }
            //Zmena titulnej fotky
            else if (model.TitleImage != null)
            {
                HttpPostedFileBase[] subor = model.TitleImage;
                var miestoUlozenia = "~/Uploads/" + model.Image;
                miestoUlozenia = miestoUlozenia.Substring(0, miestoUlozenia.LastIndexOf("/") + 1);
                string fullPath = Request.MapPath(miestoUlozenia);

                if (System.IO.File.Exists(fullPath))
                {
                    System.IO.File.Delete(fullPath);
                }

                foreach (HttpPostedFileBase file in subor)
                {

                    //Checking file is available to save.  
                    if (file != null)
                    {
                        var InputFileName = Path.GetFileName(file.FileName);
                        var ServerSavePath = Path.Combine(Server.MapPath(miestoUlozenia + InputFileName));
                        //Save file to server folder  
                        byte[] fileByte;
                        using (var reader = new BinaryReader(file.InputStream))
                        {
                            fileByte = reader.ReadBytes(file.ContentLength);
                        }
                        WebImage img = new WebImage(fileByte);
                        if (img.Width > 1000)
                        {
                            img.Resize(1000 + 1, 1000 + 1, true).Crop(1, 1);
                        }
                        img.Save(ServerSavePath);

                        var isTheSameImage = model.Image.Substring(0, model.Image.LastIndexOf("/") + 1) + InputFileName;
                        if (model.Image != isTheSameImage)
                        {

                            var data = db.blog.Single(i => i.id == model.Id);
                            data.image = isTheSameImage;
                            db.SaveChanges();
                        }
                        //assigning file uploaded status to ViewBag for showing message to user.  
                        ViewBag.UploadStatus = subor.Count().ToString() + " files uploaded successfully.";
                    }

                }

            }
            else { }
            return RedirectToAction("EditArticle", new { id });
        }


        public ActionResult DeletePicture(string url, int id)
        {
            string fullPath = Request.MapPath(url);

            if (System.IO.File.Exists(fullPath))
            {
                System.IO.File.Delete(fullPath);
            }
            return Redirect(Url.Content("~/editovat-blog/" + id) + "#galleria");
        }
    }

}