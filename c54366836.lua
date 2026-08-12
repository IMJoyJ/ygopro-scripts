--No.54 反骨の闘士ライオンハート
-- 效果：
-- 1星怪兽×3
-- ①：攻击表示的这张卡不会被战斗破坏。
-- ②：这张卡和对方怪兽进行战斗的伤害计算时1次，把这张卡1个超量素材取除才能发动。那次战斗发生的对自己的战斗伤害由对方代受。
-- ③：这张卡的战斗让自己受到战斗伤害的场合发动。给与对方为受到的伤害数值的伤害。
function c54366836.initial_effect(c)
	-- 设置XYZ召唤手续：1星怪兽×3
	aux.AddXyzProcedure(c,nil,1,3)
	c:EnableReviveLimit()
	-- ①：攻击表示的这张卡不会被战斗破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetCondition(c54366836.indcon)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	-- ③：这张卡的战斗让自己受到战斗伤害的场合发动。给与对方为受到的伤害数值的伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(54366836,0))  --"LP伤害"
	e2:SetCategory(CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_BATTLE_DAMAGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c54366836.damcon)
	e2:SetTarget(c54366836.damtg)
	e2:SetOperation(c54366836.damop)
	c:RegisterEffect(e2)
	-- ②：这张卡和对方怪兽进行战斗的伤害计算时1次，把这张卡1个超量素材取除才能发动。那次战斗发生的对自己的战斗伤害由对方代受。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(54366836,1))  --"伤害反射"
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,EFFECT_COUNT_CODE_CHAIN)
	e3:SetCondition(c54366836.damcon2)
	e3:SetCost(c54366836.damcost2)
	e3:SetOperation(c54366836.damop2)
	c:RegisterEffect(e3)
end
-- 设置该怪兽的“No.”编号为54
aux.xyz_number[54366836]=54
-- 效果③的触发条件：自己因这张卡的战斗受到战斗伤害
function c54366836.damcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return ep==tp and c:IsRelateToBattle()
end
-- 效果③的靶向与操作信息设置：以对方玩家为对象，设置伤害数值为受到的战斗伤害
function c54366836.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将效果处理的对象玩家设置为对方
	Duel.SetTargetPlayer(1-tp)
	-- 将效果处理的对象参数设置为受到的战斗伤害数值
	Duel.SetTargetParam(ev)
	-- 设置当前连锁的操作信息为给与对方等同于该战斗伤害数值的伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,ev)
end
-- 效果③的实际处理：给与对方等同于受到的战斗伤害数值的效果伤害
function c54366836.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中设定的目标玩家和伤害数值
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 以效果原因给与目标玩家对应的伤害
	Duel.Damage(p,d,REASON_EFFECT)
end
-- 效果②的触发条件：这张卡存在进行战斗的对方怪兽
function c54366836.damcon2(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetBattleTarget()~=nil
end
-- 效果②的代价：取除这张卡的1个超量素材
function c54366836.damcost2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:CheckRemoveOverlayCard(tp,1,REASON_COST) end
	c:RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 效果②的实际处理：创建一个在伤害计算时使自己受到的战斗伤害由对方代受的全局效果
function c54366836.damop2(e,tp,eg,ep,ev,re,r,rp)
	-- 那次战斗发生的对自己的战斗伤害由对方代受。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_REFLECT_BATTLE_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE+PHASE_DAMAGE_CAL)
	-- 将代受战斗伤害的全局效果注册给玩家
	Duel.RegisterEffect(e1,tp)
end
-- 效果①的适用条件：这张卡处于表侧攻击表示
function c54366836.indcon(e)
	return e:GetHandler():IsPosition(POS_FACEUP_ATTACK)
end
