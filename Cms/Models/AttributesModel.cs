using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Web;

namespace Cms.Models
{
    public class AttributesModel
    {
        public int Id { get; set; }
        [Required(ErrorMessage = "Názov je vyžadovaný!")]
        public string Name { get; set; }
        public string Value { get; set; }
    }
}