--紅炎の騎士
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：这张卡已在怪兽区域存在的状态，这张卡以外的炎属性怪兽被破坏送去自己墓地的场合发动。从卡组把1只炎属性怪兽送去墓地。
-- ②：这张卡被破坏送去墓地的场合发动。从卡组把1只炎属性怪兽送去墓地。
function c36569343.initial_effect(c)
	-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。①：这张卡已在怪兽区域存在的状态，这张卡以外的炎属性怪兽被破坏送去自己墓地的场合发动。从卡组把1只炎属性怪兽送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(36569343,0))  --"卡组送墓"
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,36569343)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCondition(c36569343.tgcon1)
	e1:SetTarget(c36569343.tgtg)
	e1:SetOperation(c36569343.tgop1)
	c:RegisterEffect(e1)
	-- ②：这张卡被破坏送去墓地的场合发动。从卡组把1只炎属性怪兽送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(36569343,0))  --"卡组送墓"
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCountLimit(1,36569343)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCondition(c36569343.tgcon2)
	e2:SetTarget(c36569343.tgtg)
	e2:SetOperation(c36569343.tgop2)
	c:RegisterEffect(e2)
end
-- 定义①的触发筛选函数：判断一张卡是否为tp控制的、因破坏而送去墓地的炎属性怪兽，用于确认满足“这张卡以外的炎属性怪兽被破坏送去自己墓地”的条件。
function c36569343.cfilter(c,tp)
	return c:IsControler(tp) and c:IsReason(REASON_DESTROY) and c:IsAttribute(ATTRIBUTE_FIRE)
end
-- ①的发动条件：当前送入墓地的怪兽组eg中存在至少1只满足cfilter条件的炎属性怪兽（即被破坏送去自己墓地的炎属性怪兽）。
function c36569343.tgcon1(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c36569343.cfilter,1,nil,tp)
end
-- ①的目标设定：效果不取对象，chk==0时直接允许发动，并设置操作信息，预告将从卡组把1只怪兽送去墓地。
function c36569343.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置本次效果的操作信息：效果分类为CATEGORY_TOGRAVE，预计把1张卡从tp的卡组送去墓地（数量1，玩家tp，位置卡组）。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- ①的效果处理：先确认效果持有者仍在场上且与效果关联（否则不处理）；然后提示玩家从己方卡组选择1只满足条件的炎属性怪兽，并送去墓地。
function c36569343.tgop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFacedown() or not c:IsRelateToEffect(e) then return end
	-- 向玩家显示“请选择要送去墓地的卡”的选择提示，用于后续卡组选择操作。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从己方卡组中筛选并选择1张满足tgfilter条件的炎属性怪兽（不取对象）。
	local g=Duel.SelectMatchingCard(tp,c36569343.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡以效果原因送去墓地。
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
-- ②的发动条件：这张卡自身被破坏并送去墓地时满足条件。
function c36569343.tgcon2(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_DESTROY)
end
-- 定义卡组送墓的筛选条件：选择卡必须是怪兽、炎属性，并且可以送去墓地。
function c36569343.tgfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAttribute(ATTRIBUTE_FIRE) and c:IsAbleToGrave()
end
-- ②的效果处理：直接提示玩家从己方卡组选择1只满足tgfilter条件的炎属性怪兽并送去墓地；②在墓地发动，无需检查自身在场。
function c36569343.tgop2(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家显示“请选择要送去墓地的卡”的选择提示，用于后续卡组选择操作。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从己方卡组中筛选并选择1张满足tgfilter条件的炎属性怪兽（不取对象）。
	local g=Duel.SelectMatchingCard(tp,c36569343.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡以效果原因送去墓地。
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
