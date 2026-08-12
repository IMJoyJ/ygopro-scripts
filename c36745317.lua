--森と目覚の春化精
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：把这张卡和1只怪兽或者和1张「春化精」卡从手卡丢弃才能发动。把1只可以通常召唤的地属性怪兽从卡组送去墓地。那之后，可以从自己墓地选和那只怪兽卡名不同的1只地属性怪兽特殊召唤。这个回合，自己不能把地属性以外的怪兽的效果发动。
-- ②：以自己场上1只「春化精」怪兽为对象才能发动。那只怪兽的攻击力直到回合结束时变成2倍。
function c36745317.initial_effect(c)
	-- ①：把这张卡和1只怪兽或者和1张「春化精」卡从手卡丢弃才能发动。把1只可以通常召唤的地属性怪兽从卡组送去墓地。那之后，可以从自己墓地选和那只怪兽卡名不同的1只地属性怪兽特殊召唤。这个回合，自己不能把地属性以外的怪兽的效果发动。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_SPECIAL_SUMMON+CATEGORY_GRAVE_SPSUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,36745317)
	e1:SetCost(c36745317.tgcost)
	e1:SetTarget(c36745317.tgtg)
	e1:SetOperation(c36745317.tgop)
	c:RegisterEffect(e1)
	-- ②：以自己场上1只「春化精」怪兽为对象才能发动。那只怪兽的攻击力直到回合结束时变成2倍。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,36745318)
	e2:SetTarget(c36745317.atktg)
	e2:SetOperation(c36745317.atkop)
	c:RegisterEffect(e2)
end
-- 用于判断手牌是否可以作为发动①效果的代价，条件为：是怪兽卡或「春化精」卡且可丢弃。
function c36745317.costfilter(c)
	return (c:IsType(TYPE_MONSTER) or c:IsSetCard(0x182)) and c:IsDiscardable()
end
-- ①效果的发动费用处理，检查是否满足丢弃条件，若适用「春化精的花冠」效果则优先使用该效果。
function c36745317.tgcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查玩家是否受到「春化精的花冠」效果影响。
	local fe=Duel.IsPlayerAffectedByEffect(tp,14108995)
	-- 检查玩家手牌中是否存在满足代价条件的卡。
	local b2=Duel.IsExistingMatchingCard(c36745317.costfilter,tp,LOCATION_HAND,0,1,c)
	if chk==0 then return c:IsDiscardable() and (fe or b2) end
	-- 判断是否使用「春化精的花冠」效果，若适用则使用该效果。
	if fe and (not b2 or Duel.SelectYesNo(tp,aux.Stringid(14108995,0))) then  --"是否适用「春化精的花冠」的效果？"
		-- 提示使用「春化精的花冠」效果。
		Duel.Hint(HINT_CARD,0,14108995)
		fe:UseCountLimit(tp)
		-- 将发动效果的卡送入墓地作为费用。
		Duel.SendtoGrave(c,REASON_COST+REASON_DISCARD)
	else
		-- 提示玩家选择要丢弃的手牌。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)  --"请选择要丢弃的手牌"
		-- 选择满足代价条件的手牌。
		local g=Duel.SelectMatchingCard(tp,c36745317.costfilter,tp,LOCATION_HAND,0,1,1,c)
		g:AddCard(c)
		-- 将选择的卡送入墓地作为费用。
		Duel.SendtoGrave(g,REASON_COST+REASON_DISCARD)
	end
end
-- 用于筛选可以送去墓地的地属性怪兽，条件为：地属性、可通常召唤且能送去墓地。
function c36745317.tgfilter(c)
	return c:IsAttribute(ATTRIBUTE_EARTH) and c:IsSummonableCard() and c:IsAbleToGrave()
end
-- ①效果的发动条件处理，检查卡组中是否存在满足条件的怪兽。
function c36745317.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在满足条件的怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c36745317.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置效果处理信息，表示将要从卡组送去墓地1张卡。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 用于筛选可以从墓地特殊召唤的地属性怪兽，条件为：地属性、卡名与送去墓地的怪兽不同、可特殊召唤。
function c36745317.spfilter(c,e,tp,code)
	return c:IsAttribute(ATTRIBUTE_EARTH) and not c:IsCode(code) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①效果的处理流程，选择并送去墓地1只怪兽，之后从墓地特殊召唤1只怪兽。
function c36745317.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择满足条件的怪兽送去墓地。
	local g=Duel.SelectMatchingCard(tp,c36745317.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	local tc=g:GetFirst()
	-- 判断是否成功将卡送去墓地。
	if g:GetCount()>0 and Duel.SendtoGrave(g,REASON_EFFECT)>0 and tc:IsLocation(LOCATION_GRAVE) then
		-- 获取满足特殊召唤条件的墓地怪兽组。
		local sg=Duel.GetMatchingGroup(aux.NecroValleyFilter(c36745317.spfilter),tp,LOCATION_GRAVE,0,nil,e,tp,tc:GetCode())
		-- 检查玩家场上是否有空位。
		if sg:GetCount()>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			-- 询问玩家是否从墓地特殊召唤。
			and Duel.SelectYesNo(tp,aux.Stringid(36745317,0)) then  --"是否从墓地特殊召唤？"
			-- 中断当前效果处理，使后续处理视为错时点。
			Duel.BreakEffect()
			-- 提示玩家选择要特殊召唤的卡。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			local sc=sg:Select(tp,1,1,nil)
			-- 将选择的卡特殊召唤。
			Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)
		end
	end
	-- ①效果发动后，设置一个回合结束时无效地属性以外怪兽效果发动的效果。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetTargetRange(1,0)
	e1:SetValue(c36745317.aclimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将设置的效果注册到场上。
	Duel.RegisterEffect(e1,tp)
end
-- 设置无效效果的判断条件，即无效非地属性怪兽的效果。
function c36745317.aclimit(e,re,tp)
	return re:IsActiveType(TYPE_MONSTER) and re:GetHandler():IsNonAttribute(ATTRIBUTE_EARTH)
end
-- 用于判断是否为「春化精」怪兽且表侧表示。
function c36745317.atkfilter(c)
	return c:IsSetCard(0x182) and c:IsFaceup()
end
-- ②效果的发动条件处理，选择场上1只「春化精」怪兽作为对象。
function c36745317.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c36745317.atkfilter(chkc) end
	-- 检查场上是否存在满足条件的「春化精」怪兽。
	if chk==0 then return Duel.IsExistingTarget(c36745317.atkfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择表侧表示的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择场上1只「春化精」怪兽作为对象。
	Duel.SelectTarget(tp,c36745317.atkfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- ②效果的处理流程，将对象怪兽的攻击力变为2倍。
function c36745317.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前效果的目标怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 设置目标怪兽的攻击力变为2倍的效果。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(tc:GetAttack()*2)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
