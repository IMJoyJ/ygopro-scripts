--バスター・バースト
-- 效果：
-- 把自己场上存在的1只名字带有「/爆裂体」的怪兽解放发动。双方受到那只怪兽的等级×200的数值的伤害。
function c93469007.initial_effect(c)
	-- 把自己场上存在的1只名字带有「/爆裂体」的怪兽解放发动。双方受到那只怪兽的等级×200的数值的伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c93469007.cost)
	e1:SetTarget(c93469007.target)
	e1:SetOperation(c93469007.activate)
	c:RegisterEffect(e1)
end
-- 发动代价：解放自己场上1只「/爆裂体」怪兽，并记录其等级×200的伤害数值
function c93469007.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	-- 检查场上是否存在可解放的「/爆裂体」怪兽
	if chk==0 then return Duel.CheckReleaseGroup(tp,Card.IsSetCard,1,nil,0x104f) end
	-- 选择自己场上1只「/爆裂体」怪兽
	local g=Duel.SelectReleaseGroup(tp,Card.IsSetCard,1,1,nil,0x104f)
	e:SetLabel(g:GetFirst():GetLevel()*200)
	-- 解放选中的怪兽
	Duel.Release(g,REASON_COST)
end
-- 效果的目标处理：设置伤害数值并宣告伤害操作信息
function c93469007.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local res=e:GetLabel()~=0
		e:SetLabel(0)
		return res
	end
	-- 将伤害数值保存为连锁的对象参数
	Duel.SetTargetParam(e:GetLabel())
	-- 设置操作信息，宣告将对双方玩家造成伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,PLAYER_ALL,e:GetLabel())
	e:SetLabel(0)
end
-- 效果处理：获取伤害数值并对双方玩家造成伤害
function c93469007.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中保存的伤害数值
	local d=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
	-- 对对方玩家造成伤害（分步处理）
	Duel.Damage(1-tp,d,REASON_EFFECT,true)
	-- 对自身玩家造成伤害（分步处理）
	Duel.Damage(tp,d,REASON_EFFECT,true)
	-- 完成伤害处理并触发相关时点
	Duel.RDComplete()
end
