--神碑の泉
-- 效果：
-- ①：只要这张卡在场地区域存在，自己在对方回合可以把「神碑」速攻魔法卡从手卡发动。
-- ②：1回合1次，自己把「神碑」速攻魔法卡发动的场合，以自己墓地最多3张「神碑」速攻魔法卡为对象才能发动。那些卡用喜欢的顺序回到卡组下面。那之后，自己从卡组抽出回去的数量。
local s,id,o=GetID()
-- 初始化效果注册：注册场地魔法卡的发动效果、在对方回合从手卡发动「神碑」速攻魔法的效果，以及自己发动「神碑」速攻魔法时回收墓地卡片并抽卡的效果。
function s.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：只要这张卡在场地区域存在，自己在对方回合可以把「神碑」速攻魔法卡从手卡发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"适用「神碑之泉」的效果来发动"
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_QP_ACT_IN_NTPHAND)
	e2:SetRange(LOCATION_FZONE)
	-- 设置允许从手卡发动的卡片过滤条件为「神碑」卡片（即「神碑」速攻魔法卡）。
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x17f))
	e2:SetTargetRange(LOCATION_HAND,0)
	c:RegisterEffect(e2)
	-- ②：1回合1次，自己把「神碑」速攻魔法卡发动的场合，以自己墓地最多3张「神碑」速攻魔法卡为对象才能发动。那些卡用喜欢的顺序回到卡组下面。那之后，自己从卡组抽出回去的数量。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))  --"回收并抽卡"
	e3:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_CHAINING)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(s.condition)
	e3:SetTarget(s.target)
	e3:SetOperation(s.operation)
	c:RegisterEffect(e3)
end
-- 检查效果发动的条件：必须是自己发动了「神碑」速攻魔法卡的效果。
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return rp==tp and re:IsActiveType(TYPE_SPELL) and re:IsActiveType(TYPE_QUICKPLAY) and re:IsHasType(EFFECT_TYPE_ACTIVATE)
		and re:GetHandler():IsSetCard(0x17f)
end
-- 过滤函数：筛选自己墓地中属于「神碑」且是速攻魔法、并且可以回到卡组的卡片。
function s.filter(c)
	return c:IsSetCard(0x17f) and c:IsType(TYPE_QUICKPLAY) and c:IsAbleToDeck()
end
-- 效果发动的对象选择与可行性检查：检查是否能抽卡，以及墓地是否存在符合条件的卡，并选择1到3张目标卡。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.filter(chkc) end
	-- 检查发动时玩家是否可以进行抽卡。
	if chk==0 then return Duel.IsPlayerCanDraw(tp)
		-- 检查自己墓地是否存在至少1张符合过滤条件的卡片。
		and Duel.IsExistingTarget(s.filter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 在界面上提示玩家选择要返回卡组的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 让玩家选择自己墓地1到3张符合条件的卡片作为效果的对象。
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_GRAVE,0,1,3,nil)
	-- 设置操作信息：预计将选中的卡片送回卡组。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,#g,0,0)
	-- 设置操作信息：预计自己从卡组抽出与返回卡组数量相同的卡片。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,#g)
end
-- 效果处理：将对象卡片送回卡组最上方，由玩家排序后依次移至卡组最下方，最后抽对应数量的卡。
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中仍与此效果相关的对象卡片组。
	local sg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if #sg==0 then return end
	-- 将这些对象卡片送回持有者的卡组最上方。
	Duel.SendtoDeck(sg,nil,SEQ_DECKTOP,REASON_EFFECT)
	-- 获取上一步操作中实际被送回卡组的卡片组。
	local og=Duel.GetOperatedGroup()
	local ct=og:FilterCount(Card.IsLocation,nil,LOCATION_DECK)
	if ct==0 then return end
	-- 让玩家对卡组最上方的这些卡片按喜欢的顺序进行排序。
	Duel.SortDecktop(tp,tp,ct)
	for i=1,ct do
		-- 获取卡组最上方的一张卡片。
		local mg=Duel.GetDecktopGroup(tp,1)
		-- 将该卡片移动到卡组的最下方（通过循环实现将排序后的卡片整体移至卡组最下方）。
		Duel.MoveSequence(mg:GetFirst(),1)
	end
	-- 中断当前效果处理，使后续的抽卡处理与返回卡组不视为同时进行。
	Duel.BreakEffect()
	-- 让玩家因效果从卡组抽出与实际返回卡组数量相同的卡片。
	Duel.Draw(tp,ct,REASON_EFFECT)
end
