--コアキメイル・クルセイダー
-- 效果：
-- 这张卡的控制者在每次自己的结束阶段从手卡把1张「核成兽的钢核」送去墓地或把手卡1只兽战士族怪兽给对方观看。或者都不进行让这张卡破坏。这张卡战斗破坏对方怪兽的场合，可以把自己墓地存在的1张名字带有「核成」的卡加入手卡。
function c32314730.initial_effect(c)
	-- 记录该卡具有「核成兽的钢核」这张卡的卡号
	aux.AddCodeList(c,36623431)
	-- 这张卡的控制者在每次自己的结束阶段从手卡把1张「核成兽的钢核」送去墓地或把手卡1只兽战士族怪兽给对方观看。或者都不进行让这张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c32314730.mtcon)
	e1:SetOperation(c32314730.mtop)
	c:RegisterEffect(e1)
	-- 这张卡战斗破坏对方怪兽的场合，可以把自己墓地存在的1张名字带有「核成」的卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(32314730,0))  --"选择一张「核成兽的钢核」送去墓地"
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_DESTROYING)
	e2:SetCondition(c32314730.thcon)
	e2:SetTarget(c32314730.thtg)
	e2:SetOperation(c32314730.thop)
	c:RegisterEffect(e2)
end
-- 判断是否为当前回合玩家触发效果
function c32314730.mtcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否为当前回合玩家
	return Duel.GetTurnPlayer()==tp
end
-- 过滤手卡中可作为cost送去墓地的「核成兽的钢核」
function c32314730.cfilter1(c)
	return c:IsCode(36623431) and c:IsAbleToGraveAsCost()
end
-- 过滤手卡中未公开的兽战士族怪兽
function c32314730.cfilter2(c)
	return c:IsType(TYPE_MONSTER) and c:IsRace(RACE_BEASTWARRIOR) and not c:IsPublic()
end
-- 处理结束阶段效果选择
function c32314730.mtop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 为该卡显示选为对象的动画效果
	Duel.HintSelection(Group.FromCards(c))
	-- 获取手卡中可作为cost送去墓地的「核成兽的钢核」
	local g1=Duel.GetMatchingGroup(c32314730.cfilter1,tp,LOCATION_HAND,0,nil)
	-- 获取手卡中未公开的兽战士族怪兽
	local g2=Duel.GetMatchingGroup(c32314730.cfilter2,tp,LOCATION_HAND,0,nil)
	local select=2
	if g1:GetCount()>0 and g2:GetCount()>0 then
		-- 选择三种选项：送去墓地/给对方观看/破坏
		select=Duel.SelectOption(tp,aux.Stringid(32314730,0),aux.Stringid(32314730,1),aux.Stringid(32314730,2))  --"选择一张「核成兽的钢核」送去墓地/选择一张兽战士族怪兽给对方观看/破坏「核成十字军」"
	elseif g1:GetCount()>0 then
		-- 选择两种选项：送去墓地/破坏
		select=Duel.SelectOption(tp,aux.Stringid(32314730,0),aux.Stringid(32314730,2))  --"选择一张「核成兽的钢核」送去墓地/破坏「核成十字军」"
		if select==1 then select=2 end
	elseif g2:GetCount()>0 then
		-- 选择两种选项：给对方观看/破坏
		select=Duel.SelectOption(tp,aux.Stringid(32314730,1),aux.Stringid(32314730,2))+1  --"选择一张兽战士族怪兽给对方观看/破坏「核成十字军」"
	else
		-- 只能选择破坏
		select=Duel.SelectOption(tp,aux.Stringid(32314730,2))  --"破坏「核成十字军」"
		select=2
	end
	if select==0 then
		-- 提示选择要送去墓地的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		local g=g1:Select(tp,1,1,nil)
		-- 将选择的卡送去墓地
		Duel.SendtoGrave(g,REASON_COST)
	elseif select==1 then
		-- 提示选择要给对方确认的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
		local g=g2:Select(tp,1,1,nil)
		-- 向对方确认选择的卡
		Duel.ConfirmCards(1-tp,g)
		-- 洗切自己的手牌
		Duel.ShuffleHand(tp)
	else
		-- 破坏该卡
		Duel.Destroy(c,REASON_COST)
	end
end
-- 判断该卡是否参与了战斗且击败了对方怪兽
function c32314730.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsRelateToBattle() and c:GetBattleTarget():IsType(TYPE_MONSTER)
end
-- 过滤墓地中的「核成」卡
function c32314730.filter(c)
	return c:IsSetCard(0x1d) and c:IsAbleToHand()
end
-- 设置效果目标并准备处理效果
function c32314730.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c32314730.filter(chkc) end
	-- 检查是否存在满足条件的墓地目标卡
	if chk==0 then return Duel.IsExistingTarget(c32314730.filter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择一张满足条件的墓地卡作为目标
	local g=Duel.SelectTarget(tp,c32314730.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置效果操作信息为回手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 处理效果的发动和执行
function c32314730.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡加入手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 向对方确认加入手牌的卡
		Duel.ConfirmCards(1-tp,tc)
	end
end
