--黒翼の魔術師
-- 效果：
-- 只要这张卡在自己场上表侧表示存在，这张卡的控制者可以在「爆裂模式」盖放的回合发动。
function c49826746.initial_effect(c)
	-- 将卡号80280737（「爆裂模式」）登记到这张卡的代码列表中，用于标记这张卡的效果记载着「爆裂模式」这一卡名，以便后续通过卡号匹配对应的卡。
	aux.AddCodeList(c,80280737)
	-- 只要这张卡在自己场上表侧表示存在，这张卡的控制者可以在「爆裂模式」盖放的回合发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(49826746,0))  --"适用「黑翼的魔术师」的效果来发动"
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
	e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_SZONE,0)
	-- 将效果适用对象限定为卡号为80280737的「爆裂模式」卡片；结合EFFECT_FLAG_SET_AVAILABLE，表示在场上里侧表示的该卡片也能受此效果影响，从而允许其在盖放回合发动。
	e1:SetTarget(aux.TargetBoolFunction(Card.IsCode,80280737))
	c:RegisterEffect(e1)
end
