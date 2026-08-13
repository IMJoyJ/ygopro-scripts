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
-- 效果发动时的目标处理：无特定选取对象，只要在可发动条件下即返回 true，并登记本效果将造成伤害的操作信息。
function c46918794.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 登记本次连锁的操作信息为伤害效果，目标玩家为双方玩家，伤害数值参数为 500，用于相关时点和连锁的判定。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,PLAYER_ALL,500)
end
-- 效果处理函数：依次让对方受到 1000 点伤害、自己受到 500 点伤害，并在处理完毕后完成伤害相关时点的触发。
function c46918794.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 以效果原因给予对方（1-tp）1000 点伤害，is_step=true 表示作为过程性伤害，暂不触发时点。
	Duel.Damage(1-tp,1000,REASON_EFFECT,true)
	-- 以效果原因给予自己（tp）500 点伤害，is_step=true 表示作为过程性伤害，暂不触发时点。
	Duel.Damage(tp,500,REASON_EFFECT,true)
	-- 调用 Duel.RDComplete()，完成伤害/回复的 LP 变化过程，并触发因伤害产生的时点。
	Duel.RDComplete()
end
