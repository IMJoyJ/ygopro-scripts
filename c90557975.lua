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
c90557975.mentioned_counter={
	[0x1019]=true,
}
-- 带有雾指示物的怪兽过滤条件
function c90557975.filter(c)
	return c:GetCounter(0x1019)>0
end
-- 伤害效果Cost：取除场上全部雾指示物并计算伤害数值
function c90557975.damcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：场上存在带有雾指示物的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c90557975.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 获取场上所有带有雾指示物的怪兽
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
-- 伤害效果发动准备与目标确定
function c90557975.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置伤害的接受目标玩家为对方
	Duel.SetTargetPlayer(1-tp)
	-- 设置伤害数值参数（取除的指示物数量×300）
	Duel.SetTargetParam(e:GetLabel())
	-- 设置连锁操作信息：给予对方指定数值的效果伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,e:GetLabel())
end
-- 伤害效果处理：给予对方效果伤害
function c90557975.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取目标玩家和伤害数值参数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 执行效果伤害处理
	Duel.Damage(p,d,REASON_EFFECT)
end
