--E・HERO マリン・ネオス
-- 效果：
-- 「元素英雄 新宇侠」＋「新空间侠·海洋海豚」
-- 让自己场上的上记卡回到卡组的场合才能从额外卡组特殊召唤。
-- ①：1回合1次，自己主要阶段才能发动。对方手卡随机选1张破坏。
function c5128859.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加融合召唤手续，使用卡号为89943723和78734254的两只怪兽作为融合素材
	aux.AddFusionProcCode2(c,89943723,78734254,false,false)
	-- 添加接触融合特殊召唤规则，要求自己场上的符合条件的怪兽回到卡组作为召唤条件
	aux.AddContactFusionProcedure(c,Card.IsAbleToDeckOrExtraAsCost,LOCATION_ONFIELD,0,aux.ContactFusionSendToDeck(c))
	-- ①：1回合1次，自己主要阶段才能发动。对方手卡随机选1张破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(c5128859.splimit)
	c:RegisterEffect(e1)
	-- ①：1回合1次，自己主要阶段才能发动。对方手卡随机选1张破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(5128859,0))  --"手牌破坏"
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetTarget(c5128859.destg)
	e3:SetOperation(c5128859.desop)
	c:RegisterEffect(e3)
end
c5128859.material_setcode=0x8
-- 特殊召唤条件限制：只有当此卡不在额外卡组时才能特殊召唤
function c5128859.splimit(e,se,sp,st)
	return not e:GetHandler():IsLocation(LOCATION_EXTRA)
end
-- 效果发动时的处理函数，判断对方手牌数量是否大于0，并设置操作信息
function c5128859.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断对方手牌数量是否大于0
	if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)>0 end
	-- 设置连锁操作信息，指定将对方手牌破坏
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,1-tp,LOCATION_HAND)
end
-- 效果执行函数，从对方手牌中随机选择一张进行破坏
function c5128859.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方手牌组的所有卡片
	local g=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
	local sg=g:RandomSelect(tp,1)
	-- 将选定的卡片进行破坏
	Duel.Destroy(sg,REASON_EFFECT)
end
