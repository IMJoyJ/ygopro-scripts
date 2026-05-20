--カブキ・ドラゴン
-- 效果：
-- ①：1回合1次，自己怪兽向对方怪兽攻击的伤害计算前才能发动。那只对方怪兽的表示形式变更。
-- ②：1回合1次，对方怪兽向自己怪兽攻击的伤害计算前才能发动。那只自己怪兽的表示形式变更。
function c7541475.initial_effect(c)
	-- ①：1回合1次，自己怪兽向对方怪兽攻击的伤害计算前才能发动。那只对方怪兽的表示形式变更。②：1回合1次，对方怪兽向自己怪兽攻击的伤害计算前才能发动。那只自己怪兽的表示形式变更。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(7541475,0))  --"表示形式变更"
	e1:SetCategory(CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_CONFIRM)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(c7541475.postg)
	e1:SetOperation(c7541475.posop)
	c:RegisterEffect(e1)
end
-- 定义效果的发动检测与目标确认函数，检查是否存在可改变表示形式的被攻击怪兽
function c7541475.postg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取当前战斗的攻击目标（被攻击的怪兽）
	local d=Duel.GetAttackTarget()
	-- 在发动检测阶段，确认存在攻击目标、双方怪兽控制者不同（非同侧战斗）且该目标可以改变表示形式
	if chk==0 then return d and d:GetControler()~=Duel.GetAttacker():GetControler() and d:IsCanChangePosition() end
	-- 设置连锁操作信息，表明此效果的处理涉及改变1只攻击目标怪兽的表示形式
	Duel.SetOperationInfo(0,CATEGORY_POSITION,d,1,0,0)
end
-- 定义效果的执行函数，在伤害计算前改变攻击目标的表示形式
function c7541475.posop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前战斗的攻击目标（被攻击的怪兽）
	local d=Duel.GetAttackTarget()
	if d:IsRelateToBattle() then
		-- 将攻击目标怪兽的表示形式变更（表侧攻击变表侧守备，表侧守备变里侧守备，里侧守备变表侧攻击）
		Duel.ChangePosition(d,POS_FACEUP_DEFENSE,POS_FACEDOWN_DEFENSE,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK)
	end
end
