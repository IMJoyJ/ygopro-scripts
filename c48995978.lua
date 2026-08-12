--No.88 ギミック・パペット－デステニー・レオ
-- 效果：
-- 8星怪兽×3
-- 这张卡有3个命运指示物被放置时，自己决斗胜利。
-- ①：1回合1次，自己的魔法与陷阱区域没有卡存在的场合才能发动。这张卡1个超量素材取除，给这张卡放置1个命运指示物。这个效果发动的回合，自己不能进行战斗阶段。
function c48995978.initial_effect(c)
	c:EnableCounterPermit(0x2b)
	-- 为这张卡添加超量召唤手续：把3只8星怪兽叠放进行超量召唤。
	aux.AddXyzProcedure(c,nil,8,3)
	c:EnableReviveLimit()
	-- ①：1回合1次，自己的魔法与陷阱区域没有卡存在的场合才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(48995978,0))  --"放置指示物"
	e1:SetCategory(CATEGORY_COUNTER)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c48995978.condition)
	e1:SetCost(c48995978.cost)
	e1:SetTarget(c48995978.target)
	e1:SetOperation(c48995978.operation)
	c:RegisterEffect(e1)
	-- 这张卡有3个命运指示物被放置时，自己决斗胜利。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_ADJUST)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetOperation(c48995978.winop)
	c:RegisterEffect(e2)
end
-- 在超量号码表中登记这张卡为「No.88」，供按编号检索的支援卡识别。
aux.xyz_number[48995978]=88
c48995978.mentioned_counter={
	[0x2b]=true,
}
-- 过滤函数：选取序列号小于5的魔陷区卡（即不包括场地区域的卡）。
function c48995978.filter(c)
	return c:GetSequence()<5
end
-- 发动条件：自己的魔法与陷阱区域没有卡存在。
function c48995978.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己的魔法与陷阱区域（不含场地区域）不存在任何卡。
	return not Duel.IsExistingMatchingCard(c48995978.filter,tp,LOCATION_SZONE,0,1,nil)
end
-- 代价处理：确认当前为主要阶段1，并给发动者注册本回合不能进行战斗阶段的誓约效果。
function c48995978.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查当前阶段是否为主要阶段1（因发动后本回合不能进行战斗阶段）。
	if chk==0 then return Duel.GetCurrentPhase()==PHASE_MAIN1 end
	-- 这张卡1个超量素材取除，给这张卡放置1个命运指示物。这个效果发动的回合，自己不能进行战斗阶段。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_BP)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 把「不能进入战斗阶段」的誓约效果注册给发动玩家，直到回合结束。
	Duel.RegisterEffect(e1,tp)
end
-- 检查这张卡能以效果取除1个超量素材，并且可以放置1个命运指示物。
function c48995978.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_EFFECT)
		and e:GetHandler():IsCanAddCounter(0x2b,1) end
	-- 设置连锁操作信息：本效果处理将放置1个命运指示物（0x2b），供其他效果的发动检测使用。
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,1,0,0x2b)
end
-- 效果处理：若这张卡与效果关联且表侧表示存在，则取除1个超量素材，并给这张卡放置1个命运指示物。
function c48995978.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() and c:RemoveOverlayCard(tp,1,1,REASON_EFFECT) then
		c:AddCounter(0x2b,1)
	end
end
-- 不入连锁的持续处理：每次调整后检测这张卡的命运指示物，若恰有3个则令自己决斗胜利。
function c48995978.winop(e,tp,eg,ep,ev,re,r,rp)
	local WIN_REASON_DESTINY_LEO=0x17
	local c=e:GetHandler()
	if c:GetCounter(0x2b)==3 then
		-- 令自己玩家以「No.88 机关傀儡-命运狮子」的专用胜利理由取得决斗胜利。
		Duel.Win(tp,WIN_REASON_DESTINY_LEO)
	end
end
