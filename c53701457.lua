--No.28 タイタニック・モス
-- 效果：
-- 7星怪兽×2
-- ①：自己场上没有其他怪兽存在的场合，这张卡可以直接攻击。那次直接攻击给与对方的战斗伤害变成一半。
-- ②：这张卡给与对方战斗伤害时，把这张卡1个超量素材取除才能发动。给与对方为对方手卡数量×500伤害。
function c53701457.initial_effect(c)
	-- 添加XYZ召唤手续，使用等级为7的怪兽进行2只叠放
	aux.AddXyzProcedure(c,nil,7,2)
	c:EnableReviveLimit()
	-- 自己场上没有其他怪兽存在的场合，这张卡可以直接攻击
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_DIRECT_ATTACK)
	e1:SetCondition(c53701457.dircon)
	c:RegisterEffect(e1)
	-- 这张卡给与对方战斗伤害时，把这张卡1个超量素材取除才能发动。给与对方为对方手卡数量×500伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
	e2:SetCondition(c53701457.rdcon)
	-- 将给与对方的战斗伤害变为一半
	e2:SetValue(aux.ChangeBattleDamage(1,HALF_DAMAGE))
	c:RegisterEffect(e2)
	-- ②：这张卡给与对方战斗伤害时，把这张卡1个超量素材取除才能发动。给与对方为对方手卡数量×500伤害。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_DAMAGE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCode(EVENT_BATTLE_DAMAGE)
	e3:SetCondition(c53701457.damcon)
	e3:SetCost(c53701457.damcost)
	e3:SetTarget(c53701457.damtg)
	e3:SetOperation(c53701457.damop)
	c:RegisterEffect(e3)
end
-- 设置该卡的XYZ编号为28
aux.xyz_number[53701457]=28
-- 判断自己场上是否只有这张卡或没有其他怪兽
function c53701457.dircon(e)
	-- 判断自己场上怪兽数量是否小于等于1
	return Duel.GetFieldGroupCount(e:GetHandlerPlayer(),LOCATION_MZONE,0)<=1
end
-- 判断是否为直接攻击且攻击怪兽未被攻击过
function c53701457.rdcon(e)
	local c=e:GetHandler()
	local tp=e:GetHandlerPlayer()
	-- 判断攻击目标是否为空
	return Duel.GetAttackTarget()==nil
		-- 判断攻击怪兽的直接攻击效果次数小于2且自己场上有怪兽
		and c:GetEffectCount(EFFECT_DIRECT_ATTACK)<2 and Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0
end
-- 判断造成战斗伤害的玩家是否为对方
function c53701457.damcon(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp
end
-- 支付1个超量素材作为代价
function c53701457.damcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 设置伤害计算的目标玩家和伤害值
function c53701457.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取对方手牌数量
	local ct=Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)
	if chk==0 then return ct>0 end
	-- 设置连锁处理的目标玩家为对方
	Duel.SetTargetPlayer(1-tp)
	local dam=ct*500
	-- 设置连锁处理的目标参数为计算出的伤害值
	Duel.SetTargetParam(dam)
	-- 设置连锁操作信息为伤害效果
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,dam)
end
-- 执行伤害计算并造成伤害
function c53701457.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中设定的目标玩家
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 计算目标玩家手牌数量并乘以500作为伤害值
	local dam=Duel.GetFieldGroupCount(p,LOCATION_HAND,0)*500
	-- 对目标玩家造成指定伤害
	Duel.Damage(p,dam,REASON_EFFECT)
end
