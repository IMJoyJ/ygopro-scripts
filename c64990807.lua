--氷結界の三方陣
-- 效果：
-- ①：把卡名不同的手卡3只「冰结界」怪兽给对方观看，以对方场上1张卡为对象才能发动。那张对方的卡破坏，从手卡把1只「冰结界」怪兽特殊召唤。
function c64990807.initial_effect(c)
	-- ①：把卡名不同的手卡3只「冰结界」怪兽给对方观看，以对方场上1张卡为对象才能发动。那张对方的卡破坏，从手卡把1只「冰结界」怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCost(c64990807.cost)
	e1:SetTarget(c64990807.target)
	e1:SetOperation(c64990807.activate)
	c:RegisterEffect(e1)
end
-- 过滤手牌中未公开的「冰结界」怪兽
function c64990807.cfilter(c)
	return c:IsSetCard(0x2f) and c:IsType(TYPE_MONSTER) and not c:IsPublic()
end
-- 发动代价：展示手牌中3张卡名不同的「冰结界」怪兽
function c64990807.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取手牌中所有未公开的「冰结界」怪兽
	local g=Duel.GetMatchingGroup(c64990807.cfilter,tp,LOCATION_HAND,0,nil)
	if chk==0 then return g:GetClassCount(Card.GetCode)>=3 end
	-- 提示玩家选择要展示确认的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 从符合条件的卡片中选择3张卡名不同的卡
	local cg=g:SelectSubGroup(tp,aux.dncheck,false,3,3)
	-- 向对方展示选中的卡片
	Duel.ConfirmCards(1-tp,cg)
	-- 洗切自身手牌
	Duel.ShuffleHand(tp)
end
-- 过滤手牌中可以特殊召唤的「冰结界」怪兽
function c64990807.spfilter(c,e,tp)
	return c:IsSetCard(0x2f) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动时的对象选择与可行性检查
function c64990807.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsOnField() end
	-- 检查对方场上是否存在可以作为对象的目标卡片
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil)
		-- 检查自身场上是否有空余的怪兽区域
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手牌中是否存在可以特殊召唤的「冰结界」怪兽
		and Duel.IsExistingMatchingCard(c64990807.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 提示玩家选择要破坏的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上1张卡片作为效果对象
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置破坏操作的信息，包含目标卡片
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 设置特殊召唤操作的信息，包含从手牌特召1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果处理：破坏对象卡片，并从手牌特殊召唤「冰结界」怪兽
function c64990807.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的卡片
	local tc=Duel.GetFirstTarget()
	-- 若对象卡片仍存在于场上且由对方控制，则将其破坏，破坏成功时继续处理
	if tc:IsRelateToEffect(e) and tc:IsControler(1-tp) and Duel.Destroy(tc,REASON_EFFECT)~=0 then
		-- 检查怪兽区域是否仍有空位，若无则结束处理
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		-- 提示玩家选择要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从手牌选择1只满足条件的「冰结界」怪兽
		local g=Duel.SelectMatchingCard(tp,c64990807.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
		-- 将选中的怪兽以表侧表示特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
