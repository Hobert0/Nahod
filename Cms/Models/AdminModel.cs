using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Web;

namespace Cms.Models
{
    public class AdminModel
    {
        [Required(ErrorMessage = "Meno je vyžadované!")]
        public string Username { get; set; }

        [Required(ErrorMessage = "Heslo je vyžadované!")]
        public string Password { get; set; }

        public string ReturnUrl { get; set; }
    }
}