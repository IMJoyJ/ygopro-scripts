--原初の種
-- 效果：
-- 「混沌战士 -开辟的使者-」或「混沌帝龙 -终焉的使者-」在场上存在的场合，这张卡才能发动。将自己2张从游戏中除外的卡加入自己手卡。
function c23701465.initial_effect(c)
	-- 对应卡片效果原文：“「混沌战士 -开辟的使者-」或「混沌帝龙 -终焉的使者-」在场上存在的场合，这张卡才能发动。将自己2张从游戏中除外的卡加入自己手卡。” 整段代码是注册该效果的流程：创建效果、设置类别/取对象/发动类型/自由时点、条件/目标/处理函数并注册到卡片。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c23701465.condition)
	e1:SetTarget(c23701465.target)
	e1:SetOperation(c23701465.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：判断怪兽是否表侧表示且卡名是“混沌战士 -开辟的使者-”（72989439）或“混沌帝龙 -终焉的使者-”（82301904），用于检查发动所需的场上存在条件。
function c23701465.cfilter(c)
	return c:IsFaceup() and c:IsCode(72989439,82301904)
end
-- 发动条件函数：检测场上（LOCATION_ONFIELD）是否存在满足cfilter的卡，若存在则允许发动。
function c23701465.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查是否存在至少1张满足cfilter条件的表侧表示怪兽在场（“混沌战士 -开辟的使者-”或“混沌帝龙 -终焉的使者-”），作为这张卡的发动的条件。
	return Duel.IsExistingMatchingCard(c23701465.cfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
end
-- 效果发动时的目标处理函数：校验是否可以选择自己除外区的卡为对象，并让玩家选择2张可以加入手卡的除外卡，再写入操作信息。
function c23701465.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_REMOVED) and chkc:IsAbleToHand()end
	-- 发动合法性检查（chk==0）：确认自己的除外区是否存在至少2张“可以加入手卡”的卡，不足则不能发动。
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToHand,tp,LOCATION_REMOVED,0,2,nil) end
	-- 向当前玩家显示选择提示信息，提示语为“请选择要加入手牌的卡”（HINTMSG_ATOHAND）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从自己除外区选择2张可以加入手卡的卡作为效果对象（取对象效果，并自动将选择设置为连锁对象）。
	local g=Duel.SelectTarget(tp,Card.IsAbleToHand,tp,LOCATION_REMOVED,0,2,2,nil)
	-- 设置本次连锁的操作信息：类别为CATEGORY_TOHAND，对象为已选择的2张卡，用于后续效果互动判定（如被无效、连锁对应等）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,2,0,0)
end
-- 效果处理函数：从连锁信息中取得发动时选择的对象卡，过滤出仍与该效果相关的卡，将其加入手卡，并展示给对方玩家确认。
function c23701465.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中取出发动时选择的对象卡组（即被取对象的2张除外区的卡）。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local sg=g:Filter(Card.IsRelateToEffect,nil,e)
	if sg:GetCount()>0 then
		-- 将筛选后的对象卡加入其持有者的手卡（nil表示回到持有者手卡），原因为效果处理（REASON_EFFECT）。
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		-- 向对方玩家（1-tp）展示加入手卡的卡片，以确认效果处理结果。
		Duel.ConfirmCards(1-tp,sg)
	end
end
