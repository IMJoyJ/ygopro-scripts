--E・HERO フォレストマン
-- 效果：
-- ①：1回合1次，自己准备阶段才能发动。选自己的卡组·墓地1张「融合」加入手卡。
function c75434695.initial_effect(c)
	-- ①：1回合1次，自己准备阶段才能发动。选自己的卡组·墓地1张「融合」加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(75434695,0))  --"把1张「融合」魔法卡加入手牌。"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e1:SetCountLimit(1)
	e1:SetCondition(c75434695.con)
	e1:SetTarget(c75434695.tg)
	e1:SetOperation(c75434695.op)
	c:RegisterEffect(e1)
end
-- 效果发动条件函数：判断是否为自己的准备阶段
function c75434695.con(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为自己
	return Duel.GetTurnPlayer()==tp
end
-- 过滤条件函数：卡名为「融合」且可以加入手牌
function c75434695.filter(c)
	return c:IsCode(24094653) and c:IsAbleToHand()
end
-- 效果发动目标函数：验证卡组或墓地是否存在「融合」并设置操作信息
function c75434695.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动时，检查自己的卡组或墓地是否存在至少1张满足条件的「融合」
	if chk==0 then return Duel.IsExistingMatchingCard(c75434695.filter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	-- 设置效果处理信息为：将自己卡组或墓地的1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
-- 效果处理函数：从卡组或墓地选择1张「融合」加入手牌并给对方确认
function c75434695.op(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组或墓地选择1张满足条件的「融合」（适用王家长眠之谷的过滤）
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c75434695.filter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡片加入玩家手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对方玩家确认加入手牌的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
