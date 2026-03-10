--墓守の呪術師
-- 效果：
-- 这张卡召唤·反转召唤·特殊召唤时，给与对方玩家基本分500分的伤害。
function c50712728.initial_effect(c)
	-- 这张卡召唤·反转召唤·特殊召唤时，给与对方玩家基本分500分的伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(50712728,0))  --"伤害"
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_TRIGGER_F+EFFECT_TYPE_SINGLE)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c50712728.target)
	e1:SetOperation(c50712728.operation)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e3)
end
-- 效果作用
function c50712728.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将连锁的目标玩家设置为对方玩家
	Duel.SetTargetPlayer(1-tp)
	-- 将连锁的目标参数设置为500
	Duel.SetTargetParam(500)
	-- 设置当前处理的连锁的操作信息为造成500点伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,500)
end
-- 效果作用
function c50712728.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中设定的目标玩家和目标参数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 对目标玩家造成指定数值的伤害，伤害原因为效果
	Duel.Damage(p,d,REASON_EFFECT)
end
