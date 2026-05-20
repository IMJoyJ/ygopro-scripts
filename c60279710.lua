--サイバース・エンチャンター
-- 效果：
-- 怪兽2只以上
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡是已用「电子界男巫」为素材作连接召唤的场合，以对方场上1只怪兽为对象才能发动。那只怪兽的表示形式变更，那个效果直到回合结束时无效化。这个效果在对方回合也能发动。
-- ②：这张卡被战斗或者对方的效果破坏的场合才能发动。从自己的手卡·卡组·墓地选1只「电子界男巫」特殊召唤。
function c60279710.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡添加连接召唤手续，需要2只以上的怪兽作为素材。
	aux.AddLinkProcedure(c,nil,2)
	-- ①：这张卡是已用「电子界男巫」为素材作连接召唤的场合
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_MATERIAL_CHECK)
	e0:SetValue(c60279710.valcheck)
	c:RegisterEffect(e0)
	-- ①：这张卡是已用「电子界男巫」为素材作连接召唤的场合，以对方场上1只怪兽为对象才能发动。那只怪兽的表示形式变更，那个效果直到回合结束时无效化。这个效果在对方回合也能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(60279710,0))
	e1:SetCategory(CATEGORY_POSITION+CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,60279710)
	e1:SetCondition(c60279710.poscon)
	e1:SetTarget(c60279710.postg)
	e1:SetOperation(c60279710.posop)
	e1:SetLabelObject(e0)
	c:RegisterEffect(e1)
	-- ②：这张卡被战斗或者对方的效果破坏的场合才能发动。从自己的手卡·卡组·墓地选1只「电子界男巫」特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(60279710,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetCountLimit(1,60279711)
	e2:SetCondition(c60279710.spcon)
	e2:SetTarget(c60279710.sptg)
	e2:SetOperation(c60279710.spop)
	c:RegisterEffect(e2)
end
-- 检查连接素材中是否存在卡名为「电子界男巫」的怪兽，若存在则将效果的Label设为1。
function c60279710.valcheck(e,c)
	local g=c:GetMaterial()
	e:SetLabel(0)
	if g:IsExists(Card.IsLinkCode,1,nil,36033786) then
		e:SetLabel(1)
	end
end
-- 判定效果1的发动条件，即检查连接召唤时是否使用了「电子界男巫」作为素材。
function c60279710.poscon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetLabelObject():GetLabel()==1
end
-- 效果1的靶向/发动准备阶段，确认对方场上是否存在可以改变表示形式的怪兽并将其作为效果对象。
function c60279710.postg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and chkc:IsCanChangePosition() end
	-- 在发动效果的检测阶段，检查对方场上是否存在至少1只可以改变表示形式的怪兽。
	if chk==0 then return Duel.IsExistingTarget(Card.IsCanChangePosition,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择效果的对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 让玩家选择对方场上1只可以改变表示形式的怪兽作为效果的对象。
	Duel.SelectTarget(tp,Card.IsCanChangePosition,tp,0,LOCATION_MZONE,1,1,nil)
end
-- 效果1的处理函数，将作为对象的怪兽表示形式变更，并使其效果直到回合结束时无效。
function c60279710.posop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取在发动时选择的效果对象怪兽。
	local tc=Duel.GetFirstTarget()
	-- 确认对象怪兽是否仍适用此效果，将其表示形式变更，若变更成功且该怪兽处于表侧表示，则继续处理无效化效果。
	if tc:IsRelateToEffect(e) and Duel.ChangePosition(tc,POS_FACEUP_DEFENSE,POS_FACEDOWN_DEFENSE,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK)>0 and (tc:IsFaceup() and tc:IsCanBeDisabledByEffect(e)) then
		-- 使与该对象怪兽相关的连锁中已发动的效果无效化。
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		-- 那个效果直到回合结束时无效化。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 那个效果直到回合结束时无效化。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
	end
end
-- 判定效果2的发动条件，即这张卡被战斗或者对方的效果破坏。
function c60279710.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_BATTLE)
		or (rp==1-tp and c:IsReason(REASON_EFFECT) and c:IsPreviousControler(tp))
end
-- 过滤出卡名为「电子界男巫」且可以被特殊召唤的怪兽。
function c60279710.spfilter(c,e,tp)
	return c:IsCode(36033786) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果2的发动准备阶段，确认自身场上有空余怪兽区域，且手卡、卡组、墓地存在可特殊召唤的「电子界男巫」。
function c60279710.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动效果的检测阶段，检查自己场上是否有空余的怪兽区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己的手卡、卡组、墓地是否存在至少1只满足特殊召唤条件的「电子界男巫」。
		and Duel.IsExistingMatchingCard(c60279710.spfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置效果处理的分类为特殊召唤，涉及卡片数量为1，范围为手卡、卡组、墓地。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE)
end
-- 效果2的处理函数，从自己的手卡、卡组、墓地选择1只「电子界男巫」特殊召唤。
function c60279710.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时，若自己场上已无空余的怪兽区域，则不处理效果。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己的手卡、卡组、墓地中选择1只不受「王家长眠之谷」影响的「电子界男巫」。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c60279710.spfilter),tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
