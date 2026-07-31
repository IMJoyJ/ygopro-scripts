--マジックテンペスター
-- 效果：
-- 调整＋调整以外的魔法师族怪兽1只以上
-- 这张卡同调召唤成功时，给这张卡放置1个魔力指示物。1回合1次，可以把自己手卡任意数量送去墓地，那个数量的魔力指示物给自己场上表侧表示存在的怪兽放置。此外，可以把场上存在的魔力指示物全部取除，给与对方基本分那个数量×500的数值的伤害。
function c63101919.initial_effect(c)
	c:EnableCounterPermit(0x1)
	-- 注册同调召唤手续：调整＋调整以外的魔法师族怪兽1只以上
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(Card.IsRace,RACE_SPELLCASTER),1)
	c:EnableReviveLimit()
	-- 这张卡同调召唤成功时，给这张卡放置1个魔力指示物。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(63101919,0))  --"放置魔力指示物"
	e1:SetCategory(CATEGORY_COUNTER)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c63101919.addcc1)
	e1:SetTarget(c63101919.addct1)
	e1:SetOperation(c63101919.addc1)
	c:RegisterEffect(e1)
	-- 1回合1次，可以把自己手卡任意数量送去墓地，那个数量的魔力指示物给自己场上表侧表示存在的怪兽放置。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(63101919,1))  --"放置手卡送去墓地数量的魔力指示物"
	e2:SetCategory(CATEGORY_COUNTER)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetCountLimit(1)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCost(c63101919.ctcost)
	e2:SetTarget(c63101919.cttg)
	e2:SetOperation(c63101919.ctop)
	c:RegisterEffect(e2)
	-- 此外，可以把场上存在的魔力指示物全部取除，给与对方基本分那个数量×500的数值的伤害。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(63101919,2))  --"魔力指示物全部取除，给与对方伤害"
	e3:SetCategory(CATEGORY_DAMAGE)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCost(c63101919.damcost)
	e3:SetTarget(c63101919.damtg)
	e3:SetOperation(c63101919.damop)
	c:RegisterEffect(e3)
end
c63101919.mentioned_counter={
	[0x1]=true,
}
-- ①效果发动条件：此卡同调召唤成功
function c63101919.addcc1(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- ①效果发动准备：设置放置魔力指示物的操作信息
function c63101919.addct1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁操作信息：放置魔力指示物
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,2,0,0x1)
end
-- ①效果处理：给这张卡放置1个魔力指示物
function c63101919.addc1(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		e:GetHandler():AddCounter(0x1,1)
	end
end
-- ②效果发动Cost：选择手牌任意数量的卡送去墓地
function c63101919.ctcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- Cost检查：手牌是否存在可以送去墓地的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToGraveAsCost,tp,LOCATION_HAND,0,1,nil) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从手牌选择任意数量的卡
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToGraveAsCost,tp,LOCATION_HAND,0,1,63,nil)
	-- 将选中的手牌送去墓地
	Duel.SendtoGrave(g,REASON_COST)
	e:SetLabel(g:GetCount())
end
-- ②效果发动准备：设置放置指示物连锁操作信息
function c63101919.cttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁操作信息：放置等同于送墓数量的魔力指示物
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,e:GetLabel(),0,0x1)
end
-- ②效果处理：逐个分配魔力指示物放置到自己场上表侧表示怪兽上
function c63101919.ctop(e,tp,eg,ep,ev,re,r,rp)
	local ct=e:GetLabel()
	for i=1,ct do
		-- 提示玩家选择要放置指示物的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_COUNTER)  --"请选择要放置指示物的卡"
		-- 选择自己场上1只可以放置魔力指示物的怪兽
		local g=Duel.SelectMatchingCard(tp,Card.IsCanAddCounter,tp,LOCATION_MZONE,0,1,1,nil,0x1,1)
		if g:GetCount()==0 then return end
		g:GetFirst():AddCounter(0x1,1)
	end
end
-- 指示物检查过滤条件：带有魔力指示物的卡
function c63101919.damfilter(c)
	return c:GetCounter(0x1)>0
end
-- ③效果发动Cost：取除场上存在的全部魔力指示物
function c63101919.damcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- Cost检查：全场是否存在至少1个魔力指示物
	if chk==0 then return Duel.GetCounter(tp,1,1,0x1)>0 end
	-- 获取全场所有带有魔力指示物的卡
	local g=Duel.GetMatchingGroup(c63101919.damfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	local tc=g:GetFirst()
	local sum=0
	while tc do
		local sct=tc:GetCounter(0x1)
		tc:RemoveCounter(tp,0x1,sct,0)
		sum=sum+sct
		tc=g:GetNext()
	end
	e:SetLabel(sum)
end
-- ③效果发动准备：设置给与对方伤害的操作信息
function c63101919.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local ct=e:GetLabel()
	-- 设置伤害目标玩家为对方
	Duel.SetTargetPlayer(1-tp)
	-- 计算并设置伤害数值：指示物数量×500
	Duel.SetTargetParam(ct*500)
	-- 设置连锁操作信息：给与对方计算出的伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,ct*500)
end
-- ③效果处理：给与对方基本分取除数量×500数值的伤害
function c63101919.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁信息中的伤害目标玩家与伤害数值
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 给与目标玩家效果伤害
	Duel.Damage(p,d,REASON_EFFECT)
end
