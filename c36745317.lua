--森と目覚の春化精
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：把这张卡和1只怪兽或者和1张「春化精」卡从手卡丢弃才能发动。把1只可以通常召唤的地属性怪兽从卡组送去墓地。那之后，可以从自己墓地选和那只怪兽卡名不同的1只地属性怪兽特殊召唤。这个回合，自己不能把地属性以外的怪兽的效果发动。
-- ②：以自己场上1只「春化精」怪兽为对象才能发动。那只怪兽的攻击力直到回合结束时变成2倍。
function c36745317.initial_effect(c)
	-- 这个卡名的①②的效果1回合各能使用1次。①：把这张卡和1只怪兽或者和1张「春化精」卡从手卡丢弃才能发动。把1只可以通常召唤的地属性怪兽从卡组送去墓地。那之后，可以从自己墓地选和那只怪兽卡名不同的1只地属性怪兽特殊召唤。
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
-- 定义代价过滤函数：选择手卡中能够丢弃的怪兽卡或「春化精」卡，作为①效果发动时与这张卡一起丢弃的候选。
function c36745317.costfilter(c)
	return (c:IsType(TYPE_MONSTER) or c:IsSetCard(0x182)) and c:IsDiscardable()
end
-- ①效果的代价处理：根据是否适用「春化精的花冠」选择只丢弃自身，还是从手卡另选1只怪兽/「春化精」卡与自身一同丢弃，并实际执行丢弃。
function c36745317.tgcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 获取玩家是否受到「春化精的花冠」（14108995）的适用中效果影响，该效果可让「春化精」怪兽效果发动时的丢弃代价只丢弃那只怪兽。
	local fe=Duel.IsPlayerAffectedByEffect(tp,14108995)
	-- 检查手牌中是否存在这张卡以外、可作为追加代价丢弃的怪兽或「春化精」卡，用于判断常规代价是否满足。
	local b2=Duel.IsExistingMatchingCard(c36745317.costfilter,tp,LOCATION_HAND,0,1,c)
	if chk==0 then return c:IsDiscardable() and (fe or b2) end
	-- 如果适用花冠效果，且没有其他可丢弃卡或玩家选择适用花冠，则改为按花冠的代替方式只丢弃这张卡。
	if fe and (not b2 or Duel.SelectYesNo(tp,aux.Stringid(14108995,0))) then  --"是否适用「春化精的花冠」的效果？"
		-- 展示「春化精的花冠」的卡片动画，提示正在适用花冠的代替效果。
		Duel.Hint(HINT_CARD,0,14108995)
		fe:UseCountLimit(tp)
		-- 将这张卡自身作为代价丢弃（在花冠代替下只丢这1张）。
		Duel.SendtoGrave(c,REASON_COST+REASON_DISCARD)
	else
		-- 显示提示文字，要求玩家从手卡选择要丢弃的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)  --"请选择要丢弃的手牌"
		-- 从手卡中选择1张满足代价过滤条件的卡（怪兽或「春化精」卡，不能选自身）作为追加代价。
		local g=Duel.SelectMatchingCard(tp,c36745317.costfilter,tp,LOCATION_HAND,0,1,1,c)
		g:AddCard(c)
		-- 将选中的追加代价卡和这张卡一起丢弃去墓地，完成代价支付。
		Duel.SendtoGrave(g,REASON_COST+REASON_DISCARD)
	end
end
-- 定义从卡组送墓的过滤条件：地属性、可以通常召唤的怪兽、且能送去墓地。
function c36745317.tgfilter(c)
	return c:IsAttribute(ATTRIBUTE_EARTH) and c:IsSummonableCard() and c:IsAbleToGrave()
end
-- ①效果的目标处理：确认卡组有符合条件的怪兽可送墓，并设置“从卡组送1张卡去墓地”的操作信息。
function c36745317.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：卡组中不存在符合条件的可通常召唤地属性怪兽时不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c36745317.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息，标明本次效果包含从卡组将1张卡送去墓地的处理，供其他效果参考。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 定义墓地特殊召唤的过滤条件：地属性、卡名与已送墓怪兽不同、可被当前效果特殊召唤。
function c36745317.spfilter(c,e,tp,code)
	return c:IsAttribute(ATTRIBUTE_EARTH) and not c:IsCode(code) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①效果的处理：从卡组选1张地属性可通常召唤怪兽送去墓地；成功且该卡在墓地时，再选择是否从墓地特殊召唤1只不同卡名的地属性怪兽。
function c36745317.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 显示“请选择要送去墓地的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从卡组选择1张符合条件的怪兽送去墓地。
	local g=Duel.SelectMatchingCard(tp,c36745317.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	local tc=g:GetFirst()
	-- 确认送墓成功且该怪兽实际在墓地，才继续后续的特召处理。
	if g:GetCount()>0 and Duel.SendtoGrave(g,REASON_EFFECT)>0 and tc:IsLocation(LOCATION_GRAVE) then
		-- 筛选自己墓地中可特殊召唤的地属性且卡名不同的候选怪兽，并排除受王家长眠之谷影响无法移动的卡。
		local sg=Duel.GetMatchingGroup(aux.NecroValleyFilter(c36745317.spfilter),tp,LOCATION_GRAVE,0,nil,e,tp,tc:GetCode())
		-- 确认墓地存在可特殊召唤的候选，且己方场上有空余的怪兽区域。
		if sg:GetCount()>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			-- 询问玩家是否选择执行“从墓地特殊召唤”的后续处理。
			and Duel.SelectYesNo(tp,aux.Stringid(36745317,0)) then  --"是否从墓地特殊召唤？"
			-- 中断当前效果处理，使特殊召唤与之前的送墓效果错开时点，避免占用同一时点。
			Duel.BreakEffect()
			-- 显示“请选择要特殊召唤的卡”的选择提示。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			local sc=sg:Select(tp,1,1,nil)
			-- 将选中的墓地怪兽以表侧攻击表示特殊召唤到自己场上。
			Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)
		end
	end
	-- 这个回合，自己不能把地属性以外的怪兽的效果发动。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetTargetRange(1,0)
	e1:SetValue(c36745317.aclimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将自肃效果注册到决斗中：该效果为影响玩家的永续效果，持续到回合结束时。
	Duel.RegisterEffect(e1,tp)
end
-- 自肃效果的判定函数：若发动的是怪兽效果且该怪兽不是地属性，则禁止其发动。
function c36745317.aclimit(e,re,tp)
	return re:IsActiveType(TYPE_MONSTER) and re:GetHandler():IsNonAttribute(ATTRIBUTE_EARTH)
end
-- 定义②效果的取对象过滤条件：表侧表示的「春化精」怪兽。
function c36745317.atkfilter(c)
	return c:IsSetCard(0x182) and c:IsFaceup()
end
-- ②效果的目标处理：确认自己场上有表侧「春化精」怪兽可对象，并让玩家选择1只作为对象。
function c36745317.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c36745317.atkfilter(chkc) end
	-- 发动条件检查：自己场上不存在表侧「春化精」怪兽时不能发动。
	if chk==0 then return Duel.IsExistingTarget(c36745317.atkfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 显示“请选择表侧表示的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 从自己场上选择1只表侧表示「春化精」怪兽，将其设置为效果对象。
	Duel.SelectTarget(tp,c36745317.atkfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- ②效果处理函数：若对象仍与效果关联且表侧表示，则使其攻击力变成当前攻击力的2倍直到回合结束。
function c36745317.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得②效果选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 那只怪兽的攻击力直到回合结束时变成2倍。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(tc:GetAttack()*2)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
