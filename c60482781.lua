--ミスティック・ソードマン LV6
-- 效果：
-- 这张卡通常召唤的场合，必须以里侧守备表示的形式出场。攻击里侧守备表示的怪兽时，不进行伤害计算，那只怪兽以里侧守备表示的状态直接破坏。此效果破坏的怪兽可以不送去墓地，放到对方卡组的最上面。
function c60482781.initial_effect(c)
	-- 攻击里侧守备表示的怪兽时，不进行伤害计算，那只怪兽以里侧守备表示的状态直接破坏。此效果破坏的怪兽可以不送去墓地，放到对方卡组的最上面。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(60482781,0))  --"破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_BATTLE_START)
	e1:SetCondition(c60482781.descon)
	e1:SetTarget(c60482781.destg)
	e1:SetOperation(c60482781.desop)
	c:RegisterEffect(e1)
	-- 这张卡通常召唤的场合，必须以里侧守备表示的形式出场。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_LIMIT_SUMMON_PROC)
	e2:SetCondition(c60482781.sumcon)
	c:RegisterEffect(e2)
end
c60482781.lvdn={47507260,74591968}
-- 判断是否满足破坏效果的发动条件（自身攻击里侧守备表示怪兽）
function c60482781.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前的攻击目标怪兽
	local d=Duel.GetAttackTarget()
	-- 验证自身是攻击怪兽，且攻击目标存在、处于里侧表示且处于守备表示
	return e:GetHandler()==Duel.GetAttacker() and d and d:IsFacedown() and d:IsDefensePos()
end
-- 破坏效果的发动准备，设置效果处理时的操作信息
function c60482781.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置效果处理信息为破坏1只攻击目标怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,Duel.GetAttackTarget(),1,0,0)
end
-- 破坏效果的具体处理，根据玩家选择决定将怪兽送去墓地还是放回对方卡组最上面
function c60482781.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前的攻击目标怪兽
	local d=Duel.GetAttackTarget()
	if d:IsRelateToBattle() then
		-- 若被攻击怪兽的持有者为对方，则询问玩家是否将其放回对方卡组最上面
		if d:GetOwner()~=tp and Duel.SelectYesNo(tp,aux.Stringid(60482781,1)) then  --"是否要返回对方卡组？"
			-- 因效果破坏该怪兽，并将其移动到卡组最上面
			Duel.Destroy(d,REASON_EFFECT,LOCATION_DECK)
		else
			-- 因效果破坏该怪兽并送去墓地
			Duel.Destroy(d,REASON_EFFECT)
		end
	end
end
-- 限制通常召唤的条件，使其无法进行表侧表示的通常召唤
function c60482781.sumcon(e,c,minc)
	if not c then return true end
	return false
end
