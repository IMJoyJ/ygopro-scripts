--武神帝－スサノヲ
-- 效果：
-- 4星「武神」怪兽×2
-- ①：「武神帝-须佐之男」在自己场上只能有1只表侧表示存在。
-- ②：这张卡可以向对方怪兽全部各作1次攻击。
-- ③：1回合1次，把这张卡1个超量素材取除才能发动。从卡组选1只「武神」怪兽加入手卡或送去墓地。
function c75840616.initial_effect(c)
	c:SetUniqueOnField(1,0,75840616)
	-- 设置超量召唤手续：需要2只4星的「武神」怪兽
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsSetCard,0x88),4,2)
	c:EnableReviveLimit()
	-- ③：1回合1次，把这张卡1个超量素材取除才能发动。从卡组选1只「武神」怪兽加入手卡或送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_DECKDES)
	e1:SetDescription(aux.Stringid(75840616,0))  --"检索"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c75840616.cost)
	e1:SetTarget(c75840616.target)
	e1:SetOperation(c75840616.operation)
	c:RegisterEffect(e1)
	-- ②：这张卡可以向对方怪兽全部各作1次攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_ATTACK_ALL)
	e2:SetValue(1)
	c:RegisterEffect(e2)
end
-- 效果③的代价值：检查并取除这张卡的1个超量素材
function c75840616.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 过滤卡组中属于「武神」且可以加入手卡或送去墓地的怪兽
function c75840616.filter(c)
	return c:IsSetCard(0x88) and c:IsType(TYPE_MONSTER) and (c:IsAbleToHand() or c:IsAbleToGrave())
end
-- 效果③的发动准备：检查卡组中是否存在符合条件的「武神」怪兽
function c75840616.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段，检查卡组中是否存在至少1只可以加入手卡或送去墓地的「武神」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c75840616.filter,tp,LOCATION_DECK,0,1,nil) end
end
-- 效果③的实际效果：从卡组选择1只「武神」怪兽，并根据玩家选择将其加入手卡或送去墓地
function c75840616.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家发送提示信息，要求选择要操作的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
	-- 从卡组中选择1只满足过滤条件的「武神」怪兽
	local g=Duel.SelectMatchingCard(tp,c75840616.filter,tp,LOCATION_DECK,0,1,1,nil)
	local tc=g:GetFirst()
	-- 判断所选卡片是否能加入手卡，若能且不能送去墓地，或玩家在提示框中选择了“加入手卡”选项，则执行加入手卡分支
	if tc and tc:IsAbleToHand() and (not tc:IsAbleToGrave() or Duel.SelectOption(tp,1190,1191)==0) then
		-- 将选中的卡片加入手卡
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手卡的卡片
		Duel.ConfirmCards(1-tp,tc)
	else
		-- 将选中的卡片送去墓地
		Duel.SendtoGrave(tc,REASON_EFFECT)
	end
end
