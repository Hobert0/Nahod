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
        public string Type { get; set; }
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
        public string Variants { get; set; }


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

        /*Velkost*/
        public List<SelectListItem> SelectionSize()
        {
            List<SelectListItem> size = new List<SelectListItem>();

            size.Add(new SelectListItem { Text = "XS", Value = "XS" });
            size.Add(new SelectListItem { Text = "S", Value = "S" });
            size.Add(new SelectListItem { Text = "M", Value = "M" });
            size.Add(new SelectListItem { Text = "L", Value = "L" });
            size.Add(new SelectListItem { Text = "XL", Value = "XL" });
            size.Add(new SelectListItem { Text = "XXL", Value = "XXL" });

            return size;
        }

        /*Velkost-tenisky*/
        public List<SelectListItem> SelectionShoes()
        {
            List<SelectListItem> shoes = new List<SelectListItem>();

            shoes.Add(new SelectListItem { Text = "35", Value = "35" });
            shoes.Add(new SelectListItem { Text = "36", Value = "36" });
            shoes.Add(new SelectListItem { Text = "37", Value = "37" });
            shoes.Add(new SelectListItem { Text = "38", Value = "38" });
            shoes.Add(new SelectListItem { Text = "39", Value = "39" });
            shoes.Add(new SelectListItem { Text = "40", Value = "40" });
            shoes.Add(new SelectListItem { Text = "41", Value = "41" });
            shoes.Add(new SelectListItem { Text = "42", Value = "42" });
            shoes.Add(new SelectListItem { Text = "43", Value = "43" });
            shoes.Add(new SelectListItem { Text = "44", Value = "44" });
            shoes.Add(new SelectListItem { Text = "45", Value = "45" });
            shoes.Add(new SelectListItem { Text = "46", Value = "46" });

            return shoes;
        }

        /*Velkost - kosiky*/
        public List<SelectListItem> SelectionSizeBra1()
        {
            List<SelectListItem> size = new List<SelectListItem>();

            size.Add(new SelectListItem { Text = "AA", Value = "AA" });
            size.Add(new SelectListItem { Text = "A", Value = "A" });
            size.Add(new SelectListItem { Text = "B", Value = "B" });
            size.Add(new SelectListItem { Text = "C", Value = "C" });
            size.Add(new SelectListItem { Text = "D", Value = "D" });
            size.Add(new SelectListItem { Text = "E", Value = "E" });
            size.Add(new SelectListItem { Text = "F", Value = "F" });
            size.Add(new SelectListItem { Text = "G", Value = "G" });
            size.Add(new SelectListItem { Text = "H", Value = "H" });
            size.Add(new SelectListItem { Text = "I", Value = "I" });
            size.Add(new SelectListItem { Text = "J", Value = "J" });
            size.Add(new SelectListItem { Text = "K", Value = "K" });
            size.Add(new SelectListItem { Text = "DD", Value = "DD" });
            size.Add(new SelectListItem { Text = "FF", Value = "FF" });
            size.Add(new SelectListItem { Text = "GG", Value = "GG" });
            size.Add(new SelectListItem { Text = "BB", Value = "BB" });

            return size;
        }

        /*Velkost - OBVOD*/
        public List<SelectListItem> SelectionSizeBra2()
        {
            List<SelectListItem> size = new List<SelectListItem>();

            size.Add(new SelectListItem { Text = "28", Value = "28" });
            size.Add(new SelectListItem { Text = "30", Value = "30" });
            size.Add(new SelectListItem { Text = "32", Value = "32" });
            size.Add(new SelectListItem { Text = "34", Value = "34" });
            size.Add(new SelectListItem { Text = "36", Value = "36" });
            size.Add(new SelectListItem { Text = "38", Value = "38" });
            size.Add(new SelectListItem { Text = "40", Value = "40" });
            size.Add(new SelectListItem { Text = "65", Value = "65" });
            size.Add(new SelectListItem { Text = "70", Value = "70" });
            size.Add(new SelectListItem { Text = "75", Value = "75" });
            size.Add(new SelectListItem { Text = "80", Value = "80" });
            size.Add(new SelectListItem { Text = "85", Value = "85" });
            size.Add(new SelectListItem { Text = "90", Value = "90" });
            size.Add(new SelectListItem { Text = "95", Value = "95" });
            size.Add(new SelectListItem { Text = "100", Value = "100" });
            size.Add(new SelectListItem { Text = "105", Value = "105" });

            return size;
        }
    }
}