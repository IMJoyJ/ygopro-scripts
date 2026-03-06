--虚空の騎士
-- 效果：
-- 这张卡在场上表侧表示存在的场合场上的怪兽回到手卡·卡组时，从自己卡组把1只风属性怪兽送去墓地。这个效果1回合只能使用1次。
function c27632240.initial_effect(c)
	-- 效果原文内容：这张卡在场上表侧表示存在的场合场上的怪兽回到手卡·卡组时，从自己卡组把1只风属性怪兽送去墓地。这个效果1回合只能使用1次。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(27632240,0))  --"送墓"
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,EFFECT_COUNT_CODE_SINGLE)
	e1:SetCode(EVENT_TO_HAND)
	e1:SetCondition(c27632240.tgcon1)
	e1:SetTarget(c27632240.tgtg)
	e1:SetOperation(c27632240.tgop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_TO_DECK)
	e2:SetCondition(c27632240.tgcon2)
	c:RegisterEffect(e2)
end
-- 过滤函数：判断怪兽是否从怪兽区域离开
function c27632240.cfilter1(c)
	return c:IsPreviousLocation(LOCATION_MZONE)
end
-- 效果条件：场上怪兽回到手卡时触发，且有怪兽从怪兽区域离开
function c27632240.tgcon1(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c27632240.cfilter1,1,nil)
end
-- 过滤函数：判断怪兽是否从怪兽区域离开且在卡组中
function c27632240.cfilter2(c)
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsLocation(LOCATION_DECK)
end
-- 效果条件：场上怪兽回到卡组时触发，且有怪兽从怪兽区域离开且在卡组中
function c27632240.tgcon2(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c27632240.cfilter2,1,nil)
end
-- 效果目标：设置将要处理的卡为1只风属性怪兽
function c27632240.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：将要处理的卡为1只风属性怪兽
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 过滤函数：筛选风属性怪兽
function c27632240.tgfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAttribute(ATTRIBUTE_WIND) and c:IsAbleToGrave()
end
-- 效果处理：选择并把1只风属性怪兽送去墓地
function c27632240.tgop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFacedown() or not c:IsRelateToEffect(e) then return end
	-- 提示选择：提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择卡片：从卡组中选择1只风属性怪兽
	local g=Duel.SelectMatchingCard(tp,c27632240.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将卡片送去墓地：将选中的风属性怪兽送去墓地
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
