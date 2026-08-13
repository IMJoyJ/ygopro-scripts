--派手ハネ
-- 效果：
-- 反转：可以选择场上最多3只怪兽回到手卡。
function c28357177.initial_effect(c)
	-- 反转：可以选择场上最多3只怪兽回到手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(28357177,0))  --"返回手牌"
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetTarget(c28357177.target)
	e1:SetOperation(c28357177.operation)
	c:RegisterEffect(e1)
end
-- 发动效果时的目标选择函数：确认对象条件、选择1~3只场上怪兽并设定返回手牌的操作信息。
function c28357177.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsAbleToHand() end
	-- 在效果发动时检查场上是否存在至少1只满足“可送去手卡”的怪兽，若不存在则不能发动。
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToHand,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向玩家显示“请选择要返回手牌的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 玩家从双方场上怪兽中选择1~3张可作为本次效果对象的卡，并设为效果对象。
	local g=Duel.SelectTarget(tp,Card.IsAbleToHand,tp,LOCATION_MZONE,LOCATION_MZONE,1,3,nil)
	-- 将本次连锁的处理信息设置为“返回手牌”，对象为所选的怪兽，数量为所选数量。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,g:GetCount(),0,0)
end
-- 效果处理时的执行函数：取出连锁中的对象卡，筛选仍与该效果相关的卡，并将其返回持有者手卡。
function c28357177.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本次连锁记录的效果对象卡片组。
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	if tg then
		local g=tg:Filter(Card.IsRelateToEffect,nil,e)
		if g:GetCount()>0 then
			-- 将筛选出的对象卡以效果原因送回持有者手卡。
			Duel.SendtoHand(g,nil,REASON_EFFECT)
		end
	end
end
