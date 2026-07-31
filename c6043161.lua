--R.B.GA１０ドリラー
-- 效果：
-- 自己场上的表侧表示怪兽不存在的场合或者只有「奏悦机组」怪兽的场合，这张卡可以从手卡特殊召唤。自己对「奏悦机组 筑工钻机」的这个方法的特殊召唤1回合只能有1次。
-- 主要阶段，这张卡在「奏悦机组」连接怪兽所连接区存在的场合（诱发即时效果）：可以支付500基本分，以对方场上1只怪兽为对象；那只怪兽和这张卡破坏。「奏悦机组 筑工钻机」的这个效果1回合只能使用1次。
local s,id,o=GetID()
-- 初始化卡片效果：注册①手牌规则特召、②主要阶段连接区炸怪效果
function s.initial_effect(c)
	-- 自己场上没有表侧怪兽或只有「奏悦机组」怪兽的场合，此卡可以从手牌特殊召唤（1回合1次）
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.spcon)
	c:RegisterEffect(e1)
	-- ①：主要阶段，此卡在「奏悦机组」连接怪兽所连接区存在的场合，支付500LP，以对方场上1只怪兽为对象才能发动。那只怪兽和这张卡破坏。
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
-- 过滤条件：非「奏悦机组」字段的表侧表示怪兽
function s.cfilter(c)
	return c:IsFaceup() and not c:IsSetCard(0x1cf)
end
-- 手牌特召条件：怪兽区有空位且场上没有非「奏悦机组」的表侧表示怪兽
function s.spcon(e,c)
	if c==nil then return true end
	-- 检查主要怪兽区域是否有空位
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
		-- 且自己场上不存在非「奏悦机组」的表侧表示怪兽
		and not Duel.IsExistingMatchingCard(s.cfilter,c:GetControler(),LOCATION_MZONE,0,1,nil)
end
-- 过滤条件：表侧表示的「奏悦机组」连接怪兽
function s.ecfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x1cf) and c:IsType(TYPE_LINK)
end
-- 破坏效果发动条件：主要阶段且此卡在「奏悦机组」连接怪兽的连接区
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前是否为主要阶段
	if not Duel.IsMainPhase() then return false end
	-- 获取场上所有的表侧表示「奏悦机组」连接怪兽
	local lg=Duel.GetMatchingGroup(s.ecfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	local lg2=Group.CreateGroup()
	-- 遍历连接怪兽并合并它们的所连接区域
	for lc in aux.Next(lg) do
		lg2:Merge(lc:GetLinkedGroup())
	end
	return lg2 and lg2:IsContains(e:GetHandler())
end
-- 效果Cost：支付500基本分
function s.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- Cost检查：判断是否能支付500基本分
	if chk==0 then return Duel.CheckLPCost(tp,500) end
	-- 支付500基本分
	Duel.PayLPCost(tp,500)
end
-- 破坏效果发动准备：选择对方场上1只怪兽为对象
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) end
	-- 发动条件检查：对方场上是否存在怪兽
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上1只怪兽作为对象
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_MZONE,1,1,nil)
	g:AddCard(e:GetHandler())
	-- 设置连锁操作信息：破坏2张卡（目标怪兽与自身）
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,2,0,0)
end
-- 破坏效果处理：将目标怪兽和这张卡破坏
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取选中的目标怪兽
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToChain() and tc:IsRelateToChain() and tc:IsType(TYPE_MONSTER) then
		local g=Group.FromCards(c,tc)
		-- 将选中的怪兽和这张卡破坏
		Duel.Destroy(g,REASON_EFFECT)
	end
end
