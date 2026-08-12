--剣闘獣の底力
-- 效果：
-- 自己场上表侧表示存在的1只名字带有「剑斗兽」的怪兽的攻击力直到结束阶段时上升500。可以让自己墓地存在的2张名字带有「剑斗兽」的卡回到卡组，自己墓地存在的这张卡回到手卡。
function c55136228.initial_effect(c)
	-- 自己场上表侧表示存在的1只名字带有「剑斗兽」的怪兽的攻击力直到结束阶段时上升500。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	e1:SetCondition(c55136228.condition)
	e1:SetTarget(c55136228.target)
	e1:SetOperation(c55136228.activate)
	c:RegisterEffect(e1)
	-- 可以让自己墓地存在的2张名字带有「剑斗兽」的卡回到卡组，自己墓地存在的这张卡回到手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCost(c55136228.thcost)
	e1:SetTarget(c55136228.thtg)
	e1:SetOperation(c55136228.thop)
	c:RegisterEffect(e1)
end
-- 发动条件：在伤害步骤中，如果已经计算了战斗伤害则不能发动
function c55136228.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 如果在伤害步骤且已经计算了伤害，则不能发动
	if Duel.GetCurrentPhase()==PHASE_DAMAGE and Duel.IsDamageCalculated() then return false end
	return true
end
-- 过滤条件：自己场上表侧表示的名字带有「剑斗兽」的怪兽
function c55136228.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x1019)
end
-- 效果选择目标：选择自己场上1只表侧表示的「剑斗兽」怪兽为对象
function c55136228.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c55136228.filter(chkc) end
	-- 检查自己场上是否存在至少1只满足过滤条件的「剑斗兽」怪兽
	if chk==0 then return Duel.IsExistingTarget(c55136228.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择1只满足条件的「剑斗兽」怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,c55136228.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果处理：使选择的怪兽攻击力上升500直到结束阶段
function c55136228.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 攻击力直到结束阶段时上升500
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(500)
		tc:RegisterEffect(e1)
	end
end
-- 过滤条件：墓地中可以回到卡组的名字带有「剑斗兽」的卡
function c55136228.cfilter(c)
	return c:IsSetCard(0x1019) and c:IsAbleToDeckAsCost()
end
-- 发动费用：让自己墓地存在的2张名字带有「剑斗兽」的卡回到卡组
function c55136228.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己墓地是否存在至少2张除这张卡以外的名字带有「剑斗兽」的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c55136228.cfilter,tp,LOCATION_GRAVE,0,2,e:GetHandler()) end
	-- 提示玩家选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择自己墓地2张除这张卡以外的名字带有「剑斗兽」的卡
	local g=Duel.SelectMatchingCard(tp,c55136228.cfilter,tp,LOCATION_GRAVE,0,2,2,e:GetHandler())
	-- 为选择的卡片显示被选中的动画效果
	Duel.HintSelection(g)
	-- 将选择的卡作为发动费用返回卡组并洗牌
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_COST)
end
-- 效果目标：确认墓地的这张卡是否能回到手卡，并设置操作信息
function c55136228.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	-- 设置效果处理信息：将墓地的这张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- 效果处理：将墓地的这张卡回到手卡，并给对方确认
function c55136228.thop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		-- 将这张卡加入手卡
		Duel.SendtoHand(e:GetHandler(),nil,REASON_EFFECT)
		-- 向对方玩家展示并确认这张卡
		Duel.ConfirmCards(1-tp,e:GetHandler())
	end
end
