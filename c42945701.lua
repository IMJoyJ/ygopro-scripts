--火霊術－「紅」
-- 效果：
-- ①：把自己场上1只炎属性怪兽解放才能发动。给与对方解放的怪兽的原本攻击力数值的伤害。
function c42945701.initial_effect(c)
	-- 效果原文内容：①：把自己场上1只炎属性怪兽解放才能发动。给与对方解放的怪兽的原本攻击力数值的伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c42945701.cost)
	e1:SetTarget(c42945701.target)
	e1:SetOperation(c42945701.activate)
	c:RegisterEffect(e1)
end
-- 检查是否满足解放炎属性怪兽的条件并选择解放的怪兽，将该怪兽的攻击力设为效果的伤害值
function c42945701.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	-- 检查玩家场上是否存在至少1张满足条件的炎属性怪兽（非上级召唤用）
	if chk==0 then return Duel.CheckReleaseGroup(tp,Card.IsAttribute,1,nil,ATTRIBUTE_FIRE) end
	-- 从玩家场上选择1张满足条件的炎属性怪兽作为解放对象
	local g=Duel.SelectReleaseGroup(tp,Card.IsAttribute,1,1,nil,ATTRIBUTE_FIRE)
	local atk=g:GetFirst():GetTextAttack()
	if atk<0 then atk=0 end
	e:SetLabel(atk)
	-- 以代价原因解放所选的怪兽
	Duel.Release(g,REASON_COST)
end
-- 设置连锁处理的目标玩家和参数，准备发动伤害效果
function c42945701.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local res=e:GetLabel()~=0
		e:SetLabel(0)
		return res
	end
	-- 将连锁处理的目标玩家设置为对方玩家
	Duel.SetTargetPlayer(1-tp)
	-- 将连锁处理的目标参数设置为之前计算的怪兽攻击力
	Duel.SetTargetParam(e:GetLabel())
	-- 设置当前连锁的操作信息为伤害效果，目标为对方玩家，伤害值为之前设定的攻击力
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,e:GetLabel())
	e:SetLabel(0)
end
-- 处理连锁的伤害效果，对目标玩家造成对应伤害
function c42945701.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标玩家和目标参数（即伤害值）
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 以效果原因对目标玩家造成对应数值的伤害
	Duel.Damage(p,d,REASON_EFFECT)
end
