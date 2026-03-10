--電脳堺門－青龍
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：从自己墓地把1张「电脑堺」卡除外，以场上1只表侧表示怪兽为对象才能发动。那只怪兽的效果直到回合结束时无效。
-- ②：把墓地的这张卡除外才能发动。从卡组把1只「电脑堺」怪兽加入手卡。那之后选1张手卡送去墓地。
function c50275295.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：从自己墓地把1张「电脑堺」卡除外，以场上1只表侧表示怪兽为对象才能发动。那只怪兽的效果直到回合结束时无效。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(50275295,0))  --"无效怪兽"
	e2:SetCategory(CATEGORY_DISABLE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,50275295)
	e2:SetCost(c50275295.discost)
	e2:SetTarget(c50275295.distg)
	e2:SetOperation(c50275295.disop)
	c:RegisterEffect(e2)
	-- ②：把墓地的这张卡除外才能发动。从卡组把1只「电脑堺」怪兽加入手卡。那之后选1张手卡送去墓地。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(50275295,1))  --"加入手卡"
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_HANDES)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,50275296)
	-- 将此卡自身从墓地除外作为费用
	e3:SetCost(aux.bfgcost)
	e3:SetTarget(c50275295.thtg)
	e3:SetOperation(c50275295.thop)
	c:RegisterEffect(e3)
end
-- 过滤函数，用于判断场上是否有满足条件的「电脑堺」卡（可被除外）
function c50275295.cfilter(c)
	return c:IsSetCard(0x14e) and c:IsAbleToRemoveAsCost()
end
-- 效果发动时的费用处理，选择并除外1张满足条件的「电脑堺」卡
function c50275295.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足除外条件
	if chk==0 then return Duel.IsExistingMatchingCard(c50275295.cfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择满足条件的1张卡
	local g=Duel.SelectMatchingCard(tp,c50275295.cfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将选中的卡除外作为费用
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 设置效果目标，选择场上1只可被无效化的怪兽
function c50275295.distg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 判断是否为有效目标
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and aux.NegateMonsterFilter(chkc) end
	-- 检查是否有满足条件的目标怪兽
	if chk==0 then return Duel.IsExistingTarget(aux.NegateMonsterFilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要无效的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
	-- 选择满足条件的1只怪兽作为目标
	local g=Duel.SelectTarget(tp,aux.NegateMonsterFilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置效果操作信息，记录将要无效化的怪兽
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
end
-- 效果处理函数，使目标怪兽的效果无效
function c50275295.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中被选中的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) and tc:IsCanBeDisabledByEffect(e) then
		-- 使目标怪兽的效果无效
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 使目标怪兽的效果在回合结束时恢复
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
	end
end
-- 过滤函数，用于判断卡组中是否有满足条件的「电脑堺」怪兽
function c50275295.thfilter(c)
	return c:IsSetCard(0x14e) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 设置效果目标，检索满足条件的怪兽
function c50275295.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足检索条件
	if chk==0 then return Duel.IsExistingMatchingCard(c50275295.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息，记录将要加入手牌的怪兽
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理函数，从卡组检索并加入手牌，然后丢弃1张手卡
function c50275295.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的1只怪兽
	local g=Duel.SelectMatchingCard(tp,c50275295.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	-- 判断是否成功将卡加入手牌
	if g:GetCount()>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)>0 then
		-- 确认对方看到被加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
		-- 洗切自己的手牌
		Duel.ShuffleHand(tp)
		-- 中断当前效果处理，使后续处理视为不同时处理
		Duel.BreakEffect()
		-- 丢弃自己1张手卡
		Duel.DiscardHand(tp,nil,1,1,REASON_EFFECT)
	end
end
