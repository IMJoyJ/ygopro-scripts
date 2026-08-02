--火器の祝台
-- 效果：
-- 这张卡发动的场合，给这张卡放置5个祝台指示物来发动。
-- ①：因魔法·陷阱卡的效果，从额外卡组有怪兽特殊召唤的场合或者从卡组有卡被送去墓地的场合发动。这张卡1个祝台指示物取除。那之后，这张卡的祝台指示物数量是0的场合，这张卡破坏，自己回复4000基本分。那之后，从自己的卡组·墓地把1张「祝台」陷阱卡在自己场上盖放。那之后，自己卡组的数量是1张以下的场合，自己决斗胜利。
local s,id,o=GetID()
-- 初始化函数，注册放置指示物的许可和各个效果
function s.initial_effect(c)
	c:EnableCounterPermit(0x6d)
	-- 这张卡发动的场合，给这张卡放置5个祝台指示物来发动。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_COUNTER)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	c:RegisterEffect(e1)
	-- 赋予这张卡可以放置祝台指示物的属性，且效果不会被无效不能被复制
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
-- 效果发动的目标选择函数，判断是否能放置指示物并执行放置
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查是否能给这张卡放置5个祝台指示物
	if chk==0 then return Duel.IsCanAddCounter(tp,0x6d,5,c) end
	c:AddCounter(0x6d,5)
end
-- 判断卡片是否在魔陷区且正在连锁中，作为允许放置指示物的条件
function s.ctpermit(e)
	local c=e:GetHandler()
	return c:IsLocation(LOCATION_SZONE) and c:IsStatus(STATUS_CHAINING)
end
-- 检查卡片是否从特定区域特殊召唤，且是因为效果特殊召唤
function s.cfilter1(c,loc)
	return c:IsPreviousLocation(loc) and c:GetSpecialSummonInfo(SUMMON_INFO_REASON_EFFECT)
end
-- 检查卡片是否从特定区域送去墓地，且是因为效果被送去墓地
function s.cfilter2(c,loc)
	return c:IsPreviousLocation(loc) and c:IsReason(REASON_EFFECT)
end
-- 判断是否是魔法·陷阱卡的效果发动，并且有怪兽从额外卡组特殊召唤
function s.ccon1(e,tp,eg,ep,ev,re,r,rp)
	return re and re:IsActiveType(TYPE_TRAP+TYPE_SPELL)
		and eg:IsExists(s.cfilter1,1,nil,LOCATION_EXTRA)
end
-- 判断是否是魔法·陷阱卡的效果发动，并且有卡从卡组被送去墓地
function s.ccon2(e,tp,eg,ep,ev,re,r,rp)
	return re and re:IsActiveType(TYPE_TRAP+TYPE_SPELL)
		and eg:IsExists(s.cfilter2,1,nil,LOCATION_DECK)
end
-- 效果的cost函数，限制每回合只能发动1次
function s.ccost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家本回合是否已经发动过该效果
	if chk==0 then return Duel.GetFlagEffect(tp,id)==0 end
	-- 给玩家注册一个标识效果，表示已经发动过该效果
	Duel.RegisterFlagEffect(tp,id,RESET_CHAIN,0,1)
end
-- 检查卡片是否是名字带有「祝台」的陷阱卡，且可以盖放
function s.setfilter(c)
	return c:IsSetCard(0x1bd) and c:IsType(TYPE_TRAP) and c:IsSSetable()
end
-- 效果处理函数，取除指示物，破坏卡片回复基本分，盖放陷阱卡，最后判断是否决斗胜利
function s.cop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:RemoveCounter(tp,0x6d,1,REASON_EFFECT) and c:GetCounter(0x6d)==0 then
		-- 中断当前效果，使前后的效果处理不视为同时发生
		Duel.BreakEffect()
		-- 判断是否成功破坏这张卡，且成功回复了4000基本分
		if Duel.Destroy(c,REASON_EFFECT)~=0 and Duel.Recover(tp,4000,REASON_EFFECT)~=0 then
			-- 提示玩家选择要盖放的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
			-- 让玩家从卡组或墓地选择1张符合条件的卡片，该选择不受王家长眠之谷影响
			local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.setfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
			if g:GetCount()>0 then
				-- 中断当前效果，使前后的效果处理不视为同时发生
				Duel.BreakEffect()
				-- 判断是否成功盖放卡片，且卡组剩余卡片数量在1张以下
				if Duel.SSet(tp,g:GetFirst())>0 and Duel.GetMatchingGroupCount(aux.TRUE,tp,LOCATION_DECK,0,nil)<=1 then
					-- 中断当前效果，使前后的效果处理不视为同时发生
					Duel.BreakEffect()
					-- 令玩家以0x23原因决斗胜利
					Duel.Win(tp,0x23)
				end
			end
		end
	end
end
