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
	-- 使该卡在场上或墓地时视为「天空的圣域」
	aux.EnableChangeCode(c,56433456,LOCATION_SZONE+LOCATION_GRAVE)
	-- 只要这张卡在魔法与陷阱区域存在，场上的天使族怪兽的攻击力·守备力上升300
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	-- 选择目标为天使族怪兽
	e3:SetTarget(aux.TargetBoolFunction(Card.IsRace,RACE_FAIRY))
	e3:SetValue(300)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e4)
	-- 只要这张卡在魔法与陷阱区域存在，场上盖放的魔法·陷阱卡不会成为效果的对象
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e5:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e5:SetRange(LOCATION_SZONE)
	e5:SetTargetRange(LOCATION_SZONE,LOCATION_SZONE)
	-- 选择目标为里侧表示的卡
	e5:SetTarget(aux.TargetBoolFunction(Card.IsPosition,POS_FACEDOWN))
	e5:SetValue(1)
	c:RegisterEffect(e5)
	local e6=e5:Clone()
	e6:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e6:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	c:RegisterEffect(e6)
	-- 1回合1次，从自己墓地的天使族怪兽以及反击陷阱卡之中以合计3张为对象才能发动
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
-- 过滤满足条件的卡片：为天使族或反击陷阱且能回到卡组
function c15449853.tdfilter(c,e)
	return (c:IsRace(RACE_FAIRY) or c:IsType(TYPE_COUNTER)) and c:IsAbleToDeck() and (not e or c:IsCanBeEffectTarget(e))
end
-- 检索满足条件的卡片组并选择3张不同卡名的卡片
function c15449853.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 获取满足条件的卡片组
	local g=Duel.GetMatchingGroup(c15449853.tdfilter,tp,LOCATION_GRAVE,0,nil,e)
	if chk==0 then return g:GetClassCount(Card.GetCode)>=3 end
	-- 提示玩家选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 从符合条件的卡片中选择3张不同卡名的卡片
	local tg=g:SelectSubGroup(tp,aux.dncheck,false,3,3)
	-- 设置选中的卡片为目标
	Duel.SetTargetCard(tg)
	-- 设置操作信息为将目标卡片送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,tg,tg:GetCount(),0,0)
end
-- 执行将目标卡片送回卡组并排序的操作
function c15449853.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中设置的目标卡片并筛选出与当前效果相关的卡片
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if tg:GetCount()==0 then return end
	-- 将目标卡片送回卡组顶部
	if Duel.SendtoDeck(tg,nil,SEQ_DECKTOP,REASON_EFFECT)==0 then return end
	-- 统计实际被送回卡组的卡片数量
	local ct=Duel.GetOperatedGroup():FilterCount(Card.IsLocation,nil,LOCATION_DECK)
	-- 若送回卡组的卡片数量大于0，则对玩家卡组顶部进行排序
	if ct>0 then Duel.SortDecktop(tp,tp,ct) end
end
