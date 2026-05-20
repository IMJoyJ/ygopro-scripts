--サイバネティック・ホライゾン
-- 效果：
-- 这个卡名在规则上也当作「电子暗黑」卡使用。这个卡名的卡在1回合只能发动1张，这张卡发动的回合，自己不是机械族怪兽不能从额外卡组特殊召唤。
-- ①：从手卡以及卡组各把1只龙族·机械族的「电子」怪兽送去墓地才能发动（相同属性最多1只）。从卡组把1只龙族·机械族的「电子」怪兽加入手卡，从额外卡组把1只机械族「电子」融合怪兽送去墓地。
function c63031396.initial_effect(c)
	-- ①：从手卡以及卡组各把1只龙族·机械族的「电子」怪兽送去墓地才能发动（相同属性最多1只）。从卡组把1只龙族·机械族的「电子」怪兽加入手卡，从额外卡组把1只机械族「电子」融合怪兽送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,63031396+EFFECT_COUNT_CODE_OATH)
	e1:SetCost(c63031396.cost)
	e1:SetTarget(c63031396.target)
	e1:SetOperation(c63031396.activate)
	c:RegisterEffect(e1)
	-- 注册一个自定义活动计数器，用于检测本回合从额外卡组特殊召唤非机械族怪兽的行为
	Duel.AddCustomActivityCounter(63031396,ACTIVITY_SPSUMMON,c63031396.counterfilter)
end
-- 计数器的过滤函数，筛选非额外卡组特殊召唤的怪兽，或者是机械族的怪兽
function c63031396.counterfilter(c)
	return not c:IsSummonLocation(LOCATION_EXTRA) or c:IsRace(RACE_MACHINE)
end
-- 过滤手卡或卡组中可以作为发动Cost送去墓地的龙族或机械族「电子」怪兽
function c63031396.costfilter(c)
	return c:IsRace(RACE_DRAGON+RACE_MACHINE) and c:IsSetCard(0x93) and c:IsAbleToGraveAsCost()
end
-- 过滤卡组中可以加入手卡的龙族或机械族「电子」怪兽
function c63031396.thfilter(c)
	return c:IsRace(RACE_DRAGON+RACE_MACHINE) and c:IsSetCard(0x93) and c:IsAbleToHand()
end
-- 检查选定的卡片组是否满足“手卡和卡组各1张”、“属性不同”且“卡组中仍有可检索的卡”的条件
function c63031396.fselect(g,tp)
	local sg=g:Clone()
	local res=true
	-- 遍历选定的卡片组
	for c in aux.Next(sg) do
		res=res and not sg:IsExists(Card.IsAttribute,1,c,c:GetAttribute())
	end
	-- 返回是否满足“选定卡片分别来自手卡和卡组”、“属性不同”且“卡组中存在不属于选定卡片且满足检索条件的卡”
	return g:GetClassCount(Card.GetLocation)==g:GetCount() and res and Duel.IsExistingMatchingCard(c63031396.thfilter,tp,LOCATION_DECK,0,1,g)
end
-- 效果发动的Cost处理函数，检查是否满足发动条件并执行Cost
function c63031396.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取手卡和卡组中所有满足Cost过滤条件的卡片
	local g=Duel.GetMatchingGroup(c63031396.costfilter,tp,LOCATION_HAND+LOCATION_DECK,0,nil)
	-- 在chk==0时，检查本回合是否未从额外卡组特殊召唤过非机械族怪兽
	if chk==0 then return Duel.GetCustomActivityCount(63031396,tp,ACTIVITY_SPSUMMON)==0
		and g:CheckSubGroup(c63031396.fselect,2,2,tp) end
	-- 这张卡发动的回合，自己不是机械族怪兽不能从额外卡组特殊召唤。①：从手卡以及卡组各把1只龙族·机械族的「电子」怪兽送去墓地才能发动（相同属性最多1只）。从卡组把1只龙族·机械族的「电子」怪兽加入手卡，从额外卡组把1只机械族「电子」融合怪兽送去墓地。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c63031396.splimit)
	-- 注册不能从额外卡组特殊召唤非机械族怪兽的玩家效果
	Duel.RegisterEffect(e1,tp)
	-- 给玩家发送提示信息，要求选择送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	local sg=g:SelectSubGroup(tp,c63031396.fselect,false,2,2,tp)
	-- 将选定的2张卡作为发动Cost送去墓地
	Duel.SendtoGrave(sg,REASON_COST)
end
-- 限制不能从额外卡组特殊召唤非机械族的怪兽
function c63031396.splimit(e,c)
	return c:IsLocation(LOCATION_EXTRA) and not c:IsRace(RACE_MACHINE)
end
-- 过滤额外卡组中可以送去墓地的机械族「电子」融合怪兽
function c63031396.tgfilter(c)
	return c:IsRace(RACE_MACHINE) and c:IsSetCard(0x93) and c:IsType(TYPE_FUSION) and c:IsAbleToGrave()
end
-- 效果发动的Target处理函数，检查卡组和额外卡组中是否存在符合条件的卡
function c63031396.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在chk==0时，检查卡组中是否存在可检索的龙族或机械族「电子」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c63031396.thfilter,tp,LOCATION_DECK,0,1,nil)
		-- 并且检查额外卡组中是否存在可送去墓地的机械族「电子」融合怪兽
		and Duel.IsExistingMatchingCard(c63031396.tgfilter,tp,LOCATION_EXTRA,0,1,nil) end
	-- 设置连锁处理信息，表示该效果包含从卡组将1张卡加入手卡的操作
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	-- 设置连锁处理信息，表示该效果包含从额外卡组将1张卡送去墓地的操作
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_EXTRA)
end
-- 效果发动的Operation处理函数，执行检索并送去墓地的效果
function c63031396.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 给玩家发送提示信息，要求选择加入手卡的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1只满足条件的龙族或机械族「电子」怪兽
	local tc=Duel.SelectMatchingCard(tp,c63031396.thfilter,tp,LOCATION_DECK,0,1,1,nil):GetFirst()
	-- 如果成功将选定的怪兽加入手卡
	if tc and Duel.SendtoHand(tc,nil,REASON_EFFECT)~=0 then
		-- 给对方玩家确认加入手卡的卡片
		Duel.ConfirmCards(1-tp,tc)
		-- 给玩家发送提示信息，要求选择送去墓地的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		-- 让玩家从额外卡组选择1只满足条件的机械族「电子」融合怪兽
		local g=Duel.SelectMatchingCard(tp,c63031396.tgfilter,tp,LOCATION_EXTRA,0,1,1,nil)
		if g:GetCount()>0 then
			-- 将选定的额外卡组怪兽送去墓地
			Duel.SendtoGrave(g,REASON_EFFECT)
		end
	end
end
