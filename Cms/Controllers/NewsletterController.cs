using Cms.Models;
using Newtonsoft.Json.Linq;
using PagedList;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.IO;
using System.Linq;
using System.Net;
using System.Net.Mail;
using System.Threading.Tasks;
using System.Web;
using System.Web.Mvc;

namespace Cms.Controllers
{
    public class NewsletterController : Controller
    {

        Entities db = new Entities();

        [Route("newsletter")]
        public ActionResult Newsletter(string sortOrder, string currrentFilter, string searchString, int? page)
        {
            if (Session["username"] != null && Session["role"].ToString() == "0")
            {
                ViewBag.CurrentSort = sortOrder;
                if (searchString != null)
                {
                    page = 1;
                }
                else
                {
                    searchString = currrentFilter;
                }
                ViewBag.CureentFilter = searchString;

                int pageSize = 12;
                int pageNumber = (page ?? 1);

                NewsletterModel newMod = new NewsletterModel();
                var model = new MultipleIndexModel();
                model.AllNewslettersPaged = db.newsletter.ToList().OrderBy(x => Guid.NewGuid()).ToPagedList(pageNumber, pageSize);

                return View(model);
            }
            else
            {
                return RedirectToAction("Admin");
            }

        }

        [Route("novynewsletter")]
        public ActionResult AddNewsletter()
        {
            if (Session["username"] != null && Session["role"].ToString() == "0")
            {
                return View();
            }
            else
            {
                return RedirectToAction("Admin");
            }
        }

        [HttpPost, Route("novynewsletter")]
        public async Task<ActionResult> AddNewsletter(MultipleIndexModel model)
        {
            newsletter n = new newsletter();

            n.subject = model.NewsletterModel.Subject;
            n.body = model.NewsletterModel.Body;

            db.newsletter.Add(n);
            db.SaveChanges();

            return RedirectToAction("Newsletter", "Newsletter");
        }

        public ActionResult DeleteNewsletter(int? newsletterId, bool confirm)
        {
            var data = db.newsletter.Find(newsletterId);
            if (true)
            {
                ViewBag.Status = true;
                db.newsletter.Remove(data);

                db.SaveChanges();
            }
            else { ViewBag.Status = false; }

            return RedirectToAction("Newsletter", "Newsletter");
        }
        [Route("editovat-newsletter/{newsletterId}")]
        public ActionResult EditNewsletter(int? newsletterId)
        {
            if (Session["username"] != null && Session["role"].ToString() == "0")
            {
                var newsletters = db.newsletter.Where(item => item.id == newsletterId).ToList();
                NewsletterModel model = new NewsletterModel();
                foreach (var newsletter in newsletters)
                {
                    model.Id = newsletter.id;
                    model.Subject = newsletter.subject;
                    model.Body = newsletter.body;
                }

                return View(model);
            }
            else
            {
                return RedirectToAction("Admin", "Admin");
            }
        }

        [HttpPost]
        public async Task<ActionResult> EditNewsletterInDB(NewsletterModel model)
        { 
            if (Session["username"] != null && Session["role"].ToString() == "0")
            {
                var data = db.newsletter.Single(i => i.id == model.Id);
                data.subject = model.Subject ?? "";
                data.body = model.Body ?? "";

                db.SaveChanges();
                return RedirectToAction("Newsletter", "Newsletter");
            }
            else
            {
                return RedirectToAction("Admin", "Admin");
            }
        }

        [Route("send-newsletter/{newsletterId}")]
        public ActionResult SendNewsletter(string sortOrder, string currrentFilter, string searchString, int? page, int? newsletterId)
        {
            if (Session["username"] != null && Session["role"].ToString() == "0")
            {
                ViewBag.CurrentSort = sortOrder;
                if (searchString != null)
                {
                    page = 1;
                }
                else
                {
                    searchString = currrentFilter;
                }
                ViewBag.CureentFilter = searchString;


                MultipleIndexModel model = new MultipleIndexModel();

                model.AllUsers = db.users.Where(i => i.role == 1).ToList();
                model.AllUsersMetaModel = db.usersmeta.Where(n => n.news == true).ToList();
                //model.AllUsersMetaModel = db.usersmeta.ToList();
                model.AllNewslettersModel = db.newsletter.Where(k => k.id == newsletterId).ToList();

                return View(model);
            }
            else {
                return RedirectToAction("Admin", "Admin");
            }
        }

        [Route("send-newsletter-all/{id}")]
        public ActionResult SendAllNewsletter(int id)
        {
            if (Session["username"] != null && Session["role"].ToString() == "0")
            {
                var allUsersNewsTrue = db.usersmeta.Where(i => i.news == true).ToList();
            var template = db.newsletter.Where(t => t.id == id).ToList();
            var settings = db.settings.SingleOrDefault().email;

            var subject = "";
            var body = "";

            foreach (var item in template)
            {
                subject = item.subject;
                body = item.body;
            }

            foreach(var singleUserNewsTrue in allUsersNewsTrue)
            {

                MailMessage mailMessage = new MailMessage();

                mailMessage.From = new MailAddress(settings);
                mailMessage.Subject = subject;
                mailMessage.Body = body;
                mailMessage.IsBodyHtml = true;
            
                mailMessage.To.Add(new MailAddress(singleUserNewsTrue.email));

                SmtpClient smtp = new SmtpClient();

                smtp.Host = ConfigurationManager.AppSettings["Host"];

                smtp.EnableSsl = Convert.ToBoolean(ConfigurationManager.AppSettings["EnableSsl"]);

                System.Net.NetworkCredential NetworkCred = new System.Net.NetworkCredential();

                NetworkCred.UserName = ConfigurationManager.AppSettings["UserName"]; //reading from web.config  

                NetworkCred.Password = ConfigurationManager.AppSettings["Password"]; //reading from web.config  

                smtp.UseDefaultCredentials = true;

                smtp.Credentials = NetworkCred;

                smtp.Port = int.Parse(ConfigurationManager.AppSettings["Port"]); //reading from web.config  

                smtp.Send(mailMessage);

            }

            return RedirectToAction("Newsletter", "Newsletter");
            }
            else
            {
                return RedirectToAction("Admin", "Admin");
            }
        }

        [Route("send-newsletter-selected/{idOfTemplate}")]
        public ActionResult SendSelectedNewsletter(int idOfTemplate, List<string> methodParam)
        {
            if (Session["username"] != null && Session["role"].ToString() == "0")
            {

                var template = db.newsletter.Where(t => t.id == idOfTemplate).ToList();
            var settings = db.settings.SingleOrDefault().email;

            var subject = "";
            var body = "";

            foreach (var item in template)
            {
                subject = item.subject;
                body = item.body;
            }



            foreach (var singleUserNewsTrue in methodParam)
            {

                MailMessage mailMessage = new MailMessage();

                mailMessage.From = new MailAddress(settings);
                mailMessage.Subject = subject;
                mailMessage.Body = body;
                mailMessage.IsBodyHtml = true;

                mailMessage.To.Add(new MailAddress(singleUserNewsTrue));

                SmtpClient smtp = new SmtpClient();

                smtp.Host = ConfigurationManager.AppSettings["Host"];

                smtp.EnableSsl = Convert.ToBoolean(ConfigurationManager.AppSettings["EnableSsl"]);

                System.Net.NetworkCredential NetworkCred = new System.Net.NetworkCredential();

                NetworkCred.UserName = ConfigurationManager.AppSettings["UserName"]; //reading from web.config  

                NetworkCred.Password = ConfigurationManager.AppSettings["Password"]; //reading from web.config  

                smtp.UseDefaultCredentials = true;

                smtp.Credentials = NetworkCred;

                smtp.Port = int.Parse(ConfigurationManager.AppSettings["Port"]); //reading from web.config  

                smtp.Send(mailMessage);

            }

            return RedirectToAction("Newsletter", "Newsletter");
        }
            else {
                return RedirectToAction("Admin", "Admin");
    }
}

        [HttpPost]
        public async Task<ActionResult> Subscribe(MultipleIndexModel model)
        {
            //Validate Google recaptcha
            var response = Request["g-recaptcha-response"];
            string secretKey = "6LfAQx0bAAAAAAFaQvmwM-Q13RNOW0y5HOoanhcl";
            var client = new WebClient();
            var result = client.DownloadString(string.Format(
                "https://www.google.com/recaptcha/api/siteverify?secret={0}&response={1}", secretKey, response));
            var obj = JObject.Parse(result);
            var status = (bool)obj.SelectToken("success");

            if (status && model.UsersModel.Email != null && model.UsersModel.Email != "")
            {
                users u = new users();
                u.username = model.UsersModel.Email;
                u.email = model.UsersModel.Email;
                u.password = "123456";
                u.role = 2;
                u.deleted = false;

                db.users.Add(u);
                db.SaveChanges();

                usersmeta n = new usersmeta();

                n.userid = db.users.Select(i => i.id).Max();
                n.email = model.UsersModel.Email;
                n.news = true;
                n.name = "";
                n.surname = "";
                n.address = "";
                n.city = "";
                n.companyname = "";
                n.phone = "";
                n.zip = "";
                n.country = "";
                n.deleted = false;
                n.created = DateTime.Now.ToString();
                n.news = true;
                n.gdpr = true;

                db.usersmeta.Add(n);
                db.SaveChanges();

                //odosleme email o uspesnom zaregistrovani do newslettru
                OrdersController oc = new OrdersController();
                string body = createNewsletterEmailBody();
                oc.SendHtmlFormattedEmail("Ďakujeme za registráciu do newslettru!", body, n.email, "register", "");


                TempData["msg"] = "<small class='text-success'>Úspešne sme Vás pridali medzi odoberateľov našeho emailu. Ďakujeme.</small>";
            }
            else
            {
                TempData["msg"] = "<small class='text-warning'>Prihlásenie medzi odoberateľov našeho newslettru sa nezdarilo. Prosím, kontaktujte nás.</small>";
            }

            return Redirect(Url.Content("/#hp-newsletter"));


        }

        private string createNewsletterEmailBody()
        {

            string body = string.Empty;
            //using streamreader for reading my htmltemplate   
            using (StreamReader rea = new StreamReader(Server.MapPath("~/Views/Shared/RegisterEmail.cshtml")))
            {
                body = rea.ReadToEnd();
            }

            var str = "Ďakujeme za prihlásenie sa k odberu noviniek. Za odmenu od nás získavate kupón na <strong><u>zľavu 10%</u></strong> na všetok nezľavnený tovar.";
            str += "<br><br>Pri objednávke stačí zadať kód <strong><u>NAHOD10</u></strong> a zľava 10% sa automaticky uplatní.";
            body = body.Replace("{Text}", str);

            return body;
        }

    }
}