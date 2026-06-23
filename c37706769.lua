--冥府の執行者 プルート
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 这个卡名在规则上也当作「代行者」卡使用。这个卡名的②的效果1回合只能使用1次。
-- ①：1回合1次，从自己墓地把1只怪兽除外，以场上1只效果怪兽为对象才能发动。那只怪兽变成里侧守备表示。场上或者墓地有「天空的圣域」存在的场合，这个效果在对方回合也能发动。
-- ②：把墓地的这张卡除外才能发动。从自己的卡组·墓地选1张「天空的圣域」加入手卡。
function c37706769.initial_effect(c)
	-- 添加同调召唤手续，要求1只调整和1只调整以外的怪兽作为素材
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	-- 记录该卡具有「代行者」卡的特性
	aux.AddCodeList(c,56433456)
	c:EnableReviveLimit()
	-- ①：1回合1次，从自己墓地把1只怪兽除外，以场上1只效果怪兽为对象才能发动。那只怪兽变成里侧守备表示。场上或者墓地有「天空的圣域」存在的场合，这个效果在对方回合也能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(37706769,0))
	e1:SetCategory(CATEGORY_POSITION+CATEGORY_MSET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,EFFECT_COUNT_CODE_SINGLE)
	e1:SetCondition(c37706769.noqkcon)
	e1:SetCost(c37706769.poscost)
	e1:SetTarget(c37706769.postg)
	e1:SetOperation(c37706769.posop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e2:SetCondition(c37706769.qkcon)
	c:RegisterEffect(e2)
	-- ②：把墓地的这张卡除外才能发动。从自己的卡组·墓地选1张「天空的圣域」加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(37706769,1))
	e3:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,37706770)
	-- 设置效果发动时需要将此卡除外作为费用
	e3:SetCost(aux.bfgcost)
	e3:SetTarget(c37706769.thtg)
	e3:SetOperation(c37706769.thop)
	c:RegisterEffect(e3)
end
-- 判断场上或墓地是否存在「天空的圣域」
function c37706769.qkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断场上或墓地是否存在「天空的圣域」
	return Duel.IsEnvironment(56433456,PLAYER_ALL,LOCATION_ONFIELD+LOCATION_GRAVE)
end
-- 判断当前回合不是有「天空的圣域」存在时的效果发动条件
function c37706769.noqkcon(e,tp,eg,ep,ev,re,r,rp)
	return not c37706769.qkcon(e,tp,eg,ep,ev,re,r,rp)
end
-- 定义除外费用的过滤条件：墓地的怪兽且可作为除外费用
function c37706769.poscostfilter(c)
	return c:IsAbleToRemoveAsCost() and c:IsType(TYPE_MONSTER)
end
-- 处理效果发动的除外费用，选择1只满足条件的怪兽除外
function c37706769.poscost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否有满足条件的怪兽可作为除外费用
	if chk==0 then return Duel.IsExistingMatchingCard(c37706769.poscostfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择满足条件的1只怪兽作为除外费用
	local g=Duel.SelectMatchingCard(tp,c37706769.poscostfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将选中的怪兽除外作为发动费用
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 定义目标怪兽的过滤条件：表侧表示、效果怪兽、可变为里侧守备表示
function c37706769.posfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_EFFECT) and c:IsCanTurnSet()
end
-- 设置效果的目标选择，选择1只满足条件的怪兽
function c37706769.postg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c37706769.posfilter(chkc) end
	-- 检查是否有满足条件的怪兽可作为效果对象
	if chk==0 then return Duel.IsExistingTarget(c37706769.posfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要改变表示形式的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择满足条件的1只怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c37706769.posfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置效果处理时的操作信息，表示形式改变
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
end
-- 执行效果处理，将目标怪兽变为里侧守备表示
function c37706769.posop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsLocation(LOCATION_MZONE) and tc:IsFaceup() then
		-- 将目标怪兽变为里侧守备表示
		Duel.ChangePosition(tc,POS_FACEDOWN_DEFENSE)
	end
end
-- 定义检索卡的过滤条件：卡名为「天空的圣域」且可加入手牌
function c37706769.thfilter(c)
	return c:IsCode(56433456) and c:IsAbleToHand()
end
-- 设置效果的目标选择，检索1张「天空的圣域」
function c37706769.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否有满足条件的「天空的圣域」可加入手牌
	if chk==0 then return Duel.IsExistingMatchingCard(c37706769.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	-- 设置效果处理时的操作信息，表示要加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
-- 执行效果处理，选择并加入手牌
function c37706769.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的1张「天空的圣域」加入手牌
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c37706769.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
