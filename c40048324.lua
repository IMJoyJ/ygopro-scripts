--アーケイン・ファイロ
-- 效果：
-- 这张卡被同调怪兽的同调召唤使用送去墓地的场合，可以从自己卡组把1张「爆裂模式」加入手卡。
function c40048324.initial_effect(c)
	-- 记录该卡具有「爆裂模式」这张卡的编号，用于后续效果判断
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
-- 判断触发条件：该卡在墓地且是因同调召唤被送入墓地
function c40048324.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and r==REASON_SYNCHRO
end
-- 过滤函数：用于筛选卡组中编号为80280737（爆裂模式）且能加入手牌的卡
function c40048324.filter(c)
	return c:IsCode(80280737) and c:IsAbleToHand()
end
-- 设置效果目标：检查卡组中是否存在满足条件的卡并设置操作信息
function c40048324.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 条件判断：检查卡组中是否存在至少1张满足条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c40048324.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：设定将要处理的卡为1张加入手牌的卡，来自卡组
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理函数：执行检索并加入手牌的操作
function c40048324.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 获取满足条件的第一张卡
	local tc=Duel.GetFirstMatchingCard(c40048324.filter,tp,LOCATION_DECK,0,nil)
	if tc then
		-- 将选中的卡以效果原因送入手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 向对方确认该卡被送入手牌
		Duel.ConfirmCards(1-tp,tc)
	end
end
