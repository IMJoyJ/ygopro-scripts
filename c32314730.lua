--コアキメイル・クルセイダー
-- 效果：
-- 这张卡的控制者在每次自己的结束阶段从手卡把1张「核成兽的钢核」送去墓地或把手卡1只兽战士族怪兽给对方观看。或者都不进行让这张卡破坏。这张卡战斗破坏对方怪兽的场合，可以把自己墓地存在的1张名字带有「核成」的卡加入手卡。
function c32314730.initial_effect(c)
	-- 注册卡名代码列表，使此卡被视为记载了「核成兽的钢核」（36623431）的卡，以便相关效果能正确检索/判断。
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
-- 该结束阶段维持成本效果的触发条件：仅当当前回合玩家为此卡控制者（即自己的结束阶段）时才执行。
function c32314730.mtcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前回合玩家是否等于此卡控制者，确保只在自己的结束阶段触发。
	return Duel.GetTurnPlayer()==tp
end
-- 定义筛选条件1：手牌中存在卡名「核成兽的钢核」且可作为cost送去墓地的卡（用于维持COST）。
function c32314730.cfilter1(c)
	return c:IsCode(36623431) and c:IsAbleToGraveAsCost()
end
-- 定义筛选条件2：手牌中存在兽战士族怪兽且未公开（非公开状态）的卡（用于展示给对方维持COST）。
function c32314730.cfilter2(c)
	return c:IsType(TYPE_MONSTER) and c:IsRace(RACE_BEASTWARRIOR) and not c:IsPublic()
end
-- 处理结束阶段维持COST：根据手牌可用选项，让控制者选择送「核成兽的钢核」去墓地、展示兽战士族怪兽、或进行破坏此卡的操作。
function c32314730.mtop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 手动为此卡播放被选择/注视的动画提示，并标记它为处理对象。
	Duel.HintSelection(Group.FromCards(c))
	-- 获取手牌中可作为维持COST送去墓地的「核成兽的钢核」集合。
	local g1=Duel.GetMatchingGroup(c32314730.cfilter1,tp,LOCATION_HAND,0,nil)
	-- 获取手牌中可作为维持COST展示给对方看的兽战士族怪兽集合。
	local g2=Duel.GetMatchingGroup(c32314730.cfilter2,tp,LOCATION_HAND,0,nil)
	local select=2
	if g1:GetCount()>0 and g2:GetCount()>0 then
		-- 当两种COST都有可行卡时，弹出三选项菜单：送钢核去墓地/展示兽战士族怪兽/破坏此卡。
		select=Duel.SelectOption(tp,aux.Stringid(32314730,0),aux.Stringid(32314730,1),aux.Stringid(32314730,2))  --"选择一张「核成兽的钢核」送去墓地/选择一张兽战士族怪兽给对方观看/破坏「核成十字军」"
	elseif g1:GetCount()>0 then
		-- 当只有送钢核可行时，弹出两选项菜单：送钢核去墓地/破坏此卡，并将“破坏”选项编号修正为2。
		select=Duel.SelectOption(tp,aux.Stringid(32314730,0),aux.Stringid(32314730,2))  --"选择一张「核成兽的钢核」送去墓地/破坏「核成十字军」"
		if select==1 then select=2 end
	elseif g2:GetCount()>0 then
		-- 当只有展示怪兽可行时，弹出两选项菜单：展示兽战士族怪兽/破坏此卡，并将结果加1以对应正确选项编号。
		select=Duel.SelectOption(tp,aux.Stringid(32314730,1),aux.Stringid(32314730,2))+1  --"选择一张兽战士族怪兽给对方观看/破坏「核成十字军」"
	else
		-- 当两种COST均不可行时，直接选择破坏此卡（将唯一选项的返回值强制设为2）。
		select=Duel.SelectOption(tp,aux.Stringid(32314730,2))  --"破坏「核成十字军」"
		select=2
	end
	if select==0 then
		-- 提示玩家选择要送去墓地的卡片（用于选择「核成兽的钢核」）。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		local g=g1:Select(tp,1,1,nil)
		-- 将选择的「核成兽的钢核」作为COST送去墓地，完成维持COST。
		Duel.SendtoGrave(g,REASON_COST)
	elseif select==1 then
		-- 提示玩家选择要展示给对方确认的卡片。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
		local g=g2:Select(tp,1,1,nil)
		-- 将选择的兽战士族怪兽展示给对方玩家确认，满足维持COST条件。
		Duel.ConfirmCards(1-tp,g)
		-- 因为手牌被展示过，洗切该玩家手牌以重置顺序和公开状态。
		Duel.ShuffleHand(tp)
	else
		-- 当控制者既不送墓地也不展示怪兽时，将此卡破坏作为未维持成本的代价。
		Duel.Destroy(c,REASON_COST)
	end
end
-- 此卡战斗破坏对方怪兽后的触发条件：自身仍关联本次战斗且战斗对象为怪兽。
function c32314730.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsRelateToBattle() and c:GetBattleTarget():IsType(TYPE_MONSTER)
end
-- 定义检索条件：墓地中名字带有「核成」（0x1d）字段的卡，且可以被加入手卡。
function c32314730.filter(c)
	return c:IsSetCard(0x1d) and c:IsAbleToHand()
end
-- 第二个效果发动时的目标选择及操作信息登记：从自己墓地选1张带「核成」字段的卡作为对象，并声明回手牌。
function c32314730.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c32314730.filter(chkc) end
	-- 发动合法性检查：确认自己墓地存在至少1张符合条件的「核成」卡可选。
	if chk==0 then return Duel.IsExistingTarget(c32314730.filter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要加入手牌的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从自己墓地选择1张符合条件的「核成」卡作为效果对象，并登记为连锁对象卡。
	local g=Duel.SelectTarget(tp,c32314730.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 向系统登记操作信息：本次效果处理将把1张对象卡返回手牌（供后续相关效果判定使用）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果处理阶段：将目标卡加入持有者手牌，并向对方玩家展示。
function c32314730.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果发动时选择的对象卡（即目标卡）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡以效果原因送回其持有者的手牌。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 将刚加入手牌的目标卡展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,tc)
	end
end
