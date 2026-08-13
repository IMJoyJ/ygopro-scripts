--No.28 タイタニック・モス
-- 效果：
-- 7星怪兽×2
-- ①：自己场上没有其他怪兽存在的场合，这张卡可以直接攻击。那次直接攻击给与对方的战斗伤害变成一半。
-- ②：这张卡给与对方战斗伤害时，把这张卡1个超量素材取除才能发动。给与对方为对方手卡数量×500伤害。
function c53701457.initial_effect(c)
	-- 为这张卡添加XYZ召唤手续：需要2只等级7的怪兽作为超量素材（对应效果原文‘7星怪兽×2’）。
	aux.AddXyzProcedure(c,nil,7,2)
	c:EnableReviveLimit()
	-- ①：自己场上没有其他怪兽存在的场合，这张卡可以直接攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_DIRECT_ATTACK)
	e1:SetCondition(c53701457.dircon)
	c:RegisterEffect(e1)
	-- 那次直接攻击给与对方的战斗伤害变成一半。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
	e2:SetCondition(c53701457.rdcon)
	-- 设置战斗伤害变更数值：将这张卡给与对方的战斗伤害变为一半（HALF_DAMAGE）。
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
-- 注册这张卡的XYZ编号为28，用于《No.》相关效果判定。
aux.xyz_number[53701457]=28
-- 定义直接攻击条件函数：自己场上没有其他怪兽存在时（即场上怪兽数量≤1，包含自身），允许这张卡直接攻击。
function c53701457.dircon(e)
	-- 检查自己场上怪兽区域卡数是否≤1，满足直接攻击条件（自己场上没有其他怪兽）。
	return Duel.GetFieldGroupCount(e:GetHandlerPlayer(),LOCATION_MZONE,0)<=1
end
-- 定义战斗伤害减半条件函数：当这张卡进行直接攻击（无攻击目标）且对方场上存在怪兽（本卡允许在对方有怪兽时直接攻击），并且没有多个直接攻击效果叠加时，将这次直接攻击给与对方的战斗伤害变为一半。
function c53701457.rdcon(e)
	local c=e:GetHandler()
	local tp=e:GetHandlerPlayer()
	-- 判断攻击目标为空，即本次攻击是直接攻击。
	return Duel.GetAttackTarget()==nil
		-- 确认这张卡的直接攻击效果未重复叠加（效果数量<2），且对方场上存在怪兽（符合本卡在对方有怪兽时仍可直接攻击的场景）。
		and c:GetEffectCount(EFFECT_DIRECT_ATTACK)<2 and Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0
end
-- 定义②的触发条件：对方受到战斗伤害（ep≠tp），即这张卡给与对方战斗伤害时。
function c53701457.damcon(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp
end
-- 定义②的发动代价：取除这张卡1个超量素材（先检查能否取除，再实际取除）。
function c53701457.damcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 定义②的发动目标：获取对方手卡数并计算伤害值，指定伤害对象玩家为对方，并设置对应操作信息。
function c53701457.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 取得对方手卡数量（tp为这张卡控制者，0代表对方），用于计算伤害。
	local ct=Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)
	if chk==0 then return ct>0 end
	-- 设置连锁的目标玩家为对手（1-tp），即伤害的承受方。
	Duel.SetTargetPlayer(1-tp)
	local dam=ct*500
	-- 把计算出的伤害值（手卡数×500）保存为连锁目标参数。
	Duel.SetTargetParam(dam)
	-- 设置本次操作信息：效果分类为伤害，对象为对方玩家，伤害数值为dam（用于连锁判定与发动时点）。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,dam)
end
-- 定义②的伤害处理：从连锁信息取得目标玩家，按该玩家当前手牌数×500造成伤害。
function c53701457.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁记录的目标玩家，确定伤害对象。
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 以目标玩家当前手牌数×500计算实际伤害值。
	local dam=Duel.GetFieldGroupCount(p,LOCATION_HAND,0)*500
	-- 以效果原因（REASON_EFFECT）对该玩家造成伤害。
	Duel.Damage(p,dam,REASON_EFFECT)
end
