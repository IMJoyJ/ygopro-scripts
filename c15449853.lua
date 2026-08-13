--パーシアスの神域
-- 效果：
-- ①：这张卡的卡名只要在场上·墓地存在当作「天空的圣域」使用。
-- ②：只要这张卡在魔法与陷阱区域存在，场上的天使族怪兽的攻击力·守备力上升300，场上盖放的魔法·陷阱卡不会成为效果的对象，不会被效果破坏。
-- ③：1回合1次，从自己墓地的天使族怪兽以及反击陷阱卡之中以合计3张为对象才能发动（同名卡最多1张）。那些卡用喜欢的顺序回到卡组上面。
function c15449853.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 效果①：让此卡在魔法与陷阱区域·墓地中卡名当作「天空的圣域」（卡号56433456）使用。
	aux.EnableChangeCode(c,56433456,LOCATION_SZONE+LOCATION_GRAVE)
	-- ②：只要这张卡在魔法与陷阱区域存在，场上的天使族怪兽的攻击力·守备力上升300
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	-- 指定攻击力提升效果只适用于场上的天使族怪兽（效果对象为天使族怪兽）。
	e3:SetTarget(aux.TargetBoolFunction(Card.IsRace,RACE_FAIRY))
	e3:SetValue(300)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e4)
	-- ②：场上盖放的魔法·陷阱卡不会被效果破坏
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e5:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e5:SetRange(LOCATION_SZONE)
	e5:SetTargetRange(LOCATION_SZONE,LOCATION_SZONE)
	-- 设定该保护效果只适用于里侧表示的魔法·陷阱卡（即场上盖放的魔法·陷阱卡）。
	e5:SetTarget(aux.TargetBoolFunction(Card.IsPosition,POS_FACEDOWN))
	e5:SetValue(1)
	c:RegisterEffect(e5)
	local e6=e5:Clone()
	e6:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e6:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	c:RegisterEffect(e6)
	-- ③：1回合1次，从自己墓地的天使族怪兽以及反击陷阱卡之中以合计3张为对象才能发动（同名卡最多1张）。那些卡用喜欢的顺序回到卡组上面。
	local e7=Effect.CreateEffect(c)
	e7:SetCategory(CATEGORY_TODECK)
	e7:SetType(EFFECT_TYPE_IGNITION)
	e7:SetRange(LOCATION_SZONE)
	e7:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e7:SetCountLimit(1)
	e7:SetTarget(c15449853.tdtg)
	e7:SetOperation(c15449853.tdop)
	c:RegisterEffect(e7)
end
-- 筛选③可选的对象：自己墓地的天使族怪兽或反击陷阱卡，且能够返回卡组；若传入效果e，还需能成为该效果的对象（取对象判定）。
function c15449853.tdfilter(c,e)
	return (c:IsRace(RACE_FAIRY) or c:IsType(TYPE_COUNTER)) and c:IsAbleToDeck() and (not e or c:IsCanBeEffectTarget(e))
end
-- ③的发动时点处理：检查自己墓地中是否存在至少3种卡名的可选卡；存在则让玩家选择3张（同名卡最多1张）作为对象，并登记回卡组的操作信息。
function c15449853.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 获取自己墓地中所有满足③对象条件的卡（天使族怪兽或反击陷阱卡且可返回卡组且可成为效果对象）。
	local g=Duel.GetMatchingGroup(c15449853.tdfilter,tp,LOCATION_GRAVE,0,nil,e)
	if chk==0 then return g:GetClassCount(Card.GetCode)>=3 end
	-- 向玩家显示“请选择要返回卡组的卡”的选择提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 让玩家从可选卡中选出3张，并通过aux.dncheck保证所选卡卡名互不相同（同名卡最多1张）。
	local tg=g:SelectSubGroup(tp,aux.dncheck,false,3,3)
	-- 将选中的3张卡登记为当前连锁的效果对象，作为取对象效果的对象。
	Duel.SetTargetCard(tg)
	-- 登记操作信息：本次效果将所选对象卡返回卡组（CATEGORY_TODECK），数量为所选卡的张数。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,tg,tg:GetCount(),0,0)
end
-- ③的效果处理：取出对象卡并筛选仍与效果相关的卡，将其送回持有者卡组顶端；若成功送回，则让发动者对卡组顶部的这些卡按喜欢的顺序排序。
function c15449853.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁登记的效果对象，并筛选出仍然与效果相关的对象（未离场或未失效）。
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if tg:GetCount()==0 then return end
	-- 将这些对象卡以效果原因送回各自持有者卡组的最顶端；若实际返回数量为0则效果处理中止。
	if Duel.SendtoDeck(tg,nil,SEQ_DECKTOP,REASON_EFFECT)==0 then return end
	-- 统计上一步实际被送回卡组的卡的数量（以当前位于卡组区域为准）。
	local ct=Duel.GetOperatedGroup():FilterCount(Card.IsLocation,nil,LOCATION_DECK)
	-- 若确实有卡被放回卡组顶端，则让发动者tp对这些卡组顶部的卡按喜欢的顺序进行排列，实现“用喜欢的顺序回到卡组上面”。
	if ct>0 then Duel.SortDecktop(tp,tp,ct) end
end
