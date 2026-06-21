--海晶乙女コーラルトライアングル
-- 效果：
-- 「海晶少女」怪兽2只以上
-- 这个卡名的①②的效果1回合各能使用1次，这些效果发动的回合，自己不是水属性怪兽不能特殊召唤。
-- ①：从手卡把1只水属性怪兽送去墓地才能发动。从卡组把1张「海晶少女」陷阱卡加入手卡。
-- ②：只有对方场上才有怪兽存在的场合，把墓地的这张卡除外才能发动。连接标记合计直到变成3为止，从自己墓地选水属性连接怪兽任意数量特殊召唤。
function c84546257.initial_effect(c)
	-- 设置连接召唤手续：需要2只以上的「海晶少女」怪兽作为连接素材。
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkSetCard,0x12b),2)
	c:EnableReviveLimit()
	-- ①：从手卡把1只水属性怪兽送去墓地才能发动。从卡组把1张「海晶少女」陷阱卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,84546257)
	e1:SetCost(c84546257.thcost)
	e1:SetTarget(c84546257.thtg)
	e1:SetOperation(c84546257.thop)
	c:RegisterEffect(e1)
	-- ②：只有对方场上才有怪兽存在的场合，把墓地的这张卡除外才能发动。连接标记合计直到变成3为止，从自己墓地选水属性连接怪兽任意数量特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,84546258)
	e2:SetCondition(c84546257.spcon)
	e2:SetCost(c84546257.spcost)
	e2:SetTarget(c84546257.sptg)
	e2:SetOperation(c84546257.spop)
	c:RegisterEffect(e2)
	-- 注册一个自定义活动计数器，用于记录本回合非水属性怪兽的特殊召唤次数。
	Duel.AddCustomActivityCounter(84546257,ACTIVITY_SPSUMMON,c84546257.counterfilter)
end
-- 计数器过滤函数：如果是水属性怪兽，则不计入非水属性特殊召唤的计数。
function c84546257.counterfilter(c)
	return c:IsAttribute(ATTRIBUTE_WATER) and c:IsFaceup()
end
-- 效果发动开销与誓约限制处理：检查本回合是否未特殊召唤过非水属性怪兽，并注册本回合不能特殊召唤非水属性怪兽的誓约效果。
function c84546257.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动效果前，检查本回合玩家是否没有特殊召唤过非水属性怪兽。
	if chk==0 then return Duel.GetCustomActivityCount(84546257,tp,ACTIVITY_SPSUMMON)==0 end
	-- 这些效果发动的回合，自己不是水属性怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c84546257.splimit)
	-- 给玩家注册不能特殊召唤非水属性怪兽的限制效果。
	Duel.RegisterEffect(e1,tp)
end
-- 特殊召唤限制：限制不能特殊召唤非水属性怪兽。
function c84546257.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsAttribute(ATTRIBUTE_WATER)
end
-- 过滤手卡中可以作为发动开销送去墓地的水属性怪兽。
function c84546257.costfilter(c)
	return c:IsAttribute(ATTRIBUTE_WATER) and c:IsAbleToGraveAsCost()
end
-- 效果①的发动开销（Cost）处理：检查并执行送去墓地以及誓约限制。
function c84546257.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return c84546257.cost(e,tp,eg,ep,ev,re,r,rp,0)
		-- 检查手卡中是否存在至少1只可以送去墓地的水属性怪兽。
		and Duel.IsExistingMatchingCard(c84546257.costfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 提示玩家选择要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从手卡选择1只满足条件的水属性怪兽。
	local g=Duel.SelectMatchingCard(tp,c84546257.costfilter,tp,LOCATION_HAND,0,1,1,nil)
	-- 将选择的怪兽作为发动开销送去墓地。
	Duel.SendtoGrave(g,REASON_COST)
	c84546257.cost(e,tp,eg,ep,ev,re,r,rp,1)
end
-- 过滤卡组中可以加入手卡的「海晶少女」陷阱卡。
function c84546257.thfilter(c)
	return c:IsSetCard(0x12b) and c:IsType(TYPE_TRAP) and c:IsAbleToHand()
end
-- 效果①的靶向（Target）处理：检查卡组中是否存在可检索的卡，并设置检索操作信息。
function c84546257.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1张「海晶少女」陷阱卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c84546257.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁处理信息：从卡组将1张卡加入手卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果①的效果处理（Operation）：从卡组选1张「海晶少女」陷阱卡加入手卡。
function c84546257.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1张「海晶少女」陷阱卡。
	local g=Duel.SelectMatchingCard(tp,c84546257.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡加入玩家手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对方玩家确认加入手卡的卡。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 效果②的发动条件（Condition）检查：只有对方场上才有怪兽存在。
function c84546257.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上的怪兽数量是否为0。
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
		-- 检查对方场上的怪兽数量是否大于0。
		and Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0
end
-- 效果②的发动开销（Cost）处理：检查并执行将墓地的这张卡除外，以及誓约限制。
function c84546257.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return c84546257.cost(e,tp,eg,ep,ev,re,r,rp,0)
		and e:GetHandler():IsAbleToRemoveAsCost() end
	-- 将墓地的这张卡表侧表示除外。
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_COST)
	c84546257.cost(e,tp,eg,ep,ev,re,r,rp,1)
end
-- 过滤墓地中可以特殊召唤的水属性连接怪兽。
function c84546257.spfilter(c,e,tp)
	return c:IsAttribute(ATTRIBUTE_WATER) and c:IsType(TYPE_LINK) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 子组选择条件：所选怪兽的连接标记（Link Rating）合计必须刚好等于3。
function c84546257.fselect(sg)
	return sg:GetSum(Card.GetLink)==3
end
-- 动态选择检查：所选怪兽的连接标记合计不能超过3。
function c84546257.gcheck(sg)
	return sg:GetSum(Card.GetLink)<=3
end
-- 效果②的靶向（Target）处理：检查墓地中是否存在满足连接标记合计为3的水属性连接怪兽组合，并设置特殊召唤操作信息。
function c84546257.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取自己场上可用的怪兽区域数量。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if ft>1 and Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 获取自己墓地中除这张卡以外所有满足条件的水属性连接怪兽。
	local g=Duel.GetMatchingGroup(c84546257.spfilter,tp,LOCATION_GRAVE,0,e:GetHandler(),e,tp)
	if chk==0 then
		if ft<=0 then return false end
		-- 设置辅助选择的动态检查函数，限制选择过程中的连接标记总和不超过3。
		aux.GCheckAdditional=c84546257.gcheck
		local res=g:CheckSubGroup(c84546257.fselect,1,ft)
		-- 重置辅助选择的动态检查函数。
		aux.GCheckAdditional=nil
		return res
	end
	-- 设置连锁处理信息：从墓地特殊召唤怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
-- 效果②的效果处理（Operation）：从自己墓地选择任意数量水属性连接怪兽（连接标记合计为3）特殊召唤。
function c84546257.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前自己场上可用的怪兽区域数量。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if ft>1 and Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 获取自己墓地中不受「王家之谷」影响且满足条件的水属性连接怪兽。
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(c84546257.spfilter),tp,LOCATION_GRAVE,0,nil,e,tp)
	-- 提示玩家选择要特殊召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 在玩家选择时，设置辅助选择的动态检查函数，限制连接标记总和不超过3。
	aux.GCheckAdditional=c84546257.gcheck
	local sg=g:SelectSubGroup(tp,c84546257.fselect,false,1,ft)
	-- 在玩家选择完毕后，重置辅助选择的动态检查函数。
	aux.GCheckAdditional=nil
	if sg then
		-- 将选择的怪兽以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
	end
end
