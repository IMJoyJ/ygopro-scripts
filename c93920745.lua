--ペンギン・ソルジャー
-- 效果：
-- ①：这张卡反转的场合，以场上最多2只怪兽为对象才能发动。那些怪兽回到持有者手卡。
function c93920745.initial_effect(c)
	-- ①：这张卡反转的场合，以场上最多2只怪兽为对象才能发动。那些怪兽回到持有者手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(93920745,0))  --"返回手牌"
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP+EFFECT_TYPE_TRIGGER_O)
	e1:SetTarget(c93920745.target)
	e1:SetOperation(c93920745.operation)
	c:RegisterEffect(e1)
end
-- 效果①的发动准备（检查是否满足发动条件、选择对象并设置操作信息）
function c93920745.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsAbleToHand() end
	-- 在发动阶段，检查场上是否存在至少1只可以返回手牌的怪兽作为对象
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToHand,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要返回手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择场上1到2只可以返回手牌的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,Card.IsAbleToHand,tp,LOCATION_MZONE,LOCATION_MZONE,1,2,nil)
	-- 设置当前连锁的操作信息为：将选中的对象怪兽送回手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,g:GetCount(),0,0)
end
-- 效果①的处理（获取对象怪兽，并将仍存在于场上的对象怪兽送回持有者手牌）
function c93920745.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选为效果对象的卡片组
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	if tg then
		local sg=tg:Filter(Card.IsRelateToEffect,nil,e)
		-- 将符合条件的对象怪兽因效果送回持有者的手牌
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
	end
end
