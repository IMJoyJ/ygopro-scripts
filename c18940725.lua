--ふわんだりぃず×ろびーな
-- 效果：
-- 这个卡名的①③的效果1回合各能使用1次，这些效果发动的回合，自己不能把怪兽特殊召唤。
-- ①：这张卡召唤成功的场合才能发动。从卡组把1只4星以下的鸟兽族怪兽加入手卡。那之后，可以把1只鸟兽族怪兽召唤。
-- ②：表侧表示的这张卡从场上离开的场合除外。
-- ③：这张卡除外中的状态，自己场上有鸟兽族怪兽召唤的场合才能发动。这张卡加入手卡。
function c18940725.initial_effect(c)
	-- 这个卡名的①③的效果1回合各能使用1次，这些效果发动的回合，自己不能把怪兽特殊召唤。①：这张卡召唤成功的场合才能发动。从卡组把1只4星以下的鸟兽族怪兽加入手卡。那之后，可以把1只鸟兽族怪兽召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(18940725,0))
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,18940725)
	e1:SetCost(c18940725.cost)
	e1:SetTarget(c18940725.thtg)
	e1:SetOperation(c18940725.thop)
	c:RegisterEffect(e1)
	-- 给该卡添加“表侧表示从场上离开时除外”的重定向效果，实现②：表侧表示的这张卡从场上离开的场合除外。
	aux.AddBanishRedirect(c)
	-- ③：这张卡除外中的状态，自己场上有鸟兽族怪兽召唤的场合才能发动。这张卡加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(18940725,1))  --"这张卡加入手卡"
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetRange(LOCATION_REMOVED)
	e3:SetCountLimit(1,18940726)
	e3:SetCondition(c18940725.thcon2)
	e3:SetCost(c18940725.cost)
	e3:SetTarget(c18940725.thtg2)
	e3:SetOperation(c18940725.thop2)
	c:RegisterEffect(e3)
end
-- ①③效果的公共代价：若本回合自己未进行过特殊召唤，则给己方附加直到结束阶段“不能特殊召唤”的誓约效果；否则不能发动。
function c18940725.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检测：只有当本回合自己还没进行过特殊召唤时，才能发动效果（chk==0，若已有特殊召唤则返回false）。
	if chk==0 then return Duel.GetActivityCount(tp,ACTIVITY_SPSUMMON)==0 end
	-- 这个卡名的①③的效果1回合各能使用1次，这些效果发动的回合，自己不能把怪兽特殊召唤。①：这张卡召唤成功的场合才能发动。从卡组把1只4星以下的鸟兽族怪兽加入手卡。那之后，可以把1只鸟兽族怪兽召唤。③：这张卡除外中的状态，自己场上有鸟兽族怪兽召唤的场合才能发动。这张卡加入手卡。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	-- 将“不能特殊召唤”的誓约效果注册到当前玩家tp身上，持续到回合结束。
	Duel.RegisterEffect(e1,tp)
end
-- 定义检索过滤器：从卡组中选出1只4星以下、鸟兽族且能够加入手卡的怪兽。
function c18940725.thfilter(c)
	return c:IsLevelBelow(4) and c:IsRace(RACE_WINDBEAST) and c:IsAbleToHand()
end
-- ①效果的目标函数：确认卡组有检索目标，并记录本次效果涉及“加入手卡”和“通常召唤”两类操作。
function c18940725.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检测：卡组中存在1张满足检索条件的4星以下鸟兽族怪兽时，效果才可发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c18940725.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：本次效果将把1张卡从卡组加入持有者手卡（不取对象，目标位置为卡组）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	-- 设置操作信息：预告本次效果可能伴随一次通常召唤（目标数量和位置暂不确定，用于相关卡片检测）。
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,nil,0,0,0)
end
-- 定义召唤过滤器：选择1只当前可以通常召唤的鸟兽族怪兽（可以在手牌或场上）。
function c18940725.sumfilter(c)
	return c:IsSummonable(true,nil) and c:IsRace(RACE_WINDBEAST)
end
-- ①效果处理：先从卡组检索1只4星以下鸟兽族加入手卡并让对方确认；再询问玩家是否追加召唤1只鸟兽族怪兽，若选择是则执行追加召唤。
function c18940725.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 弹出“请选择要加入手牌的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中筛选并选择1张符合条件的4星以下鸟兽族怪兽。
	local g=Duel.SelectMatchingCard(tp,c18940725.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将检索到的卡加入其持有者的手卡，原因为效果。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示这张加入手卡的卡，让对方确认。
		Duel.ConfirmCards(1-tp,g)
		-- 检查手牌或场上是否存在可以通常召唤的鸟兽族怪兽，作为追加召唤的前提条件。
		if Duel.IsExistingMatchingCard(c18940725.sumfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil)
			-- 询问玩家是否进行鸟兽族怪兽的追加通常召唤。
			and Duel.SelectYesNo(tp,aux.Stringid(18940725,2)) then  --"是否把鸟兽族怪兽召唤？"
			-- 中断当前效果链，使之后的追加召唤处理视为另一个独立时点，避免错过召唤成功的时点。
			Duel.BreakEffect()
			-- 洗切手牌，防止玩家选择召唤的卡时泄露手牌顺序信息。
			Duel.ShuffleHand(tp)
			-- 弹出“请选择要召唤的卡”的选择提示。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)  --"请选择要召唤的卡"
			-- 从手牌或场上选择1只符合条件的鸟兽族怪兽作为追加召唤的对象。
			local sg=Duel.SelectMatchingCard(tp,c18940725.sumfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil)
			if sg:GetCount()>0 then
				-- 执行那次追加的鸟兽族怪兽通常召唤（忽略本回合通常召唤次数限制）。
				Duel.Summon(tp,sg:GetFirst(),true,nil)
			end
		end
	end
end
-- ③效果的发动条件：当触发时点的事件怪兽为鸟兽族且控制者为己方时，条件成立。
function c18940725.thcon2(e,tp,eg,ep,ev,re,r,rp)
	local ec=eg:GetFirst()
	return ec:IsControler(tp) and ec:IsRace(RACE_WINDBEAST)
end
-- ③效果的目标函数：确认除外区的本卡可以加入手卡，并登记“加入手卡”的操作信息。
function c18940725.thtg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	-- 设置操作信息：将除外区的这张卡加入持有者手卡（目标确定为自己，数量为1）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- ③效果处理：若这张卡仍然与当前效果相关，则将其加入手卡。
function c18940725.thop2(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		-- 将除外区的这张卡送入其持有者的手卡，原因为效果。
		Duel.SendtoHand(e:GetHandler(),nil,REASON_EFFECT)
	end
end
