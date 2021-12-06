using System;
using System.Collections.Generic;
using System.Collections.Specialized;
using System.IO;
using System.Linq;
using System.Security.Cryptography;
using System.Text;
using System.Web;
using System.Web.Mvc;
using System.Web.Security;
using Cms.Models;
using System.Net;
using System.Net.Http;
using System.Threading.Tasks;
using System.Web.Helpers;
using Newtonsoft.Json;
using PagedList;
using Newtonsoft.Json.Linq;
using System.Text.RegularExpressions;


namespace Cms.Controllers
{

    public class AdminController : Controller
    {
        Entities db = new Entities();

        // GET: Admin
        [Route("administracia")]
        public ActionResult Admin()
        {
            return View();
        }

        [Route("stranky")]
        public ActionResult Pages()
        {
            if (Request.Cookies["username"] != null && Request.Cookies["role"].Value == "0")
            {
                return View(db.pages.OrderByDescending(a => a.id).ToList());
            }
            else { return RedirectToAction("Admin"); }
        }

        /*ORDERS VIEW*/
        [Route("objednavky")]
        public ActionResult Orders()
        {
            if (Request.Cookies["username"] != null && Request.Cookies["role"].Value == "0")
            {
                var orders = db.orders.Where(i => i.deleted == false).Select(a => new OrdersModel
                {
                    Id = a.id,
                    Ordernumber = a.ordernumber,
                    Date = a.date,
                    Shipping = a.shipping,
                    Payment = a.payment,
                    Finalprice = a.finalprice.ToString(),
                    Status = a.status,
                    Name = a.name,
                    Surname = a.surname,
                    NameShipp = a.name_shipp,
                    SurnameShipp = a.surname_shipp,
                    Address = a.address,
                    City = a.city,
                    Zip = a.zip,
                    AddressShipp = a.address_shipp,
                    CityShipp = a.city_shipp,
                    ZipShipp = a.zip_shipp,
                    Comment = a.comment,
                    Note = a.note,
                    UserRating = a.user_rating
                }).ToList();


                return View(orders);
            }
            else
            {
                return RedirectToAction("Admin", "Admin");
            }
        }
        /*ORDERS VIEW - END*/
        [Route("nastavenia")]
        public ActionResult Settings()
        {
            if (Request.Cookies["username"] != null && Request.Cookies["role"].Value == "0")
            {
                var id = 1;
                var allsettings = db.settings.Where(item => item.id == id).ToList();
                SettingsModel model = new SettingsModel();
                foreach (var set in allsettings)
                {
                    model.Description = set.description;
                    model.Email = set.email;
                    model.Googleanalyt = set.googleanalyt;
                    model.Facebook = set.facebook;
                    model.Instagram = set.instagram;
                    model.Adress = set.adress;
                    model.Psc = set.psc;
                    model.City = set.city;
                    model.Phone = set.phone;
                    if (set.indexed == 1)
                    {
                        model.Indexed = true;
                    }
                    else
                    {
                        model.Indexed = false;
                    }

                }
                return View(model);
            }
            else
            {
                return RedirectToAction("Admin");
            }
        }
        /*PRODUCT ACTIONS*/
        #region Product_actions
        [Route("produkty")]
        public ActionResult Products()
        {
            if (Request.Cookies["username"] != null && Request.Cookies["role"].Value == "0")
            {
                MultipleIndexModel model = new MultipleIndexModel();
                model.CategoriesModel = db.categories.ToList();
                model.ProductModel = db.products.Where(x => x.deleted == false).OrderByDescending(a => a.id).ToList();
                model.VariantAttributesModel = db.variants.Where(x => x.deleted == false).Join(db.attributes, a => a.attribute_id, b => b.id, (a,b) => new VariantAttributesModel { Id = a.id, ProdId = a.prod_id, AttrName = b.name, AttrValue = a.value, Stock = a.stock }).OrderByDescending(a => a.ProdId).ThenBy(a => a.AttrName).ToList();

                ViewData["kategoria"] = SelectionKategoria();
                ViewData["druh"] = SelectionDruh();
                ViewData["znacka"] = SelectionBrand();

                return View(model);
            }
            else { return RedirectToAction("Admin"); }
        }
        #endregion
        /*PRODUCT ACTIONS - END*/

        public List<SelectListItem> SelectionBrand()
        {
            List<SelectListItem> brand = new List<SelectListItem>();
            var brands = db.brands.OrderBy(a => a.name).ToList();
            brand.Add(new SelectListItem { Text = "", Value = "" });
            foreach (var cat in brands)
            {
                brand.Add(new SelectListItem { Text = cat.name, Value = cat.id.ToString() });
            }
            return brand;
        }

        /*Category - products - get categories*/
        public List<SelectListItem> SelectionKategoria()
        {
            List<SelectListItem> znacka = new List<SelectListItem>();
            var cats = db.categories.OrderBy(a => a.name).ToList();
            znacka.Add(new SelectListItem { Text = "", Value = "" });
            foreach (var cat in cats)
            {

                if (cat.topcat2 == "" || cat.topcat2 == "Žiadna")
                {
                    znacka.Add(new SelectListItem { Text = cat.name + " → " + cat.topcat, Value = cat.id.ToString() });
                }
                else
                {
                    znacka.Add(new SelectListItem { Text = cat.name + " → " + cat.topcat2 + " → " + cat.topcat, Value = cat.id.ToString() });
                }

            }
            return znacka;
        }

        /*Type - products - get types*/
        public List<SelectListItem> SelectionDruh()
        {
            List<SelectListItem> znacka = new List<SelectListItem>();
            var types = db.types.OrderBy(a => a.name).ToList();
            znacka.Add(new SelectListItem { Text = "", Value = "" });
            foreach (var type in types)
            {
                znacka.Add(new SelectListItem { Text = type.name, Value = type.id.ToString() });
            }
            return znacka;
        }

        /*WISHLIST ACTIONS*/
        #region Oblubene_actions
        [Route("oblubene/{id}")]
        public ActionResult Oblubene(int id)
        {
            if (Request.Cookies["username"] != null && Request.Cookies["role"].Value == "0")
            {

                MultipleIndexModel model = new MultipleIndexModel();

                var wishValues = db.wishlist.Where(i => i.userid == id).SingleOrDefault().data;

                model.AllWishlistModel = db.wishlist.Where(u => u.userid == id).ToList();
                model.ProductModel = db.products.ToList();

                return View(model);
            }
            else { return RedirectToAction("Admin"); }
        }
        #endregion
        /*WISHLIST ACTIONS - END*/



        [HttpPost, Route("administracia")]
        public ActionResult Admin(AdminModel obj)
        {
            MD5CryptoServiceProvider md5provider = new MD5CryptoServiceProvider();
            md5provider.ComputeHash(ASCIIEncoding.ASCII.GetBytes(obj.Password));
            byte[] overHeslo = md5provider.Hash;
            StringBuilder hesloDb = new StringBuilder();

            for (int i = 0; i < overHeslo.Length; i++)
            {
                hesloDb.Append(overHeslo[i].ToString("x2"));
            }
            string heslo = hesloDb.ToString();

            var autorizacia = db.users.SingleOrDefault(v => v.username == obj.Username && v.password == heslo);
            if (autorizacia == null)
            {
                ViewBag.Msg = "Meno alebo heslo je zadané nesprávne!";
            }
            else
            {
                var rola = db.users.Where(i => i.username == obj.Username).FirstOrDefault();
                Response.Cookies["username"].Value = obj.Username;
                Response.Cookies["role"].Value = rola.role.ToString();
                Response.Cookies["userid"].Value = rola.id.ToString();
                Response.Cookies["username"].Expires = DateTime.Now.AddDays(1);
                Response.Cookies["role"].Expires = DateTime.Now.AddDays(1);
                Response.Cookies["userid"].Expires = DateTime.Now.AddDays(1);
                return RedirectToAction("Cms");
            }

            return View();
        }

        [HttpPost]
        public ActionResult UserRegister(MultipleIndexModel model)
        {

            Entities db = new Entities();
            users o = new users();
            usersmeta um = new usersmeta();

            MD5CryptoServiceProvider md5provider = new MD5CryptoServiceProvider();
            md5provider.ComputeHash(ASCIIEncoding.ASCII.GetBytes(model.AdminLoginModel.Password));
            byte[] overHeslo = md5provider.Hash;
            StringBuilder hesloDb = new StringBuilder();

            for (int i = 0; i < overHeslo.Length; i++)
            {
                hesloDb.Append(overHeslo[i].ToString("x2"));
            }
            string heslo = hesloDb.ToString();

            //skontrolujeme, ci uz pouzivatel nema vytvorene newsletter konto
            var existsNewsUser = db.users.Where(a => a.username == model.AdminLoginModel.Username && a.password == "123456").FirstOrDefault();

            // ak uz existuje newsletter user, tak updatneme stlpce v db
            if (existsNewsUser != null)
            {
                var existsNewsUserMeta = db.usersmeta.Where(a => a.userid == existsNewsUser.id).FirstOrDefault();

                existsNewsUser.password = heslo;
                existsNewsUser.role = 1;

                existsNewsUserMeta.address = model.UsersmetaModel.Address;
                existsNewsUserMeta.city = model.UsersmetaModel.City;
                existsNewsUserMeta.companyname = model.UsersmetaModel.Companyname;
                existsNewsUserMeta.dic = model.UsersmetaModel.Dic;
                existsNewsUserMeta.email = model.AdminLoginModel.Username;
                existsNewsUserMeta.icdph = model.UsersmetaModel.Icdph;
                existsNewsUserMeta.ico = model.UsersmetaModel.Ico;
                existsNewsUserMeta.name = model.UsersmetaModel.Name;
                existsNewsUserMeta.news = model.UsersmetaModel.News;
                existsNewsUserMeta.gdpr = true;
                existsNewsUserMeta.phone = model.UsersmetaModel.Phone;
                existsNewsUserMeta.surname = model.UsersmetaModel.Surname;
                existsNewsUserMeta.zip = model.UsersmetaModel.Zip;
                existsNewsUserMeta.country = model.UsersmetaModel.Country;
                existsNewsUserMeta.rating = 1;

                db.SaveChanges();

            }
            // inak vytvorime nove konto
            else {
                o.username = model.AdminLoginModel.Username;
                o.password = heslo;
                o.role = 1;
                o.email = model.AdminLoginModel.Username;
                db.users.Add(o);
                db.SaveChanges();

                um.address = model.UsersmetaModel.Address;
                um.city = model.UsersmetaModel.City;
                um.companyname = model.UsersmetaModel.Companyname;
                um.dic = model.UsersmetaModel.Dic;
                um.email = model.AdminLoginModel.Username;
                um.icdph = model.UsersmetaModel.Icdph;
                um.ico = model.UsersmetaModel.Ico;
                um.name = model.UsersmetaModel.Name;
                um.news = model.UsersmetaModel.News;
                um.gdpr = true;
                um.phone = model.UsersmetaModel.Phone;
                um.surname = model.UsersmetaModel.Surname;
                um.zip = model.UsersmetaModel.Zip;
                um.country = model.UsersmetaModel.Country;
                um.created = DateTime.Now.ToString("d.M.yyyy HH:mm:ss");
                um.rating = 1;
                um.userid = db.users.Select(i => i.id).Max();

                db.usersmeta.Add(um);
                db.SaveChanges();
            }

           
            TempData["IsValid"] = true;
            ViewBag.IsValid = true;

            Response.Cookies["username"].Value = model.AdminLoginModel.Username;
            Response.Cookies["role"].Value = "1";
            Response.Cookies["userid"].Value = db.users.Where(i => i.email == model.AdminLoginModel.Username).Select(i => i.id).FirstOrDefault().ToString();
            Response.Cookies["username"].Expires = DateTime.Now.AddDays(1);
            Response.Cookies["role"].Expires = DateTime.Now.AddDays(1);
            Response.Cookies["userid"].Expires = DateTime.Now.AddDays(1);


            //Session["username"] = model.AdminLoginModel.Username;
            //Session["role"] = 1;
            //Session["userid"] = db.users.Where(i => i.email == model.AdminLoginModel.Username).Select(i => i.id).FirstOrDefault();

            //odosleme email o uspesnom zaregistrovani
            OrdersController oc = new OrdersController();
            string body = createRegisterEmailBody(um.name);
            oc.SendHtmlFormattedEmail("Ďakujeme za registráciu!", body, model.AdminLoginModel.Username, "register", "");

            string returnUrl = model.UsersmetaModel.ReturnUrl;
            return Redirect(returnUrl);
            //return RedirectToAction("Index", "Home", new { register = true });
        }

        [HttpPost]
        public ActionResult UserLogin(MultipleIndexModel obj)
        {

            //ak je to user, ktory si musi vytvorit nove heslo
            if (db.users.Where(i => i.username == obj.AdminLoginModel.Username && i.password == "reset").ToList().Count() > 0)
            {
                return RedirectToAction("ForgotPasswordSendLinkReset", "Home", new { forgotPasswordEmail = obj.AdminLoginModel.Username });
            }
            else
            {

                MD5CryptoServiceProvider md5provider = new MD5CryptoServiceProvider();
                md5provider.ComputeHash(ASCIIEncoding.ASCII.GetBytes(obj.AdminLoginModel.Password));
                byte[] overHeslo = md5provider.Hash;
                StringBuilder hesloDb = new StringBuilder();

                for (int i = 0; i < overHeslo.Length; i++)
                {
                    hesloDb.Append(overHeslo[i].ToString("x2"));
                }
                string heslo = hesloDb.ToString();

                var autorizacia = db.users.SingleOrDefault(v => v.username == obj.AdminLoginModel.Username && v.password == heslo);
                if (autorizacia == null)
                {
                    ViewBag.Msg = "Meno alebo heslo je zadané nesprávne!";
                    return RedirectToAction("Index", "Home", new { authorize = false });
                }
                else
                {
                    var rola = db.users.Where(i => i.username == obj.AdminLoginModel.Username).Select(o => o.role).FirstOrDefault();
                    var userid = db.users.Where(i => i.username == obj.AdminLoginModel.Username).Select(o => o.id).FirstOrDefault();
                    //Session["username"] = obj.AdminLoginModel.Username;
                    //Session["role"] = rola;
                    //Session["userid"] = userid;

                    Response.Cookies["username"].Value = obj.AdminLoginModel.Username;
                    Response.Cookies["role"].Value = rola.ToString();
                    Response.Cookies["userid"].Value = userid.ToString();
                    Response.Cookies["username"].Expires = DateTime.Now.AddDays(1);
                    Response.Cookies["role"].Expires = DateTime.Now.AddDays(1);
                    Response.Cookies["userid"].Expires = DateTime.Now.AddDays(1);

                    var userdata = db.wishlist.Where(i => i.userid == userid).ToList();
                    if (userdata.Count() == 0)
                    {
                        // do nothing                    
                    }
                    else
                    {
                        var actualWish = JsonConvert.SerializeObject(Session["wishitems"]);

                        if (actualWish != "null")
                        {
                            actualWish = actualWish.Replace("[", "").Replace("]", "");

                            var wishValues = db.wishlist.Where(i => i.userid == userid).SingleOrDefault().data;

                            wishValues = wishValues.Replace("[", "").Replace("]", "");

                            var newWish = "[";
                            newWish += actualWish;
                            newWish += ",";
                            newWish += wishValues;
                            newWish += "]";

                            Session["wishitems"] = JsonConvert.DeserializeObject<List<dynamic>>(newWish);

                            var update = db.wishlist.Where(i => i.userid == userid).Single();
                            update.data = newWish.ToString();

                            db.SaveChanges();
                        }
                        else
                        {
                            //do nothing only read from db
                            var wishValues = db.wishlist.Where(i => i.userid == userid).SingleOrDefault().data;
                            Session["wishitems"] = JsonConvert.DeserializeObject<List<dynamic>>(wishValues);
                        }


                    }

                    string returnUrl = obj.AdminLoginModel.ReturnUrl + "?userLogin=true";
                    return Redirect(returnUrl);
                }
            }
        }

        public ActionResult EmailExist(string email)
        {
            var emailExist = db.users.Where(i => i.username == email && i.password != "123456").FirstOrDefault();
            if (emailExist != null)
            {
                return Json(new { success = false }, JsonRequestBehavior.AllowGet);
            }
            else
            {
                return Json(new { success = true }, JsonRequestBehavior.AllowGet);
            }

        }

        [Route("cms")]
        public ActionResult Cms(int? id)
        {
            if (Request.Cookies["username"] != null && Request.Cookies["role"].Value == "0")
            {
                MultipleIndexModel model = new MultipleIndexModel();

                model.OrderDataModel = db.orders.ToList();
                
                ViewBag.DataPoints = JsonConvert.SerializeObject(db.orders.ToList(), _jsonSetting);
                return View(model);
            }
            else
            {
                return RedirectToAction("Admin");
            }
        }
        JsonSerializerSettings _jsonSetting = new JsonSerializerSettings() { NullValueHandling = NullValueHandling.Ignore };

        [Route("odhlasit-sa")]
        public ActionResult LogOut()
        {
            var rola = Request.Cookies["role"].Value;
            FormsAuthentication.SignOut();
            Response.Cookies["username"].Expires = DateTime.Now.AddDays(-1);
            Response.Cookies["role"].Expires = DateTime.Now.AddDays(-1);
            Response.Cookies["userid"].Expires = DateTime.Now.AddDays(-1);
            if (rola == "0")
            {
                return RedirectToAction("Admin");
            }
            else
            {
                return RedirectToAction("Index", "Home");
            }
        }


        /*TINYMCE Image Upload*/
        [Route("upload-image")]
        public ActionResult UploadImage(HttpPostedFileBase file)
        {
            var folderpath = "~/Uploads/images/" + DateTime.Now.Year + DateTime.Now.Month + "/";
            string path = Server.MapPath(folderpath + file.FileName);
            var folder = Directory.CreateDirectory(Server.MapPath(folderpath));
            byte[] fileByte;

            if (file.ContentType != "application/pdf" && file.ContentType != "application/vnd.openxmlformats-officedocument.wordprocessingml.document" && file.ContentType != "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet" && file.ContentType != "application/vnd.openxmlformats-officedocument.presentationml.presentation")
            {
                using (var reader = new BinaryReader(file.InputStream))
                {
                    fileByte = reader.ReadBytes(file.ContentLength);
                }
                WebImage img = new WebImage(fileByte);
                if (img.Width > 1000)
                {
                    img.Resize(1000 + 1, 1000 + 1, true).Crop(1, 1);
                }
                img.Save(path);
            }
            else
            {
                file.SaveAs(path);
            }
            return Json(new { location = DateTime.Now.Year + "" + DateTime.Now.Month + "/" + file.FileName });
        }
        /*TINYMCE Image Upload - END*/

        [Route("pouzivatelia")]
        public ActionResult Users(string sortOrder, string currentFilter, string searchString, int? page)
        {
            if (Request.Cookies["username"] != null && Request.Cookies["role"].Value == "0")
            {
                /*
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

                UsersModel zamMod = new UsersModel();
                var model = new MultipleIndexModel();
                model.AllUsersPaged = db.users.Where(i => i.deleted == false).ToList().OrderBy(x => Guid.NewGuid()).ToPagedList(pageNumber, pageSize);
                */

                var model = new MultipleIndexModel();
                model.AllUsers = db.users.Where(i => i.deleted == false).ToList();
                model.AllUsersMetaModel = db.usersmeta.Where(i => i.deleted == false).ToList();

                model.AllWishlistModel = db.wishlist.ToList();


                //ViewData["Rola"] = zamMod.SelectionRola();
                return View(model);
            }
            else
            {
                return RedirectToAction("Admin");
            }
        }

        [Route("pouzivatelia-vytvor")]
        public ActionResult UserCreate()
        {
            if (Request.Cookies["username"] != null && Request.Cookies["role"].Value == "0")
            {
                
                var model = new MultipleIndexModel();

                //ViewData["countries"] = SelectionCountries();

                return View(model);
            }
            else
            {
                return RedirectToAction("Admin");
            }
        }

        [Route("pouzivatelia-uprav/{id}")]
        public ActionResult UserEdit(int id)
        {
            if (Request.Cookies["username"] != null && Request.Cookies["role"].Value == "0")
            {
                var user = db.users.Where(item => item.id == id).Join(db.usersmeta, a => a.id, b => b.userid, (a, b) => new UsersmetaModel { Id = b.id, Userid = b.userid, Name = b.name, Surname = b.surname, Address = b.address, City = b.city, Zip = b.zip, Country = b.country, Phone = b.phone, Email = b.email, Companyname = b.companyname, Ico = b.ico, Dic = b.dic, Icdph = b.icdph, News = b.news, Gdpr = b.gdpr, Rating = b.rating }).SingleOrDefault();
                MultipleIndexModel model = new MultipleIndexModel();
                model.UsersmetaModel = user;

                //ViewData["countries"] = SelectionCountries();
                ViewData["ratings"] = SelectionRatings();

                return View(model);
            }
            else
            {
                return RedirectToAction("Admin");
            }
        }

        [HttpPost, Route("ulozadmin")]
        public async Task<ActionResult> AddAdmin(MultipleIndexModel model)
        {
            users o = new users();

            MD5CryptoServiceProvider md5provider = new MD5CryptoServiceProvider();
            md5provider.ComputeHash(ASCIIEncoding.ASCII.GetBytes(model.UsersModel.Password));
            byte[] overHeslo = md5provider.Hash;
            StringBuilder hesloDb = new StringBuilder();

            for (int i = 0; i < overHeslo.Length; i++)
            {
                hesloDb.Append(overHeslo[i].ToString("x2"));
            }
            string heslo = hesloDb.ToString();

            o.username = model.UsersModel.Username;
            o.password = heslo;
            o.role = 0;
            o.email = model.UsersModel.Username;


            db.users.Add(o);
            db.SaveChanges();

            usersmeta u = new usersmeta();

            var thisId = db.users.Where(i => i.username == model.UsersModel.Username).SingleOrDefault().id;

            u.userid = thisId;
            u.name = "";
            u.surname = "";
            u.address = "";
            u.city = "";
            u.zip = "";
            u.country = "";
            u.phone = "";
            u.email = model.UsersModel.Username;
            u.news = true;
            u.gdpr = true;
            u.created = DateTime.Now.ToString("dd.MM.yyyy HH:mm:ss");
            u.rating = 1;

            db.usersmeta.Add(u);
            db.SaveChanges();

            TempData["IsValid"] = true;
            ViewBag.IsValid = true;

            return RedirectToAction("Users", "Admin");
        }

        [HttpPost, Route("ulozpouziv")]
        public async Task<ActionResult> AddUser(MultipleIndexModel model)
        {
            users o = new users();

            MD5CryptoServiceProvider md5provider = new MD5CryptoServiceProvider();
            md5provider.ComputeHash(ASCIIEncoding.ASCII.GetBytes(model.UsersModel.Password));
            byte[] overHeslo = md5provider.Hash;
            StringBuilder hesloDb = new StringBuilder();

            for (int i = 0; i < overHeslo.Length; i++)
            {
                hesloDb.Append(overHeslo[i].ToString("x2"));
            }
            string heslo = hesloDb.ToString();

            o.username = model.UsersModel.Username;
            o.password = heslo;
            o.role = 1;
            o.email = model.UsersModel.Username;

            db.users.Add(o);
            db.SaveChanges();

            usersmeta u = new usersmeta();

            var thisId = db.users.Where(i => i.username == model.UsersModel.Username).SingleOrDefault().id;

            u.userid = thisId;
            u.name = model.UsersmetaModel.Name;
            u.surname = model.UsersmetaModel.Surname;
            u.address = model.UsersmetaModel.Address;
            u.city = model.UsersmetaModel.City;
            u.zip = model.UsersmetaModel.Zip;
            u.country = model.UsersmetaModel.Country;
            u.phone = model.UsersmetaModel.Phone;
            u.email = model.UsersmetaModel.Name;
            u.companyname = model.UsersmetaModel.Companyname;
            u.ico = model.UsersmetaModel.Ico;
            u.dic = model.UsersmetaModel.Dic;
            u.icdph = model.UsersmetaModel.Icdph;
            u.news = true;
            u.gdpr = true;
            u.created = DateTime.Now.ToString("dd.MM.yyyy HH:mm:ss");
            u.rating = 1;

            db.usersmeta.Add(u);
            db.SaveChanges();
            
            TempData["IsValid"] = true;
            ViewBag.IsValid = true;

            return RedirectToAction("Users", "Admin");
        }

        [HttpPost, Route("upravpouziv")]
        public async Task<ActionResult> EditUser(MultipleIndexModel model)
        {
            var u = db.usersmeta.Where(i => i.userid == model.UsersmetaModel.Userid).SingleOrDefault();

            u.name = model.UsersmetaModel.Name;
            u.surname = model.UsersmetaModel.Surname;
            u.address = model.UsersmetaModel.Address;
            u.city = model.UsersmetaModel.City;
            u.zip = model.UsersmetaModel.Zip;
            u.country = model.UsersmetaModel.Country;
            u.phone = model.UsersmetaModel.Phone;
            u.email = model.UsersmetaModel.Name;
            u.companyname = model.UsersmetaModel.Companyname;
            u.ico = model.UsersmetaModel.Ico;
            u.dic = model.UsersmetaModel.Dic;
            u.icdph = model.UsersmetaModel.Icdph;
            u.rating = model.UsersmetaModel.Rating;

            db.SaveChanges();

            return RedirectToAction("Users", "Admin");
        }

        public ActionResult OrdersCount()
        {
            var countOrders = db.orders.Where(i => i.status != 1).Count().ToString();
            return Content(countOrders);
        }
        private string createRegisterEmailBody(string name)
        {

            string body = string.Empty;
            var ownerEmail = db.settings.Select(i => i.email).FirstOrDefault();
            //using streamreader for reading my htmltemplate   
            using (StreamReader rea = new StreamReader(Server.MapPath("~/Views/Shared/RegisterEmail.cshtml")))
            {
                body = rea.ReadToEnd();
            }

            var str = "Ďakujeme " + name + " za registráciu, stali ste sa našim <strong><u>bronzovým zákazníkom</u></strong>. Odteraz získavate automaticky <strong><u>zľavu 5%</u></strong> na všetok nezľavnený tovar.";
            str += "<br><br>Pri ďalších objednávkach môžete získať <strong><u>zľavu až 15%</u></strong><br><ul><li>Bronzový zákazník zľava 5% ihneď po registrácií</li><li>Strieborný zákazník zľava 10%, ak je výška všetkých predošlých objednávok nad 500€</li><li>Zlatý zákazník zľava 15%, ak je výška všetkých predošlých objednávok nad 1000€</li></ul>";
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

        /*Countries*/
        /*
        public List<SelectListItem> SelectionCountries()
        {
            List<SelectListItem> countries = new List<SelectListItem>();

            countries.Add(new SelectListItem { Text = "Slovenská republika", Value = "Slovenská republika" });
            countries.Add(new SelectListItem { Text = "Česká republika", Value = "Česká republika" });

            return countries;
        }
        */

        /*Ratings*/
        public List<SelectListItem> SelectionRatings()
        {
            List<SelectListItem> countries = new List<SelectListItem>();

            countries.Add(new SelectListItem { Text = "Bronzový", Value = "1" });
            countries.Add(new SelectListItem { Text = "Strieborný", Value = "2" });
            countries.Add(new SelectListItem { Text = "Zlatý", Value = "3" });

            return countries;
        }

    }
}