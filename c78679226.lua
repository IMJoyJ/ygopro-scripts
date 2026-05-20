--未来への沈黙
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：从卡组把有「光之黄金柜」的卡名记述的1只怪兽加入手卡。自己场上有着「光之黄金柜」以及有那个卡名记述的怪兽存在的状态，把这张卡在自己·对方的战斗阶段发动的场合，再让双方各自直到手卡变成6张为止抽卡。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含不带抽卡追加效果的常规发动（e1）和在战斗阶段满足条件时带抽卡追加效果的发动（e2）
function s.initial_effect(c)
	-- 将「光之黄金柜」（卡号79791878）注册到该卡的关联卡片密码列表中，以便其他卡片检测
	aux.AddCodeList(c,79791878)
	-- 这个卡名的卡在1回合只能发动1张。①：从卡组把有「光之黄金柜」的卡名记述的1只怪兽加入手卡。
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
-- 过滤函数：检测场上是否存在表侧表示的「光之黄金柜」
function s.sfilter(c)
	return c:IsFaceup() and c:IsCode(79791878)
end
-- 过滤函数：检测场上是否存在表侧表示的、有「光之黄金柜」卡名记述的怪兽
function s.mfilter(c)
	-- 过滤条件：表侧表示、有「光之黄金柜」卡名记述、且是怪兽卡
	return c:IsFaceup() and aux.IsCodeListed(c,79791878) and c:IsType(TYPE_MONSTER)
end
-- 常规发动的发动条件：不满足追加抽卡效果的发动条件
function s.ndcon(e,tp,eg,ep,ev,re,r,rp)
	return not s.dcon(e,tp,eg,ep,ev,re,r,rp)
end
-- 追加抽卡效果的发动条件：在自己或对方的战斗阶段，且自己场上存在「光之黄金柜」以及有该卡名记述的怪兽
function s.dcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前阶段是否处于自己或对方的战斗阶段（从战斗阶段开始到战斗阶段结束）
	return (Duel.GetCurrentPhase()>=PHASE_BATTLE_START and Duel.GetCurrentPhase()<=PHASE_BATTLE)
	-- 检查自己场上是否存在「光之黄金柜」以及有该卡名记述的怪兽
	and Duel.IsExistingMatchingCard(s.sfilter,tp,LOCATION_ONFIELD,0,1,nil) and Duel.IsExistingMatchingCard(s.mfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 过滤函数：检索卡组中记有「光之黄金柜」卡名的怪兽
function s.filter(c)
	-- 过滤条件：卡片文本记有「光之黄金柜」卡名、是怪兽卡、且可以加入手卡
	return aux.IsCodeListed(c,79791878) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 常规发动的目标处理：检查卡组中是否存在可检索的怪兽，并设置检索的操作信息
function s.ndtarget(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动时的可行性检查：卡组中必须存在至少1只满足检索条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：从卡组将1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 追加抽卡效果的发动目标处理：计算双方需要抽卡的数量，检查可行性并设置检索和抽卡的操作信息
function s.dtarget(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 计算自己需要抽卡的数量（因为此卡发动后会离开手卡，所以计算时手卡数量需扣除这张卡，目标是检索后手卡达到6张，即检索前手卡达到5张，故用5减去当前手卡数）
	local ct1=5-Duel.GetMatchingGroupCount(nil,tp,LOCATION_HAND,0,e:GetHandler())
	-- 计算对方需要抽卡的数量（目标是手卡达到6张，故用6减去对方当前手卡数）
	local ct2=6-Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)
	-- 效果发动时的可行性检查：卡组中必须存在至少1只满足检索条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil)
		-- 检查自己是否需要抽卡且自己是否能够进行抽卡（因为还要检索1张，所以需要能抽 ct1+1 张卡）
		and ct1>0 and Duel.IsPlayerCanDraw(tp,ct1+1)
		-- 检查对方是否需要抽卡且对方是否能够进行抽卡
		and ct2>0 and Duel.IsPlayerCanDraw(1-tp,ct2)
	end
	-- 设置操作信息：从卡组将1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	-- 设置操作信息：自己抽卡，数量为ct1
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,ct1)
	-- 设置操作信息：对方抽卡，数量为ct2
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,1-tp,ct2)
end
-- 常规发动的效果处理：从卡组选择1只满足条件的怪兽加入手卡并给对方确认
function s.ndactivate(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1张满足过滤条件的卡
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡因效果加入手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 追加抽卡效果的效果处理：先执行检索，然后双方各自抽卡直到手卡变成6张
function s.dactivate(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1张满足过滤条件的卡
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡因效果加入手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
	-- 重新计算自己需要抽卡的数量（此时检索的卡已加入手卡，故用6减去当前手卡数）
	local ct1=6-Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)
	-- 重新计算对方需要抽卡的数量（用6减去对方当前手卡数）
	local ct2=6-Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)
	-- 如果有任意一方需要抽卡，则中断当前效果处理，使后续的抽卡处理与前面的检索处理不视为同时进行
	if ct1>0 or ct2>0 then Duel.BreakEffect() end
	-- 如果自己手卡不足6张，则因效果抽卡直到手卡变成6张
	if ct1>0 then Duel.Draw(tp,ct1,REASON_EFFECT) end
	-- 如果对方手卡不足6张，则因效果抽卡直到手卡变成6张
	if ct2>0 then Duel.Draw(1-tp,ct2,REASON_EFFECT) end
end
