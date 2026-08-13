--虚空の騎士
-- 效果：
-- 这张卡在场上表侧表示存在的场合场上的怪兽回到手卡·卡组时，从自己卡组把1只风属性怪兽送去墓地。这个效果1回合只能使用1次。
function c27632240.initial_effect(c)
	-- 这张卡在场上表侧表示存在的场合场上的怪兽回到手卡·卡组时，从自己卡组把1只风属性怪兽送去墓地。这个效果1回合只能使用1次。
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
-- 筛选触发事件中满足条件的对象：判断事件涉及的怪兽原先是否位于怪兽区（即是否为场上的怪兽）。
function c27632240.cfilter1(c)
	return c:IsPreviousLocation(LOCATION_MZONE)
end
-- 诱发条件：当场上存在至少1只原先在怪兽区的怪兽被加入手卡时，满足“场上的怪兽回到手卡时”的发动条件。
function c27632240.tgcon1(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c27632240.cfilter1,1,nil)
end
-- 筛选事件对象：判断怪兽原先位于怪兽区且现在回到卡组，用于识别“场上的怪兽回到卡组”这一情况。
function c27632240.cfilter2(c)
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsLocation(LOCATION_DECK)
end
-- 诱发条件：当场上存在至少1只原先在怪兽区的怪兽回到卡组时，满足“场上的怪兽回到卡组时”的发动条件。
function c27632240.tgcon2(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c27632240.cfilter2,1,nil)
end
-- 发动时的效果处理目标设定：不取对象，只登记将进行送去墓地的操作信息；合法性检查阶段直接通过。
function c27632240.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 登记操作信息：本效果处理时将把1张卡从持有者的卡组送去墓地，用于系统中其他卡对此效果的响应判定。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 筛选卡组中符合条件的卡片：选择持有者卡组中1只风属性怪兽且该怪兽可以被送去墓地。
function c27632240.tgfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAttribute(ATTRIBUTE_WIND) and c:IsAbleToGrave()
end
-- 效果处理：先确认效果持有者仍在场上且与本效果关联，然后从持有者卡组中选择1只风属性怪兽并送去墓地。
function c27632240.tgop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFacedown() or not c:IsRelateToEffect(e) then return end
	-- 给持有者显示“请选择要送去墓地的卡”的提示消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 不取对象地从持有者卡组中选择1张满足条件的风属性怪兽（选牌时已排除不能送墓的情况）。
	local g=Duel.SelectMatchingCard(tp,c27632240.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择到的怪兽以效果原因送去墓地，完成“从卡组把1只风属性怪兽送去墓地”的处理。
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
