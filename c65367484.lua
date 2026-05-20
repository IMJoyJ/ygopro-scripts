--フォトン・スラッシャー
-- 效果：
-- 这张卡不能通常召唤。自己场上没有怪兽存在的场合可以特殊召唤。
-- ①：自己场上有这张卡以外的怪兽存在的场合，这张卡不能攻击。
function c65367484.initial_effect(c)
	c:EnableReviveLimit()
	-- 自己场上没有怪兽存在的场合可以特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c65367484.spcon)
	c:RegisterEffect(e1)
	-- ①：自己场上有这张卡以外的怪兽存在的场合，这张卡不能攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_CANNOT_ATTACK)
	e2:SetCondition(c65367484.atcon)
	c:RegisterEffect(e2)
end
-- 定义特殊召唤规则的条件函数，判断自身能否从手牌特殊召唤
function c65367484.spcon(e,c)
	if c==nil then return true end
	-- 检查自己场上的怪兽数量是否为0
	return Duel.GetFieldGroupCount(c:GetControler(),LOCATION_MZONE,0)==0
		-- 且自己场上存在可用的怪兽区域
		and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
end
-- 定义不能攻击效果的条件函数，判断自己场上是否存在这张卡以外的怪兽
function c65367484.atcon(e)
	-- 检查自己场上的怪兽数量是否大于1（即存在这张卡以外的怪兽）
	return Duel.GetFieldGroupCount(e:GetHandlerPlayer(),LOCATION_MZONE,0)>1
end
