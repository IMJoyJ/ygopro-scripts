--ジェムナイト・アイオーラ
-- 效果：
-- 这张卡在墓地或者场上表侧表示存在的场合，当作通常怪兽使用。场上表侧表示存在的这张卡可以作当成通常召唤使用的再度召唤，这张卡变成当作效果怪兽使用并得到以下效果。
-- ●1回合1次，可以把自己墓地存在的1只名字带有「宝石」的怪兽从游戏中除外，选择自己墓地存在的1张名字带有「宝石骑士」的卡加入手卡。
function c45662855.initial_effect(c)
	-- 为卡片添加二重怪兽属性
	aux.EnableDualAttribute(c)
	-- ●1回合1次，可以把自己墓地存在的1只名字带有「宝石」的怪兽从游戏中除外，选择自己墓地存在的1张名字带有「宝石骑士」的卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetDescription(aux.Stringid(45662855,0))  --"加入手卡"
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	-- 设置效果条件为二重怪兽处于再度召唤状态
	e1:SetCondition(aux.IsDualState)
	e1:SetCost(c45662855.cost)
	e1:SetTarget(c45662855.target)
	e1:SetOperation(c45662855.operation)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于判断墓地是否存在满足条件的「宝石」怪兽作为除外代价
function c45662855.costfilter(c,tp)
	return c:IsSetCard(0x47) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
		-- 检查是否存在满足条件的「宝石骑士」卡作为目标
		and Duel.IsExistingTarget(c45662855.tgfilter,tp,LOCATION_GRAVE,0,1,c)
end
-- 过滤函数，用于判断墓地是否存在满足条件的「宝石骑士」卡
function c45662855.tgfilter(c)
	return c:IsSetCard(0x1047) and c:IsAbleToHand()
end
-- 设置效果的发动费用，标记为需要处理除外操作
function c45662855.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	return true
end
-- 设置效果的目标选择函数，处理除外和选择手牌的逻辑
function c45662855.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c45662855.tgfilter(chkc) end
	if chk==0 then
		if e:GetLabel()==1 then
			e:SetLabel(0)
			-- 检查是否存在满足条件的「宝石」怪兽用于除外
			return Duel.IsExistingMatchingCard(c45662855.costfilter,tp,LOCATION_GRAVE,0,1,nil,tp)
		else
			-- 检查是否存在满足条件的「宝石骑士」卡用于加入手牌
			return Duel.IsExistingTarget(c45662855.tgfilter,tp,LOCATION_GRAVE,0,1,nil)
		end
	end
	if e:GetLabel()==1 then
		-- 提示玩家选择要除外的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		-- 选择满足条件的「宝石」怪兽进行除外
		local cg=Duel.SelectMatchingCard(tp,c45662855.costfilter,tp,LOCATION_GRAVE,0,1,1,nil,tp)
		-- 将选中的怪兽从游戏中除外
		Duel.Remove(cg,POS_FACEUP,REASON_COST)
		e:SetLabel(0)
	end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的「宝石骑士」卡作为目标
	local g=Duel.SelectTarget(tp,c45662855.tgfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置效果处理信息，指定将卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 设置效果的处理函数，执行将卡加入手牌和确认卡牌的操作
function c45662855.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果的目标卡
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 将目标卡加入玩家手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 向对方玩家确认手牌内容
		Duel.ConfirmCards(1-tp,tc)
	end
end
