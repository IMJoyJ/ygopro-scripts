--冥府の執行者 プルート
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 这个卡名在规则上也当作「代行者」卡使用。这个卡名的②的效果1回合只能使用1次。
-- ①：1回合1次，从自己墓地把1只怪兽除外，以场上1只效果怪兽为对象才能发动。那只怪兽变成里侧守备表示。场上或者墓地有「天空的圣域」存在的场合，这个效果在对方回合也能发动。
-- ②：把墓地的这张卡除外才能发动。从自己的卡组·墓地选1张「天空的圣域」加入手卡。
function c37706769.initial_effect(c)
	-- 为这张卡添加同调召唤手续：需要1只调整＋1只以上调整以外的怪兽。
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	-- 将「天空的圣域」的卡号56433456加入本卡的代码列表，用于“这张卡上记载着另一张卡名”的规则判定。
	aux.AddCodeList(c,56433456)
	c:EnableReviveLimit()
	-- ①：1回合1次，从自己墓地把1只怪兽除外，以场上1只效果怪兽为对象才能发动。那只怪兽变成里侧守备表示。（此处实现的是场上或墓地没有「天空的圣域」时的通常起动效果）
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
	-- ②：把墓地的这张卡除外才能发动。从自己的卡组·墓地选1张「天空的圣域」加入手卡。（同时通过SetCountLimit实现这个卡名的②的效果1回合只能使用1次）
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(37706769,1))
	e3:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,37706770)
	-- 为②效果设置发动代价：将墓地中的本卡除外（aux.bfgcost实现）。
	e3:SetCost(aux.bfgcost)
	e3:SetTarget(c37706769.thtg)
	e3:SetOperation(c37706769.thop)
	c:RegisterEffect(e3)
end
-- 定义快速效果发动条件：当场上或墓地有「天空的圣域」时，①效果可以作为诱发即时效果在对方回合发动。
function c37706769.qkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查双方场上或墓地是否存在卡号为56433456的「天空的圣域」，用于判断是否可以在对方回合发动①效果。
	return Duel.IsEnvironment(56433456,PLAYER_ALL,LOCATION_ONFIELD+LOCATION_GRAVE)
end
-- 定义非快速效果的发动条件：当场上或墓地没有「天空的圣域」时，①效果只能作为起动效果在自己主要阶段发动。
function c37706769.noqkcon(e,tp,eg,ep,ev,re,r,rp)
	return not c37706769.qkcon(e,tp,eg,ep,ev,re,r,rp)
end
-- 定义①效果cost的筛选条件：从自己墓地选择1只可除外的怪兽。
function c37706769.poscostfilter(c)
	return c:IsAbleToRemoveAsCost() and c:IsType(TYPE_MONSTER)
end
-- 处理①效果的cost：支付时选择1只自己墓地的怪兽，将其表侧除外。
function c37706769.poscost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- cost合法性检查：发动时确认自己墓地存在至少1张满足cost过滤条件的怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c37706769.poscostfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 发送选择提示，提示玩家选择要除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从自己墓地选择1张满足条件的怪兽作为发动代价。
	local g=Duel.SelectMatchingCard(tp,c37706769.poscostfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将选择的代价怪兽以表侧表示除外，支付代价。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 定义①效果对象筛选条件：场上的表侧效果怪兽且可以变为里侧守备表示。
function c37706769.posfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_EFFECT) and c:IsCanTurnSet()
end
-- ①效果的目标选择与登记：从双方场上选择1只表侧效果怪兽，并设置操作信息为改变表示形式。
function c37706769.postg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c37706769.posfilter(chkc) end
	-- 目标合法性检查：发动时确认场上存在至少1只可被选择为对象的表侧效果怪兽。
	if chk==0 then return Duel.IsExistingTarget(c37706769.posfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 发送选择提示，提示玩家选择表侧表示的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让玩家从双方场上选择1只满足条件的表侧效果怪兽，并登记为效果对象。
	local g=Duel.SelectTarget(tp,c37706769.posfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息：将选择的怪兽作为CATEGORY_POSITION（改变表示形式）处理的对象。
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
end
-- ①效果处理：若对象仍与效果关联且在场上表侧表示，则将其变成里侧守备表示。
function c37706769.posop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得①效果选择的对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsLocation(LOCATION_MZONE) and tc:IsFaceup() then
		-- 将对象怪兽的表示形式变成里侧守备表示。
		Duel.ChangePosition(tc,POS_FACEDOWN_DEFENSE)
	end
end
-- 定义②效果检索卡的条件：必须是卡号56433456的「天空的圣域」且可以加入手卡。
function c37706769.thfilter(c)
	return c:IsCode(56433456) and c:IsAbleToHand()
end
-- ②效果发动时的目标检测与操作信息设定：检查卡组·墓地是否存在可加入手牌的「天空的圣域」。
function c37706769.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- ②效果发动条件检查：卡组·墓地中是否存在至少1张满足检索条件的「天空的圣域」。
	if chk==0 then return Duel.IsExistingMatchingCard(c37706769.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	-- 设置操作信息：从己方卡组·墓地选1张「天空的圣域」加入手卡（处理时再选择具体卡片）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
-- ②效果处理：从卡组·墓地选择1张「天空的圣域」加入手卡，并向对方确认。
function c37706769.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 发送选择提示，提示玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从己方卡组·墓地选择1张满足thfilter条件的「天空的圣域」，并应用NecroValleyFilter以避开王家长眠之谷等影响。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c37706769.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的「天空的圣域」加入其持有者的手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手卡的「天空的圣域」展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
	end
end
