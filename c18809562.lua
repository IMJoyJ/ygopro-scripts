--魔導契約の扉
-- 效果：
-- ①：从自己手卡选1张魔法卡加入对方手卡。那之后，从自己卡组把1只7·8星的暗属性怪兽加入自己手卡。
function c18809562.initial_effect(c)
	-- ①：从自己手卡选1张魔法卡加入对方手卡。那之后，从自己卡组把1只7·8星的暗属性怪兽加入自己手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c18809562.target)
	e1:SetOperation(c18809562.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数：判定卡片是否为7·8星且暗属性，并且能够加入手卡。
function c18809562.filter(c)
	return c:IsLevel(7,8) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsAbleToHand()
end
-- 效果发动条件判定：自己手牌存在魔法卡且卡组存在符合条件的7·8星暗属性怪兽时才可发动。
function c18809562.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己手牌是否存在1张魔法卡。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsType,tp,LOCATION_HAND,0,1,e:GetHandler(),TYPE_SPELL)
		-- 检查自己卡组是否存在1只满足filter条件的7·8星暗属性怪兽。
		and Duel.IsExistingMatchingCard(c18809562.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：本次效果可能涉及从卡组将卡片加入手卡，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：先选择1张手牌魔法卡加入对方手卡，再从卡组选1只7·8星暗属性怪兽加入自己手卡。
function c18809562.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 显示提示，要求玩家选择1张要加入对方手卡的手牌魔法卡。
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(18809562,0))  --"请选择要加入对方手卡的卡"
	-- 从自己手牌选择1张魔法卡，此选择发生在效果处理时而非发动时。
	local ag=Duel.SelectMatchingCard(tp,Card.IsType,tp,LOCATION_HAND,0,1,1,nil,TYPE_SPELL)
	if ag:GetCount()>0 then
		-- 将选择的手牌魔法卡加入对方手卡。
		Duel.SendtoHand(ag,1-tp,REASON_EFFECT)
		-- 让对方确认被加入手卡的是哪张卡。
		Duel.ConfirmCards(tp,ag)
		-- 洗切自己的手卡。
		Duel.ShuffleHand(tp)
		-- 洗切对方的手卡，因为手牌顺序因加入卡片而可能改变。
		Duel.ShuffleHand(1-tp)
		-- 显示提示，要求玩家选择1只要加入自己手牌的怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 从自己卡组选择1只满足filter条件的7·8星暗属性怪兽。
		local g=Duel.SelectMatchingCard(tp,c18809562.filter,tp,LOCATION_DECK,0,1,1,nil)
		if g:GetCount()>0 then
			-- 中断效果处理，使后续检索加入手牌的处理与前面的赠卡处理不同时进行，避免时点被占据。
			Duel.BreakEffect()
			-- 将检索到的怪兽加入其持有者（自己）的手卡。
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			-- 让对方确认检索到的怪兽卡片。
			Duel.ConfirmCards(1-tp,g)
		end
	end
end
