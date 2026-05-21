--青き眼の乙女
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：场上的表侧表示的这张卡成为效果的对象时才能发动。从自己的手卡·卡组·墓地选1只「青眼白龙」特殊召唤。
-- ②：这张卡被选择作为攻击对象时才能发动。那次攻击无效，这张卡的表示形式变更。那之后，可以从自己的手卡·卡组·墓地选1只「青眼白龙」特殊召唤。
function c88241506.initial_effect(c)
	-- 记录这张卡的效果中记载了「青眼白龙」（卡号89631139）的卡名。
	aux.AddCodeList(c,89631139)
	-- ②：这张卡被选择作为攻击对象时才能发动。那次攻击无效，这张卡的表示形式变更。那之后，可以从自己的手卡·卡组·墓地选1只「青眼白龙」特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(88241506,0))  --"攻击无效"
	e1:SetCategory(CATEGORY_POSITION+CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BE_BATTLE_TARGET)
	e1:SetCountLimit(1,88241506)
	e1:SetTarget(c88241506.natg)
	e1:SetOperation(c88241506.naop)
	c:RegisterEffect(e1)
	-- ①：场上的表侧表示的这张卡成为效果的对象时才能发动。从自己的手卡·卡组·墓地选1只「青眼白龙」特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(88241506,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EVENT_BECOME_TARGET)
	e2:SetCountLimit(1,88241506)
	e2:SetCondition(c88241506.spcon)
	e2:SetTarget(c88241506.sptg)
	e2:SetOperation(c88241506.spop)
	c:RegisterEffect(e2)
end
-- 过滤条件：卡名为「青眼白龙」且可以被特殊召唤。
function c88241506.spfilter(c,e,tp)
	return c:IsCode(89631139) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 被选择作为攻击对象时效果的发动准备（Target阶段），设置改变表示形式的操作信息。
function c88241506.natg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：此效果包含改变自身表示形式的操作。
	Duel.SetOperationInfo(0,CATEGORY_POSITION,e:GetHandler(),1,0,0)
end
-- 被选择作为攻击对象时效果的处理（Resolution阶段）：无效攻击，改变自身表示形式，并可选择特殊召唤「青眼白龙」。
function c88241506.naop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查是否成功无效攻击，且自身仍在场上。
	if Duel.NegateAttack() and c:IsRelateToEffect(e) then
		-- 改变这张卡的表示形式（攻击表示变守备表示，守备表示变攻击表示）。
		Duel.ChangePosition(c,POS_FACEUP_DEFENSE,POS_FACEUP_DEFENSE,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK)
		-- 检查自己场上是否有可用的怪兽区域，若无则结束效果处理。
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		-- 获取自己手卡、卡组、墓地中满足特召条件且不受「王家长眠之谷」影响的「青眼白龙」卡片组。
		local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(c88241506.spfilter),tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,nil,e,tp)
		-- 若存在可特殊召唤的「青眼白龙」，则询问玩家是否进行特殊召唤。
		if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(88241506,2)) then  --"是否要选择「青眼白龙」特殊召唤？"
			-- 中断当前效果，使之后的效果处理（特殊召唤）视为不同时处理。
			Duel.BreakEffect()
			-- 给玩家发送提示信息，提示选择要特殊召唤的卡。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			local g1=g:Select(tp,1,1,nil)
			-- 将选中的「青眼白龙」以表侧表示特殊召唤到自己场上。
			Duel.SpecialSummon(g1,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
-- 成为效果对象时效果的发动条件：成为效果对象的卡中包含这张卡自身。
function c88241506.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsContains(e:GetHandler())
end
-- 成为效果对象时效果的发动准备（Target阶段），检查怪兽区域空格及是否存在可特召的「青眼白龙」，并设置特召操作信息。
function c88241506.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动准备阶段，检查自己场上是否有可用的怪兽区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 在发动准备阶段，检查自己的手卡、卡组、墓地是否存在至少1只可以特殊召唤的「青眼白龙」。
		and Duel.IsExistingMatchingCard(c88241506.spfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置操作信息：此效果包含从手卡、卡组、墓地特殊召唤1只怪兽的操作。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE)
end
-- 成为效果对象时效果的处理（Resolution阶段）：从手卡、卡组、墓地选择1只「青眼白龙」特殊召唤。
function c88241506.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否有可用的怪兽区域，若无则结束效果处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 给玩家发送提示信息，提示选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手卡、卡组、墓地中选择1只不受「王家长眠之谷」影响的「青眼白龙」。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c88241506.spfilter),tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的「青眼白龙」以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
