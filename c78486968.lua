--セイクリッド・シェラタン
-- 效果：
-- ①：这张卡召唤成功时才能发动。从卡组把1只「星圣」怪兽加入手卡。
function c78486968.initial_effect(c)
	-- ①：这张卡召唤成功时才能发动。从卡组把1只「星圣」怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(78486968,0))  --"卡组检索"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c78486968.tg)
	e1:SetOperation(c78486968.op)
	c:RegisterEffect(e1)
	c78486968.star_knight_summon_effect=e1
end
-- 过滤条件：卡名含有「星圣」的怪兽，且可以加入手卡
function c78486968.filter(c)
	return c:IsSetCard(0x53) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 效果①的启动阶段（Target），检查卡组中是否存在符合条件的卡，并设置操作信息
function c78486968.tg(e,tp,eg,ep,ev,re,r,rp,chk,_,exc)
	-- 检查卡组中是否存在至少1只满足过滤条件的「星圣」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c78486968.filter,tp,LOCATION_DECK,0,1,exc) end
	-- 设置操作信息，表示该效果会从卡组将1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果①的处理阶段（Operation），让玩家从卡组选择1只「星圣」怪兽加入手卡并给对方确认
function c78486968.op(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1只满足过滤条件的「星圣」怪兽
	local g=Duel.SelectMatchingCard(tp,c78486968.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的怪兽通过效果加入玩家手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手卡的怪兽给对方玩家确认
		Duel.ConfirmCards(1-tp,g)
	end
end
