--青き眼の乙女
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：场上的表侧表示的这张卡成为效果的对象时才能发动。从自己的手卡·卡组·墓地选1只「青眼白龙」特殊召唤。
-- ②：这张卡被选择作为攻击对象时才能发动。那次攻击无效，这张卡的表示形式变更。那之后，可以从自己的手卡·卡组·墓地选1只「青眼白龙」特殊召唤。
function c88241506.initial_effect(c)
	-- 在卡上记述「青眼白龙」的卡号，供相关效果检索与识别
	aux.AddCodeList(c,89631139)
	-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。 ②：这张卡被选择作为攻击对象时才能发动。那次攻击无效，这张卡的表示形式变更。那之后，可以从自己的手卡·卡组·墓地选1只「青眼白龙」特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(88241506,0))  --"攻击无效"
	e1:SetCategory(CATEGORY_POSITION+CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES+CATEGORY_DECK_SPSUMMON)
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
-- 筛选条件：检查卡片是否为可特殊召唤的「青眼白龙」
function c88241506.spfilter(c,e,tp)
	return c:IsCode(89631139) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果的发动检测与连锁信息设置：因被选为攻击对象直接通过检测，并登记改变自身表示形式的操作信息
function c88241506.natg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 登记连锁的改变表示形式操作信息，预计改变这张卡的表示形式
	Duel.SetOperationInfo(0,CATEGORY_POSITION,e:GetHandler(),1,0,0)
end
-- ②效果的处理流程：先无效该次攻击并变更这张卡的表示形式，之后在己方有空位时可选从手卡·卡组·墓地特殊召唤1只「青眼白龙」
function c88241506.naop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 执行无效本次攻击，若无效成功且这张卡仍与效果有联系则继续后续处理
	if Duel.NegateAttack() and c:IsRelateToEffect(e) then
		-- 将这张卡的表示形式在表侧攻击与表侧守备之间变更
		Duel.ChangePosition(c,POS_FACEUP_DEFENSE,POS_FACEUP_DEFENSE,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK)
		-- 检查己方主要怪兽区是否有空位，若无空位则结束处理
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		-- 获取己方手卡·卡组·墓地（经王家长眠之谷过滤）中所有可特殊召唤的「青眼白龙」
		local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(c88241506.spfilter),tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,nil,e,tp)
		-- 若存在可特召的「青眼白龙」，询问己方是否选择特殊召唤
		if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(88241506,2)) then  --"是否要选择「青眼白龙」特殊召唤？"
			-- 中断效果处理，使后续的特殊召唤与前面的无效攻击和变更表示形式视为不同时处理
			Duel.BreakEffect()
			-- 向己方提示选择要特殊召唤的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			local g1=g:Select(tp,1,1,nil)
			-- 将所选「青眼白龙」以表侧表示特殊召唤到己方场上
			Duel.SpecialSummon(g1,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
-- ①效果的发动条件检查：确认当前成为效果对象的卡片组中包含这张卡
function c88241506.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsContains(e:GetHandler())
end
-- ①效果的发动检测：确认己方怪兽区有空位且己方手卡·卡组·墓地存在可特殊召唤的「青眼白龙」
function c88241506.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查（前半）：确认己方主要怪兽区存在可用空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 发动条件检查（后半）：确认己方手卡·卡组·墓地存在至少1只可特殊召唤的「青眼白龙」
		and Duel.IsExistingMatchingCard(c88241506.spfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 登记连锁的特殊召唤操作信息，预计从己方手卡·卡组·墓地特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE)
end
-- ①效果的处理流程：确认己方怪兽区有空位后，从手卡·卡组·墓地选1只「青眼白龙」特殊召唤
function c88241506.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查己方主要怪兽区是否有空位，若无空位则结束处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向己方提示选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让己方从手卡·卡组·墓地（经王家长眠之谷过滤）选择1只「青眼白龙」
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c88241506.spfilter),tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将所选「青眼白龙」以表侧表示特殊召唤到己方场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
