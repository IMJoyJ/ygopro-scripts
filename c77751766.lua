--火器の祝台
-- 效果：
-- 这张卡发动的场合，给这张卡放置5个祝台指示物来发动。
-- ①：因魔法·陷阱卡的效果，从额外卡组有怪兽特殊召唤的场合或者从卡组有卡被送去墓地的场合发动。这张卡1个祝台指示物取除。那之后，这张卡的祝台指示物数量是0的场合，这张卡破坏，自己回复4000基本分。那之后，从自己的卡组·墓地把1张「祝台」陷阱卡在自己场上盖放。那之后，自己卡组的数量是1张以下的场合，自己决斗胜利。
local s,id,o=GetID()
-- 初始化卡片效果：启用指示物放置、注册卡片发动（放置5个指示物）及连锁诱发指示物取除/破坏恢复盖放胜利效果
function s.initial_effect(c)
	c:EnableCounterPermit(0x6d)
	-- 这张卡发动的场合，给这张卡放置5个祝台指示物来发动。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_COUNTER)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	c:RegisterEffect(e1)
	-- 给这张卡放置5个祝台指示物
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_COUNTER_PERMIT+0x6d)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetCondition(s.ctpermit)
	c:RegisterEffect(e2)
	-- ①：因魔法·陷阱卡的效果，从额外卡组有怪兽特殊召唤的场合或者从卡组有卡被送去墓地的场合发动。这张卡1个祝台指示物取除。那之后，这张卡的祝台指示物数量是0的场合，这张卡破坏，自己回复4000基本分。那之后，从自己的卡组·墓地把1张「祝台」陷阱卡在自己场上盖放。那之后，自己卡组的数量是1张以下的场合，自己决斗胜利。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"取除指示物"
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS+CATEGORY_SSET)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCondition(s.ccon1)
	e3:SetCost(s.ccost)
	e3:SetOperation(s.cop)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetCondition(s.ccon2)
	c:RegisterEffect(e4)
end
s.mentioned_counter={
	[0x6d]=true,
}
-- 卡片发动效果准备：检查并执行放置5个祝台指示物
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查此卡是否可以放置5个祝台指示物
	if chk==0 then return Duel.IsCanAddCounter(tp,0x6d,5,c) end
	c:AddCounter(0x6d,5)
end
-- 指示物许可条件：必须在魔陷区且处于连锁发动状态
function s.ctpermit(e)
	local c=e:GetHandler()
	return c:IsLocation(LOCATION_SZONE) and c:IsStatus(STATUS_CHAINING)
end
-- 诱发条件过滤1：检查怪兽是否因效果从额外卡组特殊召唤
function s.cfilter1(c,loc)
	return c:IsPreviousLocation(loc) and c:GetSpecialSummonInfo(SUMMON_INFO_REASON_EFFECT)
end
-- 诱发条件过滤2：检查卡片是否因效果从卡组送去墓地
function s.cfilter2(c,loc)
	return c:IsPreviousLocation(loc) and c:IsReason(REASON_EFFECT)
end
-- 诱发条件1：魔陷效果导致怪兽从额外卡组特殊召唤
function s.ccon1(e,tp,eg,ep,ev,re,r,rp)
	return re and re:IsActiveType(TYPE_TRAP+TYPE_SPELL)
		and eg:IsExists(s.cfilter1,1,nil,LOCATION_EXTRA)
end
-- 诱发条件2：魔陷效果导致卡片从卡组送去墓地
function s.ccon2(e,tp,eg,ep,ev,re,r,rp)
	return re and re:IsActiveType(TYPE_TRAP+TYPE_SPELL)
		and eg:IsExists(s.cfilter2,1,nil,LOCATION_DECK)
end
-- 强制诱发效果Cost：同一连锁上限制发动1次
function s.ccost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查同一连锁上是否尚未注册发动标记
	if chk==0 then return Duel.GetFlagEffect(tp,id)==0 end
	-- 在当前连锁注册1次性发动标记
	Duel.RegisterFlagEffect(tp,id,RESET_CHAIN,0,1)
end
-- 盖放卡片过滤条件：「祝台」陷阱卡且能在场上盖放
function s.setfilter(c)
	return c:IsSetCard(0x1bd) and c:IsType(TYPE_TRAP) and c:IsSSetable()
end
-- 诱发效果处理：取除1个指示物；若变为0则自毁恢复4000分、盖放「祝台」陷阱卡，若卡组剩余<=1张则直接决斗胜利
function s.cop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:RemoveCounter(tp,0x6d,1,REASON_EFFECT) and c:GetCounter(0x6d)==0 then
		-- 连接效果处理阶段
		Duel.BreakEffect()
		-- 破坏此卡并恢复4000基本分
		if Duel.Destroy(c,REASON_EFFECT)~=0 and Duel.Recover(tp,4000,REASON_EFFECT)~=0 then
			-- 提示玩家选择要盖放的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
			-- 从卡组或墓地选择1张「祝台」陷阱卡
			local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.setfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
			if g:GetCount()>0 then
				-- 连接效果处理阶段
				Duel.BreakEffect()
				-- 成功盖放卡片且检查己方卡组数量是否在1张以下
				if Duel.SSet(tp,g:GetFirst())>0 and Duel.GetMatchingGroupCount(aux.TRUE,tp,LOCATION_DECK,0,nil)<=1 then
					-- 连接效果处理阶段
					Duel.BreakEffect()
					-- 触发特殊胜利条件，直接判定玩家决斗胜利
					Duel.Win(tp,0x23)
				end
			end
		end
	end
end
