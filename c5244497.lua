--スクープ・シューター
-- 效果：
-- 这张卡向持有比这张卡的攻击力高的守备力的场上表侧表示存在的怪兽攻击的场合，不进行伤害计算把那只怪兽破坏。
function c5244497.initial_effect(c)
	-- 这张卡向持有比这张卡的攻击力高的守备力的场上表侧表示存在的怪兽攻击的场合，不进行伤害计算把那只怪兽破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(5244497,0))  --"破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_BATTLE_START)
	e1:SetCondition(c5244497.descon)
	e1:SetTarget(c5244497.destg)
	e1:SetOperation(c5244497.desop)
	c:RegisterEffect(e1)
end
-- 当此卡为攻击怪兽且攻击对象存在、攻击对象为表侧表示、攻击对象的守备力高于此卡的攻击力时发动
function c5244497.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取此次战斗的攻击对象
	local d=Duel.GetAttackTarget()
	-- 判断此卡是否为攻击怪兽且攻击对象存在、攻击对象为表侧表示、攻击对象的守备力高于此卡的攻击力
	return e:GetHandler()==Duel.GetAttacker() and d and d:IsFaceup() and d:GetDefense()>e:GetHandler():GetAttack()
end
-- 设置连锁操作信息，确定将要破坏的卡片
function c5244497.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息，指定将要破坏的卡片为目标
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,Duel.GetAttackTarget(),1,0,0)
end
-- 执行效果，若攻击对象与战斗相关且其守备力高于此卡攻击力，则将其破坏
function c5244497.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取此次战斗的攻击对象
	local d=Duel.GetAttackTarget()
	if d:IsRelateToBattle() and d:GetDefense()>e:GetHandler():GetAttack() then
		-- 将目标怪兽以效果为原因进行破坏
		Duel.Destroy(d,REASON_EFFECT)
	end
end
