--コカローチ・ナイト
-- 效果：
-- 这张卡送去墓地时，这张卡回到卡组最上面。
function c33413638.initial_effect(c)
	-- 这张卡送去墓地时，这张卡回到卡组最上面。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(33413638,0))  --"返回卡组"
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetTarget(c33413638.tdtg)
	e1:SetOperation(c33413638.tdop)
	c:RegisterEffect(e1)
end
-- 定义效果的发动条件判定与操作信息登记：只要送去墓地即可发动，无需其他条件，并将把自身返回卡组的信息登记到本次连锁。
function c33413638.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将本次连锁的操作信息设置为“把效果持有者（这张卡）返回卡组”，数量为1，用于其他卡片进行时点或效果应对判定（由于不取对象，因此目标参数等按写法处理）。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,e:GetHandler(),1,0,0)
end
-- 效果处理函数：先确认这张卡仍与本次效果有联系（未因离场而重置），若符合则将其返回持有者卡组最顶端。
function c33413638.tdop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		-- 将以效果原因将这张卡返回其持有者卡组最顶端（SEQ_DECKTOP），因为player参数为nil所以回到持有者卡组。
		Duel.SendtoDeck(e:GetHandler(),nil,SEQ_DECKTOP,REASON_EFFECT)
	end
end
