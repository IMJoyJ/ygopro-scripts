--電極獣アニオン
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤的场合才能发动。这张卡的等级变成4星。那之后，可以从自己的卡组·墓地把1张「灵魂变换装置」加入手卡。
-- ②：以自己场上1张其他卡为对象才能发动。那张卡和这张卡送去墓地，自己抽1张。
function c58680635.initial_effect(c)
	-- ①：这张卡召唤的场合才能发动。这张卡的等级变成4星。那之后，可以从自己的卡组·墓地把1张「灵魂变换装置」加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(58680635,0))  --"改变等级"
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,58680635)
	e1:SetTarget(c58680635.lvtg)
	e1:SetOperation(c58680635.lvop)
	c:RegisterEffect(e1)
	-- ②：以自己场上1张其他卡为对象才能发动。那张卡和这张卡送去墓地，自己抽1张。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(58680635,1))  --"抽卡效果"
	e2:SetCategory(CATEGORY_DRAW+CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,58680635+1)
	e2:SetTarget(c58680635.drtg)
	e2:SetOperation(c58680635.drop)
	c:RegisterEffect(e2)
end
-- 过滤卡组或墓地中名为「灵魂变换装置」且能加入手牌的卡
function c58680635.thfilter(c)
	return c:IsCode(20802187) and c:IsAbleToHand()
end
-- 效果①的发动准备与靶向函数：检查自身等级是否不为4，并声明检索/回收的操作信息
function c58680635.lvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chk==0 then return not c:IsLevel(4) end
	-- 设置连锁信息，表示此效果包含从卡组或墓地将1张卡加入手牌的操作
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
-- 效果①的执行函数：将自身等级变为4星，之后可选择从卡组或墓地将1张「灵魂变换装置」加入手牌
function c58680635.lvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() and not c:IsLevel(4) then
		-- 这张卡的等级变成4星。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetValue(4)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
		-- 检查自身等级是否成功变为4星，且卡组或墓地中是否存在可加入手牌的「灵魂变换装置」
		if c:IsLevel(4) and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(c58680635.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil)
			-- 询问玩家是否选择将1张「灵魂变换装置」加入手牌
			and Duel.SelectYesNo(tp,aux.Stringid(58680635,2)) then  --"是否把1张「灵魂变换装置」加入手卡？"
			-- 中断当前效果处理，使前后的效果处理（等级改变与加入手牌）视为不同时处理（那之后）
			Duel.BreakEffect()
			-- 提示玩家选择要加入手牌的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
			-- 让玩家从卡组或墓地选择1张满足条件的「灵魂变换装置」
			local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c58680635.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
			if g:GetCount()>0 then
				-- 将选择的卡因效果加入玩家手牌
				Duel.SendtoHand(g,nil,REASON_EFFECT)
				-- 给对方玩家确认加入手牌的卡
				Duel.ConfirmCards(1-tp,g)
			end
		end
	end
end
-- 效果②的发动准备与靶向函数：选择自己场上1张其他卡作为对象，并声明送去墓地和抽卡的操作信息
function c58680635.drtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsOnField() and chkc:IsControler(tp) and chkc:IsAbleToGrave() end
	-- 检查是否存在可送去墓地的场上其他卡，以及玩家当前是否可以抽卡
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToGrave,tp,LOCATION_ONFIELD,0,1,c) and Duel.IsPlayerCanDraw(tp,1) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择自己场上1张其他卡作为效果的对象
	local g=Duel.SelectTarget(tp,Card.IsAbleToGrave,tp,LOCATION_ONFIELD,0,1,1,c)
	g:AddCard(e:GetHandler())
	-- 设置连锁信息，表示此效果包含将选中的卡和这张卡送去墓地的操作
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,#g,0,0)
	-- 设置连锁信息，表示此效果包含玩家抽1张卡的操作
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 效果②的执行函数：将作为对象的卡和这张卡送去墓地，若成功送去墓地则自己抽1张卡
function c58680635.drop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果②选中的对象卡
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) then
		local g=Group.FromCards(c,tc)
		-- 将对象卡和自身送去墓地，并检查是否成功将这两张卡都送入了墓地
		if Duel.SendtoGrave(g,REASON_EFFECT)>0 and g:FilterCount(Card.IsLocation,nil,LOCATION_GRAVE)==2 then
			-- 玩家因效果抽1张卡
			Duel.Draw(tp,1,REASON_EFFECT)
		end
	end
end
