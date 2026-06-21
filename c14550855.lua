--インフェルニティ・インフェルノ
-- 效果：
-- 自己最多2张手卡丢弃。那之后，这个效果丢弃的数量的名字带有「永火」的卡从卡组送去墓地。
function c14550855.initial_effect(c)
	-- 自己最多2张手卡丢弃。那之后，这个效果丢弃的数量的名字带有「永火」的卡从卡组送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_HANDES_SELF+CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c14550855.target)
	e1:SetOperation(c14550855.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：卡组中卡名含有「永火」且可以送去墓地的卡
function c14550855.filter(c)
	return c:IsSetCard(0xb) and c:IsAbleToGrave()
end
-- 在效果发动检测时，检查自己的手牌数量是否大于0，且卡组中存在至少1张可以送去墓地的「永火」卡片
function c14550855.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动检测时，检查自己的手牌数量是否大于0
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)>0
		-- 并且卡组中存在至少1张可以送去墓地的「永火」卡片
		and Duel.IsExistingMatchingCard(c14550855.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：包含自己丢弃手牌的操作
	Duel.SetOperationInfo(0,CATEGORY_HANDES_SELF,nil,0,tp,1)
	-- 设置操作信息：包含从卡组将卡送去墓地的操作
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：自己丢弃最多2张手牌，那之后从卡组选择等量名字带有「永火」的卡送去墓地
function c14550855.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 如果自己手牌数量为0，则不处理效果
	if Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)==0 then return end
	-- 计算当前卡组中符合条件的「永火」卡片数量
	local ac=Duel.GetMatchingGroupCount(c14550855.filter,tp,LOCATION_DECK,0,nil)
	if ac==0 then return end
	if ac>2 then ac=2 end
	-- 从手牌选择并丢弃1到ac张（最多2张）卡片，并记录实际丢弃的数量
	local ct=Duel.DiscardHand(tp,aux.TRUE,1,ac,REASON_DISCARD+REASON_EFFECT)
	-- 中断当前效果，使前后的处理不视为同时进行
	Duel.BreakEffect()
	-- 提示玩家选择要送去墓地的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从卡组中选择与丢弃数量（ct）相同数量的「永火」卡片
	local g=Duel.SelectMatchingCard(tp,c14550855.filter,tp,LOCATION_DECK,0,1,ct,nil)
	-- 将选中的卡片送去墓地
	Duel.SendtoGrave(g,REASON_EFFECT)
end
