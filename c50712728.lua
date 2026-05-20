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
-- 设置效果发动的目标，确定对方玩家为目标玩家，500为目标参数，并声明伤害操作信息
function c50712728.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置当前连锁的对象玩家为对方玩家
	Duel.SetTargetPlayer(1-tp)
	-- 设置当前连锁的对象参数为500
	Duel.SetTargetParam(500)
	-- 设置当前连锁的操作信息，分类为伤害，目标为对方玩家，数值为500
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,500)
end
-- 效果处理，获取目标玩家和伤害数值，并执行伤害处理
function c50712728.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中设定的目标玩家和目标参数（伤害值）
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 以效果原因给与目标玩家对应的伤害
	Duel.Damage(p,d,REASON_EFFECT)
end
