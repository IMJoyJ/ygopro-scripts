--串刺しの落とし穴
-- 效果：
-- ①：这个回合召唤·特殊召唤的对方怪兽的攻击宣言时才能发动。那只攻击怪兽破坏，给与对方那只怪兽的原本攻击力一半数值的伤害。
function c75902998.initial_effect(c)
	-- ①：这个回合召唤·特殊召唤的对方怪兽的攻击宣言时才能发动。那只攻击怪兽破坏，给与对方那只怪兽的原本攻击力一半数值的伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(c75902998.condition)
	e1:SetTarget(c75902998.target)
	e1:SetOperation(c75902998.activate)
	c:RegisterEffect(e1)
end
-- 发动条件：攻击怪兽必须是对方控制的，且是在本回合召唤或特殊召唤的怪兽
function c75902998.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前进行攻击宣言的怪兽
	local at=Duel.GetAttacker()
	return at:IsControler(1-tp) and at:IsStatus(STATUS_SUMMON_TURN+STATUS_SPSUMMON_TURN)
end
-- 发动时的效果处理：验证攻击怪兽是否与战斗关联，并计算伤害数值，设置破坏和伤害的操作信息
function c75902998.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取当前进行攻击宣言的怪兽
	local at=Duel.GetAttacker()
	if chk==0 then return at:IsRelateToBattle() end
	local dam=math.max(math.floor(at:GetBaseAttack()/2),0)
	-- 设置操作信息：破坏该攻击怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,at,1,0,0)
	-- 设置操作信息：给与对方相当于该怪兽原本攻击力一半数值的伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,dam)
end
-- 效果处理：破坏攻击怪兽，并给与对方其原本攻击力一半数值的伤害
function c75902998.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前进行攻击宣言的怪兽
	local at=Duel.GetAttacker()
	-- 若攻击怪兽仍与战斗关联，则将其用效果破坏，破坏成功时进行后续处理
	if at:IsRelateToBattle() and Duel.Destroy(at,REASON_EFFECT)~=0 then
		local atk=math.floor(at:GetBaseAttack()/2)
		if atk>0 then
			-- 给与对方相当于该怪兽原本攻击力一半数值的伤害
			Duel.Damage(1-tp,atk,REASON_EFFECT)
		end
	end
end
