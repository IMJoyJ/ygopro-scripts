--ラヴァルバル・チェイン
-- 效果：
-- 4星怪兽×2
-- ①：1回合1次，可以把这张卡1个超量素材取除，从以下效果选择1个发动。
-- ●从卡组选1张卡送去墓地。
-- ●从卡组选1只怪兽在卡组最上面放置。
function c34086406.initial_effect(c)
	-- 添加XYZ召唤手续，使用4星怪兽2只作为素材
	aux.AddXyzProcedure(c,nil,4,2)
	c:EnableReviveLimit()
	-- 从自己卡组选择1张卡送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(34086406,1))  --"从自己卡组选择1张卡送去墓地。"
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,EFFECT_COUNT_CODE_SINGLE)
	e1:SetCost(c34086406.cost)
	e1:SetTarget(c34086406.target1)
	e1:SetOperation(c34086406.operation1)
	c:RegisterEffect(e1)
	-- 从自己卡组选择1只怪兽在卡组最上面放置。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(34086406,2))  --"从自己卡组选择1只怪兽在卡组最上面放置。"
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,EFFECT_COUNT_CODE_SINGLE)
	e2:SetCost(c34086406.cost)
	e2:SetTarget(c34086406.target2)
	e2:SetOperation(c34086406.operation2)
	c:RegisterEffect(e2)
end
-- 支付效果代价，去除1个超量素材
function c34086406.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	-- 向对方玩家提示发动了效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 设置效果目标，准备从卡组选择1张卡送去墓地
function c34086406.target1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组是否存在可送去墓地的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToGrave,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁操作信息，指定将要送去墓地的卡
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 设置效果目标，准备从卡组选择1只怪兽放置到卡组最上方
function c34086406.target2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组是否存在可放置到卡组最上方的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsType,tp,LOCATION_DECK,0,1,nil,TYPE_MONSTER)
		-- 检查卡组中怪兽数量是否大于1
		and Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>1 end
end
-- 发动效果1，选择1张卡送去墓地
function c34086406.operation1(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择满足条件的卡
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToGrave,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡送去墓地
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
-- 发动效果2，选择1只怪兽放置到卡组最上方
function c34086406.operation2(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要放置到卡组最上方的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(34086406,3))  --"请选择放置到卡组最上方的怪兽"
	-- 选择满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,Card.IsType,tp,LOCATION_DECK,0,1,1,nil,TYPE_MONSTER)
	local tc=g:GetFirst()
	if tc then
		-- 洗切玩家卡组
		Duel.ShuffleDeck(tp)
		-- 将选中的怪兽移动到卡组最上方
		Duel.MoveSequence(tc,SEQ_DECKTOP)
		-- 确认卡组最上方的1张卡
		Duel.ConfirmDecktop(tp,1)
	end
end
