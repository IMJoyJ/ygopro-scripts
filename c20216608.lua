--ツッパリーチ
-- 效果：
-- ①：自己抽卡阶段通常抽卡时，把那1张卡给对方观看才能发动。那张卡回到卡组最下面，自己从卡组抽1张。
-- ②：自己因效果抽卡时，把那1张卡给对方观看才能发动。这张卡送去墓地，给人观看的卡回到卡组最下面，自己从卡组抽1张。
function c20216608.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：自己抽卡阶段通常抽卡时，把那1张卡给对方观看才能发动。那张卡回到卡组最下面，自己从卡组抽1张。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(20216608,0))
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_DRAW)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCondition(c20216608.drcon)
	e2:SetCost(c20216608.drcost)
	e2:SetTarget(c20216608.drtg)
	e2:SetOperation(c20216608.drop)
	c:RegisterEffect(e2)
	-- ②：自己因效果抽卡时，把那1张卡给对方观看才能发动。这张卡送去墓地，给人观看的卡回到卡组最下面，自己从卡组抽1张。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(20216608,1))
	e3:SetCategory(CATEGORY_TOGRAVE+CATEGORY_TODECK+CATEGORY_DRAW)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_DRAW)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCondition(c20216608.drcon2)
	e3:SetCost(c20216608.drcost)
	e3:SetTarget(c20216608.drtg2)
	e3:SetOperation(c20216608.drop2)
	c:RegisterEffect(e3)
end
-- 判断是否为自己的抽卡阶段且抽卡原因为规则抽卡
function c20216608.drcon(e,tp,eg,ep,ev,re,r,rp)
	return ep==tp and r==REASON_RULE
end
-- 设置效果标签为100，表示已支付费用
function c20216608.drcost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	return true
end
-- 过滤手牌中未公开且可送回卡组的卡片
function c20216608.tdfilter(c)
	return not c:IsPublic() and c:IsAbleToDeck()
end
-- 设置效果目标为符合条件的卡片，并确认对方观看，然后将目标卡送回卡组底端并抽一张卡
function c20216608.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local tg=eg:Filter(c20216608.tdfilter,1,nil)
	-- 检查是否满足发动条件：标签为100、有可选目标、且自己可以抽卡
	if chk==0 then return e:GetLabel()==100 and #tg>0 and Duel.IsPlayerCanDraw(tp,1) end
	e:SetLabel(0)
	local tc=tg:GetFirst()
	if #tg>1 then
		-- 提示玩家选择一张给对方确认的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
		tc=tg:Select(tp,1,1,nil):GetFirst()
	end
	-- 向对方玩家确认目标卡片
	Duel.ConfirmCards(1-tp,tc)
	-- 洗切自己的手牌
	Duel.ShuffleHand(tp)
	-- 设置当前效果的目标卡片
	Duel.SetTargetCard(tc)
	-- 设置操作信息：将目标卡送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,tc,1,0,0)
	-- 设置操作信息：自己抽一张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 执行效果：将目标卡送回卡组底端并抽一张卡
function c20216608.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前效果的目标卡片
	local tc=Duel.GetFirstTarget()
	-- 检查目标卡是否有效且已送回卡组底端
	if tc and tc:IsRelateToEffect(e) and Duel.SendtoDeck(tc,nil,SEQ_DECKBOTTOM,REASON_EFFECT)>0 and tc:IsLocation(LOCATION_DECK) then
		-- 自己从卡组抽一张卡
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
-- 判断是否为自己的抽卡阶段且抽卡原因为效果抽卡
function c20216608.drcon2(e,tp,eg,ep,ev,re,r,rp)
	return ep==tp and r==REASON_EFFECT
end
-- 设置效果目标为符合条件的卡片，并确认对方观看，然后将此卡送去墓地、目标卡送回卡组底端并抽一张卡
function c20216608.drtg2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local tg=eg:Filter(c20216608.tdfilter,1,nil)
	-- 检查是否满足发动条件：标签为100、此卡可送去墓地、有可选目标、且自己可以抽卡
	if chk==0 then return e:GetLabel()==100 and c:IsAbleToGrave() and #tg>0 and Duel.IsPlayerCanDraw(tp,1) end
	e:SetLabel(0)
	local tc=tg:GetFirst()
	if #tg>1 then
		-- 提示玩家选择一张给对方确认的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
		tc=tg:Select(tp,1,1,nil):GetFirst()
	end
	-- 向对方玩家确认目标卡片
	Duel.ConfirmCards(1-tp,tc)
	-- 洗切自己的手牌
	Duel.ShuffleHand(tp)
	-- 设置当前效果的目标卡片
	Duel.SetTargetCard(tc)
	-- 设置操作信息：将此卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,c,1,0,0)
	-- 设置操作信息：将目标卡送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,tc,1,0,0)
	-- 设置操作信息：自己抽一张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 执行效果：将此卡送去墓地、目标卡送回卡组底端并抽一张卡
function c20216608.drop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查此卡是否有效且已送去墓地
	if not c:IsRelateToEffect(e) or Duel.SendtoGrave(c,REASON_EFFECT)<=0 or not c:IsLocation(LOCATION_GRAVE) then return end
	-- 获取当前效果的目标卡片
	local tc=Duel.GetFirstTarget()
	-- 检查目标卡是否有效且已送回卡组底端
	if tc and tc:IsRelateToEffect(e) and Duel.SendtoDeck(tc,nil,SEQ_DECKBOTTOM,REASON_EFFECT)>0 and tc:IsLocation(LOCATION_DECK) then
		-- 自己从卡组抽一张卡
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
