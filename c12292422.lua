--標本の閲覧
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：把手卡1张「化石融合」给对方观看才能发动。从手卡把1只怪兽送去墓地，宣言种族和等级各1个。对方把自身的手卡·卡组确认，有持有宣言的种族·等级的怪兽的场合，那之内的1只送去墓地。
function c12292422.initial_effect(c)
	-- 登记这张卡上记载着「化石融合」（59419719）的卡名
	aux.AddCodeList(c,59419719)
	-- 这个卡名的卡在1回合只能发动1张。①：把手卡1张「化石融合」给对方观看才能发动。从手卡把1只怪兽送去墓地，宣言种族和等级各1个。对方把自身的手卡·卡组确认，有持有宣言的种族·等级的怪兽的场合，那之内的1只送去墓地。
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
-- 过滤条件：是「化石融合」（59419719）且未公开的卡
function c12292422.cfilter(c)
	return c:IsCode(59419719) and not c:IsPublic()
end
-- 发动代价：把手卡1张「化石融合」给对方观看（确认），然后洗切手卡
function c12292422.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡是否存在可以给对方观看的「化石融合」
	if chk==0 then return Duel.IsExistingMatchingCard(c12292422.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 提示玩家选择要给对方确认的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 从手卡选择1张未公开的「化石融合」
	local g=Duel.SelectMatchingCard(tp,c12292422.cfilter,tp,LOCATION_HAND,0,1,1,nil)
	-- 把选择的「化石融合」给对方确认（观看）
	Duel.ConfirmCards(1-tp,g)
	-- 洗切自己的手卡
	Duel.ShuffleHand(tp)
end
-- 过滤条件：未公开的卡或者是怪兽卡（用于判断对方手卡中是否有可确认的怪兽）
function c12292422.tgfilter0(c)
	return not c:IsPublic() or c:IsType(TYPE_MONSTER)
end
-- 目标设定：检查自己手卡有怪兽且对方卡组或手卡中存在可确认的卡，并设置送去墓地的操作信息
function c12292422.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 若自己手卡没有怪兽则无法发动
		if not Duel.IsExistingMatchingCard(Card.IsType,tp,LOCATION_HAND,0,1,nil,TYPE_MONSTER) then return false end
		-- 获取对方卡组卡的数量
		local mc=Duel.GetFieldGroupCount(tp,0,LOCATION_DECK)
		-- 获取对方手卡的卡组
		local g=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
		return mc>0 or g and g:IsExists(c12292422.tgfilter0,1,nil) end
	-- 设置操作信息：把1张卡从卡组送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 过滤条件：持有宣言的种族·等级且能送去墓地的怪兽
function c12292422.tgfilter(c,race,lv)
	return c:IsType(TYPE_MONSTER) and c:IsRace(race) and c:IsLevel(lv) and c:IsAbleToGrave()
end
-- 效果处理：从手卡把1只怪兽送去墓地，宣言种族和等级各1个，对方确认自身手卡·卡组并把其中符合条件的1只怪兽送去墓地
function c12292422.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从自己手卡选择1只怪兽
	local g=Duel.SelectMatchingCard(tp,Card.IsType,tp,LOCATION_HAND,0,1,1,nil,TYPE_MONSTER)
	-- 若成功把所选怪兽以效果送去墓地则继续后续处理
	if g:GetCount()>0 and Duel.SendtoGrave(g,REASON_EFFECT)>0 and g:GetFirst():IsLocation(LOCATION_GRAVE) then
		-- 提示玩家选择要宣言的种族
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RACE)  --"请选择要宣言的种族"
		-- 让玩家宣言1个种族
		local race=Duel.AnnounceRace(tp,1,RACE_ALL)
		-- 提示玩家选择要宣言的等级
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_LVRANK)
		-- 让玩家宣言1个等级
		local lv=Duel.AnnounceLevel(tp)
		-- 获取对方手卡和卡组的全部卡
		local cg=Duel.GetFieldGroup(tp,0,LOCATION_HAND+LOCATION_DECK)
		-- 让对方确认自身的手卡·卡组
		Duel.ConfirmCards(1-tp,cg)
		-- 提示对方选择要送去墓地的卡
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		local sg=cg:FilterSelect(1-tp,c12292422.tgfilter,1,1,nil,race,lv)
		if sg:GetCount()>0 then
			-- 对方把选出的持有宣言种族·等级的1只怪兽送去墓地
			Duel.SendtoGrave(sg,REASON_EFFECT)
		end
	end
end
