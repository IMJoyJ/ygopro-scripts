--デュエリスト・ジェネシス
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：自己的场上或墓地有调整存在的场合才能发动。从卡组把1张「同调」魔法·陷阱卡加入手卡。
local s,id,o=GetID()
-- 注册卡片发动时的效果
function s.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：自己的场上或墓地有调整存在的场合才能发动。从卡组把1张「同调」魔法·陷阱卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：场上（表侧表示）或墓地的调整怪兽
function s.cfilter(c)
	return c:IsFaceupEx() and c:IsType(TYPE_TUNER)
end
-- 发动条件：检查自己场上或墓地是否存在调整怪兽
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上（含表侧表示的额外卡组）或墓地是否存在至少1张调整怪兽
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,nil)
end
-- 过滤条件：卡组中可以加入手牌的「同调」魔法·陷阱卡
function s.filter(c)
	return c:IsSetCard(0x17) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- 效果发动时的目标选择与处理：检查卡组中是否存在可检索的卡，并设置检索的操作信息
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动准备阶段，检查卡组中是否存在至少1张可加入手牌的「同调」魔法·陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：将卡组中的1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：从卡组选择1张「同调」魔法·陷阱卡加入手牌并给对方确认
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 在客户端弹出提示，要求玩家选择要加入手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组中选择1张满足条件的「同调」魔法·陷阱卡
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		-- 将选中的卡片加入玩家手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示并确认加入手牌的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
