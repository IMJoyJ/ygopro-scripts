--伍世壊浄心
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己场上有同调怪兽存在，怪兽的效果·魔法·陷阱卡发动时才能发动。那个发动无效。自己的场上或者墓地有「维萨斯-斯塔弗罗斯特」或者攻击力1500/守备力2100的怪兽存在的场合，可以再把那张无效的卡破坏。
-- ②：把墓地的这张卡除外，以自己墓地最多3只「末那愚子族」怪兽为对象才能发动。那些怪兽回到卡组。
local s,id,o=GetID()
-- 注册卡片的初始效果，包括①②两个效果的定义
function s.initial_effect(c)
	-- 记录该卡拥有「维萨斯-斯塔弗罗斯特」的卡名
	aux.AddCodeList(c,56099748)
	-- ①：自己场上有同调怪兽存在，怪兽的效果·魔法·陷阱卡发动时才能发动。那个发动无效。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外，以自己墓地最多3只「末那愚子族」怪兽为对象才能发动。那些怪兽回到卡组。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetHintTiming(0,TIMING_END_PHASE)
	e2:SetCountLimit(1,id+o)
	-- 效果发动时需要将此卡从墓地除外作为费用
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.tdtg)
	e2:SetOperation(s.tdop)
	c:RegisterEffect(e2)
end
-- 效果发动的条件：自己场上存在同调怪兽，且发动的卡为怪兽效果或魔法/陷阱卡，且该连锁可以被无效
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在至少1只同调怪兽
	return Duel.IsExistingMatchingCard(aux.AND(Card.IsFaceup,Card.IsType),tp,LOCATION_MZONE,0,1,nil,TYPE_SYNCHRO)
		-- 检查发动的卡是否为怪兽效果或魔法/陷阱卡，且该连锁可以被无效
		and (re:IsActiveType(TYPE_MONSTER) or re:IsHasType(EFFECT_TYPE_ACTIVATE)) and Duel.IsChainNegatable(ev)
end
-- 设置效果处理时的提示信息，表示将使发动无效
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置效果处理时的提示信息，表示将使发动无效
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end
-- 定义用于判断是否为「维萨斯-斯塔弗罗斯特」或攻击力1500/守备力2100的怪兽的过滤函数
function s.filter(c)
	local b1=c:IsCode(56099748)
	local b2=c:IsAttack(1500) and c:IsDefense(2100)
	return c:IsFaceup() and (b1 or b2)
end
-- 效果处理函数：使连锁发动无效，若满足条件则破坏被无效的卡
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 尝试使连锁发动无效，若失败则返回
	if not Duel.NegateActivation(ev) then return end
	-- 检查自己场上或墓地是否存在符合条件的怪兽（维萨斯或攻击力1500/守备力2100）
	if Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_ONFIELD+LOCATION_GRAVE,0,1,nil)
		and re:GetHandler():IsRelateToEffect(re)
		-- 询问玩家是否破坏被无效的卡
		and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then  --"是否把那张无效的卡破坏？"
		-- 中断当前效果处理，使后续处理视为不同时处理
		Duel.BreakEffect()
		-- 将被无效的卡破坏
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
-- 定义用于判断是否为「末那愚子族」怪兽且可送回卡组的过滤函数
function s.tdfilter(c)
	return c:IsSetCard(0x190) and c:IsType(TYPE_MONSTER) and c:IsAbleToDeck()
end
-- 设置②效果的发动条件和目标选择逻辑
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.tdfilter(chkc) end
	-- 检查自己墓地是否存在至少1张符合条件的怪兽
	if chk==0 then return Duel.IsExistingTarget(s.tdfilter,tp,LOCATION_GRAVE,0,1,e:GetHandler()) end
	-- 提示玩家选择要送回卡组的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择1~3张符合条件的怪兽作为目标
	local g=Duel.SelectTarget(tp,s.tdfilter,tp,LOCATION_GRAVE,0,1,3,nil)
	-- 设置效果处理时的提示信息，表示将怪兽送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,0)
end
-- ②效果的处理函数：将目标怪兽送回卡组
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取与当前连锁相关的处理目标
	local g=Duel.GetTargetsRelateToChain()
	if g:GetCount()>0 then
		-- 将目标怪兽送回卡组并洗牌
		Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
