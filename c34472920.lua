--ハニーボット
-- 效果：
-- 电子界族怪兽2只
-- ①：这张卡所连接区的怪兽不会成为效果的对象，不会被战斗破坏。
function c34472920.initial_effect(c)
	-- 为这张卡添加连接召唤手续：使用2只电子界族怪兽作为连接素材。
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkRace,RACE_CYBERSE),2,2)
	c:EnableReviveLimit()
	-- 这张卡所连接区的怪兽不会被战斗破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1:SetTarget(c34472920.tgtg)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SET_AVAILABLE)
	c:RegisterEffect(e2)
end
-- 检查目标怪兽是否位于这张卡的所连接区（即此卡连接箭头指向的怪兽区域），以此限定效果适用的对象。
function c34472920.tgtg(e,c)
	return e:GetHandler():GetLinkedGroup():IsContains(c)
end
