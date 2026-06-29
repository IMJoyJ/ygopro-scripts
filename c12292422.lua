--標本の閲覧
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：把手卡1张「化石融合」给对方观看才能发动。从手卡把1只怪兽送去墓地，宣言种族和等级各1个。对方把自身的手卡·卡组确认，有持有宣言的种族·等级的怪兽的场合，那之内的1只送去墓地。
function c12292422.initial_effect(c)
	-- 将卡片「化石融合」的卡号放入此卡的关联卡片列表中
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
-- 手卡「化石融合」卡片的过滤条件
function c12292422.cfilter(c)
	return c:IsCode(59419719) and not c:IsPublic()
end
-- 发动效果的代价支付流程
function c12292422.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡中是否存在未公开的「化石融合」
	if chk==0 then return Duel.IsExistingMatchingCard(c12292422.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 向玩家发送提示，请选择给对方确认 the card
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 选择手卡中1张未公开的「化石融合」
	local g=Duel.SelectMatchingCard(tp,c12292422.cfilter,tp,LOCATION_HAND,0,1,1,nil)
	-- 向对方玩家展示作为代价发动的「化石融合」
	Duel.ConfirmCards(1-tp,g)
	-- 将自己展示过卡片的手卡重新洗牌
	Duel.ShuffleHand(tp)
end
-- 手卡中未公开或属于怪兽卡的卡片条件判断
function c12292422.tgfilter0(c)
	return not c:IsPublic() or c:IsType(TYPE_MONSTER)
end
-- 效果发动准备
function c12292422.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 检查自己手卡中是否存在怪兽卡
		if not Duel.IsExistingMatchingCard(Card.IsType,tp,LOCATION_HAND,0,1,nil,TYPE_MONSTER) then return false end
		-- 获取对方卡组中的卡片数量
		local mc=Duel.GetFieldGroupCount(tp,0,LOCATION_DECK)
		-- 获取对方手卡中的卡片组
		local g=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
		return mc>0 or g and g:IsExists(c12292422.tgfilter0,1,nil) end
	-- 设置操作信息为将对方卡组/手卡的卡片送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 对方需送去墓地的符合宣言种族和等级的怪兽的过滤条件
function c12292422.tgfilter(c,race,lv)
	return c:IsType(TYPE_MONSTER) and c:IsRace(race) and c:IsLevel(lv) and c:IsAbleToGrave()
end
-- 效果的执行
function c12292422.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家发送提示，请选择送去墓地的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从手卡选择1只怪兽送去墓地
	local g=Duel.SelectMatchingCard(tp,Card.IsType,tp,LOCATION_HAND,0,1,1,nil,TYPE_MONSTER)
	-- 若自己成功把手卡1只怪兽送去墓地，则继续处理
	if g:GetCount()>0 and Duel.SendtoGrave(g,REASON_EFFECT)>0 and g:GetFirst():IsLocation(LOCATION_GRAVE) then
		-- 向玩家发送提示，请选择要宣言的种族
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RACE)  --"请选择要宣言的种族"
		-- 由玩家宣言1个怪兽种族
		local race=Duel.AnnounceRace(tp,1,RACE_ALL)
		-- 向玩家发送提示，请选择要宣言的等级
		Duel.Hint(HINT_SELECTMSG,tp,HINGMSG_LVRANK)
		-- 由玩家宣言1个怪兽等级
		local lv=Duel.AnnounceLevel(tp)
		-- 获取对方的全部手卡和卡组的卡片组
		local cg=Duel.GetFieldGroup(tp,0,LOCATION_HAND+LOCATION_DECK)
		-- 自己确认对方的手卡和卡组的所有卡片
		Duel.ConfirmCards(1-tp,cg)
		-- 向对方玩家发送提示，请选择送去墓地的卡
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		local sg=cg:FilterSelect(1-tp,c12292422.tgfilter,1,1,nil,race,lv)
		if sg:GetCount()>0 then
			-- 对方玩家选择其符合宣言种族和等级的1只怪兽送去墓地
			Duel.SendtoGrave(sg,REASON_EFFECT)
		end
	end
end
