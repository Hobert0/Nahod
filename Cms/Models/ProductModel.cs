using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace Cms.Models
{
    public class ProductModel
    {
        public int Id { get; set; }
        [Required(ErrorMessage = "Názov je vyžadovaný!")]
        public string Title { get; set; }
        public string Image { get; set; }
        public string Number { get; set; }
        public string Stock { get; set; }
        [Required(ErrorMessage = "Cena je vyžadovaná!")]
        public string Price { get; set; }
        public string Date { get; set; }
        public string Gallery { get; set; }
        public string Category { get; set; }
        public string Weight { get; set; }
        public string Weightunit { get; set; }
        public string Custom1 { get; set; }
        public string Custom2 { get; set; }
        public string Custom3 { get; set; }
        [AllowHtml]
        public string Custom4 { get; set; }
        public string Custom5 { get; set; }
        public bool Custom6{ get; set; }
        public string Custom7 { get; set; }
        public string Custom8 { get; set; }
        public string Custom9 { get; set; }
        public string Custom10 { get; set; }
        public bool Recommended { get; set; }
        [AllowHtml]
        public string Description { get; set; }
        public string Discountprice { get; set; }
        public HttpPostedFileBase[] TitleImage { get; set; }
        public HttpPostedFileBase[] ImageGallery { get; set; }


        /*Merna jednotka*/
        public List<SelectListItem> SelectionMernaJ()
        {
            List<SelectListItem> mj = new List<SelectListItem>();

                mj.Add(new SelectListItem { Text = "ks", Value = "ks" });
                mj.Add(new SelectListItem { Text = "m", Value = "m" });
                mj.Add(new SelectListItem { Text = "pár", Value = "pár" });
                mj.Add(new SelectListItem { Text = "sada", Value = "sada" });
                mj.Add(new SelectListItem { Text = "-", Value = "-" });

            return mj;
        }
        /*Hmotnost*/
        public List<SelectListItem> SelectionHmotnost()
        {
            List<SelectListItem> weight = new List<SelectListItem>();

            weight.Add(new SelectListItem { Text = "kg", Value = "kg" });
            weight.Add(new SelectListItem { Text = "t", Value = "t" });
            weight.Add(new SelectListItem { Text = "dkg", Value = "dkg" });
            weight.Add(new SelectListItem { Text = "g", Value = "g" });
            weight.Add(new SelectListItem { Text = "-", Value = "-" });

            return weight;
        }


        /*Typ klinatizacie*/
        public List<SelectListItem> SelectionTyp()
        {
            List<SelectListItem> size = new List<SelectListItem>();

            size.Add(new SelectListItem { Text = "", Value = "" });
            size.Add(new SelectListItem { Text = "Nástenná", Value = "Nástenná" });
            size.Add(new SelectListItem { Text = "Kazetová", Value = "Kazetová" });
            size.Add(new SelectListItem { Text = "Kanálová", Value = "Kanálová" });
            size.Add(new SelectListItem { Text = "Parapetná", Value = "Parapetná" });
            size.Add(new SelectListItem { Text = "Podstropná", Value = "Podstropná" });

            return size;
        }
    }
}