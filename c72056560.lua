--ジェムナイト・アンバー
-- 效果：
-- 这张卡在墓地或者场上表侧表示存在的场合，当作通常怪兽使用。场上表侧表示存在的这张卡可以作当成通常召唤使用的再度召唤，这张卡变成当作效果怪兽使用并得到以下效果。
-- ●1回合1次，可以从手卡把1张名字带有「宝石骑士」的卡送去墓地，选择从游戏中除外的1只自己怪兽回到手卡。
function c72056560.initial_effect(c)
	-- 初始化二重怪兽属性，使其在场上或墓地表侧表示存在时当作通常怪兽
	aux.EnableDualAttribute(c)
	-- ●1回合1次，可以从手卡把1张名字带有「宝石骑士」的卡送去墓地，选择从游戏中除外的1只自己怪兽回到手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetDescription(aux.Stringid(72056560,0))  --"加入手卡"
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	-- 设置效果发动条件为自身处于再度召唤状态（当作效果怪兽使用）
	e1:SetCondition(aux.IsDualState)
	e1:SetCost(c72056560.cost)
	e1:SetTarget(c72056560.target)
	e1:SetOperation(c72056560.operation)
	c:RegisterEffect(e1)
end
-- 过滤手牌中可以作为代价送去墓地的「宝石骑士」卡片
function c72056560.costfilter(c)
	return c:IsSetCard(0x1047) and c:IsAbleToGraveAsCost()
end
-- 效果发动的代价处理，从手牌将1张「宝石骑士」卡片送去墓地
function c72056560.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手牌中是否存在可以作为代价送去墓地的「宝石骑士」卡片
	if chk==0 then return Duel.IsExistingMatchingCard(c72056560.costfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 提示玩家选择要送去墓地的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 玩家从手牌选择1张「宝石骑士」卡片
	local g=Duel.SelectMatchingCard(tp,c72056560.costfilter,tp,LOCATION_HAND,0,1,1,nil)
	-- 将选择的卡片作为代价送去墓地
	Duel.SendtoGrave(g,REASON_COST)
end
-- 过滤除外区中表侧表示且可以加入手牌的怪兽
function c72056560.tgfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 效果的目标选择与发动检测，选择除外的1只自己怪兽为对象
function c72056560.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and c72056560.tgfilter(chkc) end
	-- 检查除外区是否存在可以加入手牌的自己怪兽
	if chk==0 then return Duel.IsExistingTarget(c72056560.tgfilter,tp,LOCATION_REMOVED,0,1,nil) end
	-- 提示玩家选择要加入手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择除外区1只自己怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c72056560.tgfilter,tp,LOCATION_REMOVED,0,1,1,nil)
	-- 设置效果处理信息，将1张目标卡片加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果处理的执行，将选择的除外怪兽加入手牌并给对方确认
function c72056560.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果发动的目标卡片
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 将目标卡片因效果加入手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 让对方玩家确认加入手牌的卡片
		Duel.ConfirmCards(1-tp,tc)
	end
end
