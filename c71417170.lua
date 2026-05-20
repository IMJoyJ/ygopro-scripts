--ディフェンダーズ・クロス
-- 效果：
-- 战斗阶段中才能发动。对方场上守备表示存在的怪兽变成表侧攻击表示，那些怪兽的效果无效化。
function c71417170.initial_effect(c)
	-- 战斗阶段中才能发动。对方场上守备表示存在的怪兽变成表侧攻击表示，那些怪兽的效果无效化。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c71417170.condition)
	e1:SetTarget(c71417170.target)
	e1:SetOperation(c71417170.activate)
	c:RegisterEffect(e1)
end
-- 定义发动条件函数，限制只能在战斗阶段发动
function c71417170.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前阶段是否在战斗阶段（从战斗阶段开始到战斗阶段结束）
	return (Duel.GetCurrentPhase()>=PHASE_BATTLE_START and Duel.GetCurrentPhase()<=PHASE_BATTLE)
end
-- 定义效果的目标选择与操作信息设置函数
function c71417170.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动检测时，检查对方场上是否存在守备表示的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDefensePos,tp,0,LOCATION_MZONE,1,nil) end
	-- 获取对方场上所有守备表示的怪兽
	local g=Duel.GetMatchingGroup(Card.IsDefensePos,tp,0,LOCATION_MZONE,nil)
	-- 设置操作信息，表示此效果会改变上述怪兽的表示形式
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,g:GetCount(),0,0)
end
-- 定义效果处理函数，执行改变表示形式和无效效果的操作
function c71417170.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果处理时对方场上所有守备表示的怪兽
	local g=Duel.GetMatchingGroup(Card.IsDefensePos,tp,0,LOCATION_MZONE,nil)
	-- 将这些怪兽全部变成表侧攻击表示
	Duel.ChangePosition(g,0,0,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK)
	local tc=g:GetFirst()
	while tc do
		-- 那些怪兽的效果无效化。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 那些怪兽的效果无效化。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
		tc=g:GetNext()
	end
end
