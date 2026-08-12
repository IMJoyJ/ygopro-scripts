--レプティレス・ラミア
-- 效果：
-- 「爬虫妖」调整＋调整以外的怪兽1只以上
-- ①：这张卡同调召唤成功的场合发动。对方场上的攻击力0的怪兽全部破坏，自己从卡组抽出破坏的数量。
function c60634565.initial_effect(c)
	-- 添加同调召唤手续：以「爬虫妖」调整加上1只以上调整以外的怪兽作为素材
	aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsSetCard,0x3c),aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ①：这张卡同调召唤成功的场合发动。对方场上的攻击力0的怪兽全部破坏，自己从卡组抽出破坏的数量。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(60634565,0))  --"破坏和抽卡"
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c60634565.descon)
	e1:SetTarget(c60634565.destg)
	e1:SetOperation(c60634565.desop)
	c:RegisterEffect(e1)
end
-- 发动条件：这张卡同调召唤成功
function c60634565.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- 过滤条件：对方场上表侧表示且攻击力为0的怪兽
function c60634565.desfilter(c)
	return c:IsFaceup() and c:IsAttack(0)
end
-- 效果发动时的目标处理：获取符合条件的怪兽，并设置破坏和抽卡的操作信息
function c60634565.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取对方场上所有表侧表示且攻击力为0的怪兽组
	local g=Duel.GetMatchingGroup(c60634565.desfilter,tp,0,LOCATION_MZONE,nil)
	-- 设置破坏的操作信息，包含要破坏的怪兽组及其数量
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
	-- 设置抽卡的操作信息，抽卡数量为预计被破坏的怪兽数量
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,g:GetCount())
end
-- 效果运行空间：破坏对方场上所有攻击力为0的怪兽，并根据实际破坏的数量从卡组抽卡
function c60634565.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前对方场上所有表侧表示且攻击力为0的怪兽组
	local g=Duel.GetMatchingGroup(c60634565.desfilter,tp,0,LOCATION_MZONE,nil)
	-- 破坏这些怪兽，并记录实际被破坏的数量
	local ct=Duel.Destroy(g,REASON_EFFECT)
	-- 自己从卡组抽出与实际破坏数量相同的卡
	Duel.Draw(tp,ct,REASON_EFFECT)
end
