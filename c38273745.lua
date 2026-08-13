--ヴェルズ・ウロボロス
-- 效果：
-- 4星怪兽×3
-- 1回合1次，可以把这张卡1个超量素材取除，从以下效果选择1个发动。以下效果只在这张卡在场上表侧表示存在各能选择1次。
-- ●选择对方场上存在的1张卡回到持有者手卡。
-- ●对方手卡随机选1张送去墓地。
-- ●选择对方墓地存在的1张卡从游戏中除外。
function c38273745.initial_effect(c)
	-- 为这张卡添加XYZ召唤手续：用3只等级4的怪兽作为超量素材进行XYZ召唤。
	aux.AddXyzProcedure(c,nil,4,3)
	c:EnableReviveLimit()
	-- “1回合1次，可以把这张卡1个超量素材取除，从以下效果选择1个发动。以下效果只在这张卡在场上表侧表示存在各能选择1次。●选择对方场上存在的1张卡回到持有者手卡。●对方手卡随机选1张送去墓地。●选择对方墓地存在的1张卡从游戏中除外。”
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
-- 发动代价函数：chk==0时仅检查能否取除1个超量素材作为代价（不实际取除）；实际发动时取除这张卡的1个超量素材。
function c38273745.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 目标选择/发动合法性函数：根据本回合已用过的选项标记和当前局面判断可选效果；让玩家选择其中一个选项并记录到e的Label中，同时按选项设置效果分类、取对象属性、选择目标并设置操作信息。
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
	-- 检查选项1是否可用：该选项本回合未使用过（flag第2位为0），且对方场上有能返回手卡的卡存在。
	local b1=(flag&2==0) and Duel.IsExistingTarget(Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,1,nil)
	-- 检查选项2是否可用：该选项本回合未使用过（flag第3位为0），且对方手牌至少有1张卡。
	local b2=(flag&4==0) and Duel.GetFieldGroupCount(1-tp,LOCATION_HAND,0)~=0
	-- 检查选项3是否可用：该选项本回合未使用过（flag第4位为0），且对方墓地有能被除外的卡存在。
	local b3=(flag&8==0) and Duel.IsExistingTarget(Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,1,nil)
	if chk==0 then return b1 or b2 or b3 end
	-- 调用选项选择辅助函数，让玩家从所有可用效果中选择一个；后续参数为各选项的可用标志和对应提示文本。
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
		-- 向玩家发送选择提示，提示内容为“请选择要返回手牌的卡”。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
		-- 让玩家从对方场上选择1张能返回手卡的卡，并将其登记为当前连锁的效果对象。
		local g=Duel.SelectTarget(tp,Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,1,1,nil)
		-- 设置操作信息：本次效果处理将把选择的对象返回手卡，数量为所选卡的数量，用于其他卡的效果联动检测。
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,g:GetCount(),0,0)
	elseif op==2 then
		e:SetCategory(CATEGORY_TOGRAVE)
		e:SetProperty(0)
		-- 设置操作信息：本次效果处理将把对方1张手牌送去墓地（不取对象，处理时随机选择），数量为1，来源位置为对方手牌。
		Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,1-tp,LOCATION_HAND)
	else
		e:SetCategory(CATEGORY_REMOVE)
		e:SetProperty(EFFECT_FLAG_CARD_TARGET)
		-- 向玩家发送选择提示，提示内容为“请选择要除外的卡”。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		-- 让玩家从对方墓地选择1张能被除外的卡，并将其登记为当前连锁的效果对象。
		local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,1,1,nil)
		-- 设置操作信息：本次效果处理将把选择的对象除外，数量为1，来源位置为对方墓地。
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,1-tp,LOCATION_GRAVE)
	end
end
-- 效果处理函数：读取发动时记录在e:GetLabel()中的选项编号，执行对应处理：选项1将目标送回手卡；选项2随机选1张对方手牌送去墓地；选项3将目标除外。
function c38273745.op1(e,tp,eg,ep,ev,re,r,rp)
	local op=e:GetLabel()
	if op==1 then
		-- 取得当前连锁中记录的第一个效果对象卡。
		local tc=Duel.GetFirstTarget()
		if tc:IsRelateToEffect(e) then
			-- 将对象卡以效果原因送回其持有者手卡。
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
		end
	elseif op==2 then
		-- 取得对方手牌中的所有卡（作为一个Group）。
		local g=Duel.GetFieldGroup(1-tp,LOCATION_HAND,0)
		if g:GetCount()==0 then return end
		local sg=g:RandomSelect(1-tp,1)
		-- 将随机选出的对方手牌卡以效果原因送去墓地。
		Duel.SendtoGrave(sg,REASON_EFFECT)
	else
		-- 取得当前连锁中记录的第一个效果对象卡（此处为墓地中的卡）。
		local tc=Duel.GetFirstTarget()
		if tc:IsRelateToEffect(e) then
			-- 将对象卡以表侧表示从游戏中除外，原因为效果。
			Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
		end
	end
end
