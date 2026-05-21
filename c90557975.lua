--上昇気流
-- 效果：
-- 把场上存在的雾指示物全部取除发动。给与对方基本分取除的雾指示物数量×300的数值的伤害。
function c90557975.initial_effect(c)
	-- 把场上存在的雾指示物全部取除发动。给与对方基本分取除的雾指示物数量×300的数值的伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c90557975.damcost)
	e1:SetTarget(c90557975.damtg)
	e1:SetOperation(c90557975.damop)
	c:RegisterEffect(e1)
end
-- 过滤场上放置有雾指示物（0x1019）的怪兽
function c90557975.filter(c)
	return c:GetCounter(0x1019)>0
end
-- 发动代价：取除场上所有的雾指示物，并计算取除的总数量乘以300作为伤害值保存
function c90557975.damcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段（chk==0）检查场上是否存在至少1个放置有雾指示物的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c90557975.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 获取双方场上所有放置有雾指示物的怪兽组
	local g=Duel.GetMatchingGroup(c90557975.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	local tc=g:GetFirst()
	local s=0
	while tc do
		local ct=tc:GetCounter(0x1019)
		s=s+ct
		tc:RemoveCounter(tp,0x1019,ct,REASON_COST)
		tc=g:GetNext()
	end
	e:SetLabel(s*300)
end
-- 效果的目标处理：设定对方玩家为伤害对象，并将保存的伤害数值设为目标参数，注册伤害操作信息
function c90557975.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置对方玩家为当前连锁的对象玩家
	Duel.SetTargetPlayer(1-tp)
	-- 将保存在Label中的伤害数值设置为当前连锁的对象参数
	Duel.SetTargetParam(e:GetLabel())
	-- 设置当前连锁的操作信息为给与对方玩家对应数值的伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,e:GetLabel())
end
-- 效果处理：获取目标玩家和伤害数值，给与对方玩家相应的伤害
function c90557975.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁设定的目标玩家和伤害数值参数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 以效果原因给与目标玩家对应的伤害
	Duel.Damage(p,d,REASON_EFFECT)
end
