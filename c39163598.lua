--惑星汚染ウイルス
-- 效果：
-- 把自己场上存在的1只名字带有「外星」的怪兽解放发动。对方场上表侧表示存在的没有A指示物放置的怪兽全部破坏。用对方回合计算的3回合内对方召唤、反转召唤、特殊召唤的怪兽全部放置1个A指示物。
function c39163598.initial_effect(c)
	-- 把自己场上存在的1只名字带有「外星」的怪兽解放发动。对方场上表侧表示存在的没有A指示物放置的怪兽全部破坏。用对方回合计算的3回合内对方召唤、反转召唤、特殊召唤的怪兽全部放置1个A指示物。
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
-- cost函数：作为发动代价，确认并选择自己场上1只名字带有「外星」的怪兽并将其解放
function c39163598.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在至少1只名字带有「外星」（系列0xc）的可解放的怪兽
	if chk==0 then return Duel.CheckReleaseGroup(tp,Card.IsSetCard,1,nil,0xc) end
	-- 让自己从自己场上选择1只名字带有「外星」的可解放的怪兽
	local g=Duel.SelectReleaseGroup(tp,Card.IsSetCard,1,1,nil,0xc)
	-- 以代价原因将选择的怪兽解放
	Duel.Release(g,REASON_COST)
end
-- 破坏对象过滤函数：表侧表示且没有放置A指示物（0x100e）的怪兽
function c39163598.tgfilter(c)
	return c:IsFaceup() and c:GetCounter(0x100e)==0
end
-- target函数：检索对方场上没有A指示物的表侧表示怪兽，并设置破坏分类的操作信息
function c39163598.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 检索对方场上表侧表示且没有A指示物放置的全部怪兽
	local g=Duel.GetMatchingGroup(c39163598.tgfilter,tp,0,LOCATION_MZONE,nil)
	-- 设置操作信息：宣告本次连锁将破坏检索到的这组怪兽及其数量
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- activate函数：破坏对方场上没有A指示物的怪兽，并注册3回合内监视对方召唤、反转召唤、特殊召唤以放置A指示物的持续效果
function c39163598.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检索对方场上表侧表示且没有A指示物放置的全部怪兽
	local g=Duel.GetMatchingGroup(c39163598.tgfilter,tp,0,LOCATION_MZONE,nil)
	-- 以效果原因将这组怪兽全部破坏
	Duel.Destroy(g,REASON_EFFECT)
	-- 用对方回合计算的3回合内对方召唤、反转召唤、特殊召唤的怪兽全部放置1个A指示物。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetOperation(c39163598.ctop1)
	e1:SetReset(RESET_PHASE+PHASE_END+RESET_OPPO_TURN,3)
	-- 把监视通常召唤成功的事件效果注册为发动玩家的全局持续效果
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	-- 把监视反转召唤成功的事件效果注册为发动玩家的全局持续效果
	Duel.RegisterEffect(e2,tp)
	local e3=e1:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetOperation(c39163598.ctop2)
	-- 把监视特殊召唤成功的事件效果注册为发动玩家的全局持续效果
	Duel.RegisterEffect(e3,tp)
end
-- ctop1函数：对方通常召唤成功时，给那只召唤的怪兽放置1个A指示物
function c39163598.ctop1(e,tp,eg,ep,ev,re,r,rp)
	if ep~=tp then
		eg:GetFirst():AddCounter(0x100e,1)
	end
end
-- ctop2函数：对方反转召唤、特殊召唤成功时，逐个给那组由对方召唤的表侧表示怪兽各放置1个A指示物
function c39163598.ctop2(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	while tc do
		if tc:IsFaceup() and tc:IsSummonPlayer(1-tp) then
			tc:AddCounter(0x100e,1)
		end
		tc=eg:GetNext()
	end
end
