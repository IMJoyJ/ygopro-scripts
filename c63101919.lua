--マジックテンペスター
-- 效果：
-- 调整＋调整以外的魔法师族怪兽1只以上
-- 这张卡同调召唤成功时，给这张卡放置1个魔力指示物。1回合1次，可以把自己手卡任意数量送去墓地，那个数量的魔力指示物给自己场上表侧表示存在的怪兽放置。此外，可以把场上存在的魔力指示物全部取除，给与对方基本分那个数量×500的数值的伤害。
function c63101919.initial_effect(c)
	c:EnableCounterPermit(0x1)
	-- 设置这张卡的同调召唤手续：素材为调整＋调整以外的魔法师族怪兽1只以上
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
-- 发动条件：确认这张卡是以同调召唤方式特殊召唤成功的
function c63101919.addcc1(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- 效果目标处理：无需额外检查，设置本连锁将放置魔力指示物的操作信息
function c63101919.addct1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：本连锁为放置魔力指示物效果，预计放置2个魔力指示物
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,2,0,0x1)
end
-- 效果处理：若这张卡仍与效果关联（在场上表侧表示存在），给这张卡放置1个魔力指示物
function c63101919.addc1(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		e:GetHandler():AddCounter(0x1,1)
	end
end
-- 代价处理：确认手卡有可送去墓地的卡后，让自己选择任意数量手卡送去墓地作为代价，并把送去墓地的数量记录下来
function c63101919.ctcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 可发动性检查：确认自己手卡至少有1张可以作为代价送去墓地的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToGraveAsCost,tp,LOCATION_HAND,0,1,nil) end
	-- 向玩家显示「请选择要送去墓地的卡」的选择提示
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让自己从手卡选择1～63张可以送去墓地的卡
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToGraveAsCost,tp,LOCATION_HAND,0,1,63,nil)
	-- 把选择的卡作为代价送去墓地
	Duel.SendtoGrave(g,REASON_COST)
	e:SetLabel(g:GetCount())
end
-- 效果目标处理：无需额外检查，设置本连锁将按记录数量放置魔力指示物的操作信息
function c63101919.cttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：本连锁为放置魔力指示物效果，预计放置数量为之前送去墓地的手卡数量
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,e:GetLabel(),0,0x1)
end
-- 效果处理：按记录的数量逐次让自己选择场上1只可以放置魔力指示物的怪兽，给那只怪兽放置1个魔力指示物
function c63101919.ctop(e,tp,eg,ep,ev,re,r,rp)
	local ct=e:GetLabel()
	for i=1,ct do
		-- 向玩家显示「请选择要放置指示物的卡」的选择提示
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_COUNTER)  --"请选择要放置指示物的卡"
		-- 让自己选择自己主要怪兽区1只可以放置魔力指示物的怪兽
		local g=Duel.SelectMatchingCard(tp,Card.IsCanAddCounter,tp,LOCATION_MZONE,0,1,1,nil,0x1,1)
		if g:GetCount()==0 then return end
		g:GetFirst():AddCounter(0x1,1)
	end
end
-- 过滤条件：只选取放置了1个以上魔力指示物的卡
function c63101919.damfilter(c)
	return c:GetCounter(0x1)>0
end
-- 代价处理：确认场上存在魔力指示物后，把双方场上所有卡上放置的魔力指示物全部取除，并把取除的总数记录下来
function c63101919.damcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 可发动性检查：确认场上存在至少1个可以取除的魔力指示物
	if chk==0 then return Duel.GetCounter(tp,1,1,0x1)>0 end
	-- 取得双方场上所有放置了魔力指示物的卡
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
-- 效果目标处理：以对方玩家为对象，把伤害数值设为取除的魔力指示物数量×500，并设置伤害效果的操作信息
function c63101919.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local ct=e:GetLabel()
	-- 把本连锁的对象玩家设置为对方玩家
	Duel.SetTargetPlayer(1-tp)
	-- 把本连锁的对象参数设置为取除的魔力指示物数量×500的伤害数值
	Duel.SetTargetParam(ct*500)
	-- 设置操作信息：本连锁为伤害效果，预计给与对方玩家那个数量×500的伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,ct*500)
end
-- 效果处理：从当前连锁信息中取得对象玩家和伤害数值，给与对方玩家那个数值的伤害
function c63101919.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中取得对象玩家（对方）和对象参数（伤害数值）
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 以效果原因给与对方玩家那个数值的基本分伤害
	Duel.Damage(p,d,REASON_EFFECT)
end
