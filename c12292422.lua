--標本の閲覧
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：把手卡1张「化石融合」给对方观看才能发动。从手卡把1只怪兽送去墓地，宣言种族和等级各1个。对方把自身的手卡·卡组确认，有持有宣言的种族·等级的怪兽的场合，那之内的1只送去墓地。
function c12292422.initial_effect(c)
	-- 为卡片注册「化石融合」的卡片代码，用于后续效果判断
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
-- 过滤函数：检查手牌中是否存在未公开的「化石融合」
function c12292422.cfilter(c)
	return c:IsCode(59419719) and not c:IsPublic()
end
-- 效果发动时的费用处理函数
function c12292422.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家手牌中是否存在至少1张「化石融合」
	if chk==0 then return Duel.IsExistingMatchingCard(c12292422.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 提示玩家选择要确认的「化石融合」
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	-- 选择1张手牌中的「化石融合」并确认给对方
	local g=Duel.SelectMatchingCard(tp,c12292422.cfilter,tp,LOCATION_HAND,0,1,1,nil)
	-- 向对方玩家展示所选的「化石融合」
	Duel.ConfirmCards(1-tp,g)
	-- 将玩家手牌洗切
	Duel.ShuffleHand(tp)
end
-- 过滤函数：检查手牌或卡组中是否存在未公开的怪兽
function c12292422.tgfilter0(c)
	return not c:IsPublic() or c:IsType(TYPE_MONSTER)
end
-- 效果发动时的目标选择函数
function c12292422.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 检查玩家手牌中是否存在至少1只怪兽
		if not Duel.IsExistingMatchingCard(Card.IsType,tp,LOCATION_HAND,0,1,nil,TYPE_MONSTER) then return false end
		-- 获取玩家卡组中卡的数量
		local mc=Duel.GetFieldGroupCount(tp,0,LOCATION_DECK)
		-- 获取玩家手牌中的卡组
		local g=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
		return mc>0 or g and g:IsExists(c12292422.tgfilter0,1,nil) end
	-- 设置连锁操作信息，指定将要处理的送去墓地效果
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 过滤函数：检查是否持有指定种族和等级的怪兽
function c12292422.tgfilter(c,race,lv)
	return c:IsType(TYPE_MONSTER) and c:IsRace(race) and c:IsLevel(lv) and c:IsAbleToGrave()
end
-- 效果发动时的处理函数
function c12292422.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送去墓地的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	-- 选择1张手牌中的怪兽并送去墓地
	local g=Duel.SelectMatchingCard(tp,Card.IsType,tp,LOCATION_HAND,0,1,1,nil,TYPE_MONSTER)
	-- 判断是否成功将怪兽送去墓地
	if g:GetCount()>0 and Duel.SendtoGrave(g,REASON_EFFECT) and g:GetFirst():IsLocation(LOCATION_GRAVE) then
		-- 提示玩家宣言种族
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RACE)
		-- 让玩家宣言1个种族
		local race=Duel.AnnounceRace(tp,1,RACE_ALL)
		-- 提示玩家宣言等级
		Duel.Hint(HINT_SELECTMSG,tp,HINGMSG_LVRANK)
		-- 让玩家宣言1个等级
		local lv=Duel.AnnounceLevel(tp)
		-- 获取玩家手牌和卡组中的所有卡
		local cg=Duel.GetFieldGroup(tp,0,LOCATION_HAND+LOCATION_DECK)
		-- 向对方玩家确认其手牌和卡组中的所有卡
		Duel.ConfirmCards(1-tp,cg)
		-- 提示对方玩家选择要送去墓地的卡
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_TOGRAVE)
		local sg=cg:FilterSelect(1-tp,c12292422.tgfilter,1,1,nil,race,lv)
		if sg:GetCount()>0 then
			-- 将符合条件的卡送去墓地
			Duel.SendtoGrave(sg,REASON_EFFECT)
		end
	end
end
