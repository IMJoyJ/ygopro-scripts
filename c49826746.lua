--黒翼の魔術師
-- 效果：
-- 只要这张卡在自己场上表侧表示存在，这张卡的控制者可以在「爆裂模式」盖放的回合发动。
function c49826746.initial_effect(c)
	-- 记录该卡具有「爆裂模式」这张卡的卡片密码
	aux.AddCodeList(c,80280737)
	-- 只要这张卡在自己场上表侧表示存在，这张卡的控制者可以在「爆裂模式」盖放的回合发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(49826746,0))  --"适用「黑翼的魔术师」的效果来发动"
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
	e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_SZONE,0)
	-- 设置效果目标为拥有指定卡片密码的魔法陷阱卡
	e1:SetTarget(aux.TargetBoolFunction(Card.IsCode,80280737))
	c:RegisterEffect(e1)
end
