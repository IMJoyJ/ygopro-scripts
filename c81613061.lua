--ウォークライ・ミーディアム
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：只要特殊召唤的怪兽在对方场上存在并在自己场上有7星以上的「战吼」怪兽存在，双方的主要阶段1内，双方不能把场上的怪兽的效果发动。
-- ②：自己主要阶段才能发动。从卡组选「战吼灵媒」以外的1张「战吼」魔法·陷阱卡在自己场上盖放。这个效果的发动后，直到回合结束时自己不是战士族怪兽不能特殊召唤。
function c81613061.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：只要特殊召唤的怪兽在对方场上存在并在自己场上有7星以上的「战吼」怪兽存在，双方的主要阶段1内，双方不能把场上的怪兽的效果发动。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_ACTIVATE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(1,1)
	e2:SetCondition(c81613061.actcon)
	e2:SetValue(c81613061.aclimit)
	c:RegisterEffect(e2)
	-- ②：自己主要阶段才能发动。从卡组选「战吼灵媒」以外的1张「战吼」魔法·陷阱卡在自己场上盖放。这个效果的发动后，直到回合结束时自己不是战士族怪兽不能特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(81613061,0))
	e3:SetCategory(CATEGORY_SSET)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,81613061)
	e3:SetTarget(c81613061.settg)
	e3:SetOperation(c81613061.setop)
	c:RegisterEffect(e3)
end
-- 过滤条件：自己场上表侧表示的7星以上的「战吼」怪兽
function c81613061.actfilter(c)
	return c:IsSetCard(0x15f) and c:IsLevelAbove(7) and c:IsFaceup()
end
-- 检查是否处于主要阶段1，且对方场上有特殊召唤的怪兽存在，且自己场上有7星以上的「战吼」怪兽存在
function c81613061.actcon(e)
	local tp=e:GetHandlerPlayer()
	-- 检查当前阶段是否为主要阶段1
	return Duel.GetCurrentPhase()==PHASE_MAIN1
		-- 检查对方场上是否存在特殊召唤的怪兽
		and Duel.IsExistingMatchingCard(Card.IsSummonType,tp,0,LOCATION_MZONE,1,nil,SUMMON_TYPE_SPECIAL)
		-- 检查自己场上是否存在表侧表示的7星以上的「战吼」怪兽
		and Duel.IsExistingMatchingCard(c81613061.actfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 限制发动的效果类型：场上发动的怪兽的效果
function c81613061.aclimit(e,re,tp)
	return re:IsActiveType(TYPE_MONSTER) and re:GetHandler():IsLocation(LOCATION_MZONE)
end
-- 过滤条件：卡组中「战吼灵媒」以外的可以盖放的「战吼」魔法·陷阱卡
function c81613061.setfilter(c)
	return c:IsSetCard(0x15f) and c:IsType(TYPE_SPELL+TYPE_TRAP) and not c:IsCode(81613061) and c:IsSSetable()
end
-- 效果②的发动准备：检查卡组中是否存在可盖放的符合条件的卡
function c81613061.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动准备阶段，检查卡组中是否存在至少1张满足过滤条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c81613061.setfilter,tp,LOCATION_DECK,0,1,nil) end
end
-- 效果②的处理：从卡组选择1张符合条件的卡盖放，并适用特殊召唤限制
function c81613061.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 给玩家发送提示信息：请选择要盖放的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 让玩家从卡组选择1张满足过滤条件的卡
	local g=Duel.SelectMatchingCard(tp,c81613061.setfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡在自己场上盖放
		Duel.SSet(tp,g)
	end
	-- 这个效果的发动后，直到回合结束时自己不是战士族怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c81613061.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将不能特殊召唤非战士族怪兽的限制效果注册给发动效果的玩家
	Duel.RegisterEffect(e1,tp)
end
-- 特殊召唤限制：不能特殊召唤非战士族的怪兽
function c81613061.splimit(e,c)
	return not c:IsRace(RACE_WARRIOR)
end
