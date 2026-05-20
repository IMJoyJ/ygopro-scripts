--レアル・ジェネクス・クラッシャー
-- 效果：
-- ①：这张卡召唤时才能发动。从卡组把1只4星「真次世代」怪兽加入手卡。
function c65149697.initial_effect(c)
	-- ①：这张卡召唤时才能发动。从卡组把1只4星「真次世代」怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(65149697,0))  --"检索"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c65149697.target)
	e1:SetOperation(c65149697.operation)
	c:RegisterEffect(e1)
end
-- 过滤卡组中等级为4、卡名含有「真次世代」且能加入手牌的怪兽
function c65149697.filter(c)
	return c:IsLevel(4) and c:IsSetCard(0x1002) and c:IsAbleToHand()
end
-- 效果①的发动检测与操作信息设置
function c65149697.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段，检测卡组中是否存在满足条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c65149697.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置效果处理的操作信息为将卡组中的1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果①的效果处理：从卡组将1只满足条件的怪兽加入手牌并给对方确认
function c65149697.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组中选择1只满足过滤条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c65149697.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的怪兽加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手牌的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
