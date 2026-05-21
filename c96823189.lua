--誇りと魂の龍
-- 效果：
-- 这张卡不能通常召唤。对方墓地有卡25张以上存在的场合才能特殊召唤。
-- ①：只要自己墓地有卡25张以上存在，这张卡的攻击力·守备力上升2500。
local s,id,o=GetID()
-- 初始化效果注册函数，设置苏生限制、不能通常召唤限制、手牌特殊召唤规则以及在场上时攻守上升的永续效果
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- 对方墓地有卡25张以上存在的场合才能特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))  --"攻击力·守备力上升"
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetRange(LOCATION_HAND)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetCondition(s.condition)
	c:RegisterEffect(e2)
	-- ①：只要自己墓地有卡25张以上存在，这张卡的攻击力·守备力上升2500。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetCondition(s.atkcon)
	e3:SetValue(2500)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e4)
end
-- 特殊召唤规则的条件函数，判断是否满足特殊召唤的场地空格和对方墓地卡数条件
function s.condition(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 返回自己场上有可用的怪兽区域，且对方墓地的卡片数量在25张以上
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.GetFieldGroupCount(tp,0,LOCATION_GRAVE)>=25
end
-- 攻击力·守备力上升效果的启用条件函数，判断自己墓地卡数是否满足条件
function s.atkcon(e)
	-- 返回自己墓地的卡片数量在25张以上
	return Duel.GetFieldGroupCount(e:GetHandlerPlayer(),LOCATION_GRAVE,0)>=25
end
