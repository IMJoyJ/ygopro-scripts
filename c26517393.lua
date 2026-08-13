--裏風の精霊
-- 效果：
-- ①：这张卡召唤的场合才能发动。从卡组把1只反转怪兽加入手卡。
function c26517393.initial_effect(c)
	-- ①：这张卡召唤的场合才能发动。从卡组把1只反转怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c26517393.tg)
	e1:SetOperation(c26517393.op)
	c:RegisterEffect(e1)
end
-- 定义检索的过滤条件：卡片必须为反转怪兽，且满足能被加入手卡的限制。
function c26517393.filter(c)
	return c:IsType(TYPE_FLIP) and c:IsAbleToHand()
end
-- 效果发动前的目标处理：检查发动合法性，并登记本次效果将执行“从卡组把卡加入手卡”的操作信息。
function c26517393.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动时（chk==0）确认卡组中是否存在至少1只符合条件的反转怪兽，有才能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c26517393.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 登记连锁操作信息：声明本效果会从卡组把1张卡加入手卡，供其他卡或规则判定使用。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理时的实际执行：由玩家选择1只符合条件的反转怪兽，将其加入手卡，并让对方确认。
function c26517393.op(e,tp,eg,ep,ev,re,r,rp)
	-- 向当前玩家显示“请选择要加入手牌的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从自己的卡组中选择1只符合条件的反转怪兽（精确选择1张）。
	local g=Duel.SelectMatchingCard(tp,c26517393.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡以效果原因加入其持有者的手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手卡的卡展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
	end
end
