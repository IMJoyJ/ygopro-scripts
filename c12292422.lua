--標本の閲覧
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：把手卡1张「化石融合」给对方观看才能发动。从手卡把1只怪兽送去墓地，宣言种族和等级各1个。对方把自身的手卡·卡组确认，有持有宣言的种族·等级的怪兽的场合，那之内的1只送去墓地。
function c12292422.initial_effect(c)
	-- 添加卡名关联，使卡组检测系统知道此卡记载着「化石融合」(密码59419719)
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
-- 过滤函数：检查卡片是否为「化石融合」且未公开（在手卡中隐藏）
function c12292422.cfilter(c)
	return c:IsCode(59419719) and not c:IsPublic()
end
-- 代价处理：检查手卡是否有「化石融合」可给对方确认，并执行展示和洗牌
function c12292422.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检测：确认玩家手卡中存在未公开的「化石融合」
	if chk==0 then return Duel.IsExistingMatchingCard(c12292422.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 发送提示信息，要求玩家选择要给对方确认的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 让玩家从手卡中选择1张「化石融合」
	local g=Duel.SelectMatchingCard(tp,c12292422.cfilter,tp,LOCATION_HAND,0,1,1,nil)
	-- 将选中的卡展示给对方玩家确认
	Duel.ConfirmCards(1-tp,g)
	-- 洗切玩家手卡（重置手卡检测状态）
	Duel.ShuffleHand(tp)
end
-- 过滤函数：检查卡片是否未公开或是怪兽（用于检测对方是否有可确认的卡）
function c12292422.tgfilter0(c)
	return not c:IsPublic() or c:IsType(TYPE_MONSTER)
end
-- 目标处理：检测玩家手卡是否有怪兽，以及对方是否有卡组或手卡可确认
function c12292422.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 检测玩家手卡是否存在怪兽，若无则不能发动
		if not Duel.IsExistingMatchingCard(Card.IsType,tp,LOCATION_HAND,0,1,nil,TYPE_MONSTER) then return false end
		-- 获取对方卡组数量
		local mc=Duel.GetFieldGroupCount(tp,0,LOCATION_DECK)
		-- 获取对方手卡
		local g=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
		return mc>0 or g and g:IsExists(c12292422.tgfilter0,1,nil) end
	-- 设置操作信息，宣告将执行送墓效果
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 过滤函数：检查卡片是否符合宣言的种族和等级且可送墓
function c12292422.tgfilter(c,race,lv)
	return c:IsType(TYPE_MONSTER) and c:IsRace(race) and c:IsLevel(lv) and c:IsAbleToGrave()
end
-- 效果处理：从手卡选怪送墓，宣言种族和等级，然后对方确认手卡·卡组并送墓符合条件的怪
function c12292422.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 发送提示信息，要求玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从手卡中选择1只怪兽
	local g=Duel.SelectMatchingCard(tp,Card.IsType,tp,LOCATION_HAND,0,1,1,nil,TYPE_MONSTER)
	-- 若成功送墓且怪兽到达墓地，则执行后续处理（宣言种族和等级）
	if g:GetCount()>0 and Duel.SendtoGrave(g,REASON_EFFECT)>0 and g:GetFirst():IsLocation(LOCATION_GRAVE) then
		-- 发送提示信息，要求玩家宣言种族
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RACE)  --"请选择要宣言的种族"
		-- 让玩家宣言1个种族（从全种族中选择）
		local race=Duel.AnnounceRace(tp,1,RACE_ALL)
		-- 发送提示信息，要求玩家宣言等级
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_LVRANK)
		-- 让玩家宣言1个等级（1-12级）
		local lv=Duel.AnnounceLevel(tp)
		-- 获取对方的手卡和卡组
		local cg=Duel.GetFieldGroup(tp,0,LOCATION_HAND+LOCATION_DECK)
		-- 让玩家确认对方的全部手卡和卡组
		Duel.ConfirmCards(1-tp,cg)
		-- 发送提示信息，要求对方选择要送去墓地的卡
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		local sg=cg:FilterSelect(1-tp,c12292422.tgfilter,1,1,nil,race,lv)
		if sg:GetCount()>0 then
			-- 将对方选中的卡片送去墓地
			Duel.SendtoGrave(sg,REASON_EFFECT)
		end
	end
end
