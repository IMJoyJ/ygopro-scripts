--No.41 泥睡魔獣バグースカ
-- 效果：
-- 4星怪兽×2
-- 这张卡的控制者在每次自己准备阶段把这张卡1个超量素材取除。不能取除的场合，这张卡破坏。
-- ①：只要这张卡在怪兽区域攻击表示存在，这张卡不会被对方的效果破坏，对方不能把这张卡作为效果的对象。
-- ②：只要这张卡在怪兽区域守备表示存在，场上的表侧表示怪兽变成守备表示，守备表示怪兽发动的效果无效化。
function c90590303.initial_effect(c)
	-- 添加XYZ召唤手续：4星怪兽×2
	aux.AddXyzProcedure(c,nil,4,2)
	c:EnableReviveLimit()
	-- 这张卡的控制者在每次自己准备阶段把这张卡1个超量素材取除。不能取除的场合，这张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(c90590303.mtcon)
	e1:SetOperation(c90590303.mtop)
	c:RegisterEffect(e1)
	-- ①：只要这张卡在怪兽区域攻击表示存在，对方不能把这张卡作为效果的对象。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c90590303.tgcon)
	-- 设置不能成为对方卡的效果对象
	e2:SetValue(aux.tgoval)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	-- 设置不会被对方卡的效果破坏
	e3:SetValue(aux.indoval)
	c:RegisterEffect(e3)
	-- ②：只要这张卡在怪兽区域守备表示存在，场上的表侧表示怪兽变成守备表示
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_SET_POSITION)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e4:SetCondition(c90590303.poscon)
	e4:SetTarget(c90590303.postg)
	e4:SetValue(POS_FACEUP_DEFENSE)
	c:RegisterEffect(e4)
	-- 守备表示怪兽发动的效果无效化。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e5:SetCode(EVENT_CHAIN_SOLVING)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCondition(c90590303.discon)
	e5:SetOperation(c90590303.disop)
	c:RegisterEffect(e5)
end
-- 设置该怪兽的“No.”编号为41
aux.xyz_number[90590303]=41
-- 维持代价效果的触发条件：当前回合玩家是自己
function c90590303.mtcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为自己
	return Duel.GetTurnPlayer()==tp
end
-- 维持代价效果的执行操作：尝试取除1个超量素材，若无法取除则将自身破坏
function c90590303.mtop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) then
		e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
	else
		-- 因无法支付维持代价而将自身破坏
		Duel.Destroy(e:GetHandler(),REASON_COST)
	end
end
-- 抗性效果的适用条件：自身处于攻击表示
function c90590303.tgcon(e)
	return e:GetHandler():IsAttackPos()
end
-- 强制转防效果的适用条件：自身处于守备表示
function c90590303.poscon(e)
	return e:GetHandler():IsDefensePos()
end
-- 强制转防效果的影响对象过滤：场上表侧表示的怪兽
function c90590303.postg(e,c)
	return c:IsFaceup()
end
-- 效果无效化效果的适用条件：自身处于守备表示，且发动效果的怪兽在怪兽区且发动时为守备表示
function c90590303.discon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁发动时的位置和表示形式
	local loc,pos=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION,CHAININFO_TRIGGERING_POSITION)
	return e:GetHandler():IsDefensePos()
		and re:IsActiveType(TYPE_MONSTER) and loc==LOCATION_MZONE and bit.band(pos,POS_DEFENSE)~=0
end
-- 效果无效化效果的执行操作：使该连锁的效果无效
function c90590303.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 使指定连锁的效果无效
	Duel.NegateEffect(ev)
end
