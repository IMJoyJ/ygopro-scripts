--EMレビュー・ダンサー
-- 效果：
-- ①：对方场上有怪兽存在，自己场上没有怪兽存在的场合，这张卡可以从手卡特殊召唤。
-- ②：「娱乐伙伴」怪兽上级召唤的场合，这张卡可以作为2只的数量解放。
function c36527535.initial_effect(c)
	-- ①：对方场上有怪兽存在，自己场上没有怪兽存在的场合，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c36527535.sprcon)
	c:RegisterEffect(e1)
	-- ②：「娱乐伙伴」怪兽上级召唤的场合，这张卡可以作为2只的数量解放。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_DOUBLE_TRIBUTE)
	e2:SetValue(c36527535.dtcon)
	c:RegisterEffect(e2)
end
-- 当满足条件时，允许从手卡特殊召唤此卡，条件为己方场上无怪兽、对方场上有机场怪兽且有可用召唤区域。
function c36527535.sprcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 判断己方场上是否没有怪兽。
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
		-- 判断对方场上是否有怪兽。
		and Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0
		-- 判断己方场上是否有可用召唤区域。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
end
-- 判断此卡是否为「娱乐伙伴」卡组的怪兽。
function c36527535.dtcon(e,c)
	return c:IsSetCard(0x9f)
end
