using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using OfficeOpenXml;
using OfficeOpenXml.Table;
using System.Data;
using Cms.Models;
using System.IO;
using Microsoft.VisualBasic.FileIO;
using System.Text.RegularExpressions;
using System.Net;
using System.Drawing;
using System.Drawing.Imaging;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using System.Threading;
using System.Globalization;

namespace Cms.Controllers
{
    public class ExportImportController : Controller
    {
        Entities db = new Entities();

        [Route("exportimport")]
        public ActionResult ExpImp()
        {
            if (Request.Cookies["username"] != null && Request.Cookies["role"].Value == "0")
            {
                return View();
            }
            else
            {
                return RedirectToAction("Admin", "Admin", new { SuccesProducts = "0", SuccesOrders = "0", SuccesUsers = "0" });
            }
        }
        //function to setting orders to data table and config of style of excel sheet
        public ActionResult ExcelExportOrders()
        {

            var orders = db.orders.ToList();


            DataTable Dt = new DataTable();
            Dt.Columns.Add("ID", typeof(string));
            Dt.Columns.Add("Name", typeof(string));
            Dt.Columns.Add("Surname", typeof(string));
            Dt.Columns.Add("Address", typeof(string));
            Dt.Columns.Add("City", typeof(string));
            Dt.Columns.Add("ZIP", typeof(string));
            Dt.Columns.Add("Phone", typeof(string));
            Dt.Columns.Add("Email", typeof(string));
            Dt.Columns.Add("Company name", typeof(string));
            Dt.Columns.Add("ICO", typeof(string));
            Dt.Columns.Add("DIC", typeof(string));
            Dt.Columns.Add("IC DPH", typeof(string));
            Dt.Columns.Add("Shipping Name", typeof(string));
            Dt.Columns.Add("Shipping Surname", typeof(string));
            Dt.Columns.Add("Shipping Address", typeof(string));
            Dt.Columns.Add("Shipping Company name", typeof(string));
            Dt.Columns.Add("Shipping City", typeof(string));
            Dt.Columns.Add("Shipping ZIP", typeof(string));
            Dt.Columns.Add("Shipping Phone", typeof(string));
            Dt.Columns.Add("Comment", typeof(string));
            Dt.Columns.Add("Used coupon", typeof(string));
            Dt.Columns.Add("Date", typeof(string));
            Dt.Columns.Add("Shipping", typeof(string));
            Dt.Columns.Add("Payment", typeof(string));
            Dt.Columns.Add("Price", typeof(string));
            Dt.Columns.Add("User ID", typeof(string));

            foreach (var data in orders)
            {
                DataRow row = Dt.NewRow();
                row[0] = data.ordernumber;
                row[1] = data.name;
                row[2] = data.surname;
                row[3] = data.address;
                row[4] = data.city;
                row[5] = data.zip;
                row[6] = data.phone;
                row[7] = data.email;
                row[8] = data.companyname;
                row[9] = data.ico;
                row[10] = data.dic;
                row[11] = data.icdph;
                row[12] = data.name_shipp;
                row[13] = data.surname_shipp;
                row[14] = data.address_shipp;
                row[15] = data.companyname_shipp;
                row[16] = data.city_shipp;
                row[17] = data.zip_shipp;
                row[18] = data.phone_shipp;
                row[19] = data.comment;
                row[20] = data.usedcoupon;
                row[21] = data.date;
                row[22] = data.shipping;
                row[23] = data.payment;
                row[24] = data.finalprice;
                row[25] = data.userid;
                Dt.Rows.Add(row);
            }

            var memoryStram = new MemoryStream();
            using (var excelPackage = new ExcelPackage(memoryStram))
            {
                var worksheet = excelPackage.Workbook.Worksheets.Add("Orders");
                worksheet.Cells["A1"].LoadFromDataTable(Dt, true, TableStyles.None);
                worksheet.Cells["A1:AN1"].Style.Font.Bold = true;
                worksheet.DefaultRowHeight = 18;

                worksheet.Column(2).Style.HorizontalAlignment = OfficeOpenXml.Style.ExcelHorizontalAlignment.Left;
                worksheet.Column(6).Style.HorizontalAlignment = OfficeOpenXml.Style.ExcelHorizontalAlignment.Center;
                worksheet.Column(7).Style.HorizontalAlignment = OfficeOpenXml.Style.ExcelHorizontalAlignment.Center;
                worksheet.DefaultColWidth = 20;
                worksheet.Column(2).AutoFit();

                Session["DownloadExcel_FileManagerOrders"] = excelPackage.GetAsByteArray();
                return Json("", JsonRequestBehavior.AllowGet);
            }



        }

        //function to setting products to data table and config of style of excel sheet
        public ActionResult ExcelExportProducts()
        {

            var products = db.products.ToList();


            DataTable Dt = new DataTable();
            Dt.Columns.Add("ID", typeof(string));
            Dt.Columns.Add("Name", typeof(string));
            Dt.Columns.Add("Image", typeof(string));
            Dt.Columns.Add("Number", typeof(string));
            Dt.Columns.Add("Recommended", typeof(string));
            Dt.Columns.Add("Stock", typeof(string));
            Dt.Columns.Add("Price", typeof(string));
            Dt.Columns.Add("Date", typeof(string));
            Dt.Columns.Add("Gallery", typeof(string));
            Dt.Columns.Add("Category", typeof(string));
            Dt.Columns.Add("Weight", typeof(string));
            Dt.Columns.Add("Weight Unit", typeof(string));
            Dt.Columns.Add("Description", typeof(string));
            Dt.Columns.Add("Discount Price", typeof(string));
            Dt.Columns.Add("Custom 1", typeof(string));
            Dt.Columns.Add("Custom 2", typeof(string));
            Dt.Columns.Add("Custom 3", typeof(string));
            Dt.Columns.Add("Custom 4", typeof(string));
            Dt.Columns.Add("Custom 5", typeof(string));
            Dt.Columns.Add("Custom 6", typeof(string));
            Dt.Columns.Add("Custom 7", typeof(string));
            Dt.Columns.Add("Custom 8", typeof(string));
            Dt.Columns.Add("Custom 9", typeof(string));
            Dt.Columns.Add("Custom 10", typeof(string));


            foreach (var data in products)
            {
                DataRow row = Dt.NewRow();
                row[0] = data.id;
                row[1] = data.title;
                row[2] = data.image;
                row[3] = data.number;
                row[4] = data.recommended;
                row[5] = data.stock;
                row[6] = data.price;
                row[7] = data.date;
                row[8] = data.gallery;
                row[9] = data.category;
                row[10] = data.weight;
                row[11] = data.weightunit;
                row[12] = data.description;
                row[13] = data.discountprice;
                row[14] = data.custom1;
                row[15] = data.custom2;
                row[16] = data.custom3;
                row[17] = data.custom4;
                row[18] = data.custom5;
                row[19] = data.custom6;
                row[20] = data.custom7;
                row[21] = data.custom8;
                row[22] = data.custom9;
                row[23] = data.custom10;
                Dt.Rows.Add(row);
            }

            var memoryStram = new MemoryStream();
            using (var excelPackage = new ExcelPackage(memoryStram))
            {
                var worksheet = excelPackage.Workbook.Worksheets.Add("Products");
                worksheet.Cells["A1"].LoadFromDataTable(Dt, true, TableStyles.None);
                worksheet.Cells["A1:AN1"].Style.Font.Bold = true;
                worksheet.DefaultRowHeight = 18;

                worksheet.Column(2).Style.HorizontalAlignment = OfficeOpenXml.Style.ExcelHorizontalAlignment.Left;
                worksheet.Column(6).Style.HorizontalAlignment = OfficeOpenXml.Style.ExcelHorizontalAlignment.Center;
                worksheet.Column(7).Style.HorizontalAlignment = OfficeOpenXml.Style.ExcelHorizontalAlignment.Center;
                worksheet.DefaultColWidth = 20;
                worksheet.Column(2).AutoFit();

                Session["DownloadExcel_FileManagerProducts"] = excelPackage.GetAsByteArray();
                return Json("", JsonRequestBehavior.AllowGet);
            }



        }

        //function to setting products to data table and config of style of excel sheet
        public ActionResult ExcelExportUsers()
        {

            var users = db.usersmeta.ToList();


            DataTable Dt = new DataTable();
            Dt.Columns.Add("ID", typeof(string));
            Dt.Columns.Add("Name", typeof(string));
            Dt.Columns.Add("Surname", typeof(string));
            Dt.Columns.Add("Address", typeof(string));
            Dt.Columns.Add("City", typeof(string));
            Dt.Columns.Add("ZIP", typeof(string));
            Dt.Columns.Add("Phone", typeof(string));
            Dt.Columns.Add("Email", typeof(string));
            Dt.Columns.Add("Company Name", typeof(string));
            Dt.Columns.Add("ICO", typeof(string));
            Dt.Columns.Add("DIC", typeof(string));
            Dt.Columns.Add("ICDPH", typeof(string));
            Dt.Columns.Add("News", typeof(string));

            foreach (var data in users)
            {
                DataRow row = Dt.NewRow();
                row[0] = data.id;
                row[1] = data.name;
                row[2] = data.surname;
                row[3] = data.address;
                row[4] = data.city;
                row[5] = data.zip;
                row[6] = data.phone;
                row[7] = data.email;
                row[8] = data.companyname;
                row[9] = data.ico;
                row[10] = data.dic;
                row[11] = data.icdph;
                row[12] = data.news;
                Dt.Rows.Add(row);
            }

            var memoryStram = new MemoryStream();
            using (var excelPackage = new ExcelPackage(memoryStram))
            {
                var worksheet = excelPackage.Workbook.Worksheets.Add("Users");
                worksheet.Cells["A1"].LoadFromDataTable(Dt, true, TableStyles.None);
                worksheet.Cells["A1:AN1"].Style.Font.Bold = true;
                worksheet.DefaultRowHeight = 18;

                worksheet.Column(2).Style.HorizontalAlignment = OfficeOpenXml.Style.ExcelHorizontalAlignment.Left;
                worksheet.Column(6).Style.HorizontalAlignment = OfficeOpenXml.Style.ExcelHorizontalAlignment.Center;
                worksheet.Column(7).Style.HorizontalAlignment = OfficeOpenXml.Style.ExcelHorizontalAlignment.Center;
                worksheet.DefaultColWidth = 20;
                worksheet.Column(2).AutoFit();

                Session["DownloadExcel_FileManagerUsers"] = excelPackage.GetAsByteArray();
                return Json("", JsonRequestBehavior.AllowGet);
            }



        }

        //function to download orders export file
        public ActionResult DownloadOrders()
        {
            if (Session["DownloadExcel_FileManagerOrders"] != null)
            {
                byte[] data = Session["DownloadExcel_FileManagerOrders"] as byte[];
                return File(data, "application/octet-stream", "OrdersExport.xlsx");

            }
            else
            {
                return new EmptyResult();
            }
        }

        //function to download products export file
        public ActionResult DownloadProducts()
        {
            if (Session["DownloadExcel_FileManagerProducts"] != null)
            {
                byte[] data = Session["DownloadExcel_FileManagerProducts"] as byte[];
                return File(data, "application/octet-stream", "ProductsExport.xlsx");

            }
            else
            {
                return new EmptyResult();
            }
        }

        //function to download users export file
        public ActionResult DownloadUsers()
        {
            if (Session["DownloadExcel_FileManagerUsers"] != null)
            {
                byte[] data = Session["DownloadExcel_FileManagerUsers"] as byte[];
                return File(data, "application/octet-stream", "UsersExport.xlsx");

            }
            else
            {
                return new EmptyResult();
            }
        }

        //function to import products to the database, reading uploaded excel file and making a record to db accroding to the number of rows in file
        //automatic looking if record is in db according to the title, if record exist and is the same, record will be ignored from excel
        //if record has minimum one change will be updated in DB
        [HttpPost, Route("import-submit")]
        public ActionResult ImportProducts(ImportModel model)
        {
            if (!model.Presta)
            {

                HttpPostedFileBase file = model.File;

                if ((file != null) && (file.ContentLength > 0) && !string.IsNullOrEmpty(file.FileName))
                {
                    string fileName = file.FileName;
                    string fileContentType = file.ContentType;
                    byte[] fileBytes = new byte[file.ContentLength];
                    var data = file.InputStream.Read(fileBytes, 0, Convert.ToInt32(file.ContentLength));
                    var productList = new List<ProductModel>();
                    using (var package = new ExcelPackage(file.InputStream))
                    {
                        var currentSheet = package.Workbook.Worksheets;
                        var workSheet = currentSheet.First();
                        var noOfCol = workSheet.Dimension.End.Column;
                        var noOfRow = workSheet.Dimension.End.Row;

                        for (int rowIterator = 2; rowIterator <= noOfRow; rowIterator++)
                        {
                            var product = new products();
                            var productsInDb = new products();
                            var idOfProduct = workSheet.Cells[rowIterator, 1].Value;
                            if (idOfProduct != null)
                            {
                                var idOfProd = Int32.Parse(workSheet.Cells[rowIterator, 1].Value.ToString());
                                productsInDb = db.products.SingleOrDefault(v => v.id == idOfProd);
                            }

                            if (productsInDb.id > 0)
                            {
                                var titleExcel = workSheet.Cells[rowIterator, 2].Value == null ? string.Empty : workSheet.Cells[rowIterator, 2].Value.ToString();
                                if (productsInDb.title != titleExcel)
                                {
                                    productsInDb.title = titleExcel;
                                }
                                var imageExcel = workSheet.Cells[rowIterator, 3].Value == null ? string.Empty : workSheet.Cells[rowIterator, 3].Value.ToString();
                                if (productsInDb.image != imageExcel)
                                {
                                    productsInDb.image = imageExcel;
                                }
                                var numberExcel = workSheet.Cells[rowIterator, 4].Value == null ? string.Empty : workSheet.Cells[rowIterator, 4].Value.ToString();
                                if (productsInDb.number != numberExcel)
                                {
                                    productsInDb.number = numberExcel;
                                }

                                var recom = false;
                                var sheet = workSheet.Cells[rowIterator, 5].Value.ToString();
                                if (sheet == "true" || sheet == "True")
                                {
                                    recom = true;
                                }

                                if (productsInDb.recommended != recom)
                                {
                                    productsInDb.recommended = recom;
                                }
                                var stockExcel = workSheet.Cells[rowIterator, 6].Value == null ? string.Empty : workSheet.Cells[rowIterator, 6].Value.ToString();
                                if (productsInDb.stock != stockExcel)
                                {
                                    productsInDb.stock = stockExcel;
                                }
                                var priceExcel = Decimal.Parse(workSheet.Cells[rowIterator, 7].Value == null ? string.Empty : workSheet.Cells[rowIterator, 7].Value.ToString());
                                if (productsInDb.price != priceExcel)
                                {
                                    productsInDb.price = priceExcel;
                                }
                                var dateExcel = workSheet.Cells[rowIterator, 8].Value == null ? string.Empty : workSheet.Cells[rowIterator, 8].Value.ToString();
                                if (productsInDb.date != dateExcel)
                                {
                                    productsInDb.date = dateExcel;
                                }
                                var galleryExcel = workSheet.Cells[rowIterator, 9].Value == null ? string.Empty : workSheet.Cells[rowIterator, 9].Value.ToString();
                                if (productsInDb.gallery != galleryExcel)
                                {
                                    productsInDb.gallery = galleryExcel;
                                }
                                var categoryExcel = workSheet.Cells[rowIterator, 10].Value == null ? string.Empty : workSheet.Cells[rowIterator, 10].Value.ToString();
                                if (productsInDb.category != categoryExcel)
                                {
                                    productsInDb.category = categoryExcel;
                                }
                                var weightExcel = workSheet.Cells[rowIterator, 11].Value == null ? string.Empty : workSheet.Cells[rowIterator, 11].Value.ToString();
                                if (productsInDb.weight != weightExcel)
                                {
                                    productsInDb.weight = weightExcel;
                                }
                                var WeightUnitExcel = workSheet.Cells[rowIterator, 12].Value == null ? string.Empty : workSheet.Cells[rowIterator, 12].Value.ToString();
                                if (productsInDb.weightunit != WeightUnitExcel)
                                {
                                    productsInDb.weightunit = WeightUnitExcel;
                                }
                                var descriptionExcel = workSheet.Cells[rowIterator, 13].Value == null ? string.Empty : workSheet.Cells[rowIterator, 13].Value.ToString();
                                if (productsInDb.description != descriptionExcel)
                                {
                                    productsInDb.description = descriptionExcel;
                                }
                                var discountPriceExcel = Decimal.Parse(workSheet.Cells[rowIterator, 14].Value == null ? string.Empty : workSheet.Cells[rowIterator, 14].Value.ToString());
                                if (productsInDb.discountprice != discountPriceExcel)
                                {
                                    productsInDb.discountprice = discountPriceExcel;
                                }
                                var custom1Excel = workSheet.Cells[rowIterator, 15].Value == null ? string.Empty : workSheet.Cells[rowIterator, 15].Value.ToString();
                                if (productsInDb.custom1 != custom1Excel)
                                {
                                    productsInDb.custom1 = custom1Excel;
                                }
                                var custom2Excel = workSheet.Cells[rowIterator, 16].Value == null ? string.Empty : workSheet.Cells[rowIterator, 16].Value.ToString();
                                if (productsInDb.custom2 != custom2Excel)
                                {
                                    productsInDb.custom2 = custom2Excel;
                                }
                                var custom3Excel = workSheet.Cells[rowIterator, 17].Value == null ? string.Empty : workSheet.Cells[rowIterator, 17].Value.ToString();
                                if (productsInDb.custom3 != custom3Excel)
                                {
                                    productsInDb.custom3 = custom3Excel;
                                }
                                var custom4Excel = workSheet.Cells[rowIterator, 18].Value == null ? string.Empty : workSheet.Cells[rowIterator, 18].Value.ToString();
                                if (productsInDb.custom4 != custom4Excel)
                                {
                                    productsInDb.custom4 = custom4Excel;
                                }
                                var custom5Excel = workSheet.Cells[rowIterator, 19].Value == null ? string.Empty : workSheet.Cells[rowIterator, 19].Value.ToString();
                                if (productsInDb.custom5 != custom5Excel)
                                {
                                    productsInDb.custom5 = custom5Excel;
                                }
                                var custom6Excel = workSheet.Cells[rowIterator, 20].Value == null ? string.Empty : workSheet.Cells[rowIterator, 20].Value.ToString();
                                if (productsInDb.custom6 != custom6Excel)
                                {
                                    productsInDb.custom6 = custom6Excel;
                                }
                                var custom7Excel = workSheet.Cells[rowIterator, 21].Value == null ? string.Empty : workSheet.Cells[rowIterator, 21].Value.ToString();
                                if (productsInDb.custom7 != custom7Excel)
                                {
                                    productsInDb.custom7 = custom7Excel;
                                }
                                var custom8Excel = workSheet.Cells[rowIterator, 22].Value == null ? string.Empty : workSheet.Cells[rowIterator, 22].Value.ToString();
                                if (productsInDb.custom8 != custom8Excel)
                                {
                                    productsInDb.custom8 = custom8Excel;
                                }
                                var custom9Excel = workSheet.Cells[rowIterator, 23].Value == null ? string.Empty : workSheet.Cells[rowIterator, 23].Value.ToString();
                                if (productsInDb.custom9 != custom9Excel)
                                {
                                    productsInDb.custom9 = custom9Excel;
                                }
                                var custom10Excel = workSheet.Cells[rowIterator, 24].Value == null ? string.Empty : workSheet.Cells[rowIterator, 24].Value.ToString();
                                if (productsInDb.custom10 != custom10Excel)
                                {
                                    productsInDb.custom10 = custom10Excel;
                                }

                                db.SaveChanges();
                            }
                            else
                            {
                                product.title = workSheet.Cells[rowIterator, 2].Value == null ? string.Empty : workSheet.Cells[rowIterator, 2].Value.ToString() ?? "";
                                product.image = workSheet.Cells[rowIterator, 3].Value == null ? string.Empty : workSheet.Cells[rowIterator, 3].Value.ToString() ?? "";
                                product.number = workSheet.Cells[rowIterator, 4].Value == null ? string.Empty : workSheet.Cells[rowIterator, 4].Value.ToString() ?? "";

                                var recom = false;
                                var sheet = workSheet.Cells[rowIterator, 5].Value.ToString();
                                if (sheet == "true" || sheet == "True")
                                {
                                    recom = true;
                                }

                                product.recommended = recom;
                                product.stock = workSheet.Cells[rowIterator, 6].Value == null ? string.Empty : workSheet.Cells[rowIterator, 6].Value.ToString();
                                product.price = Decimal.Parse(workSheet.Cells[rowIterator, 7].Value == null ? string.Empty : workSheet.Cells[rowIterator, 7].Value.ToString() ?? "");
                                product.date = workSheet.Cells[rowIterator, 8].Value == null ? string.Empty : workSheet.Cells[rowIterator, 8].Value.ToString() ?? "";
                                product.gallery = workSheet.Cells[rowIterator, 9].Value == null ? string.Empty : workSheet.Cells[rowIterator, 9].Value.ToString() ?? "";
                                product.category = workSheet.Cells[rowIterator, 10].Value == null ? string.Empty : workSheet.Cells[rowIterator, 10].Value.ToString() ?? "";
                                product.weight = workSheet.Cells[rowIterator, 11].Value == null ? string.Empty : workSheet.Cells[rowIterator, 11].Value.ToString() ?? "";
                                product.weightunit = workSheet.Cells[rowIterator, 12].Value == null ? string.Empty : workSheet.Cells[rowIterator, 12].Value.ToString() ?? "";
                                product.description = workSheet.Cells[rowIterator, 13].Value == null ? string.Empty : workSheet.Cells[rowIterator, 13].Value.ToString() ?? "";
                                product.discountprice = Decimal.Parse(workSheet.Cells[rowIterator, 14].Value == null ? string.Empty : workSheet.Cells[rowIterator, 14].Value.ToString() ?? "");
                                product.custom1 = workSheet.Cells[rowIterator, 15].Value == null ? string.Empty : workSheet.Cells[rowIterator, 15].Value.ToString() ?? "";
                                product.custom2 = workSheet.Cells[rowIterator, 16].Value == null ? string.Empty : workSheet.Cells[rowIterator, 16].Value.ToString() ?? "";
                                product.custom3 = workSheet.Cells[rowIterator, 17].Value == null ? string.Empty : workSheet.Cells[rowIterator, 17].Value.ToString() ?? "";
                                product.custom4 = workSheet.Cells[rowIterator, 18].Value == null ? string.Empty : workSheet.Cells[rowIterator, 18].Value.ToString() ?? "";
                                product.custom5 = workSheet.Cells[rowIterator, 19].Value == null ? string.Empty : workSheet.Cells[rowIterator, 19].Value.ToString() ?? "";
                                product.custom6 = workSheet.Cells[rowIterator, 20].Value == null ? string.Empty : workSheet.Cells[rowIterator, 20].Value.ToString() ?? "";
                                product.custom7 = workSheet.Cells[rowIterator, 21].Value == null ? string.Empty : workSheet.Cells[rowIterator, 21].Value.ToString() ?? "";
                                product.custom8 = workSheet.Cells[rowIterator, 22].Value == null ? string.Empty : workSheet.Cells[rowIterator, 22].Value.ToString() ?? "";
                                product.custom9 = workSheet.Cells[rowIterator, 23].Value == null ? string.Empty : workSheet.Cells[rowIterator, 23].Value.ToString() ?? "";
                                product.custom10 = workSheet.Cells[rowIterator, 24].Value == null ? string.Empty : workSheet.Cells[rowIterator, 24].Value.ToString() ?? "";

                                db.products.Add(product);
                                db.SaveChanges();
                            }
                        }
                    }
                }
            }
            else
            {
                HttpPostedFileBase file = model.File;

                if ((file != null) && (file.ContentLength > 0) && !string.IsNullOrEmpty(file.FileName))
                {
                    //string fileName = file.FileName;
                    //string fileContentType = file.ContentType;
                    // byte[] fileBytes = new byte[file.ContentLength];
                    // var data = file.InputStream.Read(fileBytes, 0, Convert.ToInt32(file.ContentLength));
                    // var productList = new List<ProductModel>();
                    using (TextFieldParser parser = new TextFieldParser(file.InputStream))
                    {
                        parser.TextFieldType = FieldType.Delimited;
                        parser.SetDelimiters("^");
                        bool firstLine = true;
                        List<string> attrName = new List<string>();
                        int variablecounter = 1;

                        while (!parser.EndOfData)
                        {

                            string[] fields = parser.ReadFields();
                            bool isvariant = false;

                            // get the column headers
                            if (firstLine)
                            {
                                for (var f = 111; f < 156; f++)
                                {
                                    attrName.Add(fields[f].Replace("Attribute Group: ", ""));
                                }

                                firstLine = false;
                                continue;
                            }

                            var product = new products();
                            var productsInDb = new products();
                            var productId = fields[0];

                            //ak sa jedna o duplikat pokracuj
                            if (fields[33] == "" && fields[43] == "")
                            {
                                continue;
                            }
                            else if (fields[43] != "" && fields[33] == "")
                            {
                                isvariant = true;
                            }


                            //kategoria
                            var categories = fields[34].Replace("Root|Home|", "").Replace("||", "^");
                            string[] allcategories = categories.Split('^');
                            var categoriesInDb = db.categories;
                            List<string> catsToDb = new List<string>();
                            List<string> typesToDb = new List<string>();

                            foreach (var cat in allcategories)
                            {
                                //if splneny ak nema nadradenu kategoriu
                                if (cat.ToString().IndexOf("|") == -1)
                                {
                                    var catName = cat.ToString();
                                    var catExist = categoriesInDb.Where(x => x.name.ToLower() == catName.ToLower()).FirstOrDefault();
                                    if (catExist != null)
                                    {
                                        catsToDb.Add(catExist.id.ToString());
                                    }
                                    else
                                    {
                                        var typeExist = db.types.Where(x => x.name.ToLower() == catName.ToLower()).FirstOrDefault();
                                        if (typeExist != null)
                                        {
                                            typesToDb.Add(typeExist.id.ToString());
                                        }
                                    }
                                }
                                else
                                {
                                    string[] splitcats = cat.ToString().Split('|');
                                    var lastcat = splitcats.Count() - 1;
                                    var catName = splitcats[lastcat].ToString();
                                    var catExist = categoriesInDb.Where(x => x.name.ToLower() == catName.ToLower()).FirstOrDefault();
                                    if (catExist != null)
                                    {
                                        catsToDb.Add(catExist.id.ToString());
                                    }
                                    else
                                    {
                                        var typeExist = db.types.Where(x => x.name.ToLower() == catName.ToLower()).FirstOrDefault();
                                        if (typeExist != null)
                                        {
                                            typesToDb.Add(typeExist.id.ToString());
                                        }
                                    }
                                }
                            }

                            //znacka
                            var manufacturer = fields[36];
                            var manufacturerInDb = db.brands;
                            var brandExist = manufacturerInDb.Where(x => x.name.ToLower() == manufacturer.ToLower()).FirstOrDefault();
                            if (brandExist != null)
                            {
                                product.custom3 = brandExist.id.ToString();
                            }

                            //stahovanie fotiek
                            string[] allphotos = fields[38].Split(';');

                            var ulozObrazok = DateTime.Now.Date.ToString("dd.MM.yyyy") + "/" + DateTime.Now.Ticks + "/";
                            var miestoUlozenia = "~/Uploads/" + ulozObrazok;
                            var titleImagename = "";

                            var path = Directory.CreateDirectory(Server.MapPath(miestoUlozenia));
                            //download photos
                            for (var i = 0; i < allphotos.Length; i++)
                            {
                                if (i > 0)
                                {
                                    path = Directory.CreateDirectory(Server.MapPath(miestoUlozenia + "gallery/"));
                                }

                                using (WebClient webClient = new WebClient())
                                {
                                    if (allphotos[i] != "")
                                    {
                                        try
                                        {
                                            Thread.Sleep(500);
                                            byte[] data = webClient.DownloadData(allphotos[i]);

                                            using (MemoryStream mem = new MemoryStream(data))
                                            {
                                                using (var yourImage = Image.FromStream(mem))
                                                {
                                                    // If you want it as Png
                                                    // yourImage.Save("path_to_your_file.png", ImageFormat.Png);
                                                    var imagename = DateTime.Now.Ticks.ToString();
                                                    if (i < 1)
                                                    {
                                                        titleImagename = imagename;
                                                    }
                                                    // If you want it as Jpeg
                                                    yourImage.Save(path.FullName + imagename + ".jpg", ImageFormat.Jpeg);
                                                }
                                            }
                                        }
                                        catch (Exception ex)
                                        {

                                        }
                                    }
                                }
                            }

                            product.title = fields[103];
                            product.stock = fields[6];
                            product.recommended = false;
                            product.number = fields[13];
                            product.image = miestoUlozenia.Replace("~/Uploads/", "") + titleImagename + ".jpg";
                            product.gallery = miestoUlozenia.Replace("~/Uploads/", "") + "gallery/";
                            product.category = "[" + string.Join(",", catsToDb) + "]";

                            if (typesToDb.Count > 0)
                            {
                                product.type = "[" + string.Join(",", typesToDb) + "]";
                            }

                            product.price = Decimal.Parse(fields[8]);

                            if (fields[64] != "0,05" && fields[64] != "0,08" && fields[64] != "0,1")
                            {
                                if (fields[65] == "percentage")
                                {
                                    product.discountprice = Decimal.Parse(fields[8]) - (Decimal.Parse(fields[8]) * Decimal.Parse(fields[64]));
                                }
                                else if (fields[65] == "amount")
                                {
                                    product.discountprice = Decimal.Parse(fields[8]) - Decimal.Parse(fields[64]);
                                }
                            }

                            product.date = DateTime.Now.ToString();
                            product.heureka = true;
                            product.heurekadarcektext = fields[93];
                            product.custom6 = "False";
                            if (product.heurekadarcektext != "")
                            {
                                product.heurekadarcek = true;
                            }
                            else
                            {
                                product.heurekadarcek = false;
                            }

                            product.deleted = false;
                            product.active = true;
                            product.date = DateTime.Now.ToString();
                            product.description = fields[97];

                            if (!isvariant)
                            {
                                db.products.Add(product);
                                db.SaveChanges();
                                variablecounter = 1;
                            }

                            //ci je variabilny
                            if (fields[43] != "" && isvariant) //43 - Combination Reference
                            {
                                var title = fields[103];
                                var addedproduct = db.products.Where(i => i.title == title).FirstOrDefault();
                                variants v = new variants();
                                v.prod_id = addedproduct.id;
                                v.price = Decimal.Parse(fields[8]) + Decimal.Parse(fields[49]);
                                if (fields[64] != "0,05" && fields[64] != "0,08" && fields[64] != "0,1")
                                {
                                    if (fields[65] == "percentage")
                                    {
                                        v.discountprice = Decimal.Parse(fields[8]) - (Decimal.Parse(fields[8]) * Decimal.Parse(fields[64]));
                                    }
                                    else if (fields[65] == "amount")
                                    {
                                        v.discountprice = Decimal.Parse(fields[8]) - Decimal.Parse(fields[64]);
                                    }
                                }
                                v.stock = "";
                                v.number = fields[43];
                                v.num = variablecounter;
                                variablecounter++;

                                //najdi o ktory atribut sa jedna
                                var counter = 0;
                                for (var f = 111; f < 156; f++)
                                {
                                    if (fields[f] != "")
                                    {
                                        var fieldname = attrName[counter];
                                        var attr = db.attributes.Where(i => i.name == fieldname).FirstOrDefault();
                                        v.attribute_id = attr.id;
                                        var attrVal = fields[f];
                                        var attrExist = db.variants.Where(i => i.prod_id == addedproduct.id && i.attribute_id == attr.id && i.value == attrVal).FirstOrDefault();
                                        v.value = attrVal;

                                        if (attrExist == null)
                                        {
                                            db.variants.Add(v);
                                            db.SaveChanges();
                                        }

                                        dynamic values = JsonConvert.DeserializeObject(attr.value);
                                        bool save = false;
                                        foreach (var s in values)
                                        {
                                            if (s.name != fields[f])
                                            {
                                                save = true;
                                            }
                                            else
                                            {
                                                save = false;
                                                break;
                                            }
                                        }

                                        if (save)
                                        {
                                            var itemToAdd = new JObject();
                                            itemToAdd["name"] = fields[f];
                                            values.Add(itemToAdd);
                                            attr.value = JsonConvert.SerializeObject(values);
                                            db.SaveChanges();
                                        }
                                    }
                                    counter++;
                                }
                            }
                        }
                    }
                }
            }


            return RedirectToAction("ExpImp", new { SuccesProducts = "1" });
        }

        public string GenerateSlug(string phrase)
        {
            string str = RemoveAccent(phrase).ToLower();
            // invalid chars           
            str = Regex.Replace(str, @"[^a-z0-9\s-]", "");
            // convert multiple spaces into one space   
            str = Regex.Replace(str, @"\s+", " ").Trim();
            // cut and trim 
            //str = str.Substring(0, str.Length <= 45 ? str.Length : 45).Trim();
            str = Regex.Replace(str, @"\s", "-"); // hyphens   
            return str;
        }

        public string RemoveAccent(string txt)
        {
            byte[] bytes = System.Text.Encoding.GetEncoding("Cyrillic").GetBytes(txt);
            return System.Text.Encoding.ASCII.GetString(bytes);
        }

        //function to import user meta to the database
        [HttpPost, Route("import-submit-users")]
        public ActionResult ImportUsers(FormCollection formCollection)
        {
            if (Request != null)
            {
                HttpPostedFileBase file = Request.Files["UploadedFileUsers"];

                if ((file != null) && (file.ContentLength > 0) && !string.IsNullOrEmpty(file.FileName))
                {
                    string fileName = file.FileName;
                    string fileContentType = file.ContentType;
                    byte[] fileBytes = new byte[file.ContentLength];
                    var data = file.InputStream.Read(fileBytes, 0, Convert.ToInt32(file.ContentLength));
                    var userList = new List<UsersmetaModel>();
                    using (var package = new ExcelPackage(file.InputStream))
                    {
                        var currentSheet = package.Workbook.Worksheets;
                        var workSheet = currentSheet.First();
                        var noOfCol = workSheet.Dimension.End.Column;
                        var noOfRow = workSheet.Dimension.End.Row;

                        for (int rowIterator = 2; rowIterator <= noOfRow; rowIterator++)
                        {
                            var user = new usersmeta();
                            user.name = workSheet.Cells[rowIterator, 2].Value == null ? string.Empty : workSheet.Cells[rowIterator, 2].Value.ToString();
                            user.surname = workSheet.Cells[rowIterator, 3].Value == null ? string.Empty : workSheet.Cells[rowIterator, 3].Value.ToString();
                            user.address = workSheet.Cells[rowIterator, 4].Value == null ? string.Empty : workSheet.Cells[rowIterator, 4].Value.ToString();
                            user.city = workSheet.Cells[rowIterator, 5].Value == null ? string.Empty : workSheet.Cells[rowIterator, 5].Value.ToString();
                            user.zip = workSheet.Cells[rowIterator, 6].Value == null ? string.Empty : workSheet.Cells[rowIterator, 6].Value.ToString();
                            user.phone = workSheet.Cells[rowIterator, 7].Value == null ? string.Empty : workSheet.Cells[rowIterator, 7].Value.ToString();
                            user.email = workSheet.Cells[rowIterator, 8].Value == null ? string.Empty : workSheet.Cells[rowIterator, 8].Value.ToString();
                            user.companyname = workSheet.Cells[rowIterator, 9].Value == null ? string.Empty : workSheet.Cells[rowIterator, 9].Value.ToString();
                            user.ico = workSheet.Cells[rowIterator, 10].Value == null ? string.Empty : workSheet.Cells[rowIterator, 10].Value.ToString();
                            user.dic = workSheet.Cells[rowIterator, 11].Value == null ? string.Empty : workSheet.Cells[rowIterator, 11].Value.ToString();
                            user.icdph = workSheet.Cells[rowIterator, 12].Value == null ? string.Empty : workSheet.Cells[rowIterator, 12].Value.ToString();

                            var recom = false;
                            var sheet = workSheet.Cells[rowIterator, 13].Value.ToString();
                            if (sheet == "true" || sheet == "True")
                            {
                                recom = true;
                            }
                            user.news = recom;

                            db.usersmeta.Add(user);
                            db.SaveChanges();
                        }
                    }
                }
            }

            return RedirectToAction("ExpImp", new { SuccesUsers = "1" });
        }

        //function to import user meta to the database
        [HttpPost, Route("import-submit-users-2")]
        public ActionResult ImportUsers2(FormCollection formCollection)
        {
            if (Request != null)
            {
                HttpPostedFileBase file = Request.Files["UploadedFileUsers"];

                if ((file != null) && (file.ContentLength > 0) && !string.IsNullOrEmpty(file.FileName))
                {
                    string fileName = file.FileName;
                    string fileContentType = file.ContentType;
                    byte[] fileBytes = new byte[file.ContentLength];
                    var data = file.InputStream.Read(fileBytes, 0, Convert.ToInt32(file.ContentLength));
                    var userList = new List<UsersmetaModel>();
                    using (var package = new ExcelPackage(file.InputStream))
                    {
                        var currentSheet = package.Workbook.Worksheets;
                        var workSheet = currentSheet.First();
                        var noOfCol = workSheet.Dimension.End.Column;
                        var noOfRow = workSheet.Dimension.End.Row;

                        for (int rowIterator = 2; rowIterator <= noOfRow; rowIterator++)
                        {
                            var user = new users();

                            user.username = workSheet.Cells[rowIterator, 8].Value == null ? string.Empty : workSheet.Cells[rowIterator, 8].Value.ToString();
                            user.email = workSheet.Cells[rowIterator, 8].Value == null ? string.Empty : workSheet.Cells[rowIterator, 8].Value.ToString();
                            user.password = "reset";
                            user.role = 1;
                            user.deleted = false;

                            db.users.Add(user);
                            db.SaveChanges();

                            var usersmeta = new usersmeta();
                            usersmeta.userid = db.users.Select(i => i.id).Max();
                            usersmeta.name = workSheet.Cells[rowIterator, 2].Value == null ? string.Empty : workSheet.Cells[rowIterator, 2].Value.ToString();
                            usersmeta.surname = workSheet.Cells[rowIterator, 3].Value == null ? string.Empty : workSheet.Cells[rowIterator, 3].Value.ToString();
                            usersmeta.email = workSheet.Cells[rowIterator, 8].Value == null ? string.Empty : workSheet.Cells[rowIterator, 8].Value.ToString();

                            usersmeta.address = "";
                            usersmeta.city = "";
                            usersmeta.zip = "";
                            usersmeta.country = "";
                            usersmeta.phone = "";

                            usersmeta.sum = Convert.ToDecimal(workSheet.Cells[rowIterator, 14].Value == null ? "0" : workSheet.Cells[rowIterator, 14].Value.ToString(), CultureInfo.InvariantCulture);

                            if (usersmeta.sum >= 1000)
                            {
                                usersmeta.rating = 3;
                            }
                            else if (usersmeta.sum >= 500)
                            {
                                usersmeta.rating = 2;
                            }
                            else
                            {
                                usersmeta.rating = 1;
                            }

                            usersmeta.created = workSheet.Cells[rowIterator, 16].Value == null ? string.Empty : workSheet.Cells[rowIterator, 16].Value.ToString();
                            usersmeta.deleted = false;

                            usersmeta.gdpr = workSheet.Cells[rowIterator, 15].Value == null ? false : workSheet.Cells[rowIterator, 15].Value.ToString() == "1" ? true : false;
                            usersmeta.news = workSheet.Cells[rowIterator, 13].Value == null ? false : workSheet.Cells[rowIterator, 13].Value.ToString() == "1" ? true : false;

                            db.usersmeta.Add(usersmeta);
                            db.SaveChanges();
                        }
                    }
                }
            }

            return RedirectToAction("ExpImp", new { SuccesUsers = "1" });
        }

        //TODO make an import for orders

    }
}