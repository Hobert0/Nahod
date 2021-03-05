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
            if (Session["username"] != null && Session["role"].ToString() == "0")
            {
                return View(db.pages.OrderByDescending(a => a.id).ToList());
            }
            else { return RedirectToAction("Admin"); }
        }

        /*ORDERS VIEW*/
        [Route("objednavky")]
        public ActionResult Orders()
        {
            if (Session["username"] != null && Session["role"].ToString() == "0")
            {
                var orders = db.orders.Select(a => new OrdersModel
                {
                    Id = a.id,
                    Ordernumber = a.ordernumber,
                    Date = a.date,
                    Shipping = a.shipping,
                    Payment = a.payment,
                    Finalprice = a.finalprice,
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
                    Comment = a.comment
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
            if (Session["username"] != null && Session["role"].ToString() == "0")
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
            if (Session["username"] != null && Session["role"].ToString() == "0")
            {
                MultipleIndexModel model = new MultipleIndexModel();
                model.CategoriesModel = db.categories.ToList();
                model.ProductModel = db.products.OrderByDescending(a => a.id).ToList();

                return View(model);
            }
            else { return RedirectToAction("Admin"); }
        }
        #endregion
        /*PRODUCT ACTIONS - END*/

        /*WISHLIST ACTIONS*/
        #region Oblubene_actions
        [Route("oblubene/{id}")]
        public ActionResult Oblubene(int id)
        {
            if (Session["username"] != null && Session["role"].ToString() == "0")
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
                var rola = db.users.Where(i => i.username == obj.Username).Select(o => o.role).FirstOrDefault();
                Session["username"] = obj.Username;
                Session["role"] = rola;
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
            um.ico = model.UsersmetaModel.Dic;
            um.name = model.UsersmetaModel.Name;
            um.news = model.UsersmetaModel.News;
            um.gdpr = true;
            um.phone = model.UsersmetaModel.Phone;
            um.surname = model.UsersmetaModel.Surname;
            um.zip = model.UsersmetaModel.Zip;
            um.userid = db.users.Select(i => i.id).Max();

            db.usersmeta.Add(um);
            db.SaveChanges();
            TempData["IsValid"] = true;
            ViewBag.IsValid = true;
            Session["username"] = model.AdminLoginModel.Username;
            Session["role"] = 1;
            Session["userid"] = db.users.Where(i => i.email == model.AdminLoginModel.Username).Select(i => i.id).FirstOrDefault();

            return RedirectToAction("Index", "Home", new { register = true });
        }

        [HttpPost]
        public ActionResult UserLogin(MultipleIndexModel obj)
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
                Session["username"] = obj.AdminLoginModel.Username;
                Session["role"] = rola;
                Session["userid"] = userid;


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


                return RedirectToAction("Index", "Home");
            }


        }

        public ActionResult EmailExist(string email)
        {
            var emailExist = db.users.Where(i => i.username == email).Select(o => o.id).FirstOrDefault();
            if (emailExist != 0)
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
            if (Session["username"] != null && Session["role"].ToString() == "0")
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
            var rola = Session["role"].ToString();
            FormsAuthentication.SignOut();
            Session.Abandon(); // it will clear the session at the end of request
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
            if (Session["username"] != null && Session["role"].ToString() == "0")
            {
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
                model.AllUsersPaged = db.users.ToList().OrderBy(x => Guid.NewGuid()).ToPagedList(pageNumber, pageSize);
                model.AllUsersMetaModel = db.usersmeta.ToList();

                model.AllWishlistModel = db.wishlist.ToList();


                ViewData["Rola"] = zamMod.SelectionRola();
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
            if (Session["username"] != null && Session["role"].ToString() == "0")
            {
                
                var model = new MultipleIndexModel();

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
            u.phone = model.UsersmetaModel.Phone;
            u.email = model.UsersmetaModel.Name;
            u.companyname = model.UsersmetaModel.Companyname;
            u.ico = model.UsersmetaModel.Ico;
            u.dic = model.UsersmetaModel.Dic;
            u.icdph = model.UsersmetaModel.Icdph;
            u.news = true;
            u.gdpr = true;
            u.created = DateTime.Now.ToString("dd.MM.yyyy HH:mm:ss");

            db.usersmeta.Add(u);
            db.SaveChanges();
            //TempData["IsValid"] = true;
            //ViewBag.IsValid = true;

            return RedirectToAction("Users", "Admin");
        }

        public ActionResult OrdersCount()
        {
            var countOrders = db.orders.Where(i => i.status != 1).Count().ToString();
            return Content(countOrders);
        }

        

    }
}