--スクラップ・スコール
-- 效果：
-- 选择自己场上表侧表示存在的1只名字带有「废铁」的怪兽发动。从自己卡组把1只名字带有「废铁」的怪兽送去墓地，抽1张卡。那之后，选择的怪兽破坏。
function c48445393.initial_effect(c)
	-- 效果原文内容：选择自己场上表侧表示存在的1只名字带有「废铁」的怪兽发动。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_TOGRAVE+CATEGORY_DRAW)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c48445393.target)
	e1:SetOperation(c48445393.activate)
	c:RegisterEffect(e1)
end
-- 效果作用：过滤出场上表侧表示且名字带有「废铁」的怪兽
function c48445393.desfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x24)
end
-- 效果作用：过滤出卡组中名字带有「废铁」且为怪兽的卡片
function c48445393.sfilter(c)
	return c:IsSetCard(0x24) and c:IsType(TYPE_MONSTER) and c:IsAbleToGrave()
end
-- 效果作用：判断是否满足发动条件，包括场上有「废铁」怪兽、卡组有「废铁」怪兽、玩家可以抽2张卡
function c48445393.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c48445393.desfilter(chkc) end
	-- 效果作用：检查场上是否存在满足条件的「废铁」怪兽
	if chk==0 then return Duel.IsExistingTarget(c48445393.desfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 效果作用：检查卡组中是否存在满足条件的「废铁」怪兽
		and Duel.IsExistingMatchingCard(c48445393.sfilter,tp,LOCATION_DECK,0,1,nil)
		-- 效果作用：检查玩家是否可以抽2张卡
		and Duel.IsPlayerCanDraw(tp,2) end
	-- 效果作用：提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 效果作用：选择场上满足条件的1只「废铁」怪兽作为目标
	local g=Duel.SelectTarget(tp,c48445393.desfilter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 效果作用：设置操作信息，表示将要破坏目标怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 效果作用：设置操作信息，表示将要从卡组送去墓地1张「废铁」怪兽
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
	-- 效果作用：设置操作信息，表示将要抽1张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 效果原文内容：从自己卡组把1只名字带有「废铁」的怪兽送去墓地，抽1张卡。那之后，选择的怪兽破坏。
function c48445393.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 效果作用：从卡组中选择1张满足条件的「废铁」怪兽
	local g=Duel.SelectMatchingCard(tp,c48445393.sfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 效果作用：将选中的怪兽送去墓地
		Duel.SendtoGrave(g,REASON_EFFECT)
		if not g:GetFirst():IsLocation(LOCATION_GRAVE) then return end
		-- 效果作用：中断当前效果处理，使后续处理视为错时点
		Duel.BreakEffect()
		-- 效果作用：让玩家抽1张卡
		Duel.Draw(tp,1,REASON_EFFECT)
		-- 效果作用：获取当前连锁的目标怪兽
		local tc=Duel.GetFirstTarget()
		if tc:IsRelateToEffect(e) and tc:IsFaceup() then
			-- 效果作用：中断当前效果处理，使后续处理视为错时点
			Duel.BreakEffect()
			-- 效果作用：破坏目标怪兽
			Duel.Destroy(tc,REASON_EFFECT)
		end
	end
end
