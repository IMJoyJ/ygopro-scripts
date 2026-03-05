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
-- 效果作用
function c16222645.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取攻击战斗中被攻击的怪兽
	local d=Duel.GetAttackTarget()
	-- 判断攻击的怪兽是自己且目标怪兽是里侧守备表示
	return e:GetHandler()==Duel.GetAttacker() and d and d:IsFacedown() and d:IsDefensePos()
end
-- 效果作用
function c16222645.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁操作信息为破坏效果，目标为攻击对象怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,Duel.GetAttackTarget(),1,0,0)
end
-- 效果作用
function c16222645.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取攻击战斗中被攻击的怪兽
	local d=Duel.GetAttackTarget()
	if d:IsRelateToBattle() then
		-- 将目标怪兽以效果原因破坏
		Duel.Destroy(d,REASON_EFFECT)
	end
end
