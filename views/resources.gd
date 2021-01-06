extends Control

onready var _volatiles_label: Label = find_node("Volatiles")
onready var _metals_label: Label = find_node("Metals")
onready var _carbon_label: Label = find_node("Carbon")
onready var _silicates_label: Label = find_node("Silicates")

func _on_state_changed(state_key: String, substate):
  match state_key:
    "volatiles":
      _volatiles_label.text = "Volatiles: {amount}".format({"amount": substate})
    "metals":
      _metals_label.text = "Metals: {amount}".format({"amount": substate})
    "carbon":
      _carbon_label.text = "Carbon: {amount}".format({"amount": substate})
    "silicates":
      _silicates_label.text = "Silicates: {amount}".format({"amount": substate})

func _ready():
  Store.connect("state_changed", self, "_on_state_changed")
