--未来への沈黙
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：从卡组把有「光之黄金柜」的卡名记述的1只怪兽加入手卡。自己场上有着「光之黄金柜」以及有那个卡名记述的怪兽存在的状态，把这张卡在自己·对方的战斗阶段发动的场合，再让双方各自直到手卡变成6张为止抽卡。
local s,id,o=GetID()
-- 对未来的沉默
function s.initial_effect(c)
	-- 注册「光之黄金柜」的卡名关联
	aux.AddCodeList(c,79791878)
	-- ①：从卡组把有「光之黄金柜」的卡名记述的1只怪兽加入手卡。自己场上有着「光之黄金柜」以及有那个卡名记述的怪兽存在的状态，把这张卡在自己·对方的战斗阶段发动的场合，再让双方各自直到手卡变成6张为止抽卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.ndcon)
	e1:SetTarget(s.ndtarget)
	e1:SetOperation(s.ndactivate)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_DRAW)
	e2:SetCondition(s.dcon)
	e2:SetTarget(s.dtarget)
	e2:SetOperation(s.dactivate)
	c:RegisterEffect(e2)
end
-- 筛选自己场上表侧表示「光之黄金柜」的过滤函数
function s.sfilter(c)
	return c:IsFaceup() and c:IsCode(79791878)
end
-- 筛选自己场上表侧表示记述了「光之黄金柜」的怪兽的过滤函数
function s.mfilter(c)
	-- 检查卡片是否表侧表示、记述了「光之黄金柜」且为怪兽卡
	return c:IsFaceup() and aux.IsCodeListed(c,79791878) and c:IsType(TYPE_MONSTER)
end
-- 未满足额外抽卡条件时的发动条件
function s.ndcon(e,tp,eg,ep,ev,re,r,rp)
	return not s.dcon(e,tp,eg,ep,ev,re,r,rp)
end
-- 满足额外抽卡条件时的发动条件：战斗阶段且自己场上有「光之黄金柜」和记述了「光之黄金柜」的怪兽
function s.dcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前是否处于战斗阶段
	return (Duel.GetCurrentPhase()>=PHASE_BATTLE_START and Duel.GetCurrentPhase()<=PHASE_BATTLE)
	-- 检查自己场上是否同时存在「光之黄金柜」及记述了「光之黄金柜」的怪兽
	and Duel.IsExistingMatchingCard(s.sfilter,tp,LOCATION_ONFIELD,0,1,nil) and Duel.IsExistingMatchingCard(s.mfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 筛选卡组中记述了「光之黄金柜」的怪兽的过滤函数
function s.filter(c)
	-- 检查卡片是否记述了「光之黄金柜」、是否为怪兽卡且能否加入手牌
	return aux.IsCodeListed(c,79791878) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 普通发动的目标选择与操作信息设置
function s.ndtarget(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组是否存在可以加入手牌的卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：从卡组将1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 包含抽卡效果发动的目标选择与操作信息设置
function s.dtarget(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 计算自己需要抽卡的张数（直到手牌变成6张，考虑发动时消耗此卡）
	local ct1=5-Duel.GetMatchingGroupCount(nil,tp,LOCATION_HAND,0,e:GetHandler())
	-- 计算对方需要抽卡的张数（直到手牌变成6张）
	local ct2=6-Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)
	-- 检查卡组是否存在可以检索加入手牌的卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil)
		-- 检查自己是否有抽卡空间且能否抽卡
		and ct1>0 and Duel.IsPlayerCanDraw(tp,ct1+1)
		-- 检查对方是否有抽卡空间且能否抽卡
		and ct2>0 and Duel.IsPlayerCanDraw(1-tp,ct2)
	end
	-- 设置操作信息：从卡组将1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	-- 设置操作信息：自己抽卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,ct1)
	-- 设置操作信息：对方抽卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,1-tp,ct2)
end
-- 普通发动的效果处理：从卡组检索怪兽加入手牌
function s.ndactivate(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家选择1张符合条件的卡
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 把选择的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 包含抽卡效果的发动处理：检索怪兽加入手牌后双方抽卡
function s.dactivate(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家选择1张符合条件的卡
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 把选择的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
		if g:IsExists(Card.IsLocation,1,nil,LOCATION_HAND) then
			-- 计算自己需要抽卡的数量（直到手牌为6张）
			local ct1=6-Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)
			-- 计算对方需要抽卡的数量（直到手牌为6张）
			local ct2=6-Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)
			-- 若有玩家需要抽卡则中断当前效果处理
			if ct1>0 or ct2>0 then Duel.BreakEffect() end
			-- 自己抽卡直到手牌变成6张
			if ct1>0 then Duel.Draw(tp,ct1,REASON_EFFECT) end
			-- 对方抽卡直到手牌变成6张
			if ct2>0 then Duel.Draw(1-tp,ct2,REASON_EFFECT) end
		end
	end
end
