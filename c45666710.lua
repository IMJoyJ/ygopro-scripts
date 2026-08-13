--星義の執行者
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：从自己墓地的怪兽以及除外的自己怪兽之中以1只「星义」怪兽为对象才能发动。那只怪兽特殊召唤。这个效果特殊召唤的原本等级是11星以上的怪兽在这个回合不能把效果发动。
function c45666710.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：从自己墓地的怪兽以及除外的自己怪兽之中以1只「星义」怪兽为对象才能发动。那只怪兽特殊召唤。这个效果特殊召唤的原本等级是11星以上的怪兽在这个回合不能把效果发动。
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
-- 判定可作为对象的『星义』怪兽：位于自己墓地或表侧除外，且能被当前效果特殊召唤。
function c45666710.filter(c,e,tp)
	return (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE)) and c:IsSetCard(0x13d) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 目标检查：若为连锁处理中的对象（chkc），需位于自己墓地或除外区、由己方控制且满足filter；若为发动时判定（chk==0），则检查是否有可特殊召唤的空位及合法对象。
function c45666710.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and chkc:IsControler(tp) and c45666710.filter(chkc,e,tp) end
	-- 发动判定条件之一：自己主要怪兽区存在可用的空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 发动判定条件之二：自己墓地或除外区存在至少1只满足filter条件且可以成为对象的『星义』怪兽。
		and Duel.IsExistingTarget(c45666710.filter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp) end
	-- 向玩家显示提示：请选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己墓地或除外区选择1只满足filter条件的『星义』怪兽，并将其登记为当前效果的对象。
	local g=Duel.SelectTarget(tp,c45666710.filter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,e,tp)
	-- 设置操作信息：本效果将特殊召唤所选择的对象，数量为1，供后续效果检测使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理：若对象仍与该效果关联，则将其特殊召唤；若其原本等级为11星以上，再为其附加本回合不能发动效果的限制；最后完成特殊召唤。
function c45666710.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前处理的效果所选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	-- 若对象仍与效果关联，则将其以表侧表示特殊召唤；同时若其原本等级在11星以上，则进入附加限制的处理分支。
	if tc:IsRelateToEffect(e) and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) and tc:GetOriginalLevel()>=11 then
		-- 这个效果特殊召唤的原本等级是11星以上的怪兽在这个回合不能把效果发动。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_TRIGGER)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
	-- 完成整个特殊召唤流程，触发特殊召唤成功时的时点处理。
	Duel.SpecialSummonComplete()
end
