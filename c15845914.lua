--結束と絆の魔導師
-- 效果：
-- 这张卡不能通常召唤。自己墓地有卡25张以上存在的场合才能特殊召唤。
-- ①：只要对方墓地有卡25张以上存在，这张卡的攻击力·守备力上升2500。
local s,id,o=GetID()
-- 为这张卡添加苏生限制，并注册不可无效不可复制的特殊召唤条件（不能通常召唤的规则限制）、手卡规则特殊召唤手续（自己墓地有25张以上卡时才能从手卡特殊召唤），以及在场上时根据对方墓地卡数提升攻击力和守备力的永续效果。
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- 自己墓地有卡25张以上存在的场合才能特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetRange(LOCATION_HAND)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetCondition(s.condition)
	c:RegisterEffect(e2)
	-- ①：只要对方墓地有卡25张以上存在，这张卡的攻击力·守备力上升2500。
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
-- 特殊召唤手续的条件判定：当判定对象卡不存在时返回真以允许默认处理；否则检查该卡的控制者场上主要怪兽区是否有空位，且其墓地中卡的数量是否达到25张以上。
function s.condition(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 返回真需要同时满足：该控制者主要怪兽区有可用区域，且其墓地卡数不少于25张。
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.GetFieldGroupCount(tp,LOCATION_GRAVE,0)>=25
end
-- 攻击力/守备力上升效果的适用条件判定：本卡控制者的对方墓地中卡的数量不少于25张。
function s.atkcon(e)
	-- 返回对方墓地卡数是否达到25张以上，以此决定攻击力·守备力是否上升2500。
	return Duel.GetFieldGroupCount(e:GetHandlerPlayer(),0,LOCATION_GRAVE)>=25
end
