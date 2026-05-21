--創星神 tierra
-- 效果：
-- 这张卡不能通常召唤。让这张卡以外的自己的手卡·场上的卡10种类回到持有者的卡组·额外卡组的场合才能特殊召唤。
-- ①：这张卡的特殊召唤不会被无效化。
-- ②：这张卡特殊召唤成功的场合发动。这张卡以外的双方的手卡·场上·墓地的卡以及额外卡组的表侧表示的灵摆怪兽全部回到持有者卡组。不能对应这个效果的发动让魔法·陷阱·怪兽的效果发动。
function c91588074.initial_effect(c)
	c:EnableReviveLimit()
	-- 让这张卡以外的自己的手卡·场上的卡10种类回到持有者的卡组·额外卡组的场合才能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c91588074.spcon)
	e1:SetTarget(c91588074.sptg)
	e1:SetOperation(c91588074.spop)
	c:RegisterEffect(e1)
	-- ①：这张卡的特殊召唤不会被无效化。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_CANNOT_DISABLE_SPSUMMON)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	c:RegisterEffect(e2)
	-- 这张卡不能通常召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e3)
	-- ②：这张卡特殊召唤成功的场合发动。这张卡以外的双方的手卡·场上·墓地的卡以及额外卡组的表侧表示的灵摆怪兽全部回到持有者卡组。不能对应这个效果的发动让魔法·陷阱·怪兽的效果发动。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(91588074,0))
	e4:SetCategory(CATEGORY_TODECK)
	e4:SetType(EFFECT_TYPE_TRIGGER_F+EFFECT_TYPE_SINGLE)
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	e4:SetTarget(c91588074.tdtg)
	e4:SetOperation(c91588074.tdop)
	c:RegisterEffect(e4)
end
-- 特殊召唤规则的Condition函数：检查自己手牌·场上是否存在10种可以回到卡组·额外卡组的卡，且满足怪兽区域空位要求
function c91588074.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 过滤出自己手牌·场上除了这张卡以外、可以作为Cost回到卡组或额外卡组的卡片组
	local g=Duel.GetMatchingGroup(Card.IsAbleToDeckOrExtraAsCost,tp,LOCATION_HAND+LOCATION_ONFIELD,0,c)
	-- 设置卡片组检查的附加条件：卡片组内每张卡的卡名各不相同
	aux.GCheckAdditional=aux.dncheck
	-- 检查过滤出的卡片组中是否存在10张卡，满足“卡名各不相同”且在它们离开场后有足够的怪兽区域空位
	local res=g:CheckSubGroup(aux.mzctcheck,10,10,tp)
	-- 重置卡片组检查的附加条件
	aux.GCheckAdditional=nil
	return res
end
-- 特殊召唤规则的Target函数：让玩家选择10种手牌·场上的卡回到卡组·额外卡组
function c91588074.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 过滤出自己手牌·场上除了这张卡以外、可以作为Cost回到卡组或额外卡组的卡片组
	local g=Duel.GetMatchingGroup(Card.IsAbleToDeckOrExtraAsCost,tp,LOCATION_HAND+LOCATION_ONFIELD,0,c)
	-- 给玩家发送提示信息：请选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 设置卡片组选择的附加条件：卡片组内每张卡的卡名各不相同
	aux.GCheckAdditional=aux.dncheck
	-- 让玩家选择10张卡，满足“卡名各不相同”且在它们离开场后有足够的怪兽区域空位
	local sg=g:SelectSubGroup(tp,aux.mzctcheck,true,10,10,tp)
	-- 重置卡片组选择的附加条件
	aux.GCheckAdditional=nil
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 特殊召唤规则的Operation函数：将选中的10张卡送回持有者的卡组·额外卡组
function c91588074.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	local cg=g:Filter(Card.IsFacedown,nil)
	if cg:GetCount()>0 then
		-- 给对方玩家确认选中的卡片中处于里侧表示的卡
		Duel.ConfirmCards(1-tp,cg)
	end
	-- 将选中的卡送回持有者的卡组或额外卡组并洗牌
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_SPSUMMON)
	g:DeleteGroup()
end
-- 过滤函数：过滤出位于手牌、场上、墓地或额外卡组表侧表示的灵摆怪兽，且可以回到卡组的卡
function c91588074.tdfilter(c)
	return (c:IsLocation(0x1e) or (c:IsFaceup() and c:IsType(TYPE_PENDULUM))) and c:IsAbleToDeck()
end
-- 效果②的Target函数：设置操作信息为将双方所有其他卡回到卡组，并限制不能对应此效果发动任何效果
function c91588074.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 过滤出双方手牌、场上、墓地以及额外卡组表侧表示的灵摆怪兽中，除了这张卡以外可以回到卡组的所有卡
	local g=Duel.GetMatchingGroup(c91588074.tdfilter,tp,0x5e,0x5e,e:GetHandler())
	-- 设置当前处理的连锁操作信息：将上述卡片送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,0x5e)
	-- 设定连锁条件：不能对应这个效果的发动让魔法·陷阱·怪兽的效果发动
	Duel.SetChainLimit(aux.FALSE)
end
-- 效果②的Operation函数：将这张卡以外的双方手牌·场上·墓地的卡以及额外卡组表侧表示的灵摆怪兽全部送回持有者卡组
function c91588074.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 过滤出双方手牌、场上、墓地以及额外卡组表侧表示的灵摆怪兽中，除了作为效果源的这张卡以外可以回到卡组的所有卡
	local g=Duel.GetMatchingGroup(c91588074.tdfilter,tp,0x5e,0x5e,aux.ExceptThisCard(e))
	-- 检查是否受到「王家之谷-尼克罗谷」的影响，若有涉及墓地的操作被无效则直接返回
	if aux.NecroValleyNegateCheck(g) then return end
	-- 将符合条件的卡全部送回持有者卡组并洗牌
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
end
