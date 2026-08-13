--天地開闢
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：从卡组把包含「混沌战士」怪兽或者「暗黑骑士 盖亚」怪兽1只以上的3只战士族怪兽给对方观看，对方从那之中随机选1只。那是「混沌战士」怪兽或者「暗黑骑士 盖亚」怪兽的场合，那只怪兽加入自己手卡，剩下的卡全部送去墓地。不是的场合，给对方观看的卡全部送去墓地。
function c32360466.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：从卡组把包含「混沌战士」怪兽或者「暗黑骑士 盖亚」怪兽1只以上的3只战士族怪兽给对方观看，对方从那之中随机选1只。那是「混沌战士」怪兽或者「暗黑骑士 盖亚」怪兽的场合，那只怪兽加入自己手卡，剩下的卡全部送去墓地。不是的场合，给对方观看的卡全部送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetCountLimit(1,32360466+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c32360466.target)
	e1:SetOperation(c32360466.activate)
	c:RegisterEffect(e1)
end
-- 筛选卡组中为战士族且能被加入手牌的怪兽，作为效果可选对象的条件。
function c32360466.filter1(c)
	return c:IsRace(RACE_WARRIOR) and c:IsAbleToHand()
end
-- 筛选卡名属于「混沌战士」或「暗黑骑士 盖亚」相关字段的怪兽（通过系列编号0x10cf和0xbd判定）。
function c32360466.filter2(c)
	return c:IsSetCard(0x10cf,0xbd)
end
-- 效果发动前的合法性检查：确认卡组存在至少3只战士族且能加入手牌的怪兽，其中至少有1只满足混沌战士/暗黑骑士字段；满足后登记操作信息为检索手牌。
function c32360466.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 检查玩家是否能把卡组的卡送去墓地（用于后续展示的卡送去墓地的处理），若不能则效果不能发动。
		if not Duel.IsPlayerCanDiscardDeck(tp,1) then return false end
		-- 从卡组中筛选出所有满足filter1（战士族且可加入手牌）的怪兽集合。
		local g=Duel.GetMatchingGroup(c32360466.filter1,tp,LOCATION_DECK,0,nil)
		return g:GetCount()>2 and g:IsExists(c32360466.filter2,1,nil)
	end
	-- 设置操作信息：本连锁可能进行的操作是将1张卡从卡组加入手牌（用于满足检索类效果检测）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,0,LOCATION_DECK)
end
-- 效果处理：从符合条件的卡中选出包含1只混沌战士/暗黑骑士在内的3只战士族给对方确认，洗牌后由对方随机选1张；若选中目标卡则将其加入我方手牌，其余送墓地；否则选中的3张全部送墓地。
function c32360466.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 处理前再次确认玩家仍能从卡组送去墓地（防止效果处理时条件变化导致无法送墓）。
	if not Duel.IsPlayerCanDiscardDeck(tp,1) then return end
	-- 重新获取当前满足filter1的战士族怪兽集合。
	local g=Duel.GetMatchingGroup(c32360466.filter1,tp,LOCATION_DECK,0,nil)
	if g:IsExists(c32360466.filter2,1,nil) then
		-- 弹出选择提示，让发动者从卡组中选择1只混沌战士/暗黑骑士怪兽作为展示组的对象。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		local sg1=g:FilterSelect(tp,c32360466.filter2,1,1,nil)
		g:RemoveCard(sg1:GetFirst())
		-- 弹出选择提示，让发动者从剩余卡中再选择2只战士族怪兽，凑成3张展示组。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		local sg2=g:Select(tp,2,2,nil)
		sg1:Merge(sg2)
		-- 将选出的3张卡展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,sg1)
		-- 展示结束后洗切发动者的卡组，避免卡组信息被非公开获取。
		Duel.ShuffleDeck(tp)
		local tg=sg1:Select(1-tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 向双方提示被对方随机选中的卡（显示卡片动画），以确认随机选择结果。
		Duel.Hint(HINT_CARD,0,tc:GetCode())
		if c32360466.filter2(tc) and tc:IsAbleToHand() then
			tc:SetStatus(STATUS_TO_HAND_WITHOUT_CONFIRM,true)
			-- 若被选中的卡是混沌战士/暗黑骑士怪兽且能加入手牌，将其加入我方手牌。
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
			sg1:RemoveCard(tc)
		end
		-- 将未被选中的剩余卡全部送去墓地（若选中的不是目标卡则3张都送去墓地）。
		Duel.SendtoGrave(sg1,REASON_EFFECT)
	end
end
