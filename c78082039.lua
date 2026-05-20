--クローザー・フォレスト
-- 效果：
-- 自己墓地存在的怪兽每有1只，自己场上表侧表示存在的兽族怪兽的攻击力上升100。只要这张卡在场上存在，不能把场地魔法卡发动。此外，这张卡被破坏的回合，不能把场地魔法卡发动。
function c78082039.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 自己墓地存在的怪兽每有1只，自己场上表侧表示存在的兽族怪兽的攻击力上升100。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	-- 设置效果影响的目标为兽族怪兽
	e2:SetTarget(aux.TargetBoolFunction(Card.IsRace,RACE_BEAST))
	e2:SetValue(c78082039.val)
	c:RegisterEffect(e2)
	-- 只要这张卡在场上存在，不能把场地魔法卡发动。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_ACTIVATE)
	e3:SetRange(LOCATION_FZONE)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetTargetRange(1,1)
	e3:SetValue(c78082039.efilter)
	c:RegisterEffect(e3)
	-- 此外，这张卡被破坏的回合，不能把场地魔法卡发动。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_DESTROYED)
	e4:SetOperation(c78082039.desop)
	c:RegisterEffect(e4)
end
-- 计算攻击力上升值的回调函数
function c78082039.val(e,c)
	-- 获取自己墓地的怪兽数量并乘以100
	return Duel.GetMatchingGroupCount(Card.IsType,e:GetHandlerPlayer(),LOCATION_GRAVE,0,nil,TYPE_MONSTER)*100
end
-- 过滤出场地魔法卡的发动效果
function c78082039.efilter(e,re,tp)
	return re:GetHandler():IsType(TYPE_FIELD) and re:IsHasType(EFFECT_TYPE_ACTIVATE)
end
-- 被破坏时的效果处理，注册一个直到回合结束前限制场地魔法卡发动的效果
function c78082039.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 此外，这张卡被破坏的回合，不能把场地魔法卡发动。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,1)
	e1:SetValue(c78082039.efilter)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将限制场地魔法卡发动的效果注册给玩家
	Duel.RegisterEffect(e1,tp)
end
