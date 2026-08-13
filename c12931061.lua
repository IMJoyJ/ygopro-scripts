--U.A.ハイパー・スタジアム
-- 效果：
-- 这个卡名在规则上也当作「方程式运动员」卡使用。这个卡名的卡在1回合只能发动1张。
-- ①：作为这张卡的发动时的效果处理，可以从卡组把1只「超级运动员」怪兽或者「方程式运动员」怪兽加入手卡或从自己墓地选1张「超级运动员体育场」加入手卡。
-- ②：把手卡1张场地魔法卡给对方观看，支付1000基本分才能发动。这个回合，自己在通常召唤外加上只有1次，可以把1只「超级运动员」怪兽或者「方程式运动员」怪兽召唤。
function c12931061.initial_effect(c)
	-- 使用aux.AddCodeList将卡号19814508（超级运动员体育场）登记为这张卡的追加卡名，使这张卡在规则上也视为「超级运动员体育场」卡。
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
-- ①效果的发动条件判定：不检查额外条件，效果发动合法时返回true。
function c12931061.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
end
-- 定义可加入手牌的候选卡范围：卡组中的「超级运动员」或「方程式运动员」怪兽，或墓地中的「超级运动员体育场」，且必须能够加入手牌。
function c12931061.thfilter(c)
	if not c:IsAbleToHand() then return false end
	return c:IsLocation(LOCATION_DECK) and c:IsSetCard(0xb2,0x107) and c:IsType(TYPE_MONSTER)
		or c:IsLocation(LOCATION_GRAVE) and c:IsCode(19814508)
end
-- 执行①效果：从卡组·墓地中筛选符合条件的卡，让玩家决定是否加入手牌；若选择加入，则检索/回收选中的卡并给对方确认。
function c12931061.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取卡组和墓地中满足条件的卡（「超级运动员／方程式运动员」怪兽或「超级运动员体育场」），作为可加入手牌的候选集合。
	local g=Duel.GetMatchingGroup(c12931061.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,nil)
	local sel=1
	-- 弹出选择提示，引导玩家决定是否要使用检索/回收效果。
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(12931061,0))  --"是否把卡加入手卡？"
	if g:GetCount()>0 then
		-- 在有可用候选卡时，让玩家在“加入手卡”和“不加入”两个选项中选择；返回0表示选择加入。
		sel=Duel.SelectOption(tp,1213,1214)
	else
		-- 没有可用候选卡时，只显示“不加入”选项并使其结果为1，保证不会执行后续加入手牌处理。
		sel=Duel.SelectOption(tp,1214)+1
	end
	if sel==0 then
		-- 提示玩家选择要加入手牌的卡，设置选择时的显示消息。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 将选中的卡以效果原因加入其持有者手牌。
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		-- 将加入手牌的卡展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,sg)
	end
end
-- 定义代价筛选条件：从手牌中选择1张非公开的场地魔法卡（即当前未给对方确认的场地魔法卡）。
function c12931061.cfilter(c)
	return c:IsType(TYPE_FIELD) and not c:IsPublic()
end
-- 定义②效果的发动代价：需要手牌中有1张场地魔法卡且能支付1000LP；满足后选择并展示场地魔法卡、洗切手牌、支付LP。
function c12931061.excost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在代价检查阶段（chk==0）确认手牌中是否存在符合条件的场地魔法卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c12931061.cfilter,tp,LOCATION_HAND,0,1,nil)
		-- 同时确认玩家能够支付1000基本分作为发动代价。
		and Duel.CheckLPCost(tp,1000)
	end
	-- 提示玩家选择一张自己手牌中的场地魔法卡用于给对方确认。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 从手牌中选择1张非公开的场地魔法卡，作为展示给对方确认的代价。
	local g=Duel.SelectMatchingCard(tp,c12931061.cfilter,tp,LOCATION_HAND,0,1,1,nil)
	-- 将选中的手牌场地魔法卡给对方玩家确认，满足“给对方观看”的代价条件。
	Duel.ConfirmCards(1-tp,g)
	-- 展示手牌后洗切手牌，避免泄漏其他手牌信息。
	Duel.ShuffleHand(tp)
	-- 支付1000基本分作为发动代价。
	Duel.PayLPCost(tp,1000)
end
-- 定义②效果的发动条件：本回合尚未使用过该额外召唤效果，且玩家可以进行通常召唤并有额外召唤次数。
function c12931061.extg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查本回合是否已使用过该②效果（通过flag判断），防止同一回合重复发动。
	if chk==0 then return Duel.GetFlagEffect(tp,12931061)==0
		-- 确认玩家处于可以进行通常召唤的状态，并且拥有额外的通常召唤次数（未被“不能召唤”限制）。
		and Duel.IsPlayerCanSummon(tp) and Duel.IsPlayerCanAdditionalSummon(tp) end
end
-- 执行②效果：为本回合注册一个额外的通常召唤次数，仅限「超级运动员」或「方程式运动员」怪兽，并在回合结束时重置。
function c12931061.exop(e,tp,eg,ep,ev,re,r,rp)
	-- 这个回合，自己在通常召唤外加上只有1次，可以把1只「超级运动员」怪兽或者「方程式运动员」怪兽召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(12931061,2))  --"使用「超级运动员高超体育场」的效果召唤"
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetTargetRange(LOCATION_HAND+LOCATION_MZONE,0)
	e1:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
	e1:SetTarget(c12931061.estg)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将赋予额外召唤次数的效果注册到玩家场上，持续到回合结束。
	Duel.RegisterEffect(e1,tp)
	-- 为本回合登记“已使用②效果”的标记，回合结束时重置，防止同一回合再次发动该效果。
	Duel.RegisterFlagEffect(tp,12931061,RESET_PHASE+PHASE_END,0,1)
end
-- 额外召唤的适用对象限制：只有「超级运动员」或「方程式运动员」怪兽才能享受这次额外的通常召唤。
function c12931061.estg(e,c)
	return c:IsSetCard(0xb2,0x107)
end
