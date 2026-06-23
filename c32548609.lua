--エレキンモグラ
-- 效果：
-- 这张卡在同1次的战斗阶段中可以作2次攻击。这张卡向里侧守备表示怪兽攻击的场合，可以不进行伤害计算以里侧守备表示的状态把那只怪兽破坏。
function c32548609.initial_effect(c)
	-- 这张卡在同1次的战斗阶段中可以作2次攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EXTRA_ATTACK)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	-- 这张卡向里侧守备表示怪兽攻击的场合，可以不进行伤害计算以里侧守备表示的状态把那只怪兽破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(32548609,0))  --"里侧守备的攻击对象怪兽破坏"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_START)
	e2:SetCondition(c32548609.descon)
	e2:SetTarget(c32548609.destg)
	e2:SetOperation(c32548609.desop)
	c:RegisterEffect(e2)
end
-- 判断攻击的怪兽是否为自身且攻击对象为里侧守备表示怪兽
function c32548609.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取攻击对象怪兽
	local d=Duel.GetAttackTarget()
	-- 返回攻击怪兽为自身且攻击对象存在且为里侧守备表示
	return e:GetHandler()==Duel.GetAttacker() and d and d:IsFacedown() and d:IsDefensePos()
end
-- 设置破坏效果的发动条件和目标
function c32548609.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断攻击对象怪兽是否与本次战斗相关
	if chk==0 then return Duel.GetAttackTarget():IsRelateToBattle() end
	-- 设置连锁操作信息，指定将要破坏的怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,Duel.GetAttackTarget(),1,0,0)
end
-- 执行破坏效果
function c32548609.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取攻击对象怪兽
	local d=Duel.GetAttackTarget()
	if d:IsRelateToBattle() then
		-- 以效果原因破坏目标怪兽
		Duel.Destroy(d,REASON_EFFECT)
	end
end
