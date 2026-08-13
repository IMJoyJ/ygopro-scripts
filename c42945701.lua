--火霊術－「紅」
-- 效果：
-- ①：把自己场上1只炎属性怪兽解放才能发动。给与对方解放的怪兽的原本攻击力数值的伤害。
function c42945701.initial_effect(c)
	-- ①：把自己场上1只炎属性怪兽解放才能发动。给与对方解放的怪兽的原本攻击力数值的伤害。
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
-- 发动效果的代价处理：先检查自己场上是否有可解放的炎属性怪兽，再选择1只解放，并将其原本攻击力（若为?则视为0）存入效果标签，作为后续伤害数值。
function c42945701.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	-- 代价检查阶段：判定自己场上是否存在至少1只可解放的炎属性怪兽。
	if chk==0 then return Duel.CheckReleaseGroup(tp,Card.IsAttribute,1,nil,ATTRIBUTE_FIRE) end
	-- 从自己场上选择1只炎属性怪兽作为解放代价。
	local g=Duel.SelectReleaseGroup(tp,Card.IsAttribute,1,1,nil,ATTRIBUTE_FIRE)
	local atk=g:GetFirst():GetTextAttack()
	if atk<0 then atk=0 end
	e:SetLabel(atk)
	-- 解放所选择的怪兽，作为发动效果的代价。
	Duel.Release(g,REASON_COST)
end
-- 效果发动时的目标设定：确认代价中记录的伤害数值不为0，然后将对方玩家设为对象，将伤害数值写入连锁信息，并登记造成伤害的操作信息。
function c42945701.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local res=e:GetLabel()~=0
		e:SetLabel(0)
		return res
	end
	-- 将对象玩家设为对方玩家，即伤害的承受者。
	Duel.SetTargetPlayer(1-tp)
	-- 将代价阶段记录的原本攻击力数值设为连锁参数，作为伤害值。
	Duel.SetTargetParam(e:GetLabel())
	-- 设置本次连锁的操作信息：对对方玩家造成e:GetLabel()点伤害。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,e:GetLabel())
	e:SetLabel(0)
end
-- 效果处理时实际执行伤害：从连锁信息中取出目标玩家和伤害数值，给予对应伤害。
function c42945701.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中获取目标玩家和伤害参数。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 以效果原因向目标玩家造成d点伤害。
	Duel.Damage(p,d,REASON_EFFECT)
end
