using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Web;

namespace Cms.Models
{
    public class CouponsModel
    {
        public int Id { get; set; }
        [Required(ErrorMessage = "Názov je vyžadovaný!")]
        public string Coupon { get; set; }
        [Required(ErrorMessage = "Hodnota je vyžadovaná!")]
        public string Amount { get; set; }
        public int? Limit { get; set; }
        public int? CategoryId { get; set; }
        public int? TypeId { get; set; }
        public int? BrandId { get; set; }
        public int? ProductId { get; set; }
        public bool Active { get; set; }
    }
}