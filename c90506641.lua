--魂の開封
-- 效果：
-- ①：对方场上有怪兽存在，自己场上有通常怪兽存在的场合才能发动。从卡组选5只通常怪兽。那之内的1只加入手卡，剩下的卡除外。
function c90506641.initial_effect(c)
	-- ①：对方场上有怪兽存在，自己场上有通常怪兽存在的场合才能发动。从卡组选5只通常怪兽。那之内的1只加入手卡，剩下的卡除外。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c90506641.condition)
	e1:SetTarget(c90506641.target)
	e1:SetOperation(c90506641.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：表侧表示的通常怪兽
function c90506641.cfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_NORMAL)
end
-- 发动条件：对方场上有怪兽存在，且自己场上有通常怪兽存在
function c90506641.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查对方场上的怪兽数量是否大于0
	return Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0
		-- 检查自己场上是否存在表侧表示的通常怪兽
		and Duel.IsExistingMatchingCard(c90506641.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 过滤条件：卡组中的通常怪兽且可以加入手卡
function c90506641.filter(c)
	return c:IsType(TYPE_NORMAL) and c:IsAbleToHand()
end
-- 发动时的效果处理检查：玩家可以除外卡片，且卡组中存在至少5只通常怪兽
function c90506641.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动时检查玩家当前是否可以进行除外操作
	if chk==0 then return Duel.IsPlayerCanRemove(tp)
		-- 在发动时检查自己卡组中是否存在至少5只通常怪兽
		and Duel.IsExistingMatchingCard(c90506641.filter,tp,LOCATION_DECK,0,5,nil) end
	-- 设置操作信息：从卡组将1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：从卡组选5只通常怪兽，其中1只加入手卡，剩下的除外
function c90506641.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时，若玩家无法进行除外操作则不处理效果
	if not Duel.IsPlayerCanRemove(tp) then return end
	-- 提示玩家选择5张卡片
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(90506641,0))  --"请选择要加入手卡或除外的卡"
	-- 让玩家从卡组选择5只通常怪兽
	local g=Duel.SelectMatchingCard(tp,c90506641.filter,tp,LOCATION_DECK,0,5,5,nil)
	if g:GetCount()<5 then return end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	local sg=g:Select(tp,1,1,nil)
	-- 将选中的1只通常怪兽加入手卡
	Duel.SendtoHand(sg,nil,REASON_EFFECT)
	g:Sub(sg)
	-- 将剩下的4只通常怪兽表侧表示除外
	Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
end
