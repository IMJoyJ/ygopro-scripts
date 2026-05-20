--R.B. Ga10 Driller
-- 效果：
-- 自己场上的表侧表示怪兽不存在的场合或者只有「奏悦机组」怪兽的场合，这张卡可以从手卡特殊召唤。自己对「奏悦机组 筑工钻机」的这个方法的特殊召唤1回合只能有1次。
-- 主要阶段，这张卡在「奏悦机组」连接怪兽所连接区存在的场合（诱发即时效果）：可以支付500基本分，以对方场上1只怪兽为对象；那只怪兽和这张卡破坏。「奏悦机组 筑工钻机」的这个效果1回合只能使用1次。
local s,id,o=GetID()
-- 注册卡片效果：①手卡特召规则，②主要阶段诱发即时破坏效果。
function s.initial_effect(c)
	-- 自己场上的表侧表示怪兽不存在的场合或者只有「奏悦机组」怪兽的场合，这张卡可以从手卡特殊召唤。自己对「奏悦机组 筑工钻机」的这个方法的特殊召唤1回合只能有1次。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.spcon)
	c:RegisterEffect(e1)
	-- 主要阶段，这张卡在「奏悦机组」连接怪兽所连接区存在的场合（诱发即时效果）：可以支付500基本分，以对方场上1只怪兽为对象；那只怪兽和这张卡破坏。「奏悦机组 筑工钻机」的这个效果1回合只能使用1次。
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
-- 过滤条件：场上表侧表示且不属于「奏悦机组」系列的怪兽。
function s.cfilter(c)
	return c:IsFaceup() and not c:IsSetCard(0x1cf)
end
-- 特殊召唤规则的条件判定。
function s.spcon(e,c)
	if c==nil then return true end
	-- 检查自己场上是否有可用的怪兽区域。
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
		-- 检查自己场上是否不存在非「奏悦机组」的表侧表示怪兽。
		and not Duel.IsExistingMatchingCard(s.cfilter,c:GetControler(),LOCATION_MZONE,0,1,nil)
end
-- 过滤条件：场上表侧表示的「奏悦机组」连接怪兽。
function s.ecfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x1cf) and c:IsType(TYPE_LINK)
end
-- 破坏效果的发动条件判定。
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 限制只能在双方的主要阶段发动。
	if not Duel.IsMainPhase() then return false end
	-- 获取场上所有的「奏悦机组」连接怪兽。
	local lg=Duel.GetMatchingGroup(s.ecfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	local lg2=Group.CreateGroup()
	-- 遍历这些连接怪兽，合并它们所指向的连接区怪兽组。
	for lc in aux.Next(lg) do
		lg2:Merge(lc:GetLinkedGroup())
	end
	return lg2 and lg2:IsContains(e:GetHandler())
end
-- 支付500基本分的发动代价处理。
function s.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家当前的基本分是否足够支付500点。
	if chk==0 then return Duel.CheckLPCost(tp,500) end
	-- 扣除发动效果所需的500点基本分。
	Duel.PayLPCost(tp,500)
end
-- 破坏效果的对象选择与效果分类注册。
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) end
	-- 检查对方场上是否存在可以作为对象的怪兽。
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_MZONE,1,nil) end
	-- 在客户端显示“请选择要破坏的卡”的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上1只怪兽作为效果的对象。
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_MZONE,1,1,nil)
	g:AddCard(e:GetHandler())
	-- 设置效果处理信息：破坏包含自身和对象怪兽在内的2张卡。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,2,0,0)
end
-- 破坏效果的处理逻辑。
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取本次效果发动的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToChain() and tc:IsRelateToChain() and tc:IsType(TYPE_MONSTER) then
		local g=Group.FromCards(c,tc)
		-- 将自身和对象怪兽因效果破坏。
		Duel.Destroy(g,REASON_EFFECT)
	end
end
