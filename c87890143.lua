--ジェネレーション・フォース
-- 效果：
-- ①：自己场上有超量怪兽存在的场合才能发动。从卡组把1张「超量」卡加入手卡。
function c87890143.initial_effect(c)
	-- ①：自己场上有超量怪兽存在的场合才能发动。从卡组把1张「超量」卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c87890143.condition)
	e1:SetTarget(c87890143.target)
	e1:SetOperation(c87890143.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：表侧表示的超量怪兽
function c87890143.cfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ)
end
-- 发动条件：检查自己场上是否存在超量怪兽
function c87890143.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在至少1只表侧表示的超量怪兽
	return Duel.IsExistingMatchingCard(c87890143.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 过滤条件：卡组中可加入手卡的「超量」卡片
function c87890143.filter(c)
	return c:IsSetCard(0x73) and c:IsAbleToHand()
end
-- 效果的目标处理：检查卡组中是否存在可检索的卡，并设置操作信息
function c87890143.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动时点检查卡组中是否存在至少1张可加入手卡的「超量」卡
	if chk==0 then return Duel.IsExistingMatchingCard(c87890143.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：将卡组中的1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：从卡组将1张「超量」卡加入手卡并展示给对方
function c87890143.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择1张满足条件的「超量」卡
	local g=Duel.SelectMatchingCard(tp,c87890143.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡片加入手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手卡的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
