using System;
using System.Collections.Generic;
using System.Configuration;
using System.Globalization;
using System.IO;
using System.Linq;
using System.Net.Mail;
using System.Runtime.CompilerServices;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading.Tasks;
using System.Web;
using System.Web.Compilation;
using System.Web.Mail;
using System.Web.Mvc;
using System.Web.Script.Serialization;
using Cms.Models;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using MailMessage = System.Net.Mail.MailMessage;

namespace Cms.Controllers
{
    public class OrdersController : Controller
    {
        Entities db = new Entities();

        [HttpPost, Route("nova-objednavka")]
        public async Task<ActionResult> NewOrder(MultipleIndexModel model)
        {
            orders o = new orders();
            ordermeta om = new ordermeta();
            products p = new products();
            var ownerEmail = db.settings.Select(i => i.email).FirstOrDefault();

            /*Change coupon limit*/
            string coupon = model.OrdersModel.UsedCoupon;
            if (coupon != null)
            {
                var couponlimit = db.coupons.Where(m => m.coupon == coupon).Select(m => m.limit);
                var c = db.coupons.Single(m => m.coupon == coupon);
                if (c.limit > 1)
                {
                    c.limit = (couponlimit.First() - 1);
                    db.SaveChanges();
                }
                else if (c.limit == 1)
                {
                    c.limit = -1;
                    db.SaveChanges();
                }
                else { }
            }

            /*Save order to DB*/
            var newordernumber = (Convert.ToInt32(db.orders.OrderByDescending(u => u.id).Select(i => i.ordernumber).FirstOrDefault()) + 1);
            if (DateTime.Now.ToString("yy") == newordernumber.ToString().Substring(0, 2))
            {
                o.ordernumber = newordernumber.ToString();
            }
            else
            {
                var newYear = 1;
                o.ordernumber = DateTime.Now.ToString("yy") + newYear.ToString("0000");
            }
            o.name = model.OrdersModel.Name;
            o.surname = model.OrdersModel.Surname;
            o.address = model.OrdersModel.Address;
            o.city = model.OrdersModel.City;
            o.zip = model.OrdersModel.Zip;
            o.country = model.OrdersModel.Country;
            o.phone = model.OrdersModel.Phone;
            o.email = model.OrdersModel.Email;
            o.companyname = model.OrdersModel.Companyname;
            o.ico = model.OrdersModel.Ico;
            o.dic = model.OrdersModel.Dic;
            o.icdph = model.OrdersModel.Icdph;
            o.date = DateTime.Now.ToString("d.M.yyyy HH:mm:ss");
            o.payment = model.OrdersModel.Payment;
            o.shipping = model.OrdersModel.Shipping;
            o.status = model.OrdersModel.Status;
            o.finalprice = Decimal.Parse(model.OrdersModel.Finalprice, CultureInfo.InvariantCulture);
            o.name_shipp = model.OrdersModel.NameShipp ?? "";
            o.surname_shipp = model.OrdersModel.SurnameShipp ?? "";
            o.address_shipp = model.OrdersModel.AddressShipp ?? "";
            o.companyname_shipp = model.OrdersModel.CompanynameShipp ?? "";
            o.city_shipp = model.OrdersModel.CityShipp ?? "";
            o.zip_shipp = model.OrdersModel.ZipShipp ?? "";
            o.country_shipp = model.OrdersModel.NameShipp != null ? model.OrdersModel.CountryShipp : "";
            o.phone_shipp = model.OrdersModel.PhoneShipp ?? "";
            o.comment = model.OrdersModel.Comment;
            o.usedcoupon = coupon ?? "";

            /*Save loged user id to order*/
            var usID = 0;

            if (Request.Cookies["userid"] != null)
            {
                usID = Int32.Parse(Request.Cookies["userid"].Value);
            }

            o.userid = usID;

            db.orders.Add(o);
            db.SaveChanges();

            List<dynamic> cart = new List<dynamic>();
            cart = (List<dynamic>)Session["cartitems"];

            foreach (var item in cart)
            {
                int productid = Convert.ToInt32(item.product);
                string variantName = item.variant;

                var thisProd = db.products.Where(i => i.id == productid).Single();
                var thisVar = db.products.Join(db.variants, a => a.id, b => b.prod_id, (a, b) => new { id = a.id, variantId = b.id, price = b.price, discountprice = b.discountprice, value = b.value, title = a.title }).Where(i => i.id == productid && i.value == variantName).SingleOrDefault();

                om.ordernumber = o.ordernumber;
                om.product = thisVar == null ? thisProd.title : thisVar.title;
                om.productid = item.product;
                om.pieces = item.quantity;
                om.productimage = thisProd.image;


                //Zlavova politika
                decimal thisPrice = (decimal)0.0;
                if (thisVar == null)
                {
                    if (thisProd.discountprice == null)
                    {
                        thisPrice = thisProd.price;

                        if (Request.Cookies["username"] != null)
                        {
                            var userId = Int32.Parse(Request.Cookies["userid"].Value);
                            int rating = db.usersmeta.Where(x => x.userid == userId).SingleOrDefault().rating;

                            switch (rating)
                            {
                                case 1:
                                    thisPrice *= (decimal)0.95;
                                    break;
                                case 2:
                                    thisPrice *= (decimal)0.9;
                                    break;
                                case 3:
                                    thisPrice *= (decimal)0.85;
                                    break;
                            }
                        }
                    }
                    else
                    {
                        thisPrice = (decimal)thisProd.discountprice;
                    }
                }
                else
                {
                    if (thisVar.discountprice == null)
                    {
                        thisPrice = (decimal)thisVar.price;

                        if (Request.Cookies["username"] != null)
                        {
                            var userId = Int32.Parse(Request.Cookies["userid"].Value);
                            int rating = db.usersmeta.Where(x => x.userid == userId).SingleOrDefault().rating;

                            switch (rating)
                            {
                                case 1:
                                    thisPrice *= (decimal)0.95;
                                    break;
                                case 2:
                                    thisPrice *= (decimal)0.9;
                                    break;
                                case 3:
                                    thisPrice *= (decimal)0.85;
                                    break;
                            }
                        }
                    }
                    else
                    {
                        thisPrice = (decimal)thisVar.discountprice;
                    }
                }

                om.price = thisPrice;
                om.variant = item.variant;
                om.variant2 = item.variant2;

                db.ordermeta.Add(om);
                db.SaveChanges();

                var cartprodID = Int32.Parse(item.product.ToString());
                var stockminus = Int32.Parse(om.pieces);
                var variantId = thisVar == null ? 0 : thisVar.variantId;

                //OverrideOnstock(cartprodID, variantId, stockminus, "");
            }

            /*
            foreach (var product in cart.Select(i => i.product.Value))
            {
                int converted = (int)product;
                foreach (var items in db.products.Where(i => i.id == converted).Distinct())
                {
                    allTheData.Add(items);
                }
            }

            foreach (var uniqueproduct in cart)
            {
                var cartprodID = Int32.Parse(uniqueproduct.product.ToString());
                var firstSize = "";
                var secondSize = "";
                foreach (var group in allTheData.Where(i => i.id == cartprodID).GroupBy(i => i.id).Distinct())
                {
                    quantity = group.Count();
                    foreach (var name in group.GroupBy(i => i.title))
                    {
                        om.product = name.Key;
                    }

                    foreach (var image in group.GroupBy(i => i.image))
                    {
                        om.productimage = image.Key;
                    }

                    om.ordernumber = o.ordernumber;
                    om.productid = group.Key.ToString();
                    foreach (var size in cart.Where(i => i.product == om.productid && i.id == uniqueproduct.id))
                    {
                        om.size = "";
                        if (size.size.Value != null)
                        {
                            om.size += size.size.Value;
                            firstSize = size.size.Value;
                        }

                        if (size.size2.Value != null)
                        {
                            om.size += size.size2.Value;
                            secondSize = size.size2.Value;
                        }
                    }

                    foreach (var pieces in cart.Where(i => i.product == om.productid && i.id == uniqueproduct.id))
                    {
                        om.pieces = pieces.quantity.Value;
                    }

                    foreach (var color in cart.Where(i => i.product == om.productid && i.id == uniqueproduct.id))
                    {
                        om.color = color.color.Value;
                    }

                    foreach (var price in group.GroupBy(i => i.price))
                    {
                        productprice = price.Key.ToString();
                    }

                    foreach (var discountprice in group.GroupBy(i => i.discountprice))
                    {
                        if (discountprice.Key != null)
                        {
                            productprice = discountprice.Key.ToString();
                        }
                    }
                    om.price = (Decimal.Parse(om.pieces) * decimal.Parse(productprice.Replace(",","."), CultureInfo.InvariantCulture)).ToString();
                    db.ordermeta.Add(om);
                    db.SaveChanges();

                    var stockminus = Int32.Parse(om.pieces);

                    OverrideOnstock(cartprodID, firstSize, secondSize, stockminus, "");
                }
            }
            */

            TempData["IsValid"] = true;
            ViewBag.IsValid = true;

            //Send email to customer
            string body = this.createEmailBody(o.ordernumber, "customer");
            string body_owner = this.createEmailBody(o.ordernumber, "owner");
            this.SendHtmlFormattedEmail("Ďakujeme za objednávku!", body, o.email, "customer", o.ordernumber);
            this.SendHtmlFormattedEmail("OBJEDNÁVKA Č.: "+ o.ordernumber+"", body_owner, ownerEmail, "owner", o.ordernumber);

            //remove session
            Session["cartitems"] = new List<dynamic>();
            Session["cartsum"] = 0;

            return RedirectToAction("ThankYou", new { orderNumber = o.ordernumber });
        }

        [Route("detail-objednavky/{orderNumber}")]
        public ActionResult OrderDetail(string orderNumber)
        {
            var model = new MultipleIndexModel();
            model.ProductModel = db.products.ToList();
            model.EsettingsModel = db.e_settings.ToList();
            model.SettingsModel = db.settings.ToList();
            model.PagesModel = db.pages.ToList();
            model.BrandsModel = db.brands.ToList();
            model.CategoriesModel = db.categories.ToList();
            model.SlideshowModel = db.slideshow.Where(o => o.page == "default").ToList();
            model.OrderDataModel = db.orders.Where(i => i.ordernumber == orderNumber).ToList();
            model.OrderMetaModel = db.ordermeta.Where(i => i.ordernumber == orderNumber).ToList();
            return View(model);
        }

        public ActionResult FinishedOrder(string orderNumber)
        {
            var o = db.orders.Single(i => i.ordernumber == orderNumber);
            var userId = o.userid;

            if (userId != 0)
            {
                var um = db.usersmeta.Where(i => i.userid == userId).SingleOrDefault();

                decimal sum = 0;
                var prevSumEntity = db.orders.Where(x => x.userid == userId);
                if (prevSumEntity.Count() > 0)
                {
                    sum = prevSumEntity.Sum(x => x.finalprice);
                }

                if (sum >= 1000)
                {
                    //zmenime rating len ak je nizsi, kvoli manualnej editacie ratingov pre znamych
                    if (um.rating < 3) 
                    {
                        um.rating = 3;

                        string body_rating = this.createRatingEmailBody(orderNumber, "15");
                        this.SendHtmlFormattedEmail("Vyššia zľavová skupina!", body_rating, o.email, "rating", orderNumber);
                    }

                }
                else if (sum >= 500)
                {
                    //zmenime rating len ak je nizsi, kvoli manualnej editacie ratingov pre znamych
                    if (um.rating < 2)
                    {
                        um.rating = 2;

                        string body_rating = this.createRatingEmailBody(orderNumber, "10");
                        this.SendHtmlFormattedEmail("Vyššia zľavová skupina!", body_rating, o.email, "rating", orderNumber);
                    }

                }

                um.sum = sum;
                o.user_rating = um.rating;
            }

            o.status = 1;
           
            db.SaveChanges();

            string body_finished = this.createEmailBody(orderNumber, "finished");

            this.SendHtmlFormattedEmail("Vaša objednávka bola odoslaná!", body_finished, o.email, "finished", orderNumber);

            return RedirectToAction("Orders", "Admin");
        }

        [Route("dakujeme-za-objednavku/{orderNumber}")]
        public ActionResult ThankYou(string orderNumber)
        {
            var model = new MultipleIndexModel();
            model.ProductModel = db.products.ToList();
            model.EsettingsModel = db.e_settings.ToList();
            model.SettingsModel = db.settings.ToList();
            model.PagesModel = db.pages.ToList();
            model.CategoriesModel = db.categories.ToList();
            model.BrandsModel = db.brands.ToList();
            model.SlideshowModel = db.slideshow.ToList();
            model.OrderDataModel = db.orders.Where(i => i.ordernumber == orderNumber).ToList();

            ViewData["countries"] = new AdminController().SelectionCountries();

            return View(model);
        }

        private string createRatingEmailBody(string orderNumber, string discount)
        {
            var orderdetail = db.orders.Where(i => i.ordernumber == orderNumber).ToList();
            var ownerEmail = db.settings.Select(i => i.email).FirstOrDefault();

            string body = string.Empty;
            //using streamreader for reading my htmltemplate   
            using (StreamReader reader = new StreamReader(Server.MapPath("~/Views/Shared/RatingOrderEmail.cshtml")))
            {
                body = reader.ReadToEnd();
            }

            var str = "Ďakujeme za vaše objednávky a zároveň Vás posúvame do vyššej zľavovej skupiny a dostávate zákaznicku zľavu <span style='white-space:nowrap;'>" + discount + " %.</span>";

            body = body.Replace("{Text}", str);
            body = body.Replace("{CompanyData}", CompanyDataInEmial());
            body = body.Replace("{CustomerService}", ownerEmail);

            return body;
        }

        private string createEmailBody(string orderNumber, string toWho)
        {
            var orderdetail = db.orders.Where(i => i.ordernumber == orderNumber).ToList();

            string body = string.Empty;
            //using streamreader for reading my htmltemplate   
            if (toWho == "customer")
            {
                using (StreamReader reader = new StreamReader(Server.MapPath("~/Views/Shared/OrderEmail.cshtml")))
                {
                    body = reader.ReadToEnd();
                }
            }
            else if (toWho == "owner")
            {
                using (StreamReader reader = new StreamReader(Server.MapPath("~/Views/Shared/NewOrderEmail.cshtml")))
                {
                    body = reader.ReadToEnd();
                }
            }
            else if (toWho == "finished")
            {
                using (StreamReader reader = new StreamReader(Server.MapPath("~/Views/Shared/FinishedOrderEmail.cshtml")))
                {
                    body = reader.ReadToEnd();
                }
            }

            ViewData["OrderNumber"] = orderNumber;

            foreach (var o in orderdetail)
            {
                var pay = "";
                if (o.payment == "pay1")
                {
                    pay = "V hotovosti pri osobnom odbere";
                }
                else if (o.payment == "pay2")
                {
                    pay = "Kartou";
                }
                else if (o.payment == "pay3")
                {
                    pay = "Bankovým prevodom";
                }
                else if (o.payment == "pay4")
                {
                    pay = "Dobierkou";
                }

                var trans = "";
                if (o.shipping == "transfer1")
                {
                    trans = "Kuriérska spoločnosť";
                }
                else if (o.shipping == "transfer2")
                {
                    trans = "Slovenská pošta";
                }
                else if (o.shipping == "transfer3")
                {
                    trans = "Osobný odber";
                }


                var paySql = string.Format("select {0} from `e-settings`", o.payment);
                var payPrice = db.Database.SqlQuery<string>(paySql).FirstOrDefault();
                var shipSql = string.Format("select {0} from `e-settings`", o.shipping);
                var ownerEmail = db.settings.Select(i => i.email).FirstOrDefault();
                var finalCena = Convert.ToDecimal(o.finalprice, CultureInfo.InvariantCulture);
                var iban = db.e_settings.Select(i => i.accountnumber).FirstOrDefault();
                var freeshipping = db.e_settings.Select(i => i.transfer5).FirstOrDefault();
                
                /*
                if (finalCena < 100)
                {
                    shipSql = string.Format("select deliveryprice1 from `e-settings`");
                }
                else if (finalCena > 99 && finalCena < 501)
                {
                    shipSql = string.Format("select deliveryprice2 from `e-settings`");
                }
                else if (finalCena > 500)
                {
                    shipSql = string.Format("select deliveryprice3 from `e-settings`");
                }
                */

                var shipPrice = db.Database.SqlQuery<string>(shipSql).FirstOrDefault();

                if (o.finalprice > decimal.Parse(freeshipping, CultureInfo.InvariantCulture))
                {
                    shipPrice = "0";
                }

                body = body.Replace("{FirstName}", o.name);
                body = body.Replace("{Surname}", o.surname);//replacing the required things  
                body = body.Replace("{OrderNumber}", o.ordernumber);
                body = body.Replace("{Date}", o.date);
                body = body.Replace("{Email}", o.email);
                body = body.Replace("{Payment}", pay);
                body = body.Replace("{Address}", o.address);
                body = body.Replace("{Zip}", o.zip);
                body = body.Replace("{City}", o.city);
                body = body.Replace("{Country}", o.country);
                body = body.Replace("{Shipping}", trans);
                body = body.Replace("{FirstName-shipp}", o.name_shipp);
                body = body.Replace("{Surname-shipp}", o.surname_shipp);
                body = body.Replace("{Companyname-shipp}", o.companyname_shipp);
                body = body.Replace("{Address-shipp}", o.address_shipp);
                body = body.Replace("{Zip-shipp}", o.zip_shipp);
                body = body.Replace("{City-shipp}", o.city_shipp);
                body = body.Replace("{Country-shipp}", o.country_shipp);
                body = body.Replace("{Tel}", o.phone);
                body = body.Replace("{Finalprice}", o.finalprice.ToString());
                body = body.Replace("{PaymentPrice}", payPrice.ToString());
                body = body.Replace("{ShippingPrice}", shipPrice.ToString());
                body = body.Replace("{Products}", ProductsInEmial(orderNumber));
                body = body.Replace("{CompanyData}", CompanyDataInEmial());
                body = body.Replace("{CustomerService}", ownerEmail);
                body = body.Replace("{IBAN}", iban);
            }
            return body;
        }

        private string ProductsInEmial(string ordNumb)
        {
            var stringBuilder = new StringBuilder();
            Entities db2 = new Entities();
            foreach (var item in db.ordermeta.Where(i => i.ordernumber == ordNumb))
            {
                var prodId = int.Parse(item.productid);
                foreach (var num in db2.products.Where(o => o.id == prodId))
                {
                    stringBuilder.Append("<tr>");
                    stringBuilder.AppendLine("<td width='9' align='left' valign='middle' style='margin-top:0;margin-bottom:0;color:#000000;line-height:1.36;width:9px;border-bottom:1px solid #c8c8c8'> </td>");
                    stringBuilder.AppendLine("<td align='left' valign='middle' style='margin-top:0;margin-bottom:0;color:#000000;line-height:1.36;border-bottom:1px solid #c8c8c8'><a href='https://nahod.sk/detail-produktu/" + prodId + "' target='_blank'> " + item.product + "</a></td>");
                    stringBuilder.AppendLine("<td align='left' valign='middle' style='margin-top:0;margin-bottom:0;color:#000000;line-height:1.36;border-bottom:1px solid #c8c8c8'>" + (item.variant != "" ? (item.variant2 != "" ? item.variant + " " + item.variant2 : item.variant) : "") + "</td>");
                    stringBuilder.AppendLine("<td align='left' valign='middle' style='margin-top:0;margin-bottom:0;color:#000000;line-height:1.36;border-bottom:1px solid #c8c8c8'>" + item.pieces + "</td>");
                    stringBuilder.AppendLine("<td align='left' valign='middle' style='margin-top:0;margin-bottom:0;color:#000000;line-height:1.36;border-bottom:1px solid #c8c8c8'>" + item.price.ToString("#.##") + " €</td>");
                    stringBuilder.AppendLine("<td width='9' align='left' valign='middle' style='margin-top:0;margin-bottom:0;color:#000000;line-height:1.36;width:9px;border-bottom:1px solid #c8c8c8'> </td>");
                    stringBuilder.AppendLine("</tr>");

                }
            }
            return stringBuilder.ToString();
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

        private string CompanyDataInInvoice()
        {
            var stringBuilder = new StringBuilder();
            foreach (var info in db.e_settings)
            {
                stringBuilder.Append("<h2 class='name'>" + info.companyname + "</h2><div>" + info.address + ", " + info.city + " " + info.custom + "</div><div>IČO: " + info.ico + "  DIČ: " + info.dic + "</div><div>IČ DPH: " + info.icdph + "</div>");
            }
            return stringBuilder.ToString();
        }

        public void SendHtmlFormattedEmail(string subject, string body, string email, string toWho, string ordnumber)
        {
            using (MailMessage mailMessage = new MailMessage())
            {
                var sett1 = db.e_settings.FirstOrDefault();
                var sett2 = db.settings.ToList();
                /*ZMENIT*/
                var eshopname = "NAHOD.sk";

                //foreach(var s in sett1)
                //{
                //    eshopname = s.companyname;
                //}

                //Zvlast nastaveny email FROM (pouziva iny server)
                //mailMessage.From = new MailAddress(ConfigurationManager.AppSettings["UserName"], eshopname);

                mailMessage.From = new MailAddress("shop@nahod.sk", eshopname);
                mailMessage.Subject = subject;

                var pdfVopPath = sett1.vopPdf;
                var pdfReturnPath = sett1.returnPdf;
                var pdfCancelPath = sett1.cancelPdf;

                mailMessage.Body = body;
                if (toWho == "customer")
                {
                    //priloha do emailu poucenie spotrebitela
                    if (pdfVopPath != null)
                    {
                        Attachment attachment1 = new Attachment(Server.MapPath("~/Uploads/" + pdfVopPath));
                        mailMessage.Attachments.Add(attachment1);   //add the attachment
                    }

                    if (pdfReturnPath != null) {
                        Attachment attachment2 = new Attachment(Server.MapPath("~/Uploads/" + pdfReturnPath));
                        mailMessage.Attachments.Add(attachment2);   //add the attachment
                    }

                    if (pdfCancelPath != null)
                    {
                        Attachment attachment3 = new Attachment(Server.MapPath("~/Uploads/" + pdfCancelPath));
                        mailMessage.Attachments.Add(attachment3);   //add the attachment
                    }
                }
                else if (toWho == "finished")
                {
                    //PdfSave(ordnumber);
                    if (pdfVopPath != null)
                    {
                        Attachment attachment1 = new Attachment(Server.MapPath("~/Uploads/" + pdfVopPath));
                        mailMessage.Attachments.Add(attachment1);   //add the attachment
                    }

                    if (pdfReturnPath != null)
                    {
                        Attachment attachment2 = new Attachment(Server.MapPath("~/Uploads/" + pdfReturnPath));
                        mailMessage.Attachments.Add(attachment2);   //add the attachment
                    }

                    if (pdfCancelPath != null)
                    {
                        Attachment attachment3 = new Attachment(Server.MapPath("~/Uploads/" + pdfCancelPath));
                        mailMessage.Attachments.Add(attachment3);   //add the attachment
                    }
                }

                mailMessage.IsBodyHtml = true;
                mailMessage.To.Add(new MailAddress(email));
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
        }

        public void PdfSave(string orderNumber)
        {
            var html = createInvoiceBody(orderNumber, "");
            var file = PdfSharpConvert(html);
            var filePath = Server.MapPath("~/Content/invoices/fa_" + orderNumber + ".pdf");

            System.IO.File.WriteAllBytes(filePath, file);
        }

        public ActionResult PdfOrder(string orderNumber)
        {
            var html = createInvoiceBody(orderNumber, "");
            var file = PdfSharpConvert(html);
            return File(file, "application/pdf", "fa_" + orderNumber + ".pdf");

        }

        public ActionResult PdfStorno(string orderNumber)
        {
            var html = createInvoiceBody(orderNumber, "storno");
            var file = PdfSharpConvert(html);
            return File(file, "application/pdf", "dobr_" + orderNumber + "1.pdf");

        }

        public static Byte[] PdfSharpConvert(String html)
        {
            Byte[] res = null;
            using (MemoryStream ms = new MemoryStream())
            {
                var pdf = TheArtOfDev.HtmlRenderer.PdfSharp.PdfGenerator.GeneratePdf(html, PdfSharp.PageSize.A4);
                pdf.Save(ms);
                res = ms.ToArray();
            }
            return res;
        }

        private string createInvoiceBody(string orderNumber, string invoiceType)
        {
            var orderdetail = db.orders.Where(i => i.ordernumber == orderNumber).ToList();

            string body = string.Empty;
            //using streamreader for reading my htmltemplate   
            if (invoiceType == "storno")
            {
                using (StreamReader reader = new StreamReader(Server.MapPath("~/Views/Shared/Storno.cshtml")))
                {
                    body = reader.ReadToEnd();
                }
            }
            else
            {
                using (StreamReader reader = new StreamReader(Server.MapPath("~/Views/Shared/Invoice.cshtml")))
                {
                    body = reader.ReadToEnd();
                }
            }


            ViewData["OrderNumber"] = orderNumber;

            foreach (var o in orderdetail)
            {
                var pay = "";
                if (o.payment == "pay1")
                {
                    pay = "V hotovosti pri osobnom odbere";
                }
                else if (o.payment == "pay2")
                {
                    pay = "Kartou";
                }
                else if (o.payment == "pay3")
                {
                    pay = "Bankovým prevodom";
                }
                else if (o.payment == "pay4")
                {
                    pay = "Dobierkou";
                }

                var trans = "";
                if (o.shipping == "transfer1")
                {
                    trans = "Kuriérska spoločnosť";
                }
                else if (o.shipping == "transfer2")
                {
                    trans = "Slovenská pošta";
                }
                else if (o.shipping == "transfer3")
                {
                    trans = "Osobný odber";
                }

                var paySql = string.Format("select {0} from `e-settings`", o.payment);
                var payPrice = db.Database.SqlQuery<string>(paySql).FirstOrDefault();
                var shipSql = string.Format("select {0} from `e-settings`", o.shipping);

                var ownerEmail = db.settings.Select(i => i.email).FirstOrDefault();
                var iban = db.e_settings.Select(i => i.accountnumber).FirstOrDefault();
                var finalCena = Convert.ToDecimal(o.finalprice, CultureInfo.InvariantCulture);
                var cenabezdph = Convert.ToDecimal(finalCena * 100 / 120);
                var dph = Convert.ToDecimal(finalCena - cenabezdph).ToString("N2");

                if (finalCena < 100)
                {
                    shipSql = string.Format("select deliveryprice1 from `e-settings`");
                }
                else if (finalCena > 99 && finalCena < 501)
                {
                    shipSql = string.Format("select deliveryprice2 from `e-settings`");
                }
                else if (finalCena > 500)
                {
                    shipSql = string.Format("select deliveryprice3 from `e-settings`");
                }

                var shipPrice = db.Database.SqlQuery<string>(shipSql).FirstOrDefault();
                var freeShipping = db.Database.SqlQuery<string>("select transfer5 from `e-settings`").FirstOrDefault();

                if (finalCena > decimal.Parse(freeShipping))
                {
                    shipPrice = "0";
                }

                body = body.Replace("{FirstName}", o.name);
                body = body.Replace("{Surname}", o.surname);//replacing the required things  
                body = body.Replace("{OrderNumber}", o.ordernumber);
                body = body.Replace("{Date}", o.date);
                body = body.Replace("{Email}", o.email);
                body = body.Replace("{Payment}", pay);
                body = body.Replace("{Address}", o.address);
                body = body.Replace("{Zip}", o.zip);
                body = body.Replace("{City}", o.city);
                body = body.Replace("{Company}", o.companyname);
                body = body.Replace("{ICO}", o.ico);
                body = body.Replace("{DIC}", o.dic);
                body = body.Replace("{ICDPH}", o.icdph);
                body = body.Replace("{Shipping}", trans);
                body = body.Replace("{FirstName-shipp}", o.name_shipp);
                body = body.Replace("{Surname-shipp}", o.surname_shipp);
                body = body.Replace("{Address-shipp}", o.address_shipp);
                body = body.Replace("{Zip-shipp}", o.zip_shipp);
                body = body.Replace("{City-shipp}", o.city_shipp);
                body = body.Replace("{Tel}", o.phone);
                body = body.Replace("{Finalprice}", o.finalprice.ToString());
                body = body.Replace("{FinalpriceNoDPH}", cenabezdph.ToString("N2"));
                body = body.Replace("{DPH}", dph);
                body = body.Replace("{PaymentPrice}", payPrice.ToString());
                body = body.Replace("{ShippingPrice}", shipPrice.ToString());
                body = body.Replace("{Products}", ProductsInEmial(orderNumber));
                body = body.Replace("{CompanyData}", CompanyDataInInvoice());
                body = body.Replace("{CustomerService}", ownerEmail);
                body = body.Replace("{IBAN}", iban);
            }
            return body;
        }

        public ActionResult UseCoupon(string coupon, string page)
        {
            var exist = db.coupons.Where(m => m.coupon == coupon);
            var couponlimit = db.coupons.Where(m => m.coupon == coupon).Select(m => m.limit);
            bool couponactive = db.coupons.Where(m => m.coupon == coupon).Select(m => m.active).FirstOrDefault();

            if (couponactive && exist.Count() > 0)
            {
                if (couponlimit.First() >= 0)
                {
                    var amount = db.coupons.Where(m => m.coupon == coupon).Select(m => m.amount).First();

                    TempData["Error"] = "false";
                    TempData["Coupons"] = coupon;
                    TempData["Amount"] = amount;
                    if (page == "basket")
                    {
                        return RedirectToAction("Basket", "Home");
                    }
                    else
                    {
                        return RedirectToAction("Wishlist", "Home");
                    }
                }
                else if (couponlimit.First() == -1)
                {
                    TempData["LimitError"] = "true";
                    if (page == "basket")
                    {
                        return RedirectToAction("Basket", "Home");
                    }
                    else
                    {
                        return RedirectToAction("Wishlist", "Home");
                    }
                }
            }
            else
            {
                TempData["Error"] = "true";
                if (page == "basket")
                {
                    return RedirectToAction("Basket", "Home");
                }
                else
                {
                    return RedirectToAction("Wishlist", "Home");
                }
            }
            return RedirectToAction("Admin", "Admin");
        }

        /*
        public void OverrideOnstock(int prodId, int variantId, int stockminus, string storno)
        {
            if (variantId != 0)
            {
                string jString = db.products.Where(m => m.id == prodId).Select(m => m.custom4).FirstOrDefault();
                var counter = 1;
                string json = "[";

                //ak sa z variabilneho produktu stal pred stornom nevariabilny
                if (jString != "")
                {

                    var objects = JArray.Parse(jString); // parse as array 

                    var loopsize = objects.Count;
                    foreach (JObject root in objects)
                    {

                        var variable = root.GetValue("size1").Value<string>();
                        var variable2 = "";

                        if (size2 != "")
                        {
                            variable2 = root.GetValue("size2").Value<string>();
                        }
                        var onstock = root.GetValue("stock").Value<int>();

                        if (variable2 == "")
                        {
                            if (variable == size)
                            {
                                if (storno == "storno")
                                {
                                    onstock = onstock + stockminus;
                                }
                                else
                                {
                                    onstock = onstock - stockminus;
                                }
                            }

                            json += JsonConvert.SerializeObject(new
                            {
                                size1 = variable,
                                stock = onstock
                            });
                        }
                        else
                        {
                            if (variable == size && variable2 == size2)
                            {
                                if (storno == "storno")
                                {
                                    onstock = onstock + stockminus;
                                }
                                else
                                {
                                    onstock = onstock - stockminus;
                                }
                            }

                            json += JsonConvert.SerializeObject(new
                            {
                                size1 = variable,
                                size2 = variable2,
                                stock = onstock
                            });
                        }

                        if (counter < loopsize)
                        {
                            json += ",";
                        }
                        counter++;
                    }
                }
                else
                {
                    if (size2 == "")
                    {
                        json += JsonConvert.SerializeObject(new
                        {
                            size1 = size,
                            stock = stockminus
                        });
                    }
                    else
                    {
                        json += JsonConvert.SerializeObject(new
                        {
                            size1 = size,
                            size2 = size2,
                            stock = stockminus
                        });
                    }
                }
                json += "]";

                //Save new value to DB
                var o = db.products.Single(i => i.id == prodId);
                o.custom4 = json;
                db.SaveChanges();
            }
            else
            {
                string getStock = db.products.Where(m => m.id == prodId).Select(m => m.stock).FirstOrDefault();
                int newStock = 0;

                if (storno == "storno")
                {
                    newStock = Int32.Parse(getStock) + stockminus;
                }
                else
                {
                    if (getStock != null && getStock != "")
                    {
                        newStock = Int32.Parse(getStock) - stockminus;
                    }
                }
                //Save new value to DB
                var o = db.products.Single(i => i.id == prodId);
                o.stock = newStock.ToString();
                db.SaveChanges();

            }
        }
        */

        [Route("storno/{id}")]
        public ActionResult StornoOrder(string id)
        {
            Entities db2 = new Entities();
            var obj = db2.ordermeta.Where(i => i.ordernumber == id);
            var numAlpha = new Regex("(?<Alpha>[a-zA-Z]*)(?<Numeric>[0-9]*)");

            /*
            foreach (var prod in obj)
            {
                var match = numAlpha.Match(prod.size);
                var size1 = match.Groups["Alpha"].Value;
                var size2 = match.Groups["Numeric"].Value;

                OverrideOnstock(Int32.Parse(prod.productid), size1, size2, Int32.Parse(prod.pieces), "storno");
            }
            */

            //Set status for order
            var o = db.orders.Single(i => i.ordernumber == id);
            o.status = 2; //status - STORNO
            db.SaveChanges();

            return RedirectToAction("Orders", "Admin");
        }

        [HttpPost]
        public ActionResult OrderNote(int ordId, string noteText)
        {


            var order = db.orders.Where(x => x.deleted == false && x.id == ordId).FirstOrDefault();

            order.note = noteText;

            db.SaveChanges();

            return RedirectToAction("OrderDetail", "Orders", new { orderNumber = order.ordernumber});
        }

        public void SendTest()
        {
            using (MailMessage mailMessage = new MailMessage())
            {
                /*ZMENIT*/
                var eshopname = "NAHOD.sk";

                //Zvlast nastaveny email FROM (pouziva iny server)
                //mailMessage.From = new MailAddress(ConfigurationManager.AppSettings["UserName"], eshopname);

                mailMessage.From = new MailAddress("shop@nahod.sk", eshopname);
                mailMessage.Subject = "predmet";
                mailMessage.Body = "";
                mailMessage.IsBodyHtml = true;
                mailMessage.To.Add(new MailAddress("info@hoberto.com"));

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

        }

        /*
        [HttpPost]
        public ActionResult UpdateOrderNote(string orderNote, int orderId)
        {

            var order = db.orders.Single(i => i.id == orderId);
            order.comment = orderNote;

            db.SaveChanges();

            return RedirectToAction("Orders", "Admin");
        }
        */
    }
}