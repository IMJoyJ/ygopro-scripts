--アーケイン・ファイロ
-- 效果：
-- 这张卡被同调怪兽的同调召唤使用送去墓地的场合，可以从自己卡组把1张「爆裂模式」加入手卡。
function c40048324.initial_effect(c)
	-- 将本卡登记为关联「爆裂模式」（卡号80280737）的卡，用于记录效果文本中提到的卡名。
	aux.AddCodeList(c,80280737)
	-- 这张卡被同调怪兽的同调召唤使用送去墓地的场合，可以从自己卡组把1张「爆裂模式」加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(40048324,0))  --"检索"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_BE_MATERIAL)
	e1:SetCondition(c40048324.condition)
	e1:SetTarget(c40048324.target)
	e1:SetOperation(c40048324.operation)
	c:RegisterEffect(e1)
end
-- 发动条件判定：本卡被送去墓地且是作为同调召唤素材而被送去墓地，且当前位于墓地时，满足场合型触发条件。
function c40048324.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and r==REASON_SYNCHRO
end
-- 检索过滤条件：卡组中存在卡号为80280737的「爆裂模式」，且该卡可以被加入手卡。
function c40048324.filter(c)
	return c:IsCode(80280737) and c:IsAbleToHand()
end
-- 发动时进行合法性检查并登记操作信息：卡组有可加入手卡的「爆裂模式」时可发动；登记本次效果将处理从卡组把1张卡加入手卡。
function c40048324.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1张满足条件的「爆裂模式」，若不存在则效果不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c40048324.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 登记操作信息，标明本连锁后续将处理从卡组把1张卡加入手牌（CATEGORY_TOHAND），供其他卡效果参照。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：从卡组找出符合条件的「爆裂模式」加入手卡，并向对方展示该卡；由于不取对象，处理时直接取得第一张符合条件的卡。
function c40048324.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 显示选择提示消息“请选择要加入手牌的卡”，用于检索选牌时的界面提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组获取第一张满足条件的「爆裂模式」（不取对象，因此直接获取第一张符合条件的卡）。
	local tc=Duel.GetFirstMatchingCard(c40048324.filter,tp,LOCATION_DECK,0,nil)
	if tc then
		-- 将“爆裂模式”以效果原因加入其持有者的手卡。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 向对方玩家展示加入手卡的这张卡，使对方确认检索到的卡片。
		Duel.ConfirmCards(1-tp,tc)
	end
end
