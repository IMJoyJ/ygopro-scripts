--魔導契約の扉
-- 效果：
-- ①：从自己手卡选1张魔法卡加入对方手卡。那之后，从自己卡组把1只7·8星的暗属性怪兽加入自己手卡。
function c18809562.initial_effect(c)
	-- 效果原文内容：①：从自己手卡选1张魔法卡加入对方手卡。那之后，从自己卡组把1只7·8星的暗属性怪兽加入自己手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c18809562.target)
	e1:SetOperation(c18809562.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于筛选等级为7或8、属性为暗、可以送去手卡的怪兽
function c18809562.filter(c)
	return c:IsLevel(7,8) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsAbleToHand()
end
-- 效果的发动条件判断，检查自己手卡是否存在魔法卡且自己卡组存在符合条件的怪兽
function c18809562.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己手卡是否存在魔法卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsType,tp,LOCATION_HAND,0,1,e:GetHandler(),TYPE_SPELL)
		-- 检查自己卡组是否存在符合条件的怪兽
		and Duel.IsExistingMatchingCard(c18809562.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁处理信息，表示将要处理的卡是对方手卡的魔法卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果的发动处理函数，执行效果的两个步骤：将魔法卡送至对方手卡，再从卡组检索符合条件的怪兽
function c18809562.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入对方手卡的魔法卡
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(18809562,0))  --"请选择要加入对方手卡的卡"
	-- 选择满足条件的魔法卡
	local ag=Duel.SelectMatchingCard(tp,Card.IsType,tp,LOCATION_HAND,0,1,1,nil,TYPE_SPELL)
	if ag:GetCount()>0 then
		-- 将选中的魔法卡送至对方手卡
		Duel.SendtoHand(ag,1-tp,REASON_EFFECT)
		-- 确认玩家选择的魔法卡
		Duel.ConfirmCards(tp,ag)
		-- 洗切自己的手卡
		Duel.ShuffleHand(tp)
		-- 洗切对方的手卡
		Duel.ShuffleHand(1-tp)
		-- 提示玩家选择要加入手牌的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 选择满足条件的怪兽
		local g=Duel.SelectMatchingCard(tp,c18809562.filter,tp,LOCATION_DECK,0,1,1,nil)
		if g:GetCount()>0 then
			-- 中断当前效果，使后续处理视为不同时处理
			Duel.BreakEffect()
			-- 将选中的怪兽送至自己的手卡
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			-- 确认对方选择的怪兽
			Duel.ConfirmCards(1-tp,g)
		end
	end
end
