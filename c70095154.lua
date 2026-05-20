--サイバー・ドラゴン
-- 效果：
-- ①：只有对方场上才有怪兽存在的场合，这张卡可以从手卡特殊召唤。
function c70095154.initial_effect(c)
	-- ①：只有对方场上才有怪兽存在的场合，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c70095154.spcon)
	c:RegisterEffect(e1)
end
-- 判断自身特殊召唤的条件是否满足（自己场上没有怪兽，对方场上有怪兽，且自己场上有可用的怪兽区域）
function c70095154.spcon(e,c)
	if c==nil then return true end
	-- 判断自己场上的怪兽数量是否为0
	return Duel.GetFieldGroupCount(c:GetControler(),LOCATION_MZONE,0)==0
		-- 判断对方场上的怪兽数量是否大于0
		and	Duel.GetFieldGroupCount(c:GetControler(),0,LOCATION_MZONE)>0
		-- 判断自己场上是否有可用的怪兽区域
		and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
end
