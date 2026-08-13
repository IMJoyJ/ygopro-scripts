--デスマニア・デビル
-- 效果：
-- ①：这张卡战斗破坏对方怪兽时才能发动。从卡组把1只4星以下的兽族怪兽加入手卡。
function c42908201.initial_effect(c)
	-- ①：这张卡战斗破坏对方怪兽时才能发动。从卡组把1只4星以下的兽族怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(42908201,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_DESTROYING)
	-- 设置该效果的发动条件为：这张卡与对方怪兽进行战斗并将其战斗破坏（由 aux.bdocon 判断）。
	e1:SetCondition(aux.bdocon)
	e1:SetTarget(c42908201.target)
	e1:SetOperation(c42908201.operation)
	c:RegisterEffect(e1)
end
-- 定义检索用的过滤器：卡组中等级4以下、兽族、且能够被加入手卡的怪兽才符合条件。
function c42908201.filter(c)
	return c:IsLevelBelow(4) and c:IsRace(RACE_BEAST) and c:IsAbleToHand()
end
-- 效果发动前的目标处理：确认卡组存在符合条件的怪兽，并登记将1张卡从卡组加入手牌的处理信息。
function c42908201.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 若 chk==0（发动合法性检查），则检测我方卡组是否存在至少1只满足条件的兽族怪兽，作为能否发动效果的前提。
	if chk==0 then return Duel.IsExistingMatchingCard(c42908201.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 登记本次连锁的操作信息：将把1张卡从卡组加入手牌（对象暂不确定，数量1，持有者我方，位置卡组），供其他卡效果进行时点检测。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理时的实际操作：向玩家提供选择提示，从卡组选取1只符合条件的兽族怪兽加入手牌，并向对方公开这张卡。
function c42908201.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 显示选择提示，提示文字为“请选择要加入手牌的卡”，用于接下来的卡组检索选择。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让当前玩家从卡组中选出1张满足 c42908201.filter 条件的卡（数量固定1张），得到所选卡组集合 g。
	local g=Duel.SelectMatchingCard(tp,c42908201.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡以‘效果’的原因送往其持有者的手卡，也即把检索到的卡加入手牌。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将刚刚加入手牌的卡展示给对方玩家确认，使对方能看到检索到的是什么卡。
		Duel.ConfirmCards(1-tp,g)
	end
end
