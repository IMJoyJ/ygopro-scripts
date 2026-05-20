--A・ボム
-- 效果：
-- 这张卡被和光属性怪兽的战斗破坏送去墓地时，选择场上2张卡破坏。
function c59482302.initial_effect(c)
	-- 这张卡被和光属性怪兽的战斗破坏送去墓地时，选择场上2张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(59482302,0))  --"场上2张卡破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetCondition(c59482302.condition)
	e1:SetTarget(c59482302.target)
	e1:SetOperation(c59482302.operation)
	c:RegisterEffect(e1)
end
-- 判断此卡是否因与光属性怪兽战斗而被破坏并送入墓地
function c59482302.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and e:GetHandler():IsReason(REASON_BATTLE)
		and e:GetHandler():GetReasonCard():IsAttribute(ATTRIBUTE_LIGHT)
end
-- 过滤场上可以成为效果对象的卡片
function c59482302.filter(c,e)
	return c:IsCanBeEffectTarget(e)
end
-- 效果发动的对象选择：在场上选择2张卡作为对象，并设置破坏的操作信息
function c59482302.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and c59482302.filter(chkc,e) end
	if chk==0 then return true end
	-- 获取双方场上所有可以成为效果对象的卡片组
	local g=Duel.GetMatchingGroup(c59482302.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil,e)
	if g:GetCount()>1 then
		-- 提示玩家选择要破坏的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		local sg=g:Select(tp,2,2,nil)
		-- 将选择的卡片设置为效果的对象
		Duel.SetTargetCard(sg)
		-- 设置效果处理的操作信息为破坏这2张卡
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,2,0,0)
	end
end
-- 效果处理：破坏作为对象的2张卡
function c59482302.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选为对象的卡片组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	if not g then return end
	local dg=g:Filter(Card.IsRelateToEffect,nil,e)
	-- 将仍与效果相关的对象卡片破坏
	Duel.Destroy(dg,REASON_EFFECT)
end
