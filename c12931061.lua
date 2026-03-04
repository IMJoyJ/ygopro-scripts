--U.A.ハイパー・スタジアム
-- 效果：
-- 这个卡名在规则上也当作「方程式运动员」卡使用。这个卡名的卡在1回合只能发动1张。
-- ①：作为这张卡的发动时的效果处理，可以从卡组把1只「超级运动员」怪兽或者「方程式运动员」怪兽加入手卡或从自己墓地选1张「超级运动员体育场」加入手卡。
-- ②：把手卡1张场地魔法卡给对方观看，支付1000基本分才能发动。这个回合，自己在通常召唤外加上只有1次，可以把1只「超级运动员」怪兽或者「方程式运动员」怪兽召唤。
function c12931061.initial_effect(c)
	-- 为卡片注册「方程式运动员」卡的代码列表，用于后续效果判断
	aux.AddCodeList(c,19814508)
	-- ①：作为这张卡的发动时的效果处理，可以从卡组把1只「超级运动员」怪兽或者「方程式运动员」怪兽加入手卡或从自己墓地选1张「超级运动员体育场」加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_GRAVE_ACTION)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCountLimit(1,12931061+EFFECT_COUNT_CODE_OATH)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c12931061.target)
	e1:SetOperation(c12931061.activate)
	c:RegisterEffect(e1)
	-- ②：把手卡1张场地魔法卡给对方观看，支付1000基本分才能发动。这个回合，自己在通常召唤外加上只有1次，可以把1只「超级运动员」怪兽或者「方程式运动员」怪兽召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(12931061,1))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCost(c12931061.excost)
	e2:SetTarget(c12931061.extg)
	e2:SetOperation(c12931061.exop)
	c:RegisterEffect(e2)
end
-- 效果处理函数，用于处理发动时的效果
function c12931061.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
end
-- 检索过滤函数，用于筛选可加入手牌的卡
function c12931061.thfilter(c)
	if not c:IsAbleToHand() then return false end
	return c:IsLocation(LOCATION_DECK) and c:IsSetCard(0xb2,0x107) and c:IsType(TYPE_MONSTER)
		or c:IsLocation(LOCATION_GRAVE) and c:IsCode(19814508)
end
-- 发动效果处理函数，用于处理效果的发动
function c12931061.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取满足条件的卡组和墓地中的卡
	local g=Duel.GetMatchingGroup(c12931061.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,nil)
	local sel=1
	-- 提示玩家选择是否将卡加入手牌
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(12931061,0))  --"是否把卡加入手卡？"
	if g:GetCount()>0 then
		-- 选择选项：是否将卡加入手牌
		sel=Duel.SelectOption(tp,1213,1214)
	else
		-- 当没有满足条件的卡时，选择默认选项
		sel=Duel.SelectOption(tp,1214)+1
	end
	if sel==0 then
		-- 提示玩家选择要加入手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local sg=g:Select(tp,1,1,nil)
		-- 将选中的卡送入手牌
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		-- 向对方确认所选卡
		Duel.ConfirmCards(1-tp,sg)
	end
end
-- 场地魔法卡过滤函数，用于判断是否为未公开的场地魔法卡
function c12931061.cfilter(c)
	return c:IsType(TYPE_FIELD) and not c:IsPublic()
end
-- 效果支付费用处理函数，用于处理效果发动的费用
function c12931061.excost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否有未公开的场地魔法卡在手牌中
	if chk==0 then return Duel.IsExistingMatchingCard(c12931061.cfilter,tp,LOCATION_HAND,0,1,nil)
		-- 检查是否能支付1000基本分
		and Duel.CheckLPCost(tp,1000)
	end
	-- 提示玩家选择要确认的场地魔法卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	-- 选择一张未公开的场地魔法卡
	local g=Duel.SelectMatchingCard(tp,c12931061.cfilter,tp,LOCATION_HAND,0,1,1,nil)
	-- 向对方确认所选场地魔法卡
	Duel.ConfirmCards(1-tp,g)
	-- 将玩家手牌洗切
	Duel.ShuffleHand(tp)
	-- 支付1000基本分
	Duel.PayLPCost(tp,1000)
end
-- 效果目标处理函数，用于判断效果是否可以发动
function c12931061.extg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否已使用过此效果
	if chk==0 then return Duel.GetFlagEffect(tp,12931061)==0
		-- 检查玩家是否可以通常召唤和额外召唤
		and Duel.IsPlayerCanSummon(tp) and Duel.IsPlayerCanAdditionalSummon(tp) end
end
-- 效果发动处理函数，用于处理效果的发动
function c12931061.exop(e,tp,eg,ep,ev,re,r,rp)
	-- 创建并注册额外召唤次数效果，使玩家在本回合可以额外召唤一次超级运动员怪兽
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(12931061,2))  --"使用「超级运动员高超体育场」的效果召唤"
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetTargetRange(LOCATION_HAND+LOCATION_MZONE,0)
	e1:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
	e1:SetTarget(c12931061.estg)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将效果注册到全局环境
	Duel.RegisterEffect(e1,tp)
	-- 注册标识效果，防止此效果在本回合再次发动
	Duel.RegisterFlagEffect(tp,12931061,RESET_PHASE+PHASE_END,0,1)
end
-- 额外召唤次数效果的目标过滤函数，用于判断是否为超级运动员怪兽
function c12931061.estg(e,c)
	return c:IsSetCard(0xb2,0x107)
end
