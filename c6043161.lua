--R.B.GA１０ドリラー
-- 效果：
-- 这个卡名的①的方法的特殊召唤1回合只能有1次，②的效果1回合只能使用1次。
-- ①：自己场上的表侧表示怪兽不存在的场合或者只有「反叛曲机器人」怪兽的场合，这张卡可以从手卡特殊召唤。
-- ②：自己·对方的主要阶段，这张卡是和「反叛曲机器人」连接怪兽连接状态的场合，支付500基本分，以对方场上1只怪兽为对象才能发动。那只怪兽和这张卡破坏。
local s,id,o=GetID()
-- 初始化卡片效果：注册①的从手卡特殊召唤的特殊召唤规则效果（场上区域、不可复制、1回合1次），以及②的在主要怪兽区发动的诱发即时破坏效果（取对象、1回合1次）
function s.initial_effect(c)
	-- 这个卡名的①的方法的特殊召唤1回合只能有1次，①：自己场上的表侧表示怪兽不存在的场合或者只有「反叛曲机器人」怪兽的场合，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.spcon)
	c:RegisterEffect(e1)
	-- ②的效果1回合只能使用1次。②：自己·对方的主要阶段，这张卡是和「反叛曲机器人」连接怪兽连接状态的场合，支付500基本分，以对方场上1只怪兽为对象才能发动。那只怪兽和这张卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"破坏"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.descon)
	e2:SetCost(s.descost)
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
end
-- 过滤函数：判断该卡是否为自己场上表侧表示存在且不是「反叛曲机器人」卡（系列号0x1cf）的怪兽
function s.cfilter(c)
	return c:IsFaceup() and not c:IsSetCard(0x1cf)
end
-- ①效果特殊召唤的条件：自己场上存在可用的主要怪兽区格子，且不存在表侧表示的非「反叛曲机器人」怪兽（即场上没有怪兽或只有「反叛曲机器人」怪兽）
function s.spcon(e,c)
	if c==nil then return true end
	-- 检查自己场上主要怪兽区是否有可用的空格
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
		-- 检查自己怪兽区不存在表侧表示的非「反叛曲机器人」怪兽
		and not Duel.IsExistingMatchingCard(s.cfilter,c:GetControler(),LOCATION_MZONE,0,1,nil)
end
-- 过滤函数：判断该卡是否为表侧表示的「反叛曲机器人」连接怪兽
function s.ecfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x1cf) and c:IsType(TYPE_LINK)
end
-- ②效果的发动条件：当前为主要阶段，且这张卡与场上表侧表示的「反叛曲机器人」连接怪兽处于连接状态（这张卡位于其连接区或相互连接）
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 不在主要阶段的场合，不能发动此效果
	if not Duel.IsMainPhase() then return false end
	-- 检索双方怪兽区所有表侧表示的「反叛曲机器人」连接怪兽
	local lg=Duel.GetMatchingGroup(s.ecfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	local lg2=Group.CreateGroup()
	-- 遍历每一只「反叛曲机器人」连接怪兽
	for lc in aux.Next(lg) do
		lg2:Merge(lc:GetLinkedGroup())
	end
	return lg2 and lg2:IsContains(e:GetHandler())
end
-- ②效果的代价：检查并支付500基本分
function s.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动可行性检查时，确认玩家能支付500基本分
	if chk==0 then return Duel.CheckLPCost(tp,500) end
	-- 支付500基本分作为发动代价
	Duel.PayLPCost(tp,500)
end
-- ②效果的取对象处理：确认对方场上存在可以成为对象的怪兽，提示并选择对方场上1只怪兽作为对象，再将这张卡一并加入破坏的处理对象并设置破坏的操作信息
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) end
	-- 发动可行性检查时，确认对方场上存在至少1只可以成为效果对象的怪兽
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_MZONE,1,nil) end
	-- 向发动玩家显示「请选择要破坏的卡」的选卡提示
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家选择对方场上1只怪兽作为效果对象
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_MZONE,1,1,nil)
	g:AddCard(e:GetHandler())
	-- 设置本次连锁的操作信息：确定要破坏的卡为对象怪兽和这张卡共2张
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,2,0,0)
end
-- ②效果的处理：这张卡和对象怪兽均与连锁关联且对象仍为怪兽的场合，将它们组成卡片组并以效果破坏
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得当前连锁的对象怪兽
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToChain() and tc:IsRelateToChain() and tc:IsType(TYPE_MONSTER) then
		local g=Group.FromCards(c,tc)
		-- 将这张卡和对象怪兽以效果破坏
		Duel.Destroy(g,REASON_EFFECT)
	end
end
