--ポケ・ドラ
-- 效果：
-- 这张卡召唤成功时，可以从自己卡组把1只「袖珍龙」加入手卡。
function c8175346.initial_effect(c)
	-- 这张卡召唤成功时，可以从自己卡组把1只「袖珍龙」加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(8175346,0))  --"检索"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c8175346.target)
	e1:SetOperation(c8175346.operation)
	c:RegisterEffect(e1)
end
-- 过滤卡组中卡名为「袖珍龙」且可以加入手牌的怪兽
function c8175346.filter(c)
	return c:IsCode(8175346) and c:IsAbleToHand()
end
-- 效果发动的目标选择与检测函数
function c8175346.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段，检查自己卡组是否存在至少1张「袖珍龙」
	if chk==0 then return Duel.IsExistingMatchingCard(c8175346.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置当前连锁的操作信息为：将卡组的1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理的执行函数
function c8175346.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己卡组中第1张满足过滤条件的「袖珍龙」
	local tc=Duel.GetFirstMatchingCard(c8175346.filter,tp,LOCATION_DECK,0,nil)
	if tc then
		-- 将该卡因效果加入手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手牌的卡片
		Duel.ConfirmCards(1-tp,tc)
	end
end
