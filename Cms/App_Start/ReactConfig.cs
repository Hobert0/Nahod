using React;

[assembly: WebActivatorEx.PreApplicationStartMethod(typeof(Cms.ReactConfig), "Configure")]

namespace Cms
{
	public static class ReactConfig
	{
		public static void Configure()
		{
		    ReactSiteConfiguration.Configuration
		        .AddScript("~/Scripts/Cms.jsx");
		}
	}
}