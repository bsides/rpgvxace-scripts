#==============================================================================
# ** Victor Engine - Action Reflect
#------------------------------------------------------------------------------
# Author : Victor Sant
#
# Version History:
#  v 1.00 - 2012.07.16 > First release
#------------------------------------------------------------------------------
#  This script allows to setup a trait gives a chance of reflecting
# actions based on the actions or their types. That way you can create traits
# that can repel specific skills or items.
#------------------------------------------------------------------------------
# Compatibility
#   Requires the script 'Victor Engine - Basic Module' v 1.19 or higher
#
# * Alias methods
#   class Game_Battler < Game_BattlerBase
#     def item_mrf(user, item)
#
#   class Window_BattleLog < Window_Selectable
#     def display_reflection(target, item)
#
#------------------------------------------------------------------------------
# Instructions:
#  To instal the script, open you script editor and paste this script on
#  a new section bellow the Materials section. This script must also
#  be bellow the script 'Victor Engine - Basic'
#
#------------------------------------------------------------------------------
# Actors, Classes, Enemies, Weapons, Armors and States note tags:
#   Tags to be used on Actors, Classes, Enemies, Weapons, Armors and States
#   note boxes.
# 
#  <skill reflect x: +y%>   <item reflect x: +y%>
#  <skill reflect x: -y%>   <item reflect x: -y%>
#   Setup the skill or item and a rate of reflect for that action
#     x : ID of the skill or item
#     y : reflect chance
#
#  <skill type reflect x: +y%>   <item type reflect x: +y%>
#  <skill type reflect x: -y%>   <item type reflect x: -y%>
#   Setup the skill or item type and a rate of reflect for that actions
#     x : ID of the skill type or item type
#     y : reflect chance
#
#------------------------------------------------------------------------------
# Additional instructions:
#
#  If the action is magical, the action reflect chance is added to the
#  magic reflect chance.
#
#  You can edit the log window message on the module Vocab withing the script
#
#==============================================================================

#==============================================================================
# ** Victor Engine
#------------------------------------------------------------------------------
#   Setting module for the Victor Engine
#==============================================================================

module Victor_Engine
  #--------------------------------------------------------------------------
  # * required
  #   This method checks for the existance of the basic module and other
  #   VE scripts required for this script to work, don't edit this
  #--------------------------------------------------------------------------
  def self.required(name, req, version, type = nil)
    if !$imported[:ve_basic_module]
      msg = "The script '%s' requires the script\n"
      msg += "'VE - Basic Module' v%s or higher above it to work properly\n"
      msg += "Go to http://victorscripts.wordpress.com/ to download this script."
      msgbox(sprintf(msg, self.script_name(name), version))
      exit
    else
      self.required_script(name, req, version, type)
    end
  end
  #--------------------------------------------------------------------------
  # * script_name
  #   Get the script name base on the imported value
  #--------------------------------------------------------------------------
  def self.script_name(name, ext = "VE")
    name = name.to_s.gsub("_", " ").upcase.split
    name.collect! {|char| char == ext ? "#{char} -" : char.capitalize }
    name.join(" ")
  end
end

$imported ||= {}
$imported[:ve_action_reflect] = 1.00
Victor_Engine.required(:ve_action_reflect, :ve_basic_module, 1.19, :above)

#==============================================================================
# ** Vocab
#------------------------------------------------------------------------------
#  This module defines terms and messages. It defines some data as constant
# variables. Terms in the database are obtained from $data_system.
#==============================================================================

module Vocab

  # Action Counter Message
  VE_ActionReflection = "%s reflected the %s!"
  
end

#==============================================================================
# ** Game_Battler
#------------------------------------------------------------------------------
#  This class deals with battlers. It's used as a superclass of the Game_Actor
# and Game_Enemy classes.
#==============================================================================

class Game_Battler < Game_BattlerBase
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_reader   :action_reflected
  #--------------------------------------------------------------------------
  # * Alias method: item_mrf
  #--------------------------------------------------------------------------
  alias :item_mrf_ve_action_reflect :item_cnt
  def item_mrf(user, item)
    result = item_mrf_ve_action_reflect(user, item)
    action = action_reflect(item)
    @action_reflected = action > result
    result + action
  end
  #--------------------------------------------------------------------------
  # * New method: action_reflect
  #--------------------------------------------------------------------------
  def action_reflect(item)
    item_reflect(item) + item_type_reflect(item)
  end
  #--------------------------------------------------------------------------
  # * New method: item_reflect
  #--------------------------------------------------------------------------
  def item_reflect(item)
    get_action_reflect(item.skill? ? "SKILL" : "ITEM", item.id)
  end
  #--------------------------------------------------------------------------
  # * New method: item_type_reflect
  #--------------------------------------------------------------------------
  def item_type_reflect(item)
    type = item.skill? ? "SKILL TYPE" : "ITEM TYPE"
    item.type_set.inject(0.0) {|r, i| r += get_action_reflect(type, i) }
  end
  #--------------------------------------------------------------------------
  # * New method: get_action_reflect
  #--------------------------------------------------------------------------
  def get_action_reflect(type, id)
    regexp = /<#{type} REFLECT #{id}: ([+-]?\d+)%?>/i
    get_all_notes.scan(regexp).inject(0.0) {|r| r += ($1.to_i / 100.0) }
  end
end

#==============================================================================
# ** Window_BattleLog
#------------------------------------------------------------------------------
#  This window shows the battle progress. Do not show the window frame.
#==============================================================================

class Window_BattleLog < Window_Selectable
  #--------------------------------------------------------------------------
  # * Alias method: display_reflection
  #--------------------------------------------------------------------------
  alias :display_reflection_ve_action_reflect :display_reflection
  def display_reflection(target, item)
    if target.action_reflected
      Sound.play_reflection
      add_text(sprintf(Vocab::VE_ActionReflection, target.name, item.name))
      wait
      back_one unless $imported[:ve_animated_battle]
    else
      display_reflection_ve_action_reflect(target, item)
    end
  end
end