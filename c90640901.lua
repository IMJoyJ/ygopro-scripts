--リバース・バスター
-- 效果：
-- 这张卡只能向里侧守备表示怪兽攻击。这张卡攻击的场合，对方直到伤害步骤结束时魔法·陷阱卡不能发动。这张卡向里侧守备表示怪兽攻击的场合，可以不进行伤害计算以里侧守备表示的状态把那只怪兽破坏。
function c90640901.initial_effect(c)
	-- 这张卡只能向里侧守备表示怪兽攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e1:SetValue(c90640901.vala)
	c:RegisterEffect(e1)
	-- 这张卡只能向里侧守备表示怪兽攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
	c:RegisterEffect(e2)
	-- 这张卡攻击的场合，对方直到伤害步骤结束时魔法·陷阱卡不能发动。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCode(EFFECT_CANNOT_ACTIVATE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(0,1)
	e3:SetValue(c90640901.aclimit)
	e3:SetCondition(c90640901.actcon)
	c:RegisterEffect(e3)
	-- 这张卡向里侧守备表示怪兽攻击的场合，可以不进行伤害计算以里侧守备表示的状态把那只怪兽破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(90640901,0))  --"破坏"
	e4:SetCategory(CATEGORY_DESTROY)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_BATTLE_START)
	e4:SetCondition(c90640901.descon)
	e4:SetTarget(c90640901.destg)
	e4:SetOperation(c90640901.desop)
	c:RegisterEffect(e4)
end
-- 过滤函数，使自身不能选择表侧表示的怪兽作为攻击对象
function c90640901.vala(e,c)
	return c:IsFaceup()
end
-- 限制不能发动的卡片类型为魔法·陷阱卡的发动
function c90640901.aclimit(e,re,tp)
	return re:IsHasType(EFFECT_TYPE_ACTIVATE)
end
-- 限制效果在自身进行攻击时持续适用
function c90640901.actcon(e)
	-- 判断当前攻击的怪兽是否为自身
	return Duel.GetAttacker()==e:GetHandler()
end
-- 效果发动条件：自身进行攻击，且攻击目标是里侧守备表示怪兽
function c90640901.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前的攻击目标怪兽
	local d=Duel.GetAttackTarget()
	-- 判断自身是攻击方，且攻击目标存在、为里侧表示且为守备表示
	return e:GetHandler()==Duel.GetAttacker() and d and d:IsFacedown() and d:IsDefensePos()
end
-- 效果发动准备：检查攻击目标是否在战斗中，并设置破坏的操作信息
function c90640901.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段，检查攻击目标是否仍与本次战斗相关联
	if chk==0 then return Duel.GetAttackTarget():IsRelateToBattle() end
	-- 设置效果处理信息，表示将要破坏1个攻击目标
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,Duel.GetAttackTarget(),1,0,0)
end
-- 效果处理：如果攻击目标仍与战斗相关，则将其破坏
function c90640901.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前的攻击目标怪兽
	local d=Duel.GetAttackTarget()
	if d:IsRelateToBattle() then
		-- 通过效果将目标怪兽破坏
		Duel.Destroy(d,REASON_EFFECT)
	end
end
