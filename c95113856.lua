--幻子力空母エンタープラズニル
-- 效果：
-- 9星怪兽×2
-- ①：1回合1次，可以把这张卡1个超量素材取除，从以下效果选择1个发动。
-- ●选对方场上1张卡除外。
-- ●对方手卡随机选1张除外。
-- ●选对方墓地1张卡除外。
-- ●对方卡组最上面的卡除外。
function c95113856.initial_effect(c)
	-- 为这张卡添加XYZ召唤手续：9星怪兽×2
	aux.AddXyzProcedure(c,nil,9,2)
	c:EnableReviveLimit()
	-- ①：1回合1次，可以把这张卡1个超量素材取除，从以下效果选择1个发动。●选对方场上1张卡除外。●对方手卡随机选1张除外。●选对方墓地1张卡除外。●对方卡组最上面的卡除外。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(95113856,0))  --"选择效果发动"
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(c95113856.cost)
	e1:SetTarget(c95113856.target)
	e1:SetOperation(c95113856.operation)
	c:RegisterEffect(e1)
end
-- 效果发动的代价：把这张卡1个超量素材取除
function c95113856.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 效果发动的目标：检查对方各区域是否有可除外的卡，并让玩家选择其中一个效果发动，设置对应的操作信息
function c95113856.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方场上、手卡、墓地、卡组中是否存在至少1张可以除外的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD+LOCATION_HAND+LOCATION_GRAVE+LOCATION_DECK,1,nil) end
	-- 检查对方场上是否存在可以除外的卡
	local b1=Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,1,nil)
	-- 检查对方手卡是否存在可以除外的卡
	local b2=Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_HAND,1,nil)
	-- 检查对方墓地是否存在可以除外的卡
	local b3=Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,1,nil)
	-- 检查对方卡组是否存在可以除外的卡
	local b4=Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_DECK,1,nil)
	-- 让玩家从满足条件的可选效果中选择一个
	local op=aux.SelectFromOptions(tp,
		{b1,aux.Stringid(95113856,1)},  --"选对方场上1张卡从游戏中除外"
		{b2,aux.Stringid(95113856,2)},  --"对方手卡随机选1张从游戏中除外"
		{b3,aux.Stringid(95113856,3)},  --"选对方墓地1张卡从游戏中除外"
		{b4,aux.Stringid(95113856,4)})  --"对方卡组最上面的卡从游戏中除外"
	e:SetLabel(op)
	local oploc=({LOCATION_ONFIELD,LOCATION_HAND,LOCATION_GRAVE,LOCATION_DECK})[op]
	-- 设置操作信息：从选定的对方区域除外1张卡
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,1-tp,oploc)
end
-- 效果处理：根据玩家选择的效果，执行对应的除外操作
function c95113856.operation(e,tp,eg,ep,ev,re,r,rp)
	local op=e:GetLabel()
	if op==1 then
		-- 提示玩家选择要除外的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		-- 让玩家选择对方场上1张可以除外的卡
		local g=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,1,1,nil)
		if g:GetCount()>0 then
			-- 显式提示选中的卡片
			Duel.HintSelection(g)
			-- 将选中的对方场上的卡表侧表示除外
			Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
		end
	elseif op==2 then
		-- 获取对方手卡中所有可以除外的卡
		local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_HAND,nil)
		if g:GetCount()>0 then
			local sg=g:RandomSelect(tp,1)
			-- 将随机选中的对方手卡表侧表示除外
			Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)
		end
	elseif op==3 then
		-- 提示玩家选择要除外的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		-- 让玩家选择对方墓地1张可以除外的卡
		local g=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,1,1,nil)
		if g:GetCount()>0 then
			-- 将选中的对方墓地的卡表侧表示除外
			Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
		end
	elseif op==4 then
		-- 获取对方卡组最上方的1张卡
		local g=Duel.GetDecktopGroup(1-tp,1)
		if g:GetCount()>0 then
			-- 禁用接下来的洗牌检测（防止因从卡组顶端除外卡片而自动洗牌）
			Duel.DisableShuffleCheck()
			-- 将对方卡组最上方的卡表侧表示除外
			Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
		end
	end
end
