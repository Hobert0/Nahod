using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Threading.Tasks;
using System.Web;
using System.Web.Helpers;
using System.Web.Mvc;
using Cms.Models;

namespace Cms.Controllers
{
    public class SettingsController : Controller
    {
        Entities db = new Entities();
        [Route("nastavenia/e-shop")]
        public ActionResult EshopSettings()
        {
            if (Request.Cookies["username"].Value != null && Request.Cookies["role"].Value == "0")
            {
                var id = 1;
                var eshopsettings = db.e_settings.Where(item => item.id == id).ToList();
                EsettingsModel model = new EsettingsModel();
                foreach (var set in eshopsettings)
                {
                    model.Id = set.id;
                    model.Companyname = set.companyname;
                    model.Address = set.address;
                    model.City = set.city;
                    model.State = set.state;
                    model.Ico = set.ico;
                    model.Dic = set.dic;
                    model.Icdph = set.icdph;
                    model.Accountnumber = set.accountnumber;
                    model.Transfer1 = set.transfer1;
                    model.Transfer2 = set.transfer2;
                    model.Transfer3 = set.transfer3;
                    model.Transfer4 = set.transfer4;
                    model.Transfer5 = set.transfer5;
                    model.Pay1 = set.pay1;
                    model.Pay1Enbl = set.pay1_enbl;
                    model.Pay2 = set.pay2;
                    model.Pay2Enbl = set.pay2_enbl;
                    model.Pay3 = set.pay3;
                    model.Pay3Enbl = set.pay3_enbl;
                    model.Pay4 = set.pay4;
                    model.Pay4Enbl = set.pay4_enbl;
                    model.Transfer1Enbl = set.transfer1_enbl;
                    model.Transfer2Enbl = set.transfer2_enbl;
                    model.Transfer3Enbl = set.transfer3_enbl;
                    model.Transfer4Enbl = set.transfer4_enbl;
                    model.Custom = set.custom;
                    model.DeliveryPrice1 = set.deliveryprice1;
                    model.DeliveryPrice2 = set.deliveryprice2;
                    model.DeliveryPrice3 = set.deliveryprice3;
                    model.VopPdf = set.vopPdf;
                    model.ReturnPdf = set.returnPdf;
                }
                return View(model);
            }
            else
            {
                return RedirectToAction("Admin", "Admin");
            }
        }

        // GET: Settings

        [HttpPost]
        public async Task<ActionResult> PageSettings(SettingsModel model)
        {
            var o = db.settings.Single(i => i.id == 1);

            o.description = model.Description ?? "";
            o.email = model.Email;

            if (model.Indexed)
            {
                o.indexed = 1;
            }
            else
            {
                o.indexed = 0;
            }
            
            o.googleanalyt = model.Googleanalyt;
            o.facebook = model.Facebook;
            o.instagram = model.Instagram;
            o.adress = model.Adress;
            o.psc = model.Psc;
            o.city = model.City;
            o.phone = model.Phone;

            db.SaveChanges();

            return RedirectToAction("Settings", "Admin");
        }

        [HttpPost]
        public async Task<ActionResult> SaveEshopSettings(EsettingsModel model)
        {

            var nazovSuboruVop = string.Empty;
            if (model.VopPdfImage != null)
            {
                HttpPostedFileBase[] subor = model.VopPdfImage;
                if (model.VopPdfImage[0] != null)
                {
                    foreach (HttpPostedFileBase file in subor)
                    {
                        nazovSuboruVop = Path.GetFileName(file.FileName);
                    }
                }
            }

            var ulozObrazokVop = DateTime.Now.Date.ToString("dd.MM.yyyy") + "/" + DateTime.Now.ToString("HHmmss") + "/";

            var nazovSuboruReturn = string.Empty;
            if (model.ReturnPdfImage != null)
            {
                HttpPostedFileBase[] subor = model.ReturnPdfImage;
                if (model.ReturnPdfImage[0] != null)
                {
                    foreach (HttpPostedFileBase file in subor)
                    {
                        nazovSuboruReturn = Path.GetFileName(file.FileName);
                    }
                }
            }

            var ulozObrazokReturn = DateTime.Now.Date.ToString("dd.MM.yyyy") + "/" + DateTime.Now.ToString("HHmmss") + "/";

            var nazovSuboruCancel = string.Empty;
            if (model.CancelPdfImage != null)
            {
                HttpPostedFileBase[] subor = model.CancelPdfImage;
                if (model.CancelPdfImage[0] != null)
                {
                    foreach (HttpPostedFileBase file in subor)
                    {
                        nazovSuboruCancel = Path.GetFileName(file.FileName);
                    }
                }
            }

            var ulozObrazokCancel = DateTime.Now.Date.ToString("dd.MM.yyyy") + "/" + DateTime.Now.ToString("HHmmss") + "/";

            var o = db.e_settings.Single(i => i.id == 1);

            if (model.Transfer1 != null) { model.Transfer1 = model.Transfer1.Replace(",", "."); }
            if (model.Transfer2 != null) { model.Transfer2 = model.Transfer2.Replace(",", "."); }
            if (model.Transfer3 != null) { model.Transfer3 = model.Transfer3.Replace(",", "."); }
            if (model.Transfer4 != null) { model.Transfer4 = model.Transfer4.Replace(",", "."); }
            if (model.Transfer5 != null) { model.Transfer5 = model.Transfer5.Replace(",", "."); }
            if (model.DeliveryPrice1 != null) { model.DeliveryPrice1 = model.DeliveryPrice1.Replace(",", "."); }
            if (model.DeliveryPrice2 != null) { model.DeliveryPrice1 = model.DeliveryPrice1.Replace(",", "."); }
            if (model.DeliveryPrice3 != null) { model.DeliveryPrice1 = model.DeliveryPrice1.Replace(",", "."); }

            if (model.Pay1 != null) { model.Pay1 = model.Pay1.Replace(",", "."); }
            if (model.Pay2 != null) { model.Pay2 = model.Pay2.Replace(",", "."); }
            if (model.Pay3 != null) { model.Pay3 = model.Pay3.Replace(",", "."); }
            if (model.Pay4 != null) { model.Pay4 = model.Pay4.Replace(",", "."); }

            o.companyname = model.Companyname;
            o.address = model.Address;
            o.city = model.City;
            o.state = model.State;
            o.ico = model.Ico;
            o.dic = model.Dic;
            o.icdph = model.Icdph;
            o.accountnumber = model.Accountnumber;
            o.transfer1 = model.Transfer1;
            o.transfer2 = model.Transfer2;
            o.transfer3 = model.Transfer3;
            o.transfer4 = model.Transfer4;
            o.transfer5 = model.Transfer5;
            o.pay1 = model.Pay1;
            o.pay1_enbl = model.Pay1Enbl;
            o.pay2 = model.Pay2;
            o.pay2_enbl = model.Pay2Enbl;
            o.pay3 = model.Pay3;
            o.pay3_enbl = model.Pay3Enbl;
            o.pay4 = model.Pay4;
            o.pay4_enbl = model.Pay4Enbl;
            o.transfer1_enbl = model.Transfer1Enbl;
            o.transfer2_enbl = model.Transfer2Enbl;
            o.transfer3_enbl = model.Transfer3Enbl;
            o.transfer4_enbl = model.Transfer4Enbl;
            o.custom = model.Custom;
            o.deliveryprice1 = model.DeliveryPrice1;
            o.deliveryprice2 = model.DeliveryPrice2;
            o.deliveryprice3 = model.DeliveryPrice3;

            if (model.VopPdfImage[0] != null)
            {
                o.vopPdf = ulozObrazokVop + nazovSuboruVop;
            }

            if (model.ReturnPdfImage[0] != null)
            {
                o.returnPdf = ulozObrazokReturn + nazovSuboruReturn;
            }

            if (model.CancelPdfImage[0] != null)
            {
                o.cancelPdf = ulozObrazokCancel + nazovSuboruCancel;
            }

            db.SaveChanges();

            if (model.VopPdfImage != null)
            {
                if (model.VopPdfImage[0] != null)
                {
                    await UploadFiles(model.VopPdfImage, ulozObrazokVop);
                }
                
            }

            if (model.ReturnPdfImage != null)
            {
                if (model.ReturnPdfImage[0] != null)
                {
                    await UploadFiles(model.ReturnPdfImage, ulozObrazokReturn);
                }

            }

            if (model.CancelPdfImage != null)
            {
                if (model.CancelPdfImage[0] != null)
                {
                    await UploadFiles(model.CancelPdfImage, ulozObrazokCancel);
                }

            }

            return RedirectToAction("EshopSettings");
        }
        /*SLIDESHOW SETTINGS*/
        [Route("nastavenia/slideshow")]
        public ActionResult Slideshow()
        {
            if (Request.Cookies["username"].Value != null && Request.Cookies["role"].Value == "0")
            {
                var slideshows = db.slideshow.Select(a => new SlideshowModel
                {
                    Id = a.id,
                    Title = a.title,
                    Page = a.page,
                    Image = a.image,
                    Url = a.url,
                    Active = a.active
                }).ToList();


                return View(slideshows);
            }
            else
            {
                return RedirectToAction("Admin", "Admin");
            }
        }
        [Route("nastavenia/slideshow/edit/{stranka}")]
        public ActionResult EditSlideshow(string stranka)
        {
            if (Request.Cookies["username"].Value != null && Request.Cookies["role"].Value == "0")
            {
                SlideshowModel slideModel = new SlideshowModel();
                var model = db.slideshow.Where(item => item.page == stranka).Select(a => new SlideshowModel
                {
                    Id = a.id,
                    Title = a.title,
                    Page = a.page,
                    Image = a.image,
                    Url = a.url,
                    Header = a.header,
                    Text = a.text,
                    Subtext = a.subtext,
                    Button = a.button
                }).ToList();

                foreach (var slide in model)
                {
                    slideModel.Id= slide.Id;
                    slideModel.Title = slide.Title;
                    slideModel.Page = slide.Page;
                    slideModel.Url = slide.Url;
                    slideModel.Header = slide.Header;
                    slideModel.Text = slide.Text;
                    slideModel.Subtext = slide.Subtext;
                    slideModel.Button = slide.Button;
                    slideModel.Image = slide.Image;
                }
                return View(slideModel);
            }
            else
            {
                return RedirectToAction("Admin", "Admin");
            }
        }

        public ActionResult ActivateSlideshow(string stranka)
        {
            var data = db.slideshow.Where(i => i.page == stranka).ToList();
            foreach (var item in data)
            {
                if (item.active == 0) { item.active = 1; }
                else { item.active = 0; }
            }

            db.SaveChanges();

            return RedirectToAction("Slideshow");
        }

        public ActionResult DeleteSlide(int id, string url, string page)
        {
            string fullPath = Request.MapPath(url);
            var data = db.slideshow.Find(id);
            if (System.IO.File.Exists(fullPath))
            {
                System.IO.File.Delete(fullPath);
                ViewBag.Status = true;
                db.slideshow.Remove(data);
                db.SaveChanges();
            }
            return RedirectToAction("EditSlideshow", new { stranka = page });
        }

        [HttpPost]
        public ActionResult AddSlideshowImage(SlideshowModel model)
        {
            slideshow o = new slideshow();
            var fileName = string.Empty;

            HttpPostedFileBase[] subor = model.TitleImage;
            foreach (HttpPostedFileBase file in subor)
            {
                fileName = Path.GetFileName(file.FileName);
            }
            var saveImage = model.Page + "/";

            o.title = model.Title;
            o.image = saveImage + fileName;
            o.url = model.Url ?? "";
            o.header = model.Header;
            o.text = model.Text;
            o.subtext = model.Subtext;
            o.button = model.Button;
            o.page= model.Page;
            o.active = 1;

            db.slideshow.Add(o);
            db.SaveChanges();

            UploadSlideshowFiles(model.TitleImage, saveImage);


            TempData["IsValid"] = true;
            ViewBag.IsValid = true;
            return RedirectToAction("EditSlideshow", new { stranka = model.Page });
        }

        [HttpPost]
        public async Task<ActionResult> UploadSlideshowFiles(HttpPostedFileBase[] files, string foto)
        {

            //Ensure model state is valid  
            //iterating through multiple file collection   
            var miestoUlozenia = "~/Uploads/slideshow/" + foto;
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
                    if (img.Width > 3840)
                    {
                        img.Resize(3840 + 1, 3840 + 1, true).Crop(1, 1);
                    }
                    img.Save(ServerSavePath);
                    //assigning file uploaded status to ViewBag for showing message to user.  
                    ViewBag.UploadStatus = files.Count().ToString() + " files uploaded successfully.";
                }

            }
            // ReSharper disable once Mvc.ViewNotResolved
            return View();
        }
        /*SLIDESHOW SETTINGS - END */

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

                    file.SaveAs(ServerSavePath);

                }

            }
            // ReSharper disable once Mvc.ViewNotResolved
            return View();
        }
    }
}