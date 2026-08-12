--登竜華海瀧門
-- 效果：
-- ①：「登龙华海泷门」在自己场上只能有1张表侧表示存在。
-- ②：只要这张卡在魔法与陷阱区域存在，自己的「龙华」怪兽不会被战斗破坏。
-- ③：自己场上的「龙华」灵摆怪兽以及10星以上而原本种族是海龙族的怪兽得到以下效果。
-- ●对方回合1次，让自己场上1张表侧表示的「龙华」永续魔法卡回到卡组最下面，以场上1张卡为对象才能发动。那张卡回到手卡。
local s,id,o=GetID()
-- 注册卡片的初始效果，设置唯一性、激活效果、战斗破坏免疫效果、对方回合效果、类型变更效果
function s.initial_effect(c)
	c:SetUniqueOnField(1,0,id)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 只要这张卡在魔法与陷阱区域存在，自己的「龙华」怪兽不会被战斗破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	-- 设置效果目标为「龙华」怪兽
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x1c0))
	e2:SetValue(1)
	c:RegisterEffect(e2)
	-- 对方回合1次，让自己场上1张表侧表示的「龙华」永续魔法卡回到卡组最下面，以场上1张卡为对象才能发动。那张卡回到手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"让场上的卡回到手卡（「登龙华海泷门」）"
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(s.thcon)
	e3:SetCost(s.thcost)
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	-- 使满足条件的怪兽获得上述效果
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
	e4:SetRange(LOCATION_SZONE)
	e4:SetTargetRange(LOCATION_MZONE,0)
	e4:SetTarget(s.eftg)
	e4:SetLabelObject(e3)
	c:RegisterEffect(e4)
	-- 使满足条件的怪兽获得效果类型为效果怪兽
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetCode(EFFECT_ADD_TYPE)
	e5:SetRange(LOCATION_SZONE)
	e5:SetTargetRange(LOCATION_MZONE,0)
	e5:SetTarget(s.eftg)
	e5:SetValue(TYPE_EFFECT)
	c:RegisterEffect(e5)
	local e6=e5:Clone()
	e6:SetCode(EFFECT_REMOVE_TYPE)
	e6:SetValue(TYPE_NORMAL)
	c:RegisterEffect(e6)
end
-- 效果发动条件：当前回合不是自己
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 当前回合不是自己
	return Duel.GetTurnPlayer()==1-tp
end
-- 判断费用是否满足：场上存在1张表侧表示的「龙华」永续魔法卡且能送入卡组作为费用，并且自己场上存在至少1张能回到手牌的卡
function s.costfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0x1c0) and c:IsAbleToDeckAsCost()
		and bit.band(c:GetType(),TYPE_SPELL+TYPE_CONTINUOUS)==TYPE_SPELL+TYPE_CONTINUOUS
		-- 检查自己场上是否存在至少1张能回到手牌的卡
		and Duel.IsExistingMatchingCard(Card.IsAbleToHand,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,c)
end
-- 处理效果发动的费用：选择1张满足条件的卡送入卡组最下面
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查是否满足发动费用条件
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_ONFIELD,0,1,nil,tp) end
	-- 向对方提示效果发动
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 提示选择要送入卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择满足条件的卡
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_ONFIELD,0,1,1,nil,tp)
	-- 显示选卡动画
	Duel.HintSelection(g)
	-- 将选中的卡送入卡组最下面
	Duel.SendtoDeck(g,nil,SEQ_DECKBOTTOM,REASON_COST)
end
-- 设置效果目标：选择1张能回到手牌的卡
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsAbleToHand() end
	-- 检查是否满足效果目标条件
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToHand,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 提示选择要返回手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择目标卡
	local g=Duel.SelectTarget(tp,Card.IsAbleToHand,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置效果操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 执行效果操作：将目标卡送回手牌
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡送回手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
-- 判断满足效果的怪兽类型：10星以上且原本种族为海龙族，或「龙华」灵摆怪兽
function s.eftg(e,c)
	return c:IsLevelAbove(10) and c:GetOriginalRace()==RACE_SEASERPENT
		or c:IsSetCard(0x1c0) and c:IsType(TYPE_PENDULUM)
end
