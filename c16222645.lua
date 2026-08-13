--一刀両断侍
-- 效果：
-- 这张卡攻击里侧守备表示的怪兽的场合，不进行伤害计算，里侧守备表示的怪兽以本来的里侧守备形式直接破坏。
function c16222645.initial_effect(c)
	-- 这张卡攻击里侧守备表示的怪兽的场合，不进行伤害计算，里侧守备表示的怪兽以本来的里侧守备形式直接破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(16222645,0))  --"里侧守备的攻击对象怪兽破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_BATTLE_START)
	e1:SetCondition(c16222645.descon)
	e1:SetTarget(c16222645.destg)
	e1:SetOperation(c16222645.desop)
	c:RegisterEffect(e1)
end
-- 定义效果发动条件：攻击者为这张卡且攻击对象是里侧守备表示的怪兽时才满足触发条件。
function c16222645.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前战斗的攻击对象怪兽并存入局部变量d。
	local d=Duel.GetAttackTarget()
	-- 判定攻击者是否为效果持有者自身，且攻击对象存在、是里侧守备表示。
	return e:GetHandler()==Duel.GetAttacker() and d and d:IsFacedown() and d:IsDefensePos()
end
-- 定义效果发动时的目标处理：该效果为必发，无需取对象，直接设置破坏攻击对象的操作信息。
function c16222645.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：本次连锁将以效果破坏攻击对象1只怪兽，破坏分类为CATEGORY_DESTROY，不取对象。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,Duel.GetAttackTarget(),1,0,0)
end
-- 定义效果处理函数：在效果结算时，若攻击对象仍与本次战斗关联，则将其破坏。
function c16222645.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 在效果处理时再次获取攻击对象怪兽。
	local d=Duel.GetAttackTarget()
	if d:IsRelateToBattle() then
		-- 以效果破坏该攻击对象怪兽。
		Duel.Destroy(d,REASON_EFFECT)
	end
end
