# encoding: utf-8

from __future__ import annotations

from urllib.parse import urlencode
from typing import Any, Optional, cast, List, Tuple

from flask import Blueprint, make_response, abort, redirect, request

import ckan.model as model
import ckan.logic as logic
import ckan.lib.base as base
import ckan.lib.search as search
from ckan.lib.helpers import helper_functions as h

from ckan.common import g, config, current_user, _
from ckan.types import Context, Response

import logging
from collections import OrderedDict
import ckan.plugins as plugins

CACHE_PARAMETERS = ["__cache", "__no_cache__"]


home = Blueprint("home", __name__)
log = logging.getLogger(__name__)


@home.before_request
def before_request() -> None:
    """set context and check authorization"""
    try:
        context = cast(
            Context,
            {
                "model": model,
                "user": current_user.name,
                "auth_user_obj": current_user,
            },
        )
        logic.check_access("site_read", context)
    except logic.NotAuthorized:
        abort(403)


def index() -> str:
    """display home page"""
    extra_vars: dict[str, Any] = {}
    try:
        context = cast(
            Context,
            {
                "model": model,
                "session": model.Session,
                "user": current_user.name,
                "auth_user_obj": current_user,
            },
        )

        facets: dict[str, str] = OrderedDict()

        org_label = h.humanize_entity_type(
            "organization", h.default_group_type("organization"), "facet label"
        ) or _("Organizations")

        group_label = h.humanize_entity_type(
            "group", h.default_group_type("group"), "facet label"
        ) or _("Groups")

        default_facet_titles = {
            "organization": org_label,
            "groups": group_label,
            "tags": _("Tags"),
            "res_format": _("Formats"),
            "license_id": _("Licenses"),
        }

        for facet in h.facets():
            if facet in default_facet_titles:
                facets[facet] = default_facet_titles[facet]
            else:
                facets[facet] = facet

        # Facet titles
        for plugin in plugins.PluginImplementations(plugins.IFacets):
            facets = plugin.dataset_facets(facets, "dataset")

        extra_vars["facet_titles"] = facets
        data_dict: dict[str, Any] = {
            "q": "*:*",
            "facet.field": list(facets.keys()),
            "rows": 4,
            "start": 0,
            "sort": "view_recent desc",
            "fq": 'capacity:"public"',
        }

        query = logic.get_action("package_search")(context, data_dict)
        g.package_count = query["count"]
        g.datasets = query["results"]

        org_label = h.humanize_entity_type(
            "organization", h.default_group_type("organization"), "facet label"
        ) or _("Organizations")

        group_label = h.humanize_entity_type(
            "group", h.default_group_type("group"), "facet label"
        ) or _("Groups")

        g.facet_titles = {
            "organization": org_label,
            "groups": group_label,
            "tags": _("Tags"),
            "res_format": _("Formats"),
            "license": _("Licenses"),
        }

        log.info("FACETS_HOME")
        log.info(query)

        extra_vars["search_facets"] = query["search_facets"]

    except search.SearchError:
        g.package_count = 0

    if current_user.is_authenticated and not current_user.email:
        url = h.url_for("user.edit")
        msg = _(
            'Please <a href="%s">update your profile</a>'
            " and add your email address. "
        ) % url + _(
            "%s uses your email address" " if you need to reset your password."
        ) % config.get(
            "ckan.site_title"
        )
        h.flash_notice(msg, allow_html=True)
    return base.render("home/index.html", extra_vars=extra_vars)


def about() -> str:
    """display about page"""
    return base.render("home/about.html", extra_vars={})


def robots_txt() -> Response:
    """display robots.txt"""
    resp = make_response(base.render("home/robots.txt"))
    resp.headers["Content-Type"] = "text/plain; charset=utf-8"
    return resp


def redirect_locale(target_locale: str, path: Optional[str] = None) -> Any:

    target = f"/{target_locale}/{path}" if path else f"/{target_locale}"

    if request.args:
        target += f"?{urlencode(request.args)}"

    return redirect(target, code=308)


util_rules: List[Tuple[str, Any]] = [
    ("/", index),
    ("/about", about),
    ("/robots.txt", robots_txt),
]
for rule, view_func in util_rules:
    home.add_url_rule(rule, view_func=view_func)

locales_mapping: List[Tuple[str, str]] = [
    ("zh_TW", "zh_Hant_TW"),
    ("zh_CN", "zh_Hans_CN"),
    ("no", "nb_NO"),
]

for locale in locales_mapping:

    legacy_locale = locale[0]
    new_locale = locale[1]

    home.add_url_rule(
        f"/{legacy_locale}/",
        view_func=redirect_locale,
        defaults={"target_locale": new_locale},
    )

    home.add_url_rule(
        f"/{legacy_locale}/<path:path>",
        view_func=redirect_locale,
        defaults={"target_locale": new_locale},
    )
