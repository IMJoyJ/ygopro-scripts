--ヴェルズ・ウロボロス
-- 效果：
-- 4星怪兽×3
-- 1回合1次，可以把这张卡1个超量素材取除，从以下效果选择1个发动。以下效果只在这张卡在场上表侧表示存在各能选择1次。
-- ●选择对方场上存在的1张卡回到持有者手卡。
-- ●对方手卡随机选1张送去墓地。
-- ●选择对方墓地存在的1张卡从游戏中除外。
function c38273745.initial_effect(c)
	-- 为卡片添加等级为4、需要3个超量素材的XYZ召唤手续
	aux.AddXyzProcedure(c,nil,4,3)
	c:EnableReviveLimit()
	-- 1回合1次，可以把这张卡1个超量素材取除，从以下效果选择1个发动。以下效果只在这张卡在场上表侧表示存在各能选择1次。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_NO_TURN_RESET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(c38273745.cost)
	e1:SetTarget(c38273745.tg1)
	e1:SetOperation(c38273745.op1)
	c:RegisterEffect(e1)
end
-- 支付1个超量素材作为cost
function c38273745.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 处理效果选择阶段，判断三个选项是否可用并选择效果
function c38273745.tg1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		if e:GetLabel()==0 then
			return chkc:IsControler(1-tp) and chkc:IsOnField() and chkc:IsAbleToHand()
		elseif e:GetLabel()==2 then
			return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_GRAVE) and chkc:IsAbleToRemove()
		end
	end
	local c=e:GetHandler()
	local flag=c:GetFlagEffectLabel(38273745) or 0
	-- 判断对方场上是否存在可送回手牌的卡
	local b1=(flag&2==0) and Duel.IsExistingTarget(Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,1,nil)
	-- 判断对方手卡是否存在可送去墓地的卡
	local b2=(flag&4==0) and Duel.GetFieldGroupCount(1-tp,LOCATION_HAND,0)~=0
	-- 判断对方墓地是否存在可除外的卡
	local b3=(flag&8==0) and Duel.IsExistingTarget(Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,1,nil)
	if chk==0 then return b1 or b2 or b3 end
	-- 让玩家从三个选项中选择一个
	local op=aux.SelectFromOptions(tp,
		{b1,aux.Stringid(38273745,1)},  --"对方场上存在的1张卡回到持有者手卡。"
		{b2,aux.Stringid(38273745,2)},  --"对方手卡随机选1张送去墓地。"
		{b3,aux.Stringid(38273745,3)})  --"对方墓地存在的1张卡从游戏中除外。"
	e:SetLabel(op)
	if flag==0 then
		c:RegisterFlagEffect(38273745,RESET_EVENT+RESETS_STANDARD,0,1)
	end
	c:SetFlagEffectLabel(38273745,flag|(1<<op))
	if op==1 then
		e:SetCategory(CATEGORY_TOHAND)
		e:SetProperty(EFFECT_FLAG_CARD_TARGET)
		-- 提示玩家选择要返回手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
		-- 选择对方场上一张可送回手牌的卡作为效果对象
		local g=Duel.SelectTarget(tp,Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,1,1,nil)
		-- 设置效果处理信息为将对象卡送回手牌
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,g:GetCount(),0,0)
	elseif op==2 then
		e:SetCategory(CATEGORY_TOGRAVE)
		e:SetProperty(0)
		-- 设置效果处理信息为将对方手卡1张送去墓地
		Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,1-tp,LOCATION_HAND)
	else
		e:SetCategory(CATEGORY_REMOVE)
		e:SetProperty(EFFECT_FLAG_CARD_TARGET)
		-- 提示玩家选择要除外的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		-- 选择对方墓地一张可除外的卡作为效果对象
		local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,1,1,nil)
		-- 设置效果处理信息为将对象卡除外
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,1-tp,LOCATION_GRAVE)
	end
end
-- 处理效果发动后的操作
function c38273745.op1(e,tp,eg,ep,ev,re,r,rp)
	local op=e:GetLabel()
	if op==1 then
		-- 获取当前连锁的效果对象卡
		local tc=Duel.GetFirstTarget()
		if tc:IsRelateToEffect(e) then
			-- 将对象卡送回持有者手牌
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
		end
	elseif op==2 then
		-- 获取对方手卡组
		local g=Duel.GetFieldGroup(1-tp,LOCATION_HAND,0)
		if g:GetCount()==0 then return end
		local sg=g:RandomSelect(1-tp,1)
		-- 将随机选择的对方手卡送去墓地
		Duel.SendtoGrave(sg,REASON_EFFECT)
	else
		-- 获取当前连锁的效果对象卡
		local tc=Duel.GetFirstTarget()
		if tc:IsRelateToEffect(e) then
			-- 将对象卡从游戏中除外
			Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
		end
	end
end
