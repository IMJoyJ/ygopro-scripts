--E・HERO ストーム・ネオス
-- 效果：
-- 「元素英雄 新宇侠」＋「新空间侠·水波海豚」＋「新空间侠·天空蜂鸟」
-- 把自己场上存在的上记的卡回到卡组的场合才能从额外卡组特殊召唤（不需要「融合」）。1回合只有1次在自己的主要阶段时可以把场上的魔法·陷阱卡全部破坏。结束阶段时这张卡回到额外卡组。这个效果回到额外卡组时，场上存在的全部卡回到卡组洗切。
function c49352945.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡登记通常融合召唤手续：融合素材指定为「元素英雄 新宇侠」（89943723）、「新空间侠·水波海豚」（17955766）、「新空间侠·天空蜂鸟」（54959865）；后两个 false 表示不使用融合素材代用品且不附带其他融合条件修改。
	aux.AddFusionProcCode3(c,89943723,17955766,54959865,false,false)
	-- 注册接触融合特殊召唤手续：素材取自己场上能够作为融合素材送回卡组/额外卡组的怪兽（Card.IsAbleToDeckOrExtraAsCost），对方场上不可选；素材处理为将素材送回持有者卡组并洗牌，从而可以不使用「融合」魔法直接进行融合召唤。
	aux.AddContactFusionProcedure(c,Card.IsAbleToDeckOrExtraAsCost,LOCATION_ONFIELD,0,aux.ContactFusionSendToDeck(c))
	-- 对应效果原文：「把自己场上存在的上记的卡回到卡组的场合才能从额外卡组特殊召唤（不需要「融合」）」；该效果设置特殊召唤条件，限制此卡只能从额外卡组进行特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(c49352945.splimit)
	c:RegisterEffect(e1)
	-- 调用通用函数为这张卡注册「新空间」融合怪兽的结束阶段回额外卡组效果（返回两个触发效果 e3、e4），并以 c49352945.retop 作为回额外卡组时的处理操作，同时 e3/e4 会被关联到后续全场回卡组的触发效果上。
	local e3,e4=aux.EnableNeosReturn(c,c49352945.retop)
	-- 对应效果原文：「1回合只有1次在自己的主要阶段时可以把场上的魔法·陷阱卡全部破坏。」
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(49352945,1))  --"魔陷破坏"
	e5:SetCategory(CATEGORY_DESTROY)
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCountLimit(1)
	e5:SetTarget(c49352945.destg)
	e5:SetOperation(c49352945.desop)
	c:RegisterEffect(e5)
	-- 对应效果原文：「这个效果回到额外卡组时，场上存在的全部卡回到卡组洗切。」
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(49352945,2))  --"返回卡组"
	e6:SetCategory(CATEGORY_TODECK)
	e6:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e6:SetCode(EVENT_TO_DECK)
	e6:SetCondition(c49352945.tdcon)
	e6:SetTarget(c49352945.tdtg)
	e6:SetOperation(c49352945.tdop)
	c:RegisterEffect(e6)
	e3:SetLabelObject(e6)
	e4:SetLabelObject(e6)
end
c49352945.material_setcode=0x8
-- 特殊召唤条件判定函数：仅当此卡位于额外卡组时（即从额外卡组进行特殊召唤）才允许特殊召唤，从墓地、除外等区域不能特殊召唤。
function c49352945.splimit(e,se,sp,st)
	return not e:GetHandler():IsLocation(LOCATION_EXTRA)
end
-- 结束阶段回额外卡组的具体处理函数：若这张卡仍与该效果关联且不是里侧表示，则将其送回持有者卡组并洗切（额外卡组怪兽因此回到额外卡组）。
function c49352945.retop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	-- 以效果原因将这张卡送去持有者卡组，并标记需要洗牌；因为它是额外卡组怪兽，实际会回到额外卡组。
	Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
end
-- 破坏对象过滤器：只选择场上表侧或里侧的魔法卡和陷阱卡（类型为 SPELL+TRAP）作为可破坏对象。
function c49352945.desfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 魔陷破坏效果的发动目标函数：在发动时检查场上是否存在至少1张魔法/陷阱卡；若可以发动，则获取场上所有魔法/陷阱卡并设置操作信息，表明将破坏这些卡。
function c49352945.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性的检查：若场上双方合计存在至少1张魔法/陷阱卡，则返回 true，允许发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c49352945.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 取得场上所有魔法/陷阱卡的集合（不取对象），用于设置破坏操作信息和后续处理。
	local g=Duel.GetMatchingGroup(c49352945.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	-- 设置连锁操作信息：宣告本次效果会破坏集合 g 中的全部卡（数量为 g:GetCount()），用于对方是否能对应发动等判定。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 魔陷破坏效果的处理函数：效果处理时再次取得场上所有魔法/陷阱卡，并将其全部以效果原因破坏。
function c49352945.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前场上所有魔法/陷阱卡的集合，作为实际破坏的对象。
	local g=Duel.GetMatchingGroup(c49352945.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	-- 将集合 g 中的所有卡以「效果」为破坏原因执行破坏。
	Duel.Destroy(g,REASON_EFFECT)
end
-- 触发条件判定：检查导致本卡回卡组的那个效果的 LabelObject 是否就是当前效果 e6，以确认本卡确实是因为「新空间回归」效果回额外卡组，只有此时才触发全场回卡组效果。
function c49352945.tdcon(e,tp,eg,ep,ev,re,r,rp)
	return re:GetLabelObject()==e
end
-- 全场回卡组效果的目标函数：发动时无条件返回 true，然后取得场上所有能够回卡组的卡，并设置操作信息，宣告将把这些卡全部送回卡组并洗切。
function c49352945.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取双方场上所有符合「可以回到卡组」条件的卡集合，用于后续回卡组处理。
	local g=Duel.GetMatchingGroup(Card.IsAbleToDeck,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	-- 设置连锁操作信息：本次效果将把集合 g 中的全部卡（数量为 g:GetCount()）送回持有者卡组并洗切。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,0)
end
-- 全场回卡组效果的处理函数：效果处理时再次取得场上所有可以回卡组的卡，将它们全部以效果原因送回持有者卡组并洗切。
function c49352945.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取双方场上所有能够回卡组的卡集合，作为实际执行回卡组的对象。
	local g=Duel.GetMatchingGroup(Card.IsAbleToDeck,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	-- 以效果原因将集合 g 中的所有卡送回各自持有者的卡组，并洗切卡组。
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
end
