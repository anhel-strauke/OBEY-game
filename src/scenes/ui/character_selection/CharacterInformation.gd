extends Node2D

onready var images = {
	Constants.Reptiloid: $CharacterSprite/Reptiloid,
	Constants.Mason: $CharacterSprite/Mason,
	Constants.Tower5G: $CharacterSprite/Tower5G,
	Constants.Grayman: $CharacterSprite/Grayman
}
onready var label = $descr_animation/Label

const Descriptions = {
	Constants.Reptiloid: ("Их агенты способны притвориться королевой, президентом и крокодиловой " +
						  "сумочкой, некоторые даже одновременно! Они жаждут власти над человечеством. " +
						  "И они собираются убивать всех на своем пути."),
	Constants.Mason: ("Это существо хочет видеть себя единственным повелителем Земли. " +
					  "У него хватит бабок, чтобы отгородиться от любого шлимазла с винтовкой. " +
					  "И оно слишком благоразумно, чтобы оставлять в живых кого-то ещё."),
	Constants.Tower5G: ("Ее излучение разжижает твой мозжечок надежнее, чем компьютерные игры. " +
						"Как  только тебя коснется ее радиоволна - ты уже зазомбирован и не " +
						"можешь даже пошевелиться без ее приказа. Называй её «Ваше Высочество»"),
	Constants.Grayman: ("Серые человечки небольшого размера, но индекс их квази-мозговой активности " +
						"превышает индекс массы тела в тысячи раз! Их чуждый разум изобрел " +
						"ультра-гипероружие, которое  страшно даже представить. Они могут втоптать в " +
						"грязь саму Землю. И твою самооценку.")
}


func display_character(name: String) -> void:
	for img_name in images.keys():
		images[img_name].visible = img_name == name
	if name != "":
		label.text = Descriptions[name]
	
