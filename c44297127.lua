--奇跡の穿孔
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：从卡组把1只4星以下的岩石族怪兽送去墓地。自己墓地有「化石融合」存在的场合，再让自己从卡组抽1张。
function c44297127.initial_effect(c)
	-- 记录本卡卡名中提到的「化石融合」（卡号59419719），以便进行相关检索与判定。
	aux.AddCodeList(c,59419719)
	-- 这个卡名的卡在1回合只能发动1张。①：从卡组把1只4星以下的岩石族怪兽送去墓地。自己墓地有「化石融合」存在的场合，再让自己从卡组抽1张。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,44297127+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c44297127.target)
	e1:SetOperation(c44297127.activate)
	c:RegisterEffect(e1)
end
-- 定义送墓筛选条件：选择卡组中1只4星以下的岩石族怪兽，且该卡能够被送去墓地。
function c44297127.tgfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsRace(RACE_ROCK) and c:IsLevelBelow(4) and c:IsAbleToGrave()
end
-- 效果发动前的合法性判定与操作信息登记：检查卡组是否存在符合条件的岩石族怪兽，若墓地存在「化石融合」则同时确认我方能够抽卡。
function c44297127.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测我方墓地是否存在「化石融合」（卡号59419719），将结果赋给draw变量，用于决定是否追加抽卡。
	local draw=Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_GRAVE,0,1,nil,59419719)
	-- 发动时点检查：确认我方卡组中存在至少1只满足tgfilter条件的怪兽，作为发动的前提。
	if chk==0 then return Duel.IsExistingMatchingCard(c44297127.tgfilter,tp,LOCATION_DECK,0,1,nil)
		-- 若墓地存在「化石融合」，则还需要我方当前可以抽1张卡，只有同时满足这些条件时效果才允许发动。
		and (not draw or Duel.IsPlayerCanDraw(tp,1)) end
	-- 将本次效果会从卡组把怪兽送去墓地的操作信息写入连锁，便于其他卡片对该类效果进行响应或判定。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
	if draw then
		-- 登记本次效果可能包含抽卡的操作信息（墓地存在「化石融合」时才实际抽1张）。
		Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
	end
end
-- 效果处理：从卡组选1只4星以下的岩石族怪兽送去墓地，若送墓成功且墓地存在「化石融合」，则抽1张卡。
function c44297127.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 弹出选择提示，让玩家选择要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从卡组中选出1张满足tgfilter条件的岩石族怪兽卡。
	local g=Duel.SelectMatchingCard(tp,c44297127.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	-- 确认选到了卡且送去墓地成功，并且该卡确实位于墓地时，继续执行后续的抽卡判定。
	if g:GetCount()>0 and Duel.SendtoGrave(g,REASON_EFFECT)~=0 and g:GetFirst():IsLocation(LOCATION_GRAVE)
		-- 并检查我方墓地此时是否真实存在「化石融合」，存在则进入抽卡处理。
		and Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_GRAVE,0,1,nil,59419719) then
		-- 中断当前效果，使此前的送墓操作先完成并结算相关时点，之后再处理抽卡，避免送墓时点被后续抽卡覆盖。
		Duel.BreakEffect()
		-- 根据效果让我方抽1张卡，抽卡原因为效果。
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
