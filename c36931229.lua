--キャッスル・ゲート
-- 效果：
-- ①：这张卡不会被战斗破坏。
-- ②：1回合1次，这张卡在场上攻击表示存在的场合，把自己场上1只5星以下的怪兽解放才能发动。给与对方解放的怪兽的原本攻击力数值的伤害。
function c36931229.initial_effect(c)
	-- ①：这张卡不会被战斗破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	-- ②：1回合1次，这张卡在场上攻击表示存在的场合，把自己场上1只5星以下的怪兽解放才能发动。给与对方解放的怪兽的原本攻击力数值的伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(36931229,0))  --"伤害"
	e2:SetCategory(CATEGORY_DAMAGE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c36931229.condition)
	e2:SetCost(c36931229.cost)
	e2:SetTarget(c36931229.target)
	e2:SetOperation(c36931229.operation)
	c:RegisterEffect(e2)
end
-- 发动条件判定：本效果只能在持有者自身处于攻击表示时才能发动。
function c36931229.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsAttackPos()
end
-- 筛选可用作解放的怪兽：必须是5星以下且记载攻击力大于0的怪兽。
function c36931229.filter(c)
	return c:IsLevelBelow(5) and c:GetTextAttack()>0
end
-- 代价处理：选择并解放自己场上1只5星以下的怪兽，将解放怪兽的原本攻击力记录到效果标签中，作为后续伤害数值。
function c36931229.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检查：在发动前确认自己场上是否存在至少1只满足条件的可解放怪兽。
	if chk==0 then return Duel.CheckReleaseGroup(tp,c36931229.filter,1,nil) end
	-- 选择解放对象：从自己场上选出1只符合条件的怪兽作为解放代价。
	local sg=Duel.SelectReleaseGroup(tp,c36931229.filter,1,1,nil)
	e:SetLabel(sg:GetFirst():GetTextAttack())
	-- 执行解放：将该怪兽解放，作为发动效果所需的代价（REASON_COST）。
	Duel.Release(sg,REASON_COST)
end
-- 效果目标设定：登记伤害对象为对方玩家，伤害数值为之前记录的解放怪兽的原本攻击力，并写入连锁操作信息。
function c36931229.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将效果的对象玩家设为对方（1-tp），即伤害承受者。
	Duel.SetTargetPlayer(1-tp)
	-- 将效果参数设为记录在标签中的原本攻击力数值，作为伤害值。
	Duel.SetTargetParam(e:GetLabel())
	-- 登记伤害操作信息：类别为伤害（CATEGORY_DAMAGE），对象为对方玩家，预计伤害数值为记录的原本攻击力。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,e:GetLabel())
end
-- 效果处理：从连锁信息中取出对象玩家和伤害数值，对对方造成对应伤害。
function c36931229.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 读取当前连锁中保存的对象玩家（p）和伤害参数（d）。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 以效果原因（REASON_EFFECT）对玩家p造成d点伤害。
	Duel.Damage(p,d,REASON_EFFECT)
end
