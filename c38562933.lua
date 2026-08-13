--BF－空風のジン
-- 效果：
-- 和持有这张卡的攻击力以下的守备力的场上表侧表示存在的怪兽进行战斗的场合，不进行伤害计算把那只怪兽破坏。
function c38562933.initial_effect(c)
	-- 和持有这张卡的攻击力以下的守备力的场上表侧表示存在的怪兽进行战斗的场合，不进行伤害计算把那只怪兽破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(38562933,0))  --"破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_BATTLE_START)
	e1:SetCondition(c38562933.descon)
	e1:SetTarget(c38562933.destg)
	e1:SetOperation(c38562933.desop)
	c:RegisterEffect(e1)
end
-- 伤害步骤开始时判定是否存在与这张卡进行战斗的怪兽：该怪兽须为表侧表示且守备力不高于这张卡的当前攻击力；若存在，则将其记录到效果标签中作为破坏对象。
function c38562933.descon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取本次战斗的攻击目标怪兽（若这张卡是攻击方，则此目标就是对方怪兽）。
	local d=Duel.GetAttackTarget()
	-- 如果攻击目标就是这张卡自己，说明这张卡是被攻击方，此时将战斗对象换为攻击方怪兽。
	if d==c then d=Duel.GetAttacker() end
	e:SetLabelObject(d)
	return d and d:IsFaceup() and d:IsDefenseBelow(c:GetAttack())
end
-- 由于此效果为必发且不取对象，效果发动时直接返回true表示允许发动，并登记连锁中要破坏的怪兽信息。
function c38562933.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将效果处理中要破坏的对象（此前记录的战斗怪兽）及破坏类别、数量写入当前连锁的操作信息，使其他卡能够正确响应/连锁此破坏。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetLabelObject(),1,0,0)
end
-- 效果处理时，若这张卡仍表侧表示且效果仍适用，战斗怪兽仍与本次战斗相关且其守备力仍不高于这张卡的当前攻击力，则破坏那只怪兽。
function c38562933.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local d=e:GetLabelObject()
	if c:IsFaceup() and c:IsRelateToEffect(e) and d:IsRelateToBattle() and d:IsDefenseBelow(c:GetAttack()) then
		-- 以效果为原因将战斗对象怪兽破坏。
		Duel.Destroy(d,REASON_EFFECT)
	end
end
