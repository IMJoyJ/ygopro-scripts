--強欲で謙虚な壺
-- 效果：
-- 这个卡名的卡在1回合只能发动1张，这张卡发动的回合，自己不能把怪兽特殊召唤。
-- ①：从自己卡组上面把3张卡翻开，从那之中选1张加入手卡。那之后，剩下的卡回到卡组。
function c98645731.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张，这张卡发动的回合，自己不能把怪兽特殊召唤。①：从自己卡组上面把3张卡翻开，从那之中选1张加入手卡。那之后，剩下的卡回到卡组。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,98645731+EFFECT_COUNT_CODE_OATH)
	e1:SetCost(c98645731.cost)
	e1:SetTarget(c98645731.target)
	e1:SetOperation(c98645731.activate)
	c:RegisterEffect(e1)
end
-- 检查本回合是否进行过特殊召唤，并注册本回合不能进行特殊召唤的限制效果
function c98645731.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查本回合自己是否进行过特殊召唤
	if chk==0 then return Duel.GetActivityCount(tp,ACTIVITY_SPSUMMON)==0 end
	-- 这张卡发动的回合，自己不能把怪兽特殊召唤。①：从自己卡组上面把3张卡翻开，从那之中选1张加入手卡。那之后，剩下的卡回到卡组。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	-- 给发动玩家注册本回合不能特殊召唤怪兽的限制效果
	Duel.RegisterEffect(e1,tp)
end
-- 检查卡组数量是否足够并设置检索操作信息
function c98645731.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 检查自己卡组的卡片数量是否在3张以上
		if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)<3 then return false end
		-- 获取自己卡组最上方的3张卡
		local g=Duel.GetDecktopGroup(tp,3)
		local result=g:FilterCount(Card.IsAbleToHand,nil)>0
		return result
	end
	-- 设置当前连锁的对象玩家为自己
	Duel.SetTargetPlayer(tp)
	-- 设置操作信息为从卡组将1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,0,LOCATION_DECK)
end
-- 翻开卡组上方3张卡，选择1张加入手卡，其余卡片回到卡组
function c98645731.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的对象玩家
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 确认（翻开）该玩家卡组最上方的3张卡
	Duel.ConfirmDecktop(p,3)
	-- 获取该玩家卡组最上方的3张卡
	local g=Duel.GetDecktopGroup(p,3)
	if g:GetCount()>0 then
		-- 提示玩家选择要加入手卡的卡片
		Duel.Hint(HINT_SELECTMSG,p,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		local sg=g:Select(p,1,1,nil)
		if sg:GetFirst():IsAbleToHand() then
			-- 将选中的卡片因效果加入手卡
			Duel.SendtoHand(sg,nil,REASON_EFFECT)
			-- 给对方玩家确认加入手卡的卡片
			Duel.ConfirmCards(1-p,sg)
			-- 洗切该玩家的手卡
			Duel.ShuffleHand(p)
		else
			-- 若选中的卡无法加入手卡，则根据规则送去墓地
			Duel.SendtoGrave(sg,REASON_RULE)
		end
		-- 将剩下的卡回到卡组并洗牌
		Duel.ShuffleDeck(p)
	end
end
