--R.B. Ga10 Cutter
-- 效果：
-- 自己场上的表侧表示怪兽不存在的场合或者只有「奏悦机组」怪兽的场合，这张卡可以从手卡特殊召唤。自己对「奏悦机组 筑工切割机」的这个方法的特殊召唤1回合只能有1次。
-- 这张卡在「奏悦机组」连接怪兽所连接区存在，对方把魔法·陷阱卡的效果发动时（诱发即时效果）：可以支付700基本分；这张卡破坏，那个效果无效并破坏。「奏悦机组 筑工切割机」的这个效果1回合只能使用1次。
-- 
local s,id,o=GetID()
-- 注册两个效果：一个用于手牌特殊召唤条件，一个用于诱发即时效果
function s.initial_effect(c)
	-- 自己场上的表侧表示怪兽不存在的场合或者只有「奏悦机组」怪兽的场合，这张卡可以从手卡特殊召唤。自己对「奏悦机组 筑工切割机」的这个方法的特殊召唤1回合只能有1次。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.spcon)
	c:RegisterEffect(e1)
	-- 这张卡在「奏悦机组」连接怪兽所连接区存在，对方把魔法·陷阱卡的效果发动时（诱发即时效果）：可以支付700基本分；这张卡破坏，那个效果无效并破坏。「奏悦机组 筑工切割机」的这个效果1回合只能使用1次。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"无效并破坏"
	e2:SetCategory(CATEGORY_DISABLE+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.discon)
	e2:SetCost(s.discost)
	e2:SetTarget(s.distg)
	e2:SetOperation(s.disop)
	c:RegisterEffect(e2)
end
-- 过滤函数，检查场上是否存在非「奏悦机组」怪兽
function s.cfilter(c)
	return c:IsFaceup() and not c:IsSetCard(0x1cf)
end
-- 特殊召唤条件函数，判断是否满足手牌特殊召唤的条件
function s.spcon(e,c)
	if c==nil then return true end
	-- 判断玩家场上是否有足够的怪兽区域
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
		-- 判断场上是否不存在非「奏悦机组」怪兽
		and not Duel.IsExistingMatchingCard(s.cfilter,c:GetControler(),LOCATION_MZONE,0,1,nil)
end
-- 过滤函数，检查场上是否存在「奏悦机组」连接怪兽
function s.ecfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x1cf) and c:IsType(TYPE_LINK)
end
-- 诱发即时效果的发动条件函数，判断是否满足发动条件
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取场上所有「奏悦机组」连接怪兽
	local lg=Duel.GetMatchingGroup(s.ecfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	local lg2=Group.CreateGroup()
	-- 遍历所有「奏悦机组」连接怪兽，获取其连接区域
	for lc in aux.Next(lg) do
		lg2:Merge(lc:GetLinkedGroup())
	end
	return lg2 and lg2:IsContains(e:GetHandler())
		and not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED)
		-- 判断对方发动的是魔法或陷阱卡且该连锁可以被无效
		and ep~=tp and re:IsActiveType(TYPE_SPELL+TYPE_TRAP) and Duel.IsChainDisablable(ev)
end
-- 支付700基本分的费用函数
function s.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否能支付700基本分
	if chk==0 then return Duel.CheckLPCost(tp,700) end
	-- 让玩家支付700基本分
	Duel.PayLPCost(tp,700)
end
-- 设置诱发即时效果的目标函数
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 向对方提示该效果被发动
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置操作信息：使效果无效
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
	local dg=Group.FromCards(e:GetHandler())
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		dg:Merge(eg)
	end
	-- 设置操作信息：破坏相关卡片
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,dg,#dg,0,0)
end
-- 诱发即时效果的处理函数
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断该卡是否仍在连锁中且成功破坏
	if c:IsRelateToChain() and Duel.Destroy(c,REASON_EFFECT)>0
		-- 判断是否成功使连锁效果无效且目标卡仍在连锁中
		and Duel.NegateEffect(ev) and re:GetHandler():IsRelateToChain(ev) then
		-- 破坏对方发动的魔法或陷阱卡
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
