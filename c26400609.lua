--瀑征竜－タイダル
-- 效果：
-- 这个卡名的①～④的效果1回合只能有1次使用其中任意1个。
-- ①：从手卡把这张卡和1只水属性怪兽丢弃去墓地才能发动。从卡组把1只怪兽送去墓地。
-- ②：把2只龙族或水属性的怪兽从自己的手卡·墓地除外才能发动。这张卡从手卡·墓地特殊召唤。
-- ③：这张卡特殊召唤的场合，对方结束阶段发动。这张卡回到手卡。
-- ④：这张卡被除外的场合才能发动。从卡组把1只龙族·水属性怪兽加入手卡。
function c26400609.initial_effect(c)
	-- 效果原文：②：把2只龙族或水属性的怪兽从自己的手卡·墓地除外才能发动。这张卡从手卡·墓地特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(26400609,0))  --"从手卡特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetCountLimit(1,26400609)
	e1:SetCost(c26400609.hspcost)
	e1:SetTarget(c26400609.hsptg)
	e1:SetOperation(c26400609.hspop)
	c:RegisterEffect(e1)
	-- 效果原文：③：这张卡特殊召唤的场合，对方结束阶段发动。这张卡回到手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(26400609,1))  --"返回手牌"
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,26400609)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetCondition(c26400609.retcon)
	e2:SetTarget(c26400609.rettg)
	e2:SetOperation(c26400609.retop)
	c:RegisterEffect(e2)
	-- 效果原文：①：从手卡把这张卡和1只水属性怪兽丢弃去墓地才能发动。从卡组把1只怪兽送去墓地。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(26400609,2))  --"从卡组把1只怪兽送去墓地"
	e3:SetCategory(CATEGORY_HANDES)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_HAND)
	e3:SetCountLimit(1,26400609)
	e3:SetCost(c26400609.tgcost)
	e3:SetTarget(c26400609.tgtg)
	e3:SetOperation(c26400609.tgop)
	c:RegisterEffect(e3)
	-- 效果原文：④：这张卡被除外的场合才能发动。从卡组把1只龙族·水属性怪兽加入手卡。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(26400609,3))  --"加入手卡"
	e4:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_REMOVE)
	e4:SetCountLimit(1,26400609)
	e4:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e4:SetTarget(c26400609.thtg)
	e4:SetOperation(c26400609.thop)
	c:RegisterEffect(e4)
	c26400609.Dragon_Ruler_handes_effect=e3
end
-- 检索满足龙族或水属性且能除外的卡片组
function c26400609.rfilter(c)
	return (c:IsRace(RACE_DRAGON) or c:IsAttribute(ATTRIBUTE_WATER)) and c:IsAbleToRemoveAsCost()
end
-- 检查是否有满足条件的2张卡并选择除外
function c26400609.hspcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否有满足条件的2张卡
	if chk==0 then return Duel.IsExistingMatchingCard(c26400609.rfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,2,e:GetHandler()) end
	-- 提示选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择满足条件的2张卡
	local g=Duel.SelectMatchingCard(tp,c26400609.rfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,2,2,e:GetHandler())
	-- 将选择的卡除外作为费用
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 检查是否可以特殊召唤
function c26400609.hsptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤的处理信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 执行特殊召唤操作
function c26400609.hspop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将卡片特殊召唤到场上
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- 判断是否为特殊召唤且为对方回合
function c26400609.retcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否为对方回合
	return Duel.GetTurnPlayer()==1-tp
		and e:GetHandler():IsSummonType(SUMMON_TYPE_SPECIAL)
end
-- 设置返回手牌的处理信息
function c26400609.rettg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置返回手牌的处理信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- 执行返回手牌操作
function c26400609.retop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 将卡片送回手牌
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end
-- 检索满足水属性且可丢弃的卡片组
function c26400609.dfilter(c)
	return c:IsAttribute(ATTRIBUTE_WATER) and c:IsDiscardable() and c:IsAbleToGraveAsCost()
end
-- 检查是否有满足条件的卡并选择丢弃
function c26400609.tgcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDiscardable() and e:GetHandler():IsAbleToGraveAsCost()
		-- 检查是否有满足条件的1张手牌
		and Duel.IsExistingMatchingCard(c26400609.dfilter,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 提示选择要丢弃的手牌
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)  --"请选择要丢弃的手牌"
	-- 选择满足条件的1张手牌
	local g=Duel.SelectMatchingCard(tp,c26400609.dfilter,tp,LOCATION_HAND,0,1,1,e:GetHandler())
	g:AddCard(e:GetHandler())
	-- 将选择的手牌丢弃作为费用
	Duel.SendtoGrave(g,REASON_COST+REASON_DISCARD)
end
-- 检索满足怪兽类型且可送去墓地的卡片组
function c26400609.tgfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToGrave()
end
-- 设置送去墓地的处理信息
function c26400609.tgtg(e,tp,eg,ep,ev,re,r,rp,chk,_,exc)
	-- 检查是否有满足条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c26400609.tgfilter,tp,LOCATION_DECK,0,1,exc) end
	-- 设置送去墓地的处理信息
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 执行送去墓地操作
function c26400609.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择满足条件的1张卡
	local g=Duel.SelectMatchingCard(tp,c26400609.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡送去墓地
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
-- 检索满足龙族和水属性且可加入手牌的卡片组
function c26400609.thfilter(c)
	return c:IsRace(RACE_DRAGON) and c:IsAttribute(ATTRIBUTE_WATER) and c:IsAbleToHand()
end
-- 设置加入手牌的处理信息
function c26400609.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否有满足条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c26400609.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置加入手牌的处理信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 执行加入手牌操作
function c26400609.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的1张卡
	local g=Duel.SelectMatchingCard(tp,c26400609.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 确认对方看到加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
