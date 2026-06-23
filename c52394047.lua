--剣闘海戦
-- 效果：
-- ①：只要这张卡在魔法与陷阱区域存在并在自己场上有「剑斗兽」怪兽存在，可以攻击的对方怪兽必须作出攻击。
-- ②：1回合1次，从自己的手卡·墓地让1只「剑斗兽」怪兽回到卡组，以自己场上1只「剑斗兽」怪兽为对象才能发动。那只怪兽的攻击力直到回合结束时上升原本守备力数值。
-- ③：魔法与陷阱区域的这张卡被效果破坏的场合才能发动。这个回合，自己的「剑斗兽」怪兽不会被战斗破坏。
function c52394047.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：只要这张卡在魔法与陷阱区域存在并在自己场上有「剑斗兽」怪兽存在，可以攻击的对方怪兽必须作出攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_MUST_ATTACK)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetCondition(c52394047.macon)
	c:RegisterEffect(e2)
	-- ②：1回合1次，从自己的手卡·墓地让1只「剑斗兽」怪兽回到卡组，以自己场上1只「剑斗兽」怪兽为对象才能发动。那只怪兽的攻击力直到回合结束时上升原本守备力数值。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1)
	e3:SetHintTiming(TIMING_DAMAGE_STEP)
	-- 限制效果只能在伤害计算前的时机发动或适用
	e3:SetCondition(aux.dscon)
	e3:SetCost(c52394047.atkcost)
	e3:SetTarget(c52394047.atktg)
	e3:SetOperation(c52394047.atkop)
	c:RegisterEffect(e3)
	-- ③：魔法与陷阱区域的这张卡被效果破坏的场合才能发动。这个回合，自己的「剑斗兽」怪兽不会被战斗破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_DESTROYED)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCondition(c52394047.indcon)
	e4:SetOperation(c52394047.indop)
	c:RegisterEffect(e4)
end
-- 过滤函数，用于判断场上是否存在「剑斗兽」怪兽
function c52394047.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x1019)
end
-- 判断自己场上有「剑斗兽」怪兽存在
function c52394047.macon(e)
	-- 检查自己场上是否存在至少1只「剑斗兽」怪兽
	return Duel.IsExistingMatchingCard(c52394047.filter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
-- 过滤函数，用于选择可以送回卡组的「剑斗兽」怪兽
function c52394047.cfilter(c)
	return c:IsSetCard(0x1019) and c:IsType(TYPE_MONSTER) and c:IsAbleToDeckAsCost()
end
-- 选择并送回1只「剑斗兽」怪兽到卡组作为费用
function c52394047.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足送回卡组的条件
	if chk==0 then return Duel.IsExistingMatchingCard(c52394047.cfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择满足条件的「剑斗兽」怪兽
	local g=Duel.SelectMatchingCard(tp,c52394047.cfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil)
	-- 确认对方查看所选卡片
	Duel.ConfirmCards(1-tp,g)
	-- 将所选卡片送回卡组
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_COST)
end
-- 过滤函数，用于选择可以提升攻击力的「剑斗兽」怪兽
function c52394047.atkfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x1019) and c:GetBaseDefense()>0
end
-- 选择并设置目标怪兽
function c52394047.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c52394047.atkfilter(chkc) end
	-- 检查是否存在满足条件的目标怪兽
	if chk==0 then return Duel.IsExistingTarget(c52394047.atkfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择目标怪兽
	Duel.SelectTarget(tp,c52394047.atkfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 将目标怪兽攻击力提升至其原本守备力数值
function c52394047.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 为指定怪兽增加攻击力效果
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(tc:GetBaseDefense())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
-- 判断此卡是否因效果破坏且之前在魔法与陷阱区域
function c52394047.indcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_EFFECT) and c:IsPreviousLocation(LOCATION_SZONE)
end
-- 注册场上的「剑斗兽」怪兽不会被战斗破坏的效果
function c52394047.indop(e,tp,eg,ep,ev,re,r,rp)
	-- 注册场上的「剑斗兽」怪兽不会被战斗破坏的效果
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(c52394047.target)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetValue(1)
	-- 将效果注册给指定玩家
	Duel.RegisterEffect(e1,tp)
end
-- 目标函数，用于筛选「剑斗兽」怪兽
function c52394047.target(e,c)
	return c:IsSetCard(0x1019)
end
