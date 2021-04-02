using System;
using System.Collections.Generic;
using System.Configuration;
using System.Globalization;
using System.IO;
using System.Linq;
using System.Net.Mail;
using System.Threading.Tasks;
using System.Web;
using System.Web.Helpers;
using System.Web.Mvc;
using Cms.Models;
using Newtonsoft.Json;

namespace Cms.Controllers
{
    public class ProductsController : Controller
    {
        Entities db = new Entities();

        [Route("produkty/kategorie")]
        public ActionResult ProductCats()
        {
            if (Session["username"] != null && Session["role"].ToString() == "0")
            {
                MultipleIndexModel model = new MultipleIndexModel();
                model.CategoriesModel = db.categories.Where(i => i.deleted == false).OrderByDescending(a => a.id).ToList();
                ViewData["Maincat"] = SelectionKategorieMain();
                ViewData["Topcat"] = SelectionKategorieNew();
                ViewData["Topcat2"] = SelectionKategoria();
                return View(model);
            }
            else { return RedirectToAction("Admin", "Admin"); }
        }

        [Route("produkty/editovat-kategoriu/{id}")]
        public ActionResult EditCat(int? id) //editacia kategorie
        {
            if (Session["username"] != null && Session["role"].ToString() == "0")
            {
                var allCategories = db.categories.Where(item => item.id == id).ToList();
                CategoriesModel model = new CategoriesModel();
                foreach (var category in allCategories)
                {
                    model.Id = category.id;
                    model.Name = category.name;
                    model.Slug = category.slug;
                    model.Topcat = category.topcat;
                    model.Topcat2 = category.topcat2;
                    model.Maincat = category.maincat;
                    model.Description = category.description;
                    model.Image = category.image;
                    ViewData["maincat"] = SelectionKategorieMain();
                    ViewData["topcat"] = SelectionKategorieNew();
                    ViewData["topcat2"] = SelectionKategoria();
                }
                return View(model);
            }
            else
            {
                return RedirectToAction("Admin", "Admin");
            }
        }

        [HttpPost]
        public async Task<ActionResult> EditCatSave(CategoriesModel model)
        {
            var o = db.categories.Single(i => i.id == model.Id);

            o.name = model.Name;
            o.slug = model.Slug;
            o.maincat = model.Maincat ?? "Žiadna";
            o.topcat = model.Topcat ?? "Žiadna";
            o.topcat2 = model.Topcat2 ?? "Žiadna";
            o.description = model.Description ?? "";
            db.SaveChanges();

            return RedirectToAction("ProductCats", "Products");
        }

        [Route("produkty/zaradenia")]
        public ActionResult ProductTypes()
        {
            if (Session["username"] != null && Session["role"].ToString() == "0")
            {
                MultipleIndexModel model = new MultipleIndexModel();
                model.TypesModel = db.types.Where(i => i.deleted == false).OrderByDescending(a => a.id).ToList();
                return View(model);
            }
            else { return RedirectToAction("Admin", "Admin"); }
        }

        [Route("produkty/editovat-zaradenie/{id}")]
        public ActionResult EditType(int? id) //editacia zaradenia
        {
            if (Session["username"] != null && Session["role"].ToString() == "0")
            {
                var allTypes = db.types.Where(item => item.id == id).ToList();
                TypesModel model = new TypesModel();
                foreach (var type in allTypes)
                {
                    model.Id = type.id;
                    model.Name = type.name;
                    model.Slug = type.slug;
                    model.Description = type.description;
                    model.Image = type.image;
                }
                return View(model);
            }
            else
            {
                return RedirectToAction("Admin", "Admin");
            }
        }

        [HttpPost]
        public async Task<ActionResult> EditTypeSave(TypesModel model)
        {
            var o = db.types.Single(i => i.id == model.Id);

            o.name = model.Name;
            o.slug = model.Slug;
            o.description = model.Description;
            db.SaveChanges();

            return RedirectToAction("ProductTypes", "Products");
        }

        [Route("produkty/znacky")]
        public ActionResult ProductBrands()
        {
            if (Session["username"] != null && Session["role"].ToString() == "0")
            {
                MultipleIndexModel model = new MultipleIndexModel();
                model.BrandsModel = db.brands.Where(i => i.deleted == false).OrderByDescending(a => a.id).ToList();
                return View(model);
            }
            else { return RedirectToAction("Admin", "Admin"); }
        }

        [Route("produkty/editovat-znacku/{id}")] //editacia brands
        public ActionResult EditBrand(int? id)
        {
            if (Session["username"] != null && Session["role"].ToString() == "0")
            {
                var allBrands = db.brands.Where(item => item.id == id);
                BrandsModel model = new BrandsModel();
                foreach (var brand in allBrands)
                {
                    model.Id = brand.id;
                    model.Name = brand.name;
                    model.Slug = brand.slug;
                    model.Description = brand.description;
                    model.Image = brand.image;
                }
                return View(model);
            }
            else
            {
                return RedirectToAction("Admin", "Admin");
            }
        }

        [HttpPost]
        public async Task<ActionResult> EditBrandSave(BrandsModel model)
        {
            var o = db.brands.Single(i => i.id == model.Id);
            o.name = model.Name;
            o.slug = model.Slug;
            o.description = model.Description;
            db.SaveChanges();
            return RedirectToAction("Productbrands", "Products");
        }

        [Route("produkty/vlastnosti")]
        public ActionResult ProductAttributes()
        {
            if (Session["username"] != null && Session["role"].ToString() == "0")
            {
                MultipleIndexModel model = new MultipleIndexModel();
                model.AttributesModel = db.attributes.Where(i => i.deleted == false).OrderByDescending(a => a.id).ToList();
                return View(model);
            }
            else { return RedirectToAction("Admin", "Admin"); }
        }

        [Route("produkty/editovat-vlastnost/{id}")] //editacia attributes
        public ActionResult EditAttribute(int? id)
        {
            if (Session["username"] != null && Session["role"].ToString() == "0")
            {
                var attr = db.attributes.Where(item => item.id == id).SingleOrDefault();
                AttributesModel model = new AttributesModel();

                model.Id = attr.id;
                model.Name = attr.name;
                model.Value = attr.value;

                return View(model);
            }
            else
            {
                return RedirectToAction("Admin", "Admin");
            }
        }

        [HttpPost]
        public async Task<ActionResult> EditAttributeSave(AttributesModel model)
        {
            var o = db.attributes.Single(i => i.id == model.Id);
            o.name = model.Name;
            o.value = model.Value;
            db.SaveChanges();
            return RedirectToAction("ProductAttributes", "Products");
        }

        [Route("produkty/zlavove-kupony")]
        public ActionResult Coupons()
        {
            if (Session["username"] != null && Session["role"].ToString() == "0")
            {
                MultipleIndexModel model = new MultipleIndexModel();
                model.CouponsModel = db.coupons.Where(i => i.deleted == false).OrderByDescending(a => a.id).ToList();
                return View(model);
            }
            else { return RedirectToAction("Admin", "Admin"); }
        }


        [Route("produkty/pridat-produkt")]
        public ActionResult AddProduct()
        {
            if (Session["username"] != null && Session["role"].ToString() == "0")
            {
                ProductModel pm = new ProductModel();

                ViewData["vlastnosti"] = SelectionAttributes();
                ViewData["vlastnostiId"] = SelectionAttributesId();
                ViewData["hmotnostj"] = pm.SelectionHmotnost();
                ViewData["mernaj"] = pm.SelectionMernaJ();
                ViewData["kategoria"] = SelectionKategoria();
                ViewData["zaradenie"] = SelectionZaradenie();
                ViewData["znacka"] = SelectionBrand();
                ViewData["typ"] = pm.SelectionTyp();
                ViewData["velkost"] = pm.SelectionSize();
                ViewData["shoes"] = pm.SelectionShoes();
                ViewData["kosiky"] = pm.SelectionSizeBra1();
                ViewData["obvod"] = pm.SelectionSizeBra2();

                return View();
            }
            else { return RedirectToAction("Admin", "Admin"); }
        }

        /*Attributes - products*/
        public List<SelectListItem> SelectionAttributes()
        {
            List<SelectListItem> attributes = new List<SelectListItem>();
            foreach (var attr in db.attributes)
            {
                attributes.Add(new SelectListItem { Text = attr.name, Value = attr.value });
            }
            return attributes;
        }
        /*Attributes ID - products*/
        public List<int> SelectionAttributesId()
        {
            List<int> attributesId = new List<int>();
            foreach (var attr in db.attributes)
            {
                attributesId.Add(attr.id);
            }
            return attributesId;
        }
        /*Brands - products*/
        public List<SelectListItem> SelectionBrand()
        {
            List<SelectListItem> brand = new List<SelectListItem>();
            foreach (var cat in db.brands)
            {
                brand.Add(new SelectListItem { Text = cat.name, Value = cat.id.ToString() });
            }
            return brand;
        }
        /*Category - Add category*/
        public List<SelectListItem> SelectionKategorieMain()
        {
            List<SelectListItem> kategoria = new List<SelectListItem>();
            kategoria.Add(new SelectListItem { Text = "", Value = "" });
            foreach (var cat in db.categories.Where(i => i.maincat == "Žiadna"))
            {
                kategoria.Add(new SelectListItem { Text = cat.name, Value = cat.name.ToString() });
            }
            return kategoria;
        }


        /*Category - products - get categories*/
        public List<SelectListItem> SelectionKategoria()
        {
            List<SelectListItem> znacka = new List<SelectListItem>();
            znacka.Add(new SelectListItem { Text = "", Value = "" });
            foreach (var cat in db.categories)
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

        public List<SelectListItem> SelectionZaradenie()
        {
            List<SelectListItem> znacka = new List<SelectListItem>();
            znacka.Add(new SelectListItem { Text = "", Value = "" });
            foreach (var type in db.types)
            {
                znacka.Add(new SelectListItem { Text = type.name, Value = type.id.ToString() });
            }
            return znacka;
        }

        /*Category - Add category*/
        public List<SelectListItem> SelectionKategorieNew()
        {
            List<SelectListItem> znacka = new List<SelectListItem>();
            znacka.Add(new SelectListItem { Text = "", Value = "" });
            foreach (var cat in db.categories.Where(i => i.topcat == "Žiadna" && i.maincat != "Žiadna"))
            {
                znacka.Add(new SelectListItem { Text = cat.name, Value = cat.name.ToString() });
            }
            return znacka;
        }



        public JsonResult FetchCategories(string category, string maincat) // its a GET, not a POST
        {
            IQueryable categories = null;
            if (maincat != null)
            {
                categories = db.categories.Where(c => (c.maincat == maincat && c.topcat == "Žiadna")).Select(c => new
                {
                    ID = c.id,
                    Text = c.name
                });
            }

            if (category != null)
            {
                categories = db.categories.Where(c => (c.topcat == category && c.topcat2 == "Žiadna")).Select(c => new
                {
                    ID = c.id,
                    Text = c.name
                });
            }

            return Json(categories, JsonRequestBehavior.AllowGet);



        }

        [Route("produkty/editovat-produkt/{id}")]
        public ActionResult EditProduct(int? id)
        {
            if (Session["username"] != null && Session["role"].ToString() == "0")
            {
                var allproducts = db.products.Where(item => item.id == id).ToList();
                ProductModel model = new ProductModel();
                foreach (var product in allproducts)
                {
                    model.Id = product.id;
                    model.Title = product.title;
                    model.Image = product.image;
                    model.Description = product.description;
                    model.Gallery = product.gallery;
                    model.Heureka = product.heureka;
                    model.HeurekaDarcek = product.heurekadarcek;
                    model.Recommended = product.recommended;
                    model.Weightunit = product.weightunit;
                    model.Category = product.category;
                    model.Type = product.type;
                    model.Weight = product.weight;
                    model.Discountprice = product.discountprice.ToString();
                    model.Price = product.price.ToString();
                    model.Number = product.number;
                    model.Stock = product.stock;
                    model.Custom1 = product.custom1;
                    model.Custom2 = product.custom2;
                    model.Custom3 = product.custom3;
                    model.Custom4 = product.custom4; //sizes + stock
                    model.Custom6 = bool.Parse(product.custom6); //cena od
                    model.Custom7 = product.custom7; //color
                    model.Custom8 = product.custom8; //typ
                    model.Custom9 = product.custom9; //vykon
                    model.Custom10 = product.custom10; //plocha

                }

                var variants = db.variants.Where(item => item.prod_id == id).ToList();
                model.Variants = JsonConvert.SerializeObject(variants);

                ProductModel pm = new ProductModel();
                ViewData["vlastnosti"] = SelectionAttributes();
                ViewData["vlastnostiId"] = SelectionAttributesId();
                ViewData["hmotnostj"] = pm.SelectionHmotnost();
                ViewData["mernaj"] = pm.SelectionMernaJ();
                ViewData["kategoria"] = SelectionKategoria();
                ViewData["zaradenie"] = SelectionZaradenie();
                ViewData["znacka"] = SelectionBrand();
                ViewData["typ"] = pm.SelectionTyp();
                ViewData["velkost"] = pm.SelectionSize();
                ViewData["shoes"] = pm.SelectionShoes();
                ViewData["kosiky"] = pm.SelectionSizeBra1();
                ViewData["obvod"] = pm.SelectionSizeBra2();

                return View(model);
            }
            else
            {
                return RedirectToAction("Admin", "Admin");
            }
        }


        [HttpPost]
        public async Task<ActionResult> SaveProduct(ProductModel model)
        {
            products o = new products();
            var nazovSuboru = string.Empty;

            if (model.TitleImage != null)
            {
                HttpPostedFileBase[] subor = model.TitleImage;
                if (model.TitleImage[0] != null)
                {
                    foreach (HttpPostedFileBase file in subor)
                    {
                        nazovSuboru = Path.GetFileName(file.FileName);
                    }
                }
            }

            var ulozObrazok = DateTime.Now.Date.ToString("dd.MM.yyyy") + "/" + DateTime.Now.ToString("HHmmss") + "/";

            if (nazovSuboru == "")
            {
                nazovSuboru = "avatar_product.jpg";
            }
            if (model.Price != null && model.Price != "") { model.Price = model.Price; }
            if (model.Discountprice != null && model.Discountprice != "") { model.Discountprice = model.Discountprice; }

            o.title = model.Title;
            o.image = ulozObrazok + nazovSuboru;
            o.number = model.Number;
            o.stock = model.Stock;
            o.price = Decimal.Parse(model.Price, CultureInfo.InvariantCulture);
            o.category = model.Category;
            o.type = model.Type;
            o.weight = model.Weight;
            o.weightunit = model.Weightunit;
            o.heureka = model.Heureka;
            o.heurekadarcek = model.HeurekaDarcek;
            o.recommended = model.Recommended;
            o.description = model.Description;
            if (model.Discountprice != "NaN" && model.Discountprice != "" && model.Discountprice != null)
            {
                o.discountprice = Decimal.Parse(model.Discountprice, CultureInfo.InvariantCulture);
            }
            else {
                o.discountprice = null;
            }
            o.custom1 = model.Custom1;
            o.custom3 = model.Custom3;
            if (model.Custom5 == "1")
            {
                o.custom4 = model.Custom4.ToString();
            }
            if (model.Custom6 == true) //cena od hodnota
            {
                o.custom6 = "True";
            }
            else
            {
                o.custom6 = "False";
            }
            ///o.custom6 = (model.Custom6).ToString();
            o.custom7 = model.Custom7;
            o.custom8 = model.Custom8; //typ
            o.custom9 = model.Custom9; //vykon
            o.custom10 = model.Custom10; //plocha

            o.date = DateTime.Now.ToString();
            o.gallery = ulozObrazok + "gallery/" ?? "";

            db.products.Add(o);

            db.SaveChanges();

            //Varianty
            if (model.Variants != null)
            {
                dynamic vars = JsonConvert.DeserializeObject(model.Variants);

                foreach (var varP in vars)
                {
                    variants v = new variants();

                    v.prod_id = o.id;
                    v.number = varP.number;

                    //ak nie je vyplnena cena pre variantu, skopirujeme cenu z produktu
                    if (varP.price != null && varP.price.ToString() != "")
                    {
                        v.price = varP.price;
                    }
                    else
                    {
                        v.price = Decimal.Parse(model.Price, CultureInfo.InvariantCulture);
                    }

                    //ak nie je vyplnena discount cena pre variantu, skopirujeme discount cenu z produktu
                    if (varP.discountprice != null && varP.discountprice.ToString() != "")
                    {
                        v.discountprice = varP.discountprice;
                    }
                    else if (model.Discountprice != "NaN" && model.Discountprice != "" && model.Discountprice != null)
                    {
                        v.discountprice = Decimal.Parse(model.Discountprice, CultureInfo.InvariantCulture);
                    }
                    else {
                        v.discountprice = null;
                    }

                    v.stock = varP.stock;
                    v.attribute_id = varP.attribute_id;
                    v.value = varP.value;

                    db.variants.Add(v);
                }
            }

            db.SaveChanges();

            if (model.TitleImage != null)
            {
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
            }
            else
            {
                /*AK duplikujeme produkt vytvori nove foldre*/
                var sourcePath = HttpContext.Server.MapPath("~/Uploads/avatar_product.jpg");
                var destinationPath = HttpContext.Server.MapPath("~/Uploads/" + o.image);
                var miestoUlozenia = "~/Uploads/" + ulozObrazok;
                var path = Directory.CreateDirectory(Server.MapPath(miestoUlozenia));
                if (System.IO.File.Exists(sourcePath))
                {
                    System.IO.File.Copy(sourcePath, destinationPath);
                }

                if (model.ImageGallery != null)
                {
                    await UploadFiles(model.ImageGallery, o.gallery);
                }
            }
            TempData["IsValid"] = true;
            ViewBag.IsValid = true;
            return RedirectToAction("Products", "Admin");
        }

        public ActionResult DeleteProduct(int? id, bool confirm)
        {

            var product = db.products.Where(i => i.id == id).SingleOrDefault();

            product.deleted = true;

            var variants = db.variants.Where(i => i.prod_id == id);
            foreach (var variant in variants)
            {
                variant.deleted = true;
            }

            ViewBag.Status = true;

            db.SaveChanges();

            /*
            var data = db.products.Find(id);
            if (true)
            {
                ViewBag.Status = true;
                db.products.Remove(data);

                var variants = db.variants.Where(i => i.prod_id == id);
                foreach (var var in variants)
                {
                    db.variants.Remove(var);
                }

                db.SaveChanges();
            }
            else { ViewBag.Status = false; }
            */

            return RedirectToAction("Products", "Admin");
        }

        public async Task<ActionResult> DuplicateProduct(int? id)
        {
            var data = db.products.Single(i => i.id == id);
            ProductModel model = new ProductModel();
            model.Category = data.category;
            model.Type = data.type;
            model.Custom1 = data.custom1;
            model.Custom10 = data.custom10;
            model.Custom2 = data.custom2;
            model.Custom3 = data.custom3;
            model.Custom4 = data.custom4;
            model.Custom5 = data.custom5;
            model.Custom6 = bool.Parse(data.custom6);
            model.Custom7 = data.custom7;
            model.Custom8 = data.custom8;
            model.Custom9 = data.custom9;
            model.Date = data.date;
            model.Description = data.description;
            model.Discountprice = data.discountprice.ToString().Replace(",", ".");
            model.Gallery = data.gallery;
            model.Image = data.image;
            model.Number = data.number;
            model.Price = data.price.ToString().Replace(",", ".");
            model.Recommended = data.recommended;
            model.Stock = data.stock;
            model.Title = data.title;
            model.Weight = data.weight;
            model.Weightunit = data.weightunit;
            model.TitleImage = null;

            //Varianty
            var variants = JsonConvert.SerializeObject(db.variants.Where(i => i.prod_id == id));
            model.Variants = variants;

            _ = await SaveProduct(model);

            return RedirectToAction("Products", "Admin");
        }


        [HttpPost, Route("produkty/editovat-produkt/{id}")]
        public async Task<ActionResult> EditProduct(ProductModel model)
        {

            var o = db.products.Single(i => i.id == model.Id);

            if (model.Price != null) { model.Price = model.Price; }
            if (model.Discountprice != null) { model.Discountprice = model.Discountprice; }

            o.title = model.Title ?? "";
            o.number = model.Number;
            o.stock = model.Stock;
            o.price = Decimal.Parse(model.Price, CultureInfo.InvariantCulture);
            o.category = model.Category;
            o.type = model.Type;
            o.weight = model.Weight;
            o.weightunit = model.Weightunit;
            o.heureka = model.Heureka;
            o.heurekadarcek = model.HeurekaDarcek;
            o.recommended = model.Recommended;
            o.description = model.Description;
            if (model.Discountprice != "NaN" && model.Discountprice != null)
            {
                o.discountprice = Decimal.Parse(model.Discountprice, CultureInfo.InvariantCulture);
            }
            else {
                o.discountprice = null;
            }
            o.custom1 = model.Custom1;
            o.custom2 = model.Custom2;
            o.custom3 = model.Custom3;
            if (model.Custom5 == "1")
            {
                o.custom4 = model.Custom4;
                o.stock = "";
            }
            else
            {
                o.custom4 = "";
            }
            if (model.Custom6 == true) //cena od hodnota
            {
                o.custom6 = "True";
            }
            else
            {
                o.custom6 = "False";
            }
            o.custom7 = model.Custom7; //color
            o.custom8 = model.Custom8; //typ
            o.custom9 = model.Custom9; //vykon
            o.custom10 = model.Custom10; //plocha

            //Varianty
            //Najprv vymazeme povodne a ulozime nove
            var oldVariants = db.variants.Where(i => i.prod_id == model.Id);
            foreach (var oldVar in oldVariants)
            {
                db.variants.Remove(oldVar);
            }

            dynamic vars = JsonConvert.DeserializeObject(model.Variants);

            foreach (var varP in vars)
            {
                variants v = new variants();

                v.prod_id = o.id;
                v.number = varP.number;

                if (varP.price != null && varP.price != "")
                {
                    v.price = varP.price;
                }
                else {
                    v.price = Decimal.Parse(model.Price, CultureInfo.InvariantCulture);
                }

                if (varP.discountprice != null && varP.discountprice != "")
                {
                    v.discountprice = varP.discountprice;
                } else if (model.Discountprice != "NaN" && model.Discountprice != null) {

                    v.discountprice = Decimal.Parse(model.Discountprice, CultureInfo.InvariantCulture);
                }
                else {
                    v.discountprice = null;
                }


                v.stock = varP.stock;
                v.attribute_id = varP.attrId;
                v.value = varP.attrValues;

                db.variants.Add(v);
            }

            db.SaveChanges();

            return RedirectToAction("EditProduct", new { model.Id });
        }

        [HttpPost]
        public async Task<ActionResult> UpdateBrand(MultipleIndexModel model)
        {

            var o = db.brands.Single(i => i.id == model.BrandsEditModel.Id);

            o.name = model.BrandsEditModel.Name;
            o.slug = model.BrandsEditModel.Slug;
            o.description = model.BrandsEditModel.Description ?? "";

            db.SaveChanges();

            return RedirectToAction("ProductBrands");
        }

        [HttpPost]
        public async Task<ActionResult> UpdateCoupon(MultipleIndexModel model)
        {

            var o = db.coupons.Single(i => i.id == model.CouponsEditModel.Id);

            o.coupon = model.CouponsEditModel.Coupon;
            o.amount = model.CouponsEditModel.Amount;
            o.limit = model.CouponsEditModel.Limit ?? 0;
            o.active = model.CouponsEditModel.Active;

            db.SaveChanges();

            return RedirectToAction("Coupons");
        }

        [HttpPost]
        public ActionResult MultipleEditPrice(string multiplePricePerc, bool? isDiscountMultiple, string catId, string brandId, string priceFrom, string priceTo, bool? isDiscount)
        {

            List<products> products = null;
            decimal priceFromDec = Decimal.Parse(priceFrom, CultureInfo.InvariantCulture);
            decimal priceToDec = Decimal.Parse(priceTo, CultureInfo.InvariantCulture);

            if (catId != "" && brandId == "")
            {
                products = (isDiscount != null && isDiscount == true) ? db.products.Where(x => x.deleted == false && x.category == catId && x.price >= priceFromDec && x.price <= priceToDec && x.discountprice != null).ToList() : db.products.Where(x => x.deleted == false && x.category == catId && x.price >= priceFromDec && x.price <= priceToDec).ToList();
            }
            else if (catId == "" && brandId != "")
            {
                products = (isDiscount != null && isDiscount == true) ? db.products.Where(x => x.deleted == false && x.custom3 == brandId && x.price >= priceFromDec && x.price <= priceToDec && x.discountprice != null).ToList() : db.products.Where(x => x.deleted == false && x.custom3 == brandId && x.price >= priceFromDec && x.price <= priceToDec).ToList();
            }
            else if (catId != "" && brandId != "")
            {
                products = (isDiscount != null && isDiscount == true) ? db.products.Where(x => x.deleted == false && x.category == catId && x.custom3 == brandId && x.price >= priceFromDec && x.price <= priceToDec && x.discountprice != null).ToList() : db.products.Where(x => x.deleted == false && x.category == catId && x.custom3 == brandId && x.price >= priceFromDec && x.price <= priceToDec).ToList();
            }
            else
            {
                products = (isDiscount != null && isDiscount == true) ? db.products.Where(x => x.deleted == false && x.price >= priceFromDec && x.price <= priceToDec && x.discountprice != null).ToList() : db.products.Where(x => x.deleted == false && x.price >= priceFromDec && x.price <= priceToDec).ToList();
            }

            foreach (var product in products)
            {
                decimal changedPrice = product.price + product.price * Decimal.Parse(multiplePricePerc, CultureInfo.InvariantCulture) / 100;

                if (isDiscountMultiple == null || isDiscountMultiple == false)
                {
                    product.price = changedPrice;
                }
                else
                {
                    product.discountprice = changedPrice;
                }

                var variants = db.variants.Where(x => x.deleted == false && x.prod_id == product.id).ToList();

                foreach (var variant in variants)
                {
                    decimal changedVarPrice = (decimal)variant.price + (decimal)variant.price * Decimal.Parse(multiplePricePerc, CultureInfo.InvariantCulture) / 100;

                    if (isDiscountMultiple == null || isDiscountMultiple == false)
                    {
                        variant.price = changedVarPrice;
                    }
                    else
                    {
                        variant.discountprice = changedVarPrice;
                    }
                }
            }

            db.SaveChanges();

            return RedirectToAction("Products", "Admin");
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
        public ActionResult UploadImageCategories(CategoriesModel model)
        {
            //Zmena titulnej fotky
            if (model.TitleImage != null)
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
                            var data = db.categories.Single(i => i.id == model.Id);
                            data.image = isTheSameImage;
                            db.SaveChanges();
                        }
                        //assigning file uploaded status to ViewBag for showing message to user.  
                        ViewBag.UploadStatus = subor.Count().ToString() + " files uploaded successfully.";
                    }

                }

            }
            else { }
            return RedirectToAction("ProductCats");
        }

        [HttpPost]
        public ActionResult UploadImageTypes(TypesModel model)
        {
            //Zmena titulnej fotky
            if (model.TitleImage != null)
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
                            var data = db.types.Single(i => i.id == model.Id);
                            data.image = isTheSameImage;
                            db.SaveChanges();
                        }
                        //assigning file uploaded status to ViewBag for showing message to user.  
                        ViewBag.UploadStatus = subor.Count().ToString() + " files uploaded successfully.";
                    }

                }

            }
            else { }
            return RedirectToAction("ProductTypes");
        }

        /**HROMADNE CROPNUTIE PRETOZE RESIZE ZANECHAVAL NA FOTKACH 1px BORDER*/
        public void BulkCrop()
        {
            foreach (string d in Directory.GetDirectories(Server.MapPath("~/Uploads")))
            {
                foreach (string imgPath in Directory.GetFiles(d))
                {
                    var img = new FileInfo(imgPath);
                    if (img.Extension == ".jpg" || img.Extension == ".jpeg" || img.Extension == ".png")
                    {
                        WebImage imag = new WebImage(imgPath);
                        imag.Crop(1, 1);
                        imag.Save(imgPath);
                    }
                }
                foreach (string k in Directory.GetDirectories(d))
                {

                    foreach (string imgPath in Directory.GetFiles(k))
                    {
                        var img = new FileInfo(imgPath);
                        if (img.Extension == ".jpg" || img.Extension == ".jpeg" || img.Extension == ".png")
                        {

                            WebImage imag = new WebImage(imgPath);
                            imag.Crop(1, 1);
                            imag.Save(imgPath);
                        }
                    }
                    foreach (string x in Directory.GetDirectories(k))
                    {
                        foreach (string imgPath in Directory.GetFiles(x))
                        {
                            var img = new FileInfo(imgPath);
                            if (img.Extension == ".jpg" || img.Extension == ".jpeg" || img.Extension == ".png")
                            {

                                WebImage imag = new WebImage(imgPath);
                                imag.Crop(1, 1);
                                imag.Save(imgPath);
                            }
                        }
                    }
                }
            }
        }

        [HttpPost]
        public ActionResult UploadImageBrands(BrandsModel model)
        {
            //Zmena titulnej fotky
            if (model.TitleImage != null)
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
                            var data = db.brands.Single(i => i.id == model.Id);
                            data.image = isTheSameImage;
                            db.SaveChanges();
                        }
                        //assigning file uploaded status to ViewBag for showing message to user.  
                        ViewBag.UploadStatus = subor.Count().ToString() + " files uploaded successfully.";
                    }

                }

            }
            else { }
            return RedirectToAction("ProductBrands");
        }


        [HttpPost]
        public ActionResult UploadImages(ProductModel model)
        {
            //Zmena fotiek v galerii
            var id = model.Id;
            if (model.Gallery != null)
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
                return RedirectToAction("EditProduct", new { id });
            }
            //Zmena titulnej fotky
            else  //Zmena titulnej fotky
            if (model.TitleImage != null)
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
                            var data = db.products.Single(i => i.id == model.Id);
                            data.image = isTheSameImage;
                            db.SaveChanges();
                        }
                        //assigning file uploaded status to ViewBag for showing message to user.  
                        ViewBag.UploadStatus = subor.Count().ToString() + " files uploaded successfully.";
                    }

                }

            }
            else { }
            return RedirectToAction("EditProduct", new { id });
        }


        public ActionResult DeletePicture(string url, int id)
        {
            string fullPath = Request.MapPath(url);

            if (System.IO.File.Exists(fullPath))
            {
                System.IO.File.Delete(fullPath);
            }
            return Redirect(Url.Content("~/produkty/editovat-produkt/" + id) + "#galleria");
        }


        public ActionResult DeleteCategory(int? id, bool confirm)
        {
            var data = db.categories.Find(id);

            data.deleted = true;

            ViewBag.Status = true;
            db.SaveChanges();


            /*
            var data = db.categories.Find(id);
            if (true)
            {
                ViewBag.Status = true;
                db.categories.Remove(data);
                db.SaveChanges();
            }
            else { ViewBag.Status = false; }
            */

            return RedirectToAction("ProductCats");
        }

        public ActionResult DeleteType(int? id, bool confirm)
        {
            var data = db.types.Find(id);

            data.deleted = true;

            ViewBag.Status = true;
            db.SaveChanges();


            /*
            var data = db.categories.Find(id);
            if (true)
            {
                ViewBag.Status = true;
                db.categories.Remove(data);
                db.SaveChanges();
            }
            else { ViewBag.Status = false; }
            */

            return RedirectToAction("ProductTypes");
        }

        public ActionResult DeleteBrand(int? id, bool confirm)
        {
            var data = db.brands.Find(id);
            data.deleted = true;

            ViewBag.Status = true;

            db.SaveChanges();


            /*
            var data = db.brands.Find(id);
            if (true)
            {
                ViewBag.Status = true;
                db.brands.Remove(data);
                db.SaveChanges();
            }
            else { ViewBag.Status = false; }
            */

            return RedirectToAction("ProductBrands");
        }

        public ActionResult DeleteAttribute(int? id, bool confirm)
        {
            var data = db.attributes.Find(id);

            data.deleted = true;

            ViewBag.Status = true;
            db.SaveChanges();

            /*
            var data = db.attributes.Find(id);
            if (true)
            {
                ViewBag.Status = true;
                db.attributes.Remove(data);
                db.SaveChanges();
            }
            else { ViewBag.Status = false; }
            */

            return RedirectToAction("ProductAttributes");
        }
        public ActionResult DeleteCoupon(int? id, bool confirm)
        {
            var data = db.coupons.Find(id);
            data.deleted = true;

            ViewBag.Status = true;

            db.SaveChanges();

            /*
            var data = db.coupons.Find(id);
            if (true)
            {
                ViewBag.Status = true;
                db.coupons.Remove(data);
                db.SaveChanges();
            }
            else { ViewBag.Status = false; }
            */

            return RedirectToAction("Coupons");
        }

        [HttpPost]
        public async Task<ActionResult> AddCategory(MultipleIndexModel model)
        {
            categories o = new categories();
            var nazovSuboru = string.Empty;

            if (model.Categories.TitleImage != null)
            {
                HttpPostedFileBase[] subor = model.Categories.TitleImage;
                if (model.Categories.TitleImage[0] != null)
                {
                    foreach (HttpPostedFileBase file in subor)
                    {
                        nazovSuboru = Path.GetFileName(file.FileName);
                    }
                }
            }

            var ulozObrazok = DateTime.Now.Date.ToString("dd.MM.yyyy") + "/" + DateTime.Now.ToString("HHmmss") + "/";

            if (nazovSuboru == "")
            {
                nazovSuboru = "avatar_product.jpg";
            }

            o.name = model.Categories.Name;
            o.slug = model.Categories.Slug;
            o.description = model.Categories.Description ?? "";
            o.maincat = model.Categories.Maincat ?? "Žiadna";
            o.topcat = model.Categories.Topcat ?? "Žiadna";
            o.topcat2 = model.Categories.Topcat2 ?? "Žiadna";
            o.image = ulozObrazok + nazovSuboru;

            db.categories.Add(o);
            db.SaveChanges();

            if (model.Categories.TitleImage != null)
            {
                if (model.Categories.TitleImage[0] != null)
                {
                    await UploadFiles(model.Categories.TitleImage, ulozObrazok);
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


                }
            }
            else
            {
                /*AK duplikujeme produkt vytvori nove foldre*/
                var sourcePath = HttpContext.Server.MapPath("~/Uploads/avatar_product.jpg");
                var destinationPath = HttpContext.Server.MapPath("~/Uploads/" + o.image);
                var miestoUlozenia = "~/Uploads/" + ulozObrazok;
                var path = Directory.CreateDirectory(Server.MapPath(miestoUlozenia));
                if (System.IO.File.Exists(sourcePath))
                {
                    System.IO.File.Copy(sourcePath, destinationPath);
                }

            }

            return RedirectToAction("ProductCats");
        }

        [HttpPost]
        public async Task<ActionResult> AddType(MultipleIndexModel model)
        {
            types o = new types();
            var nazovSuboru = string.Empty;

            if (model.Types.TitleImage != null)
            {
                HttpPostedFileBase[] subor = model.Types.TitleImage;
                if (model.Types.TitleImage[0] != null)
                {
                    foreach (HttpPostedFileBase file in subor)
                    {
                        nazovSuboru = Path.GetFileName(file.FileName);
                    }
                }
            }

            var ulozObrazok = DateTime.Now.Date.ToString("dd.MM.yyyy") + "/" + DateTime.Now.ToString("HHmmss") + "/";

            if (nazovSuboru == "")
            {
                nazovSuboru = "avatar_product.jpg";
            }

            o.name = model.Types.Name;
            o.slug = model.Types.Slug;
            o.description = model.Types.Description;
            o.image = ulozObrazok + nazovSuboru;

            db.types.Add(o);
            db.SaveChanges();

            if (model.Types.TitleImage != null)
            {
                if (model.Types.TitleImage[0] != null)
                {
                    await UploadFiles(model.Types.TitleImage, ulozObrazok);
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


                }
            }
            else
            {
                /*AK duplikujeme produkt vytvori nove foldre*/
                var sourcePath = HttpContext.Server.MapPath("~/Uploads/avatar_product.jpg");
                var destinationPath = HttpContext.Server.MapPath("~/Uploads/" + o.image);
                var miestoUlozenia = "~/Uploads/" + ulozObrazok;
                var path = Directory.CreateDirectory(Server.MapPath(miestoUlozenia));
                if (System.IO.File.Exists(sourcePath))
                {
                    System.IO.File.Copy(sourcePath, destinationPath);
                }

            }

            return RedirectToAction("ProductTypes");
        }

        [HttpPost]
        public async Task<ActionResult> AddBrand(MultipleIndexModel model)
        {
            brands o = new brands();
            var nazovSuboru = string.Empty;

            if (model.Brands.TitleImage != null)
            {
                HttpPostedFileBase[] subor = model.Brands.TitleImage;
                if (model.Brands.TitleImage[0] != null)
                {
                    foreach (HttpPostedFileBase file in subor)
                    {
                        nazovSuboru = Path.GetFileName(file.FileName);
                    }
                }
            }

            var ulozObrazok = DateTime.Now.Date.ToString("dd.MM.yyyy") + "/" + DateTime.Now.ToString("HHmmss") + "/";

            if (nazovSuboru == "")
            {
                nazovSuboru = "avatar_product.jpg";
            }

            o.name = model.Brands.Name;
            o.slug = model.Brands.Slug;
            o.description = model.Brands.Description ?? "";
            o.image = ulozObrazok + nazovSuboru;

            db.brands.Add(o);
            db.SaveChanges();

            if (model.Brands.TitleImage != null)
            {
                if (model.Brands.TitleImage[0] != null)
                {
                    await UploadFiles(model.Brands.TitleImage, ulozObrazok);
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


                }
            }
            else
            {
                /*AK duplikujeme produkt vytvori nove foldre*/
                var sourcePath = HttpContext.Server.MapPath("~/Uploads/avatar_product.jpg");
                var destinationPath = HttpContext.Server.MapPath("~/Uploads/" + o.image);
                var miestoUlozenia = "~/Uploads/" + ulozObrazok;
                var path = Directory.CreateDirectory(Server.MapPath(miestoUlozenia));
                if (System.IO.File.Exists(sourcePath))
                {
                    System.IO.File.Copy(sourcePath, destinationPath);
                }

            }

            return RedirectToAction("ProductBrands");
        }

        [HttpPost, Route("produkty/vlastnosti/pridatvlastnost")]
        public ActionResult AddAttribute(MultipleIndexModel model)
        {
            attributes o = new attributes();

            o.name = model.Attributes.Name;
            o.value = model.Attributes.Value;

            db.attributes.Add(o);
            db.SaveChanges();

            return RedirectToAction("ProductAttributes");
        }

        [HttpPost]
        public async Task<ActionResult> AddCoupon(MultipleIndexModel model)
        {
            coupons o = new coupons();

            o.coupon = model.Coupons.Coupon;
            o.amount = model.Coupons.Amount;
            o.limit = model.Coupons.Limit ?? 0;
            o.active = true;

            db.coupons.Add(o);
            db.SaveChanges();

            return RedirectToAction("Coupons");
        }

        public void PassSizes(List<SizesModel> sizes)
        {
            var t = sizes;
        }
        public ActionResult askForPrice(MultipleIndexModel model, int? id)
        {
            var settings = db.settings.SingleOrDefault().email;

            MailMessage mailMessage = new MailMessage();

            mailMessage.From = new MailAddress(model.EmailSendModel.Email);
            mailMessage.Subject = model.EmailSendModel.Subject;
            mailMessage.Body = model.EmailSendModel.Message;
            mailMessage.IsBodyHtml = true;

            mailMessage.To.Add(new MailAddress(settings));

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

            ViewBag.emailStatus = "true";

            return RedirectToAction("ProductDetail", "Home", new { id = id, sent = "true" });

        }


    }
}