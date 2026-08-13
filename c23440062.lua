--ウィキッド・リボーン
-- 效果：
-- 支付800基本分，选择自己墓地存在的1只同调怪兽发动。选择的怪兽表侧攻击表示特殊召唤。这个效果特殊召唤的怪兽的效果无效化，这个回合不能攻击宣言。这张卡不在场上存在时，那只怪兽破坏。那只怪兽破坏时这张卡破坏。
function c23440062.initial_effect(c)
	-- 支付800基本分，选择自己墓地存在的1只同调怪兽发动。选择的怪兽表侧攻击表示特殊召唤。这个回合不能攻击宣言。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCost(c23440062.cost)
	e1:SetTarget(c23440062.target)
	e1:SetOperation(c23440062.operation)
	c:RegisterEffect(e1)
	-- 这张卡不在场上存在时，那只怪兽破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetOperation(c23440062.desop)
	c:RegisterEffect(e2)
	-- 那只怪兽破坏时这张卡破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCode(EVENT_LEAVE_FIELD)
	e3:SetCondition(c23440062.descon2)
	e3:SetOperation(c23440062.desop2)
	c:RegisterEffect(e3)
	-- 这个效果特殊召唤的怪兽的效果无效化
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_TARGET)
	e4:SetCode(EFFECT_DISABLE)
	e4:SetRange(LOCATION_SZONE)
	c:RegisterEffect(e4)
end
-- 发动效果所需的COST处理：先检查能否支付800基本分，确认后实际支付800基本分。
function c23440062.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动合法性检查阶段，判断玩家是否能支付800基本分。
	if chk==0 then return Duel.CheckLPCost(tp,800) end
	-- 实际支付800基本分作为发动代价。
	Duel.PayLPCost(tp,800)
end
-- 筛选条件：怪兽必须是同调怪兽，且能以表侧攻击表示被该效果特殊召唤（满足苏生限制等特召条件）。
function c23440062.filter(c,e,tp)
	return c:IsType(TYPE_SYNCHRO) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK)
end
-- 发动目标的合法性判断与选对象：从自己墓地选择1只符合筛选条件的同调怪兽作为效果对象，并确认主怪兽区有空位。
function c23440062.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c23440062.filter(chkc,e,tp) end
	-- 在合法性检查时，确认自己主要怪兽区有可用空格，保证特殊召唤能够进行。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 同时确认自己墓地存在至少1只满足条件的同调怪兽可以作为取对象目标。
		and Duel.IsExistingTarget(c23440062.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向玩家显示“请选择要特殊召唤的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己墓地选择1只符合条件的同调怪兽，并将其登记为本次连锁的效果对象。
	local g=Duel.SelectTarget(tp,c23440062.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 登记操作信息：本效果预计将1只怪兽特殊召唤，供相关时点和连锁判定使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理阶段：若发动卡和对象卡仍与效果关联，则把对象同调怪兽表侧攻击表示特殊召唤；成功后将对象记录为这张卡的持续对象，并赋予其本回合不能攻击的效果，最后完成特殊召唤结算。
function c23440062.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	-- 确认本卡与对象怪兽都未被中断关联，然后执行特殊召唤的分解步骤，将其表侧攻击表示特殊召唤。
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP_ATTACK) then
		c:SetCardTarget(tc)
		-- 这个回合不能攻击宣言
		local e5=Effect.CreateEffect(c)
		e5:SetType(EFFECT_TYPE_TARGET)
		e5:SetCode(EFFECT_CANNOT_ATTACK)
		e5:SetRange(LOCATION_SZONE)
		e5:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e5)
	end
	-- 结束SpecialSummonStep分解过程，统一处理特殊召唤成功后的时点。
	Duel.SpecialSummonComplete()
end
-- 这张卡离场时的诱发处理：若记录的对象怪兽仍在怪兽区，则将其破坏。
function c23440062.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetFirstCardTarget()
	if tc and tc:IsLocation(LOCATION_MZONE) then
		-- 以效果原因破坏那只被特殊召唤的怪兽。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- 判定条件：这张卡当前关联的对象怪兽在离场事件中，且其离场原因是破坏。
function c23440062.descon2(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetFirstCardTarget()
	return tc and eg:IsContains(tc) and tc:IsReason(REASON_DESTROY)
end
-- 对象怪兽被破坏时，这张卡自身也要被破坏的处理。
function c23440062.desop2(e,tp,eg,ep,ev,re,r,rp)
	-- 以效果原因破坏这张卡（邪恶苏生）。
	Duel.Destroy(e:GetHandler(),REASON_EFFECT)
end
