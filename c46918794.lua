--火炎地獄
-- 效果：
-- 对方受到1000分的伤害，自己受到500分的伤害。
function c46918794.initial_effect(c)
	-- 对方受到1000分的伤害，自己受到500分的伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c46918794.target)
	e1:SetOperation(c46918794.activate)
	c:RegisterEffect(e1)
end
-- 效果处理时点判断，设置连锁操作信息为伤害效果并指定伤害值为500
function c46918794.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置当前连锁操作信息为CATEGORY_DAMAGE类型，影响双方玩家，伤害值为500
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,PLAYER_ALL,500)
end
-- 效果发动时执行的处理函数，对对方造成1000伤害，对自己造成500伤害
function c46918794.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 对对方玩家造成1000点伤害，伤害原因为效果
	Duel.Damage(1-tp,1000,REASON_EFFECT,true)
	-- 对自己玩家造成500点伤害，伤害原因为效果
	Duel.Damage(tp,500,REASON_EFFECT,true)
	-- 完成伤害处理的时点触发
	Duel.RDComplete()
end
