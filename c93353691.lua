--不退の荒武者
-- 效果：
-- 战士族调整＋调整以外的战士族怪兽1只以上
-- 从持有比这张卡的攻击力高的攻击力的怪兽受到攻击的场合，这张卡不会被那次战斗破坏，进行战斗的对方怪兽在伤害计算后破坏。
function c93353691.initial_effect(c)
	-- 为这张卡添加同调召唤手续：战士族调整＋调整以外的战士族怪兽1只以上
	aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsRace,RACE_WARRIOR),aux.NonTuner(Card.IsRace,RACE_WARRIOR),1)
	c:EnableReviveLimit()
	-- 从持有比这张卡的攻击力高的攻击力的怪兽受到攻击的场合，这张卡不会被那次战斗破坏
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetValue(c93353691.indes)
	c:RegisterEffect(e1)
	-- 进行战斗的对方怪兽在伤害计算后破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_BATTLED)
	e2:SetCondition(c93353691.descon)
	e2:SetTarget(c93353691.destg)
	e2:SetOperation(c93353691.desop)
	c:RegisterEffect(e2)
end
-- 定义战斗不破效果的适用条件函数
function c93353691.indes(e,c)
	local ec=e:GetHandler()
	-- 判断自身是否为攻击对象，且攻击怪兽的当前攻击力是否高于自身
	return ec==Duel.GetAttackTarget() and c:GetAttack()>ec:GetAttack()
end
-- 定义伤害计算后破坏对方怪兽效果的发动条件函数
function c93353691.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否发生了战斗伤害计算，且攻击怪兽仍与战斗关联
	return ev==1 and Duel.GetAttacker():IsRelateToBattle()
		-- 判断攻击怪兽的当前攻击力是否高于自身
		and Duel.GetAttacker():GetAttack()>e:GetHandler():GetAttack()
end
-- 定义伤害计算后破坏对方怪兽效果的发动检测与效果处理信息设置函数
function c93353691.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置效果处理信息为破坏攻击怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,Duel.GetAttacker(),1,0,0)
end
-- 定义伤害计算后破坏对方怪兽效果的具体处理函数
function c93353691.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本次战斗的攻击怪兽
	local a=Duel.GetAttacker()
	if a:IsRelateToBattle() then
		-- 将攻击怪兽因效果破坏
		Duel.Destroy(a,REASON_EFFECT)
	end
end
