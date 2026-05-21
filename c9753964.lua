--琰魔竜 レッド・デーモン・アビス
-- 效果：
-- 调整＋调整以外的龙族·暗属性同调怪兽1只
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己·对方回合，以对方场上1张表侧表示卡为对象才能发动。那张卡的效果直到回合结束时无效。
-- ②：这张卡给与对方战斗伤害时，以自己墓地1只调整为对象才能发动。那只怪兽守备表示特殊召唤。
function c9753964.initial_effect(c)
	-- 添加同调召唤手续：需要1只调整怪兽和1只调整以外的龙族·暗属性同调怪兽。
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(c9753964.sfilter),1,1)
	c:EnableReviveLimit()
	-- ①：自己·对方回合，以对方场上1张表侧表示卡为对象才能发动。那张卡的效果直到回合结束时无效。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(9753964,0))  --"效果无效"
	e1:SetCategory(CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e1:SetCountLimit(1,9753964)
	e1:SetTarget(c9753964.target)
	e1:SetOperation(c9753964.operation)
	c:RegisterEffect(e1)
	-- ②：这张卡给与对方战斗伤害时，以自己墓地1只调整为对象才能发动。那只怪兽守备表示特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(9753964,1))  --"特殊召唤"
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_BATTLE_DAMAGE)
	e2:SetCountLimit(1,9753965)
	e2:SetCondition(c9753964.spcon)
	e2:SetTarget(c9753964.sptg)
	e2:SetOperation(c9753964.spop)
	c:RegisterEffect(e2)
end
c9753964.material_type=TYPE_SYNCHRO
-- 过滤满足条件的非调整同调素材：龙族、暗属性的同调怪兽。
function c9753964.sfilter(c)
	return c:IsRace(RACE_DRAGON) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsType(TYPE_SYNCHRO)
end
-- 效果①的发动准备与目标选择。
function c9753964.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 在效果处理前，检查已选择的对象是否仍符合条件（处于对方场上且可被无效）。
	if chkc then return chkc:IsControler(1-tp) and chkc:IsOnField() and aux.NegateAnyFilter(chkc) end
	-- 在发动效果时，检查对方场上是否存在至少1张可被无效的表侧表示卡片。
	if chk==0 then return Duel.IsExistingTarget(aux.NegateAnyFilter,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 向玩家发送提示信息，要求选择要无效的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
	-- 选择对方场上1张可被无效的表侧表示卡片作为效果对象。
	local g=Duel.SelectTarget(tp,aux.NegateAnyFilter,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置连锁的操作信息，表明此效果包含使卡片效果无效的操作，并指定目标卡片。
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
end
-- 效果①的处理逻辑：使目标卡片的效果直到回合结束时无效。
function c9753964.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取在发动时选择的效果对象。
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) and tc:IsCanBeDisabledByEffect(e,false) then
		-- 使与目标卡片相关的连锁在处理时无效化。
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		-- 那张卡的效果直到回合结束时无效。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 那张卡的效果直到回合结束时无效。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
		if tc:IsType(TYPE_TRAPMONSTER) then
			-- 那张卡的效果直到回合结束时无效。
			local e3=Effect.CreateEffect(c)
			e3:SetType(EFFECT_TYPE_SINGLE)
			e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
			e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e3)
		end
	end
end
-- 效果②的发动条件：这张卡给与对方玩家战斗伤害时。
function c9753964.spcon(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp
end
-- 过滤墓地中可以守备表示特殊召唤的调整怪兽。
function c9753964.spfilter(c,e,tp)
	return c:IsType(TYPE_TUNER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 效果②的发动准备与目标选择。
function c9753964.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c9753964.spfilter(chkc,e,tp) end
	-- 在发动效果时，检查自己场上是否有可用的怪兽区域空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地中是否存在至少1只可以特殊召唤的调整怪兽。
		and Duel.IsExistingTarget(c9753964.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向玩家发送提示信息，要求选择要特殊召唤的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只符合条件的调整怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,c9753964.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置连锁的操作信息，表明此效果包含特殊召唤的操作，并指定目标卡片。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果②的处理逻辑：将目标怪兽守备表示特殊召唤。
function c9753964.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在发动时选择的特殊召唤目标怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽以表侧守备表示特殊召唤到自己场上。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
