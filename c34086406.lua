--ラヴァルバル・チェイン
-- 效果：
-- 4星怪兽×2
-- ①：1回合1次，可以把这张卡1个超量素材取除，从以下效果选择1个发动。
-- ●从卡组选1张卡送去墓地。
-- ●从卡组选1只怪兽在卡组最上面放置。
function c34086406.initial_effect(c)
	-- 为熔岩谷锁链龙添加超量召唤手续：以任意2只4星怪兽为超量素材叠放进行超量召唤。
	aux.AddXyzProcedure(c,nil,4,2)
	c:EnableReviveLimit()
	-- ①：1回合1次，可以把这张卡1个超量素材取除，从以下效果选择1个发动。●从卡组选1张卡送去墓地。
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
	-- ①：1回合1次，可以把这张卡1个超量素材取除，从以下效果选择1个发动。●从卡组选1只怪兽在卡组最上面放置。
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
-- 这是两个选项共用的发动费用：效果发动时必须从这张卡上取除1个超量素材；先检查能否取除，再向对方提示选择的效果，并实际取除1个素材。
function c34086406.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	-- 向对方玩家提示本次发动选择的是哪个效果（显示该效果的描述文本），以便对方确认。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 第一个选项的发动条件检测与操作信息登记：检查自己卡组中是否有至少1张可以送去墓地的卡，并设置本次连锁将把卡组中的1张卡送去墓地的操作信息。
function c34086406.target1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在合法性检查阶段（chk==0），确认自己卡组中存在至少1张满足“可以送去墓地”条件的卡，作为该效果能否发动的条件。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToGrave,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：该效果属于“送去墓地”分类，目标为持有者是自己（tp）的卡组中的1张卡（数量1，处理时选择具体卡）。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 第二个选项的发动条件检测：确认自己卡组中至少存在1只怪兽，且卡组数量大于1，以满足“从卡组选1只怪兽在卡组最上面放置”的条件。
function c34086406.target2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在合法性检查阶段，确认自己卡组中存在至少1只怪兽卡，作为该选项的发动条件之一。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsType,tp,LOCATION_DECK,0,1,nil,TYPE_MONSTER)
		-- 追加条件：自己卡组的卡数量必须大于1，从而保证能够选出一只怪兽并放置到卡组最上方。
		and Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>1 end
end
-- 第一个选项的效果处理：玩家从自己卡组选择1张可以送去墓地的卡，将其送去墓地。
function c34086406.operation1(e,tp,eg,ep,ev,re,r,rp)
	-- 显示选择提示消息“请选择要送去墓地的卡”，引导玩家选择要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从自己卡组中选择1张可以送去墓地的卡（不取对象，在效果处理时选择）。
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToGrave,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的那张卡以“效果”的原因送去墓地。
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
-- 第二个选项的效果处理：从自己卡组选择1只怪兽，洗切卡组后将那只怪兽放到卡组最上面，并确认最上方的卡。
function c34086406.operation2(e,tp,eg,ep,ev,re,r,rp)
	-- 显示选择提示消息“请选择放置到卡组最上方的怪兽”，引导玩家选择要放置到卡组最上方的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(34086406,3))  --"请选择放置到卡组最上方的怪兽"
	-- 从自己卡组中选择1只怪兽卡（不取对象，在效果处理时选择）。
	local g=Duel.SelectMatchingCard(tp,Card.IsType,tp,LOCATION_DECK,0,1,1,nil,TYPE_MONSTER)
	local tc=g:GetFirst()
	if tc then
		-- 洗切自己的卡组，避免选择过程中卡组顺序被不当获知，然后再将选中的怪兽移动到卡组顶端。
		Duel.ShuffleDeck(tp)
		-- 将选中的怪兽移动到卡组最上方的位置（序列号设为卡组顶端）。
		Duel.MoveSequence(tc,SEQ_DECKTOP)
		-- 确认自己卡组最上方1张卡，即被放置到顶部的怪兽，让双方确认。
		Duel.ConfirmDecktop(tp,1)
	end
end
