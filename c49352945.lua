--E・HERO ストーム・ネオス
-- 效果：
-- 「元素英雄 新宇侠」＋「新空间侠·水波海豚」＋「新空间侠·天空蜂鸟」
-- 把自己场上存在的上记的卡回到卡组的场合才能从额外卡组特殊召唤（不需要「融合」）。1回合只有1次在自己的主要阶段时可以把场上的魔法·陷阱卡全部破坏。结束阶段时这张卡回到额外卡组。这个效果回到额外卡组时，场上存在的全部卡回到卡组洗切。
function c49352945.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加融合召唤手续，使用89943723、17955766、54959865三只怪兽作为融合素材
	aux.AddFusionProcCode3(c,89943723,17955766,54959865,false,false)
	-- 添加接触融合特殊召唤规则，要求将场上的符合条件的卡送回卡组作为召唤代价
	aux.AddContactFusionProcedure(c,Card.IsAbleToDeckOrExtraAsCost,LOCATION_ONFIELD,0,aux.ContactFusionSendToDeck(c))
	-- 特殊召唤条件限制：此卡不能从额外卡组特殊召唤（必须在额外卡组中才能发动）
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(c49352945.splimit)
	c:RegisterEffect(e1)
	-- 注册「新宇」系列怪兽共通的结束阶段返回卡组效果，包括强制和可选两种触发方式
	local e3,e4=aux.EnableNeosReturn(c,c49352945.retop)
	-- 1回合只有1次在自己的主要阶段时可以把场上的魔法·陷阱卡全部破坏
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(49352945,1))  --"魔陷破坏"
	e5:SetCategory(CATEGORY_DESTROY)
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCountLimit(1)
	e5:SetTarget(c49352945.destg)
	e5:SetOperation(c49352945.desop)
	c:RegisterEffect(e5)
	-- 结束阶段时这张卡回到额外卡组。这个效果回到额外卡组时，场上存在的全部卡回到卡组洗切
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
-- 限制此卡不能从额外卡组特殊召唤（必须在额外卡组中才能发动）
function c49352945.splimit(e,se,sp,st)
	return not e:GetHandler():IsLocation(LOCATION_EXTRA)
end
-- 当此卡因效果返回卡组时，将其送回卡组并洗牌
function c49352945.retop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	-- 将此卡送回卡组并洗牌
	Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
end
-- 定义魔法·陷阱卡的过滤函数
function c49352945.desfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 设置破坏效果的发动条件和目标
function c49352945.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在魔法·陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(c49352945.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 获取场上的魔法·陷阱卡作为破坏对象
	local g=Duel.GetMatchingGroup(c49352945.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	-- 设置连锁操作信息，指定要破坏的卡数量
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 执行破坏效果，将目标卡破坏
function c49352945.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取场上的魔法·陷阱卡作为破坏对象
	local g=Duel.GetMatchingGroup(c49352945.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	-- 将目标卡破坏
	Duel.Destroy(g,REASON_EFFECT)
end
-- 判断此卡是否因特定效果返回卡组
function c49352945.tdcon(e,tp,eg,ep,ev,re,r,rp)
	return re:GetLabelObject()==e
end
-- 设置返回卡组效果的目标和操作信息
function c49352945.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取场上的所有可送回卡组的卡
	local g=Duel.GetMatchingGroup(Card.IsAbleToDeck,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	-- 设置连锁操作信息，指定要送回卡组的卡数量
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,0)
end
-- 执行将目标卡送回卡组并洗牌的效果
function c49352945.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取场上的所有可送回卡组的卡
	local g=Duel.GetMatchingGroup(Card.IsAbleToDeck,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	-- 将目标卡送回卡组并洗牌
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
end
