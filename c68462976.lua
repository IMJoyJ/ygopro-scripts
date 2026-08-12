--魔法族の里
-- 效果：
-- ①：只有自己场上才有魔法师族怪兽存在的场合，对方不能把魔法卡发动。
-- ②：自己场上没有魔法师族怪兽存在的场合，自己不能把魔法卡发动。
function c68462976.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：只有自己场上才有魔法师族怪兽存在的场合，对方不能把魔法卡发动。②：自己场上没有魔法师族怪兽存在的场合，自己不能把魔法卡发动。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_ADJUST)
	e2:SetRange(LOCATION_FZONE)
	e2:SetOperation(c68462976.adjustop)
	c:RegisterEffect(e2)
	-- ①：只有自己场上才有魔法师族怪兽存在的场合，对方不能把魔法卡发动。②：自己场上没有魔法师族怪兽存在的场合，自己不能把魔法卡发动。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_ACTIVATE)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetRange(LOCATION_FZONE)
	e3:SetTargetRange(1,1)
	e3:SetLabel(0)
	e3:SetValue(c68462976.actlimit)
	c:RegisterEffect(e3)
	e2:SetLabelObject(e3)
end
-- 限制魔法卡发动的条件函数：根据当前的Label标记值，在满足对应条件时阻止自身或对方发动魔法卡。
function c68462976.actlimit(e,te,tp)
	if not te:IsHasType(EFFECT_TYPE_ACTIVATE) or not te:IsActiveType(TYPE_SPELL) then return false end
	if tp==e:GetHandlerPlayer() then return e:GetLabel()==1
	else return e:GetLabel()==2 end
end
-- 过滤条件：场上表侧表示的魔法师族怪兽。
function c68462976.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_SPELLCASTER)
end
-- 状态调整函数：实时检测双方场上是否存在魔法师族怪兽，并根据检测结果更新限制发动效果的Label标记值。
function c68462976.adjustop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在表侧表示的魔法师族怪兽。
	local b1=Duel.IsExistingMatchingCard(c68462976.filter,tp,LOCATION_MZONE,0,1,nil)
	-- 检查对方场上是否存在表侧表示的魔法师族怪兽。
	local b2=Duel.IsExistingMatchingCard(c68462976.filter,tp,0,LOCATION_MZONE,1,nil)
	local te=e:GetLabelObject()
	if not b1 then te:SetLabel(1)
	elseif b1 and not b2 then te:SetLabel(2)
	else te:SetLabel(0) end
end
