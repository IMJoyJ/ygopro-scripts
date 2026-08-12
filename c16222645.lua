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
-- 检查攻击目标是否为里侧守备表示的怪兽：获取攻击目标，判断当前卡是攻击者且目标存在、里侧表示且守备表示。
function c16222645.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前战斗中的攻击目标怪兽。
	local d=Duel.GetAttackTarget()
	-- 判断当前卡是攻击者且攻击目标存在、为里侧守备表示。
	return e:GetHandler()==Duel.GetAttacker() and d and d:IsFacedown() and d:IsDefensePos()
end
-- 设置破坏效果的操作信息，指定目标为攻击目标怪兽，数量为1。
function c16222645.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置CATEGORY_DESTROY分类的操作信息，目标为攻击目标怪兽，数量1，目标玩家0，位置0。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,Duel.GetAttackTarget(),1,0,0)
end
-- 执行破坏操作：获取攻击目标，若其仍与战斗关联则以效果原因破坏。
function c16222645.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 再次获取攻击目标怪兽（用于效果处理阶段）。
	local d=Duel.GetAttackTarget()
	if d:IsRelateToBattle() then
		-- 以REASON_EFFECT原因破坏攻击目标怪兽。
		Duel.Destroy(d,REASON_EFFECT)
	end
end
