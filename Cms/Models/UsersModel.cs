using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace Cms.Models
{
    public class UsersModel
    {
        public int Id { get; set; }
        public string Username { get; set; }
        public string Password { get; set; }
        public string Email { get; set; }
        public int Role { get; set; }

        public List<SelectListItem> SelectionRola()
        {
            List<SelectListItem> zaradenie = new List<SelectListItem>();
            zaradenie.Add(new SelectListItem { Text = "Zákazník", Value = "1", Selected = true });
            zaradenie.Add(new SelectListItem { Text = "Admin", Value = "0" });

            return zaradenie;
        }
    }


}