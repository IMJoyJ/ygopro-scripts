--ドン・サウザンドの契約
-- 效果：
-- 「上千主上的契约」在1回合只能发动1张。
-- ①：作为这张卡的发动时的效果处理，双方玩家失去1000基本分，各自从卡组抽1张。
-- ②：双方玩家把这张卡在魔法与陷阱区域存在期间抽到的卡以及这张卡的①的效果抽到的卡持续公开。
-- ③：这张卡的效果让手卡的魔法卡公开中的玩家不能把怪兽通常召唤。
function c56673480.initial_effect(c)
	-- 「上千主上的契约」在1回合只能发动1张。①：作为这张卡的发动时的效果处理，双方玩家失去1000基本分，各自从卡组抽1张。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,56673480+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c56673480.target)
	e1:SetOperation(c56673480.activate)
	c:RegisterEffect(e1)
	-- ②：双方玩家把这张卡在魔法与陷阱区域存在期间抽到的卡以及这张卡的①的效果抽到的卡持续公开。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_DRAW)
	e2:SetRange(LOCATION_SZONE)
	e2:SetOperation(c56673480.drop)
	c:RegisterEffect(e2)
	local g=Group.CreateGroup()
	g:KeepAlive()
	e2:SetLabelObject(g)
	-- ②：双方玩家把这张卡在魔法与陷阱区域存在期间抽到的卡以及这张卡的①的效果抽到的卡持续公开。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_PUBLIC)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTargetRange(LOCATION_HAND,LOCATION_HAND)
	e3:SetCondition(c56673480.pubcon)
	e3:SetTarget(c56673480.pubtg)
	e3:SetLabelObject(g)
	c:RegisterEffect(e3)
	-- ③：这张卡的效果让手卡的魔法卡公开中的玩家不能把怪兽通常召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_CANNOT_SUMMON)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetRange(LOCATION_SZONE)
	e4:SetTargetRange(1,0)
	e4:SetCondition(c56673480.scon1)
	e4:SetLabelObject(g)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EFFECT_CANNOT_MSET)
	c:RegisterEffect(e5)
	local e6=e4:Clone()
	e6:SetTargetRange(0,1)
	e6:SetCondition(c56673480.scon2)
	c:RegisterEffect(e6)
	local e7=e6:Clone()
	e7:SetCode(EFFECT_CANNOT_MSET)
	c:RegisterEffect(e7)
end
-- 检查双方玩家是否都满足至少有1000基本分且可以抽1张卡的条件，作为发动时的可行性检测
function c56673480.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己是否拥有至少1000基本分且可以抽卡
	if chk==0 then return Duel.GetLP(tp)>=1000 and Duel.IsPlayerCanDraw(tp,1)
		-- 检查对方是否拥有至少1000基本分且可以抽卡
		and Duel.GetLP(1-tp)>=1000 and Duel.IsPlayerCanDraw(1-tp,1) end
	-- 设置操作信息，表示此效果包含双方玩家抽卡的操作
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,PLAYER_ALL,1)
end
-- 发动时的效果处理：双方玩家失去1000基本分，各自从卡组抽1张卡（若基本分不足1000则归0且不抽卡）
function c56673480.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己当前的LP
	local lp0=Duel.GetLP(tp)
	if lp0>=1000 then
		-- 将自己的LP减少1000
		Duel.SetLP(tp,lp0-1000)
		-- 自己因效果从卡组抽1张卡
		Duel.Draw(tp,1,REASON_EFFECT)
	else
		-- 若自己基本分不足1000，则将自己的LP设为0
		Duel.SetLP(tp,0)
	end
	-- 获取对方当前的LP
	local lp1=Duel.GetLP(1-tp)
	if lp1>=1000 then
		-- 将对方的LP减少1000
		Duel.SetLP(1-tp,lp1-1000)
		-- 对方因效果从卡组抽1张卡
		Duel.Draw(1-tp,1,REASON_EFFECT)
	else
		-- 若对方基本分不足1000，则将对方的LP设为0
		Duel.SetLP(1-tp,0)
	end
end
-- 抽卡时的效果处理：将双方抽到的卡加入卡片组，并为这些卡注册用于识别的标记
function c56673480.drop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local pg=e:GetLabelObject()
	if c:GetFlagEffect(56673480)==0 then
		c:RegisterFlagEffect(56673480,RESET_EVENT+RESETS_STANDARD+RESET_DISABLE,0,1)
		pg:Clear()
	end
	local tc=eg:GetFirst()
	while tc do
		pg:AddCard(tc)
		tc:RegisterFlagEffect(56673481,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,66)
		tc=eg:GetNext()
	end
end
-- 判断此卡是否已在魔陷区存在并初始化过卡片组
function c56673480.pubcon(e)
	return e:GetHandler():GetFlagEffect(56673480)~=0
end
-- 过滤出属于记录组且带有特定标记的卡作为公开对象
function c56673480.pubtg(e,c)
	return e:GetLabelObject():IsContains(c) and c:GetFlagEffect(56673481)~=0
end
-- 过滤出处于公开状态、属于记录组、带有特定标记且是魔法卡的卡片
function c56673480.sfilter(c,pg)
	return c:IsPublic() and pg:IsContains(c) and c:GetFlagEffect(56673481)>0 and c:IsType(TYPE_SPELL)
end
-- 检查自己手卡中是否存在因该卡效果公开的魔法卡，作为自己不能通常召唤的条件
function c56673480.scon1(e)
	local tp=e:GetHandlerPlayer()
	-- 检查自己手牌中是否存在满足条件的公开魔法卡
	return Duel.IsExistingMatchingCard(c56673480.sfilter,tp,LOCATION_HAND,0,1,nil,e:GetLabelObject())
end
-- 检查对方手卡中是否存在因该卡效果公开的魔法卡，作为对方不能通常召唤的条件
function c56673480.scon2(e)
	local tp=e:GetHandlerPlayer()
	-- 检查对方手牌中是否存在满足条件的公开魔法卡
	return Duel.IsExistingMatchingCard(c56673480.sfilter,tp,0,LOCATION_HAND,1,nil,e:GetLabelObject())
end
