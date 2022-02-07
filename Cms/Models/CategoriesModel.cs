using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Web;

namespace Cms.Models
{
    public class CategoriesModel
    {
        public int Id { get; set; }
        [Required(ErrorMessage = "Názov je vyžadovaný!")]
        public string Name { get; set; }
        public string Slug { get; set; }
        public string Topcat { get; set; }
        public string Topcat2 { get; set; }
        public string Maincat { get; set; }
        public string Description { get; set; }
        public bool Heureka { get; set; }
        public bool HeurekaDarcek { get; set; }
        public string HeurekaDarcekText { get; set; }
        public string HeurekaKategoria { get; set; }
        public string HeurekaKategoriaNazov { get; set; }
        public string Image { get; set; }
        public string FbImag { get; set; }

        public int Ordering { get; set; }
        public HttpPostedFileBase[] TitleImage { get; set; }
        public HttpPostedFileBase[] FBImage { get; set; }

    }
}