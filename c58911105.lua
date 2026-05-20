--成金忍者
-- 效果：
-- 1回合1次，从手卡把1张陷阱卡送去墓地才能发动。从卡组把1只4星以下的名字带有「忍者」的怪兽表侧守备表示或者里侧守备表示特殊召唤。
function c58911105.initial_effect(c)
	-- 1回合1次，从手卡把1张陷阱卡送去墓地才能发动。从卡组把1只4星以下的名字带有「忍者」的怪兽表侧守备表示或者里侧守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(58911105,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_MSET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(c58911105.cost)
	e1:SetTarget(c58911105.target)
	e1:SetOperation(c58911105.operation)
	c:RegisterEffect(e1)
end
-- 过滤条件：手牌中可以作为代价送去墓地的陷阱卡
function c58911105.costfilter(c)
	return c:IsType(TYPE_TRAP) and c:IsAbleToGraveAsCost()
end
-- 发动代价：从手卡把1张陷阱卡送去墓地
function c58911105.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段，检查手牌中是否存在可作为代价送去墓地的陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(c58911105.costfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 提示玩家选择要送去墓地的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从手牌选择1张满足条件的陷阱卡
	local cg=Duel.SelectMatchingCard(tp,c58911105.costfilter,tp,LOCATION_HAND,0,1,1,nil)
	-- 将选中的卡作为发动代价送去墓地
	Duel.SendtoGrave(cg,REASON_COST)
end
-- 过滤条件：卡组中等级4以下、名字带有「忍者」且可以守备表示特殊召唤的怪兽
function c58911105.filter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsSetCard(0x2b) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_DEFENSE)
end
-- 发动准备：检查怪兽区域空位以及卡组中是否存在可特殊召唤的怪兽
function c58911105.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段，检查自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 在发动阶段，检查卡组中是否存在满足条件的「忍者」怪兽
		and Duel.IsExistingMatchingCard(c58911105.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置效果处理信息：包含从卡组特殊召唤1只怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：从卡组选择1只满足条件的「忍者」怪兽以守备表示特殊召唤，若是里侧特殊召唤则给对方确认
function c58911105.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时，若自己场上已无空余的怪兽区域则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组选择1只满足条件的「忍者」怪兽
	local g=Duel.SelectMatchingCard(tp,c58911105.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if not tc then return end
	-- 将选择的怪兽以守备表示特殊召唤，并判断是否为里侧守备表示
	if Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_DEFENSE)~=0 and tc:IsFacedown() then
		-- 若特殊召唤的怪兽为里侧守备表示，则给对方玩家确认该卡
		Duel.ConfirmCards(1-tp,tc)
	end
end
