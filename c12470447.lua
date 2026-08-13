--邪悪な儀式
-- 效果：
-- 场上全部怪兽的表示形式交换。发动回合，怪兽的表示形式不能变更。这张卡只能在准备阶段发动。
function c12470447.initial_effect(c)
	-- 场上全部怪兽的表示形式交换。发动回合，怪兽的表示形式不能变更。这张卡只能在准备阶段发动。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(0,EFFECT_FLAG2_COF)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_STANDBY_PHASE)
	e1:SetCondition(c12470447.condition)
	e1:SetTarget(c12470447.target)
	e1:SetOperation(c12470447.activate)
	c:RegisterEffect(e1)
end
-- 效果发动条件的判断：必须是在自己回合的准备阶段、此卡位于魔陷区且当前连锁为空时才能发动。
function c12470447.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前回合玩家是否为效果发动者，且当前阶段是否为准备阶段。
	return Duel.GetTurnPlayer()==tp and Duel.GetCurrentPhase()==PHASE_STANDBY
		-- 检查此卡是否位于魔陷区，且当前不在连锁处理中（满足“只能在准备阶段发动”并避免连锁时点）。
		and e:GetHandler():IsLocation(LOCATION_SZONE) and Duel.GetCurrentChain()==0
end
-- 发动时的目标选择与操作信息登记：若场上存在怪兽则允许发动，并登记将全场怪兽变更表示形式的操作信息。
function c12470447.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查：双方怪兽区合计存在至少1只怪兽才可发动。
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,LOCATION_MZONE)>0 end
	-- 取得双方场上所有怪兽区域的怪兽，作为后续变更表示形式的对象。
	local g=Duel.GetFieldGroup(tp,LOCATION_MZONE,LOCATION_MZONE)
	-- 登记本次效果将进行的表示形式变更操作，数量为场上怪兽总数，供星尘龙等效果进行连锁判定。
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,g:GetCount(),0,0)
end
-- 效果处理：将场上全部怪兽的表示形式交换，并在本回合内让所有怪兽都不能再变更表示形式。
function c12470447.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 取得双方场上所有怪兽区域的全部怪兽，准备进行表示形式交换。
	local g=Duel.GetFieldGroup(tp,LOCATION_MZONE,LOCATION_MZONE)
	if g:GetCount()>0 then
		-- 将全场怪兽的表示形式交换：表侧攻击表示变为表侧守备表示，表侧守备表示变为表侧攻击表示，里侧守备表示变为表侧攻击表示，里侧攻击表示变为里侧守备表示。
		Duel.ChangePosition(g,POS_FACEUP_DEFENSE,POS_FACEDOWN_DEFENSE,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK)
	end
	-- 发动回合，怪兽的表示形式不能变更。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e1:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将“怪兽不能变更表示形式”的永续效果注册到场上，使其生效并持续到结束阶段。
	Duel.RegisterEffect(e1,tp)
end
