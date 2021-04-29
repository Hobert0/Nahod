using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Web;

namespace Cms.Models
{
    public class TypesModel
    {
        public int Id { get; set; }
        [Required(ErrorMessage = "Názov je vyžadovaný!")]
        public string Name { get; set; }
        public string Slug { get; set; }
        public string Description { get; set; }
        public string Image { get; set; }
        public HttpPostedFileBase[] TitleImage { get; set; }
    }
}