--EMハンサムライガー
-- 效果：
-- 「娱乐伙伴 俊侍狮虎」的效果1回合只能使用1次。
-- ①：这张卡战斗破坏对方怪兽送去墓地时才能发动。从卡组把1只5星以上的灵摆怪兽加入手卡。
function c55997110.initial_effect(c)
	-- ①：这张卡战斗破坏对方怪兽送去墓地时才能发动。从卡组把1只5星以上的灵摆怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(55997110,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_DESTROYING)
	e1:SetCountLimit(1,55997110)
	-- 设置发动条件为：自身战斗破坏对方怪兽并送去墓地
	e1:SetCondition(aux.bdogcon)
	e1:SetTarget(c55997110.target)
	e1:SetOperation(c55997110.operation)
	c:RegisterEffect(e1)
end
-- 过滤卡组中等级5星以上且可以加入手卡的灵摆怪兽
function c55997110.filter(c)
	return c:IsLevelAbove(5) and c:IsType(TYPE_PENDULUM) and c:IsAbleToHand()
end
-- 效果发动的目标选择与检测函数
function c55997110.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段，检测卡组中是否存在至少1张满足条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c55997110.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁处理的操作信息为：从卡组将1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理的执行函数
function c55997110.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 给玩家发送提示信息：请选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择1张满足条件的卡
	local g=Duel.SelectMatchingCard(tp,c55997110.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡因效果加入手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手卡的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
