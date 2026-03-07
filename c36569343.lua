--紅炎の騎士
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：这张卡已在怪兽区域存在的状态，这张卡以外的炎属性怪兽被破坏送去自己墓地的场合发动。从卡组把1只炎属性怪兽送去墓地。
-- ②：这张卡被破坏送去墓地的场合发动。从卡组把1只炎属性怪兽送去墓地。
function c36569343.initial_effect(c)
	-- 效果原文：①：这张卡已在怪兽区域存在的状态，这张卡以外的炎属性怪兽被破坏送去自己墓地的场合发动。从卡组把1只炎属性怪兽送去墓地。
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
	-- 效果原文：②：这张卡被破坏送去墓地的场合发动。从卡组把1只炎属性怪兽送去墓地。
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
-- 规则层面：定义一个过滤函数，用于判断被破坏送去墓地的怪兽是否为炎属性且是自己控制的。
function c36569343.cfilter(c,tp)
	return c:IsControler(tp) and c:IsReason(REASON_DESTROY) and c:IsAttribute(ATTRIBUTE_FIRE)
end
-- 规则层面：判断是否有满足条件的怪兽被破坏送去墓地（即是否触发效果①）。
function c36569343.tgcon1(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c36569343.cfilter,1,nil,tp)
end
-- 规则层面：设置连锁处理时的操作信息，表示将从卡组选择1只怪兽送去墓地。
function c36569343.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 规则层面：设置当前处理的连锁操作信息为将1张卡从卡组送去墓地。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 规则层面：效果①的处理函数，选择并把1只炎属性怪兽从卡组送去墓地。
function c36569343.tgop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFacedown() or not c:IsRelateToEffect(e) then return end
	-- 规则层面：提示玩家选择要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 规则层面：从卡组中选择1只符合条件的炎属性怪兽。
	local g=Duel.SelectMatchingCard(tp,c36569343.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 规则层面：将选中的怪兽从卡组送去墓地。
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
-- 规则层面：判断当前效果是否因破坏而触发（即是否触发效果②）。
function c36569343.tgcon2(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_DESTROY)
end
-- 规则层面：定义一个过滤函数，用于筛选可以送去墓地的炎属性怪兽。
function c36569343.tgfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAttribute(ATTRIBUTE_FIRE) and c:IsAbleToGrave()
end
-- 规则层面：效果②的处理函数，选择并把1只炎属性怪兽从卡组送去墓地。
function c36569343.tgop2(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面：提示玩家选择要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 规则层面：从卡组中选择1只符合条件的炎属性怪兽。
	local g=Duel.SelectMatchingCard(tp,c36569343.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 规则层面：将选中的怪兽从卡组送去墓地。
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
