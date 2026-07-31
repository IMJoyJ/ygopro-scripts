--標本の閲覧
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：把手卡1张「化石融合」给对方观看才能发动。从手卡把1只怪兽送去墓地，宣言种族和等级各1个。对方把自身的手卡·卡组确认，有持有宣言的种族·等级的怪兽的场合，那之内的1只送去墓地。
function c12292422.initial_effect(c)
	-- 注册卡片名称代码，用于效果文本检查（对应原文：'这个卡名的卡在1回合只能发动1张。'）
	aux.AddCodeList(c,59419719)
	-- ①：把手卡1张「化石融合」给对方观看才能发动。从手卡把1只怪兽送去墓地，宣言种族和等级各1个。对方把自身的手卡·卡组确认，有持有宣言的种族·等级的怪兽的场合，那之内的1只送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,12292422+EFFECT_COUNT_CODE_OATH)
	e1:SetCost(c12292422.cost)
	e1:SetTarget(c12292422.target)
	e1:SetOperation(c12292422.operation)
	c:RegisterEffect(e1)
end
-- 定义过滤函数，用于检查卡片名称代码（对应原文：'把手卡1张「化石融合」给对方观看才能发动。」）
function c12292422.cfilter(c)
	return c:IsCode(59419719) and not c:IsPublic()
end
-- 定义效果处理时的代价函数，用于检查并选择对方确认的卡片（对应原文：'把手卡1张「化石融合」给对方观看才能发动。」）
function c12292422.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查代价条件是否成立，即确认是否有符合条件的卡片在手牌（对应原文：'把手卡1张「化石融合」给对方观看才能发动。」）
	if chk==0 then return Duel.IsExistingMatchingCard(c12292422.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 向玩家发送提示信息，指示其进行选择（对应原文：'把手卡1张「化石融合」给对方观看才能发动。」）
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 执行选择操作，让玩家指定一张符合条件的卡片（对应原文：'把手卡1张「化石融合」给对方观看才能发动。」）
	local g=Duel.SelectMatchingCard(tp,c12292422.cfilter,tp,LOCATION_HAND,0,1,1,nil)
	-- 将选定的卡片展示给对手查看（对应原文：'把手卡1张「化石融合」给对方观看才能发动。」）
	Duel.ConfirmCards(1-tp,g)
	-- 手动洗牌玩家的手牌以重置检测状态（对应原文：'把手卡1张「化石融合」给对方观看才能发动。」）
	Duel.ShuffleHand(tp)
end
-- 定义辅助过滤函数，用于目标效果中判断卡片类型（对应原文：'从手卡把1只怪兽送去墓地...'）
function c12292422.tgfilter0(c)
	return not c:IsPublic() or c:IsType(TYPE_MONSTER)
end
-- 定义效果处理的目标函数，检查是否满足发动后的操作前提（对应原文：'从手卡把1只怪兽送去墓地...'）
function c12292422.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 检查目标条件，确保手牌中有可被选中的怪兽（对应原文：'从手卡把1只怪兽送去墓地...'）
		if not Duel.IsExistingMatchingCard(Card.IsType,tp,LOCATION_HAND,0,1,nil,TYPE_MONSTER) then return false end
		-- 统计对手卡组或玩家手卡的特定区域数量（对应原文：'对方把自身的手卡·卡组确认...'）
		local mc=Duel.GetFieldGroupCount(tp,0,LOCATION_DECK)
		-- 获取玩家当前手牌的卡片集合（对应原文：'从手卡把1只怪兽送去墓地...'）
		local g=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
		return mc>0 or g and g:IsExists(c12292422.tgfilter0,1,nil) end
	-- 设定连锁操作分类及目标位置，指示后续将卡片送入墓地（对应原文：'从手卡把1只怪兽送去墓地...'）
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 定义辅助过滤函数，根据宣告的种族和等级筛选对手的卡片（对应原文：'有持有宣言的种族·等级的怪兽...'）
function c12292422.tgfilter(c,race,lv)
	return c:IsType(TYPE_MONSTER) and c:IsRace(race) and c:IsLevel(lv) and c:IsAbleToGrave()
end
-- 定义效果发动后的具体执行流程，包括选择、宣告和确认（对应原文：'从手卡把1只怪兽送去墓地...'）
function c12292422.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 指示玩家选择一张要送入墓地的卡片（对应原文：'从手卡把1只怪兽送去墓地...'）
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 玩家从手牌中选择一只怪兽（对应原文：'从手卡把1只怪兽送去墓地...'）
	local g=Duel.SelectMatchingCard(tp,Card.IsType,tp,LOCATION_HAND,0,1,1,nil,TYPE_MONSTER)
	-- 确认怪兽已送入墓地后，准备进行后续的宣告步骤（对应原文：'宣言种族和等级各1个。...'）
	if g:GetCount()>0 and Duel.SendtoGrave(g,REASON_EFFECT)>0 and g:GetFirst():IsLocation(LOCATION_GRAVE) then
		-- 指示玩家宣言种族信息（对应原文：'对方把自身的手卡·卡组确认...'）
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RACE)  --"请选择要宣言的种族"
		-- 玩家从可选列表中选择一个种族进行宣告（对应原文：'有持有宣言的种族·等级的怪兽...'）
		local race=Duel.AnnounceRace(tp,1,RACE_ALL)
		-- 指示玩家宣告等级信息（对应原文：'有持有宣言的种族·等级的怪兽...'）
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_LVRANK)
		-- 玩家选择一个等级进行宣告（对应原文：'有持有宣言的种族·等级的怪兽...'）
		local lv=Duel.AnnounceLevel(tp)
		-- 收集对手的场地区域卡片集合用于后续确认（对应原文：'对方把自身的手卡·卡组确认...'）
		local cg=Duel.GetFieldGroup(tp,0,LOCATION_HAND+LOCATION_DECK)
		-- 将收集到的对手卡片展示给其查看（对应原文：'对方把自身的手卡·卡组确认...'）
		Duel.ConfirmCards(1-tp,cg)
		-- 指示对手从确认的卡片中选择一张送入墓地（对应原文：'那之内的1只送去墓地。...'）
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		local sg=cg:FilterSelect(1-tp,c12292422.tgfilter,1,1,nil,race,lv)
		if sg:GetCount()>0 then
			-- 执行最终操作，将符合条件的对手卡片送入墓地（对应原文：'那之内的1只送去墓地。...'）
			Duel.SendtoGrave(sg,REASON_EFFECT)
		end
	end
end
