--惑星汚染ウイルス
-- 效果：
-- 把自己场上存在的1只名字带有「外星」的怪兽解放发动。对方场上表侧表示存在的没有A指示物放置的怪兽全部破坏。用对方回合计算的3回合内对方召唤、反转召唤、特殊召唤的怪兽全部放置1个A指示物。
function c39163598.initial_effect(c)
	-- 把自己场上存在的1只名字带有「外星」的怪兽解放发动。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,0x1e1)
	e1:SetCost(c39163598.cost)
	e1:SetTarget(c39163598.target)
	e1:SetOperation(c39163598.activate)
	c:RegisterEffect(e1)
end
c39163598.counter_add_list={0x100e}
c39163598.mentioned_counter={
	[0x100e]=true,
}
-- 检查玩家场上是否存在至少1张满足过滤条件Card.IsSetCard并且不等于ex的可解放的卡（非上级召唤用）。
function c39163598.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家场上是否存在至少1张满足过滤条件Card.IsSetCard并且不等于ex的可解放的卡（非上级召唤用）。
	if chk==0 then return Duel.CheckReleaseGroup(tp,Card.IsSetCard,1,nil,0xc) end
	-- 让玩家从场上选择1张不等于ex的满足条件Card.IsSetCard的可解放的卡（非上级召唤用）。
	local g=Duel.SelectReleaseGroup(tp,Card.IsSetCard,1,1,nil,0xc)
	-- 以REASON_COST原因解放targets，返回值是实际解放的数量。
	Duel.Release(g,REASON_COST)
end
-- 过滤函数，返回以player来看的指定位置满足过滤条件c并且不等于ex的卡。
function c39163598.tgfilter(c)
	return c:IsFaceup() and c:GetCounter(0x100e)==0
end
-- 设置当前处理的连锁的操作信息此操作信息包含了效果处理中确定要处理的效果分类。
function c39163598.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 返回以player来看的指定位置满足过滤条件c并且不等于ex的卡。
	local g=Duel.GetMatchingGroup(c39163598.tgfilter,tp,0,LOCATION_MZONE,nil)
	-- 设置当前处理的连锁的操作信息此操作信息包含了效果处理中确定要处理的效果分类。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 用对方回合计算的3回合内对方召唤、反转召唤、特殊召唤的怪兽全部放置1个A指示物。
function c39163598.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 返回以player来看的指定位置满足过滤条件c并且不等于ex的卡。
	local g=Duel.GetMatchingGroup(c39163598.tgfilter,tp,0,LOCATION_MZONE,nil)
	-- 以REASON_EFFECT原因破坏targets去dest，返回值是实际被破坏的数量。
	Duel.Destroy(g,REASON_EFFECT)
	-- 对方场上表侧表示存在的没有A指示物放置的怪兽全部破坏。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetOperation(c39163598.ctop1)
	e1:SetReset(RESET_PHASE+PHASE_END+RESET_OPPO_TURN,3)
	-- 把效果e作为玩家player的效果注册给全局环境。
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	-- 把效果e作为玩家player的效果注册给全局环境。
	Duel.RegisterEffect(e2,tp)
	local e3=e1:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetOperation(c39163598.ctop2)
	-- 把效果e作为玩家player的效果注册给全局环境。
	Duel.RegisterEffect(e3,tp)
end
-- 当对方召唤成功时，若该召唤不是由自己发动，则给该怪兽放置1个A指示物。
function c39163598.ctop1(e,tp,eg,ep,ev,re,r,rp)
	if ep~=tp then
		eg:GetFirst():AddCounter(0x100e,1)
	end
end
-- 当对方特殊召唤成功时，若该召唤不是由自己发动且该怪兽表侧表示，则给该怪兽放置1个A指示物。
function c39163598.ctop2(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	while tc do
		if tc:IsFaceup() and tc:IsSummonPlayer(1-tp) then
			tc:AddCounter(0x100e,1)
		end
		tc=eg:GetNext()
	end
end
