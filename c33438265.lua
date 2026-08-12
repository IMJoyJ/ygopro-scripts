--R.B.GA１０カッター
-- 效果：
-- 这个卡名的①的方法的特殊召唤1回合只能有1次，②的效果1回合只能使用1次。
-- ①：自己场上的表侧表示怪兽不存在的场合或者只有「反叛曲机器人」怪兽的场合，这张卡可以从手卡特殊召唤。
-- ②：这张卡是和「反叛曲机器人」连接怪兽连接状态的场合，对方把魔法·陷阱卡的效果发动时，支付700基本分才能发动。这张卡破坏，那个发动的效果无效并破坏。
local s,id,o=GetID()
-- 初始化并注册两个效果：e1为①的手卡特殊召唤规则效果（1回合只能有1次，誓约计数，不可复制），e2为②在怪兽区域对方发动魔法·陷阱卡效果时发动的诱发即时无效·破坏效果（1回合只能使用1次）
function s.initial_effect(c)
	-- 这个卡名的①的方法的特殊召唤1回合只能有1次。①：自己场上的表侧表示怪兽不存在的场合或者只有「反叛曲机器人」怪兽的场合，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.spcon)
	c:RegisterEffect(e1)
	-- ②的效果1回合只能使用1次。②：这张卡是和「反叛曲机器人」连接怪兽连接状态的场合，对方把魔法·陷阱卡的效果发动时，支付700基本分才能发动。这张卡破坏，那个发动的效果无效并破坏。
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
-- 过滤函数：表侧表示且不是「反叛曲机器人」系列的卡，用于检测自己场上是否存在本家以外的怪兽
function s.cfilter(c)
	return c:IsFaceup() and not c:IsSetCard(0x1cf)
end
-- ①的特殊召唤条件：自己主要怪兽区域有可用空格，且自己怪兽区域不存在表侧表示的非「反叛曲机器人」怪兽
function s.spcon(e,c)
	if c==nil then return true end
	-- 检查自己主要怪兽区域是否有可用空格（能否把这张卡特殊召唤上场）
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
		-- 并且自己怪兽区域不存在表侧表示的非「反叛曲机器人」怪兽，即自己场上没有表侧表示怪兽或只有「反叛曲机器人」怪兽
		and not Duel.IsExistingMatchingCard(s.cfilter,c:GetControler(),LOCATION_MZONE,0,1,nil)
end
-- 过滤函数：表侧表示的「反叛曲机器人」连接怪兽
function s.ecfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x1cf) and c:IsType(TYPE_LINK)
end
-- ②的发动条件：这张卡处于与「反叛曲机器人」连接怪兽连接状态、未被战斗破坏确定，且是对方把魔法·陷阱卡的效果发动、该连锁可以被无效的场合
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	-- 检索双方怪兽区域所有表侧表示的「反叛曲机器人」连接怪兽
	local lg=Duel.GetMatchingGroup(s.ecfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	local lg2=Group.CreateGroup()
	-- 逐个遍历这些连接怪兽，将其连接端的卡合并进连接状态卡组lg2
	for lc in aux.Next(lg) do
		lg2:Merge(lc:GetLinkedGroup())
	end
	return lg2 and lg2:IsContains(e:GetHandler())
		and not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED)
		-- 并且是对方玩家发动的魔法卡或陷阱卡的效果，且该连锁的效果可以被无效
		and ep~=tp and re:IsActiveType(TYPE_SPELL+TYPE_TRAP) and Duel.IsChainDisablable(ev)
end
-- ②的发动代价：发动时需支付700基本分（先检测能否支付，确认后实际支付）
function s.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己能否支付700基本分作为发动代价
	if chk==0 then return Duel.CheckLPCost(tp,700) end
	-- 支付700基本分作为发动代价
	Duel.PayLPCost(tp,700)
end
-- ②的目标设定：向对方提示发动的效果，设置无效对方连锁的操作信息，并把这张卡以及可破坏的对方发动卡一起设置为破坏对象
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 向对方玩家提示选择了「无效并破坏」效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置操作信息：使对方正在发动的那条连锁的效果无效
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
	local dg=Group.FromCards(e:GetHandler())
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		dg:Merge(eg)
	end
	-- 设置操作信息：以效果破坏这张卡和（可破坏的）对方发动的那张卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,dg,#dg,0,0)
end
-- ②的效果处理：这张卡仍与连锁相关时先将这张卡破坏，然后使对方发动的效果无效，该卡仍与连锁相关再将其破坏
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 这张卡仍与该连锁相关时，先将这张卡用效果破坏（这张卡破坏）
	if c:IsRelateToChain() and Duel.Destroy(c,REASON_EFFECT)>0
		-- 然后使对方发动的效果无效，并确认对方那张卡仍与该连锁相关
		and Duel.NegateEffect(ev) and re:GetHandler():IsRelateToChain(ev) then
		-- 将对方发动的那张魔法·陷阱卡用效果破坏（那个发动的效果无效并破坏）
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
