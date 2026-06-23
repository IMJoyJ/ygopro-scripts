--無欲な壺
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：以自己·对方的墓地的卡合计2张为对象才能发动。那些卡回到持有者卡组。这张卡发动后，不送去墓地而除外。
function c51790181.initial_effect(c)
	-- 创建效果对象并设置其分类为回卡组、类型为发动、具有取对象属性、触发时点为自由时点、限制一回合只能发动1次且与誓约次数相关
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,51790181+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c51790181.target)
	e1:SetOperation(c51790181.activate)
	c:RegisterEffect(e1)
end
-- 效果处理的选卡阶段，检查是否满足条件并提示选择2张可送入卡组的墓地卡片
function c51790181.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 判断当前是否处于选卡阶段，若未满足条件则返回false以阻止效果发动
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToDeck,tp,LOCATION_GRAVE,LOCATION_GRAVE,2,nil) end
	-- 向玩家发送提示信息，提示其选择要返回卡组的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 从自己和对方的墓地中选择2张可送入卡组的卡片作为效果对象
	local g=Duel.SelectTarget(tp,Card.IsAbleToDeck,tp,LOCATION_GRAVE,LOCATION_GRAVE,2,2,nil)
	-- 设置当前连锁的操作信息为回卡组效果，并指定目标卡片组及数量
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,2,0,0)
end
-- 效果发动后的处理阶段，获取目标卡片并将其送回卡组，再将自身除外
function c51790181.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中设定的目标卡片组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local sg=g:Filter(Card.IsRelateToEffect,nil,e)
	-- 将符合条件的卡片以效果原因送回卡组并洗牌
	Duel.SendtoDeck(sg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	if e:GetHandler():IsRelateToEffect(e) and e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		-- 将自身以效果原因除外
		Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_EFFECT)
	end
end
