--ハニーボット
-- 效果：
-- 电子界族怪兽2只
-- ①：这张卡所连接区的怪兽不会成为效果的对象，不会被战斗破坏。
function c34472920.initial_effect(c)
	-- 添加连接召唤手续，要求使用2只电子界族连接素材
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkRace,RACE_CYBERSE),2,2)
	c:EnableReviveLimit()
	-- ①：这张卡所连接区的怪兽不会成为效果的对象，不会被战斗破坏。
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
-- 目标怪兽为连接区中的怪兽时，该效果生效
function c34472920.tgtg(e,c)
	return e:GetHandler():GetLinkedGroup():IsContains(c)
end
