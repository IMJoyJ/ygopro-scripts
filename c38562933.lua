--BF－空風のジン
-- 效果：
-- 和持有这张卡的攻击力以下的守备力的场上表侧表示存在的怪兽进行战斗的场合，不进行伤害计算把那只怪兽破坏。
function c38562933.initial_effect(c)
	-- 诱发必发效果，对应一速的【……发动】
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
-- 和持有这张卡的攻击力以下的守备力的场上表侧表示存在的怪兽进行战斗的场合，不进行伤害计算把那只怪兽破坏。
function c38562933.descon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取攻击方的攻击目标
	local d=Duel.GetAttackTarget()
	-- 若攻击目标为自身则获取攻击方
	if d==c then d=Duel.GetAttacker() end
	e:SetLabelObject(d)
	return d and d:IsFaceup() and d:IsDefenseBelow(c:GetAttack())
end
-- 设置连锁操作信息，确定破坏对象
function c38562933.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置当前处理的连锁的操作信息，包含破坏效果
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetLabelObject(),1,0,0)
end
-- 执行破坏效果，将符合条件的怪兽破坏
function c38562933.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local d=e:GetLabelObject()
	if c:IsFaceup() and c:IsRelateToEffect(e) and d:IsRelateToBattle() and d:IsDefenseBelow(c:GetAttack()) then
		-- 以效果为原因破坏目标怪兽
		Duel.Destroy(d,REASON_EFFECT)
	end
end
