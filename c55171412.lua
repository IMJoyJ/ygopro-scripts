--E・HERO アクア・ネオス
-- 效果：
-- 「元素英雄 新宇侠」＋「新空间侠·水波海豚」
-- 把自己场上存在的上记的卡回到卡组的场合才能从额外卡组特殊召唤（不需要「融合」）。丢弃1张手卡，随机选择对方的1张手卡破坏。这个效果1回合只能使用1次。结束阶段时这张卡回到额外卡组。
function c55171412.initial_effect(c)
	c:EnableReviveLimit()
	-- 设定融合素材为「元素英雄 新宇侠」和「新空间侠·水波海豚」
	aux.AddFusionProcCode2(c,89943723,17955766,false,false)
	-- 注册接触融合的特殊召唤规则（将自己场上的素材送回卡组）
	aux.AddContactFusionProcedure(c,Card.IsAbleToDeckOrExtraAsCost,LOCATION_ONFIELD,0,aux.ContactFusionSendToDeck(c))
	-- 把自己场上存在的上记的卡回到卡组的场合才能从额外卡组特殊召唤（不需要「融合」）。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(c55171412.splimit)
	c:RegisterEffect(e1)
	-- 注册新宇侠融合怪兽共通的结束阶段返回额外卡组效果
	aux.EnableNeosReturn(c,c55171412.retop)
	-- 丢弃1张手卡，随机选择对方的1张手卡破坏。这个效果1回合只能使用1次。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(55171412,1))  --"手牌破坏"
	e5:SetCategory(CATEGORY_DESTROY)
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCountLimit(1)
	e5:SetCost(c55171412.descost)
	e5:SetTarget(c55171412.destg)
	e5:SetOperation(c55171412.desop)
	c:RegisterEffect(e5)
end
c55171412.material_setcode=0x8
-- 限制该卡从额外卡组特殊召唤时，只能通过其自身规定的接触融合方式进行
function c55171412.splimit(e,se,sp,st)
	return not e:GetHandler():IsLocation(LOCATION_EXTRA)
end
-- 结束阶段将该卡送回额外卡组的具体操作函数
function c55171412.retop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) or e:GetHandler():IsFacedown() then return end
	-- 将自身送回持有者的额外卡组并洗牌
	Duel.SendtoDeck(e:GetHandler(),nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
end
-- 手牌破坏效果的发动代价（Cost）处理函数
function c55171412.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己手牌中是否存在可以丢弃的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	-- 让玩家选择并丢弃1张手牌作为发动代价
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 手牌破坏效果的目标（Target）处理函数
function c55171412.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方手牌中是否存在至少1张卡
	if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)>0 end
	-- 设置连锁信息，表明该效果将破坏对方手牌中的1张卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,1-tp,LOCATION_HAND)
end
-- 手牌破坏效果的效果处理（Operation）函数
function c55171412.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方手牌中的所有卡片
	local g=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
	local sg=g:RandomSelect(tp,1)
	-- 破坏随机选中的对方手牌
	Duel.Destroy(sg,REASON_EFFECT)
end
