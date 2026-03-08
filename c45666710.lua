--星義の執行者
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：从自己墓地的怪兽以及除外的自己怪兽之中以1只「星义」怪兽为对象才能发动。那只怪兽特殊召唤。这个效果特殊召唤的原本等级是11星以上的怪兽在这个回合不能把效果发动。
function c45666710.initial_effect(c)
	-- 创建效果，设置为发动时点，可以取对象，发动次数限制为1次
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCountLimit(1,45666710+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c45666710.target)
	e1:SetOperation(c45666710.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于判断目标是否为「星义」怪兽且可以特殊召唤
function c45666710.filter(c,e,tp)
	return (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE)) and c:IsSetCard(0x13d) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果处理时点，判断是否满足发动条件
function c45666710.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and chkc:IsControler(tp) and c45666710.filter(chkc,e,tp) end
	-- 判断场上是否有足够的特殊召唤区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断自己墓地和除外区是否存在符合条件的「星义」怪兽
		and Duel.IsExistingTarget(c45666710.filter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择符合条件的1只怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c45666710.filter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,e,tp)
	-- 设置效果处理信息，表示将特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理函数，执行特殊召唤及后续处理
function c45666710.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 判断目标怪兽是否仍然有效，是否成功特殊召唤，且等级大于等于11
	if tc:IsRelateToEffect(e) and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) and tc:GetOriginalLevel()>=11 then
		-- 效果特殊召唤的原本等级是11星以上的怪兽在这个回合不能把效果发动
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_TRIGGER)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
	-- 完成特殊召唤流程
	Duel.SpecialSummonComplete()
end
