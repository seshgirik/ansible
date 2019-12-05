#!/usr/bin/python

#===================== imports ========================

import re
import sys
#import sys, math
import yaml;
import collections
import os
import uuid
import datetime
#====================== constants ======================

#====================== functions ======================
# function to preserve order
def dict_representer(dumper, data):
    return dumper.represent_dict(data.iteritems())

def dict_constructor(loader, node):
    return collections.OrderedDict(loader.construct_pairs(node))

# function to add quotes
def represent_str(self, data):
    tag = None
    style = None
    # Add these two lines:
    if '{' in data or '}' in data or ' ' in data:
        style = '"'
    try:
        data = unicode(data, 'ascii')
        tag = u'tag:yaml.org,2002:str'
    except UnicodeDecodeError:
        try:
            data = unicode(data, 'utf-8')
            tag = u'tag:yaml.org,2002:str'
        except UnicodeDecodeError:
            data = data.encode('base64')
            tag = u'tag:yaml.org,2002:binary'
            style = '|'
    return self.represent_scalar(tag, data, style=style)


#======================== START  =========================
if len(sys.argv) != 3 :
   print "usage: ", sys.argv[0], "<stack_operation_env_filename> <command>"
   exit(1)

cwd = os.getcwd()
dir_path = os.path.dirname(os.path.realpath(__file__))

# preserve order of original yaml config file
_mapping_tag = yaml.resolver.BaseResolver.DEFAULT_MAPPING_TAG
yaml.add_representer(collections.OrderedDict, dict_representer)
yaml.add_constructor(_mapping_tag, dict_constructor)

template_env_filename= sys.argv[1]
common_env_filename= sys.argv[2]
# open common env file.
in_stream = open(common_env_filename, 'r')
common_env_data = yaml.load(in_stream)
in_stream.close()

# open user env file and update original yaml config file.
template_env_stream = open(template_env_filename, 'r+')
template_env_data = yaml.load(template_env_stream)
template_env_stream.close()

# add quotes
yaml.add_representer(str, represent_str)

for key in template_env_data['parameters']:
   #print "key =", key
   if key in common_env_data.keys():
      #print "common:", key, common_env_data[key]
      if common_env_data[key] is not None:
         template_env_data['parameters'][key]=common_env_data[key]

with open(template_env_filename, 'w+') as yaml_file:
    yaml_file.write( yaml.dump(template_env_data, default_flow_style=False, encoding=None, width=10000000))
#print yaml.dump(template_env_data, default_flow_style=False, encoding='UTF-8', width=10000000)


