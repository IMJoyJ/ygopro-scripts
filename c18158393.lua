--伍世壊浄心
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己场上有同调怪兽存在，怪兽的效果·魔法·陷阱卡发动时才能发动。那个发动无效。自己的场上或者墓地有「维萨斯-斯塔弗罗斯特」或者攻击力1500/守备力2100的怪兽存在的场合，可以再把那张无效的卡破坏。
-- ②：把墓地的这张卡除外，以自己墓地最多3只「末那愚子族」怪兽为对象才能发动。那些怪兽回到卡组。
local s,id,o=GetID()
-- 定义本卡初始化函数：注册①、②两个效果。①作为魔法·陷阱卡的发动，在效果发动时将其无效并可选破坏；②在墓地除外自身，选最多3只「末那愚子族」怪兽回卡组。两个效果均设置1回合各能使用1次（对应“这个卡名的①②的效果1回合各能使用1次”）。
function s.initial_effect(c)
	-- 将卡号56099748（「维萨斯-斯塔弗罗斯特」）登记到本卡，使本卡成为记载有该卡名的卡，满足规则上相关检索/关联判定。
	aux.AddCodeList(c,56099748)
	-- ①：自己场上有同调怪兽存在，怪兽的效果·魔法·陷阱卡发动时才能发动。那个发动无效。自己的场上或者墓地有「维萨斯-斯塔弗罗斯特」或者攻击力1500/守备力2100的怪兽存在的场合，可以再把那张无效的卡破坏。
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
	-- 设定②效果发动时，将墓地的这张卡除外作为发动代价。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.tdtg)
	e2:SetOperation(s.tdop)
	c:RegisterEffect(e2)
end
-- 判断①效果的发动条件：自己场上有表侧表示的同调怪兽存在，且当前发动的效果为怪兽效果或魔法·陷阱卡的发动，并且该发动可以被无效。
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己主要怪兽区是否存在至少1张表侧表示的同调怪兽。
	return Duel.IsExistingMatchingCard(aux.AND(Card.IsFaceup,Card.IsType),tp,LOCATION_MZONE,0,1,nil,TYPE_SYNCHRO)
		-- 确认被连锁的效果是怪兽效果或魔法·陷阱卡的发动，且该连锁可以被打断/无效。
		and (re:IsActiveType(TYPE_MONSTER) or re:IsHasType(EFFECT_TYPE_ACTIVATE)) and Duel.IsChainNegatable(ev)
end
-- ①效果的发动时点不指定对象，仅设置将连锁中的那张卡作为无效对象的操作信息。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将当前连锁中发动的卡（eg）写入操作信息，类别为无效发动，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end
-- 定义可选破坏的判定条件：场上或墓地表侧表示的「维萨斯-斯塔弗罗斯特」，或攻击力1500且守备力2100的怪兽。
function s.filter(c)
	local b1=c:IsCode(56099748)
	local b2=c:IsAttack(1500) and c:IsDefense(2100)
	return c:IsFaceup() and (b1 or b2)
end
-- 处理①效果：先无效该发动；若自己场上/墓地存在上述符合条件的怪兽，且被无效的那张卡仍与效果关联，则询问玩家是否将其破坏，选择是则进行破坏。
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 若无效该发动的处理失败（例如该发动已无法被无效），则终止后续操作。
	if not Duel.NegateActivation(ev) then return end
	-- 检查自己场上或墓地是否存在至少1张满足条件的怪兽（「维萨斯-斯塔弗罗斯特」或攻1500/防2100的怪兽）。
	if Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_ONFIELD+LOCATION_GRAVE,0,1,nil)
		and re:GetHandler():IsRelateToEffect(re)
		-- 弹出“是否把那张无效的卡破坏？”的确认提示，由玩家选择是否破坏。
		and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then  --"是否把那张无效的卡破坏？"
		-- 用BreakEffect将后续的破坏处理与之前的无效处理分离，避免时点被占用，使破坏不作为同一效果处理。
		Duel.BreakEffect()
		-- 以效果原因破坏被无效的那张卡（eg即连锁发动的卡）。
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
-- 定义②效果可选对象的过滤条件：持有「末那愚子族」字段的怪兽，且能够从墓地返回卡组。
function s.tdfilter(c)
	return c:IsSetCard(0x190) and c:IsType(TYPE_MONSTER) and c:IsAbleToDeck()
end
-- ②效果发动时的取对象处理：从自己墓地选择1~3只符合条件的「末那愚子族」怪兽作为对象，并设置回卡组的操作信息。
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.tdfilter(chkc) end
	-- 在合法性检查时，确认自己墓地存在至少1张符合条件的对象，且不能选择发动效果的本卡（它已除外不在墓地）。
	if chk==0 then return Duel.IsExistingTarget(s.tdfilter,tp,LOCATION_GRAVE,0,1,e:GetHandler()) end
	-- 显示选择卡片的提示信息，提示文字为“请选择要返回卡组的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择自己墓地1~3张符合条件的「末那愚子族」怪兽作为效果对象，并自动与当前连锁关联。
	local g=Duel.SelectTarget(tp,s.tdfilter,tp,LOCATION_GRAVE,0,1,3,nil)
	-- 设置操作信息，类别为返回卡组，数量为选择的对象数。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,0)
end
-- ②效果处理：取得仍与本效果关联的对象卡，将它们返回持有者卡组，并触发洗牌。
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中仍与该效果相关的对象卡（即取对象阶段选择的卡，若离场或失效则不包含）。
	local g=Duel.GetTargetsRelateToChain()
	if g:GetCount()>0 then
		-- 将这些对象卡以效果原因送回持有者卡组，表示“回到卡组”并洗牌。
		Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
