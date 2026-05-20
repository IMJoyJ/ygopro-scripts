--炎舞－「天権」
-- 效果：
-- 这张卡在主要阶段1才能发动。这张卡的发动时，选择自己场上1只兽战士族怪兽。只在这张卡发动的主要阶段1内，选择的怪兽的效果无效，不受这张卡以外的卡的效果影响。此外，只要这张卡在场上存在，自己场上的兽战士族怪兽的攻击力上升300。
function c70329348.initial_effect(c)
	-- 这张卡在主要阶段1才能发动。这张卡的发动时，选择自己场上1只兽战士族怪兽。只在这张卡发动的主要阶段1内，选择的怪兽的效果无效，不受这张卡以外的卡的效果影响。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_MAIN_END)
	e1:SetCondition(c70329348.condition)
	e1:SetTarget(c70329348.target)
	e1:SetOperation(c70329348.activate)
	c:RegisterEffect(e1)
	-- 此外，只要这张卡在场上存在，自己场上的兽战士族怪兽的攻击力上升300。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	-- 设置效果影响的对象为兽战士族怪兽
	e3:SetTarget(aux.TargetBoolFunction(Card.IsRace,RACE_BEASTWARRIOR))
	e3:SetValue(300)
	c:RegisterEffect(e3)
end
-- 发动条件：只能在主要阶段1发动
function c70329348.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前阶段是否为主要阶段1
	return Duel.GetCurrentPhase()==PHASE_MAIN1
end
-- 过滤条件：自己场上表侧表示的兽战士族怪兽
function c70329348.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_BEASTWARRIOR)
end
-- 效果发动时的对象选择与合法性检查
function c70329348.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c70329348.filter(chkc) end
	-- 检查自己场上是否存在至少1只表侧表示的兽战士族怪兽作为合法对象
	if chk==0 then return Duel.IsExistingTarget(c70329348.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择表侧表示的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择自己场上1只表侧表示的兽战士族怪兽作为效果的对象
	Duel.SelectTarget(tp,c70329348.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果处理：使选择的怪兽效果无效，并使其不受此卡以外的效果影响
function c70329348.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取发动时选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 使与该怪兽相关的连锁中已发动的效果无效化
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		-- 选择的怪兽的效果无效
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_MAIN1)
		tc:RegisterEffect(e1)
		-- 选择的怪兽的效果无效
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_MAIN1)
		tc:RegisterEffect(e2)
		-- 不受这张卡以外的卡的效果影响
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e3:SetRange(LOCATION_MZONE)
		e3:SetCode(EFFECT_IMMUNE_EFFECT)
		e3:SetValue(c70329348.efilter)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_MAIN1)
		tc:RegisterEffect(e3)
	end
end
-- 免疫效果的过滤函数：判定效果来源是否为这张卡以外的卡
function c70329348.efilter(e,te)
	return te:GetOwner()~=e:GetOwner()
end
