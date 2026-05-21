--暗黒回廊
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：从卡组把1只「暗黑界」怪兽加入手卡。那之后，选自己1张手卡丢弃。
local s,id,o=GetID()
-- 注册卡片发动时的效果：包含检索、加入手卡、丢弃手卡分类，同名卡一回合只能发动一张
function s.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：从卡组把1只「暗黑界」怪兽加入手卡。那之后，选自己1张手卡丢弃。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_HANDES)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：卡组中的「暗黑界」怪兽且可以加入手卡
function s.filter(c)
	return c:IsSetCard(0x6) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 效果发动时的目标选择与操作信息注册：检查卡组是否存在可检索的卡，并注册加入手卡和丢弃手卡的操作信息
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1只满足条件的「暗黑界」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：从卡组将1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	-- 设置操作信息：丢弃1张手卡
	Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,tp,1)
end
-- 效果处理：从卡组选择1只「暗黑界」怪兽加入手卡，确认并洗牌，然后丢弃1张手卡
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1只满足条件的「暗黑界」怪兽
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil)
	-- 若成功将选中的怪兽加入手卡，则继续处理后续效果
	if g:GetCount()>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)~=0 and g:GetFirst():IsLocation(LOCATION_HAND) then
		-- 向对方玩家确认加入手卡的卡
		Duel.ConfirmCards(1-tp,g)
		-- 洗切自身手卡
		Duel.ShuffleHand(tp)
		-- 中断当前效果处理，使后续的丢弃手卡处理不与加入手卡同时进行
		Duel.BreakEffect()
		-- 玩家选择自己1张手卡因效果丢弃
		Duel.DiscardHand(tp,nil,1,1,REASON_EFFECT+REASON_DISCARD,nil)
	end
end
