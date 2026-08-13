--レディ・デバッガー
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：这张卡召唤·特殊召唤的场合才能发动。从卡组把1只3星以下的电子界族怪兽加入手卡。
function c16188701.initial_effect(c)
	-- 这个卡名的效果1回合只能使用1次。①：这张卡召唤·特殊召唤的场合才能发动。从卡组把1只3星以下的电子界族怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(16188701,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,16188701)
	e1:SetTarget(c16188701.tg)
	e1:SetOperation(c16188701.op)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
end
-- 定义检索对象的过滤条件：等级3以下、电子界族、且可以被加入手卡的怪兽。
function c16188701.filter(c)
	return c:IsLevelBelow(3) and c:IsRace(RACE_CYBERSE) and c:IsAbleToHand()
end
-- 设置效果的发动条件和操作信息：在效果发动时检查卡组是否存在符合条件的怪兽，并登记本次效果将进行“加入手卡”的处理。
function c16188701.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果合法性检查阶段，确认自己的卡组中存在至少1只满足条件的电子界族3星以下怪兽，作为效果能否发动的依据。
	if chk==0 then return Duel.IsExistingMatchingCard(c16188701.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 登记本次效果处理的操作信息：从自己的卡组将1张卡加入手牌（用于后续连锁和时点检测）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理时的实际执行：从卡组选择1只符合条件的怪兽加入手牌，并展示给对方确认。
function c16188701.op(e,tp,eg,ep,ev,re,r,rp)
	-- 为发动玩家弹出选择提示“请选择要加入手牌的卡”，作为选择卡片的界面消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从自己的卡组中筛选出所有满足条件的怪兽，并由玩家从中选择1张（因不取对象，所以在效果处理时选择）。
	local g=Duel.SelectMatchingCard(tp,c16188701.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的那张卡以效果原因加入其持有者的手牌。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手牌的卡展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
	end
end
