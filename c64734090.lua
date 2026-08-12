--ジェムタートル
-- 效果：
-- 反转：可以从自己卡组把1张「宝石骑士融合」加入手卡。
function c64734090.initial_effect(c)
	-- 反转：可以从自己卡组把1张「宝石骑士融合」加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(64734090,0))  --"加入手卡"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetTarget(c64734090.tg)
	e1:SetOperation(c64734090.op)
	c:RegisterEffect(e1)
end
-- 过滤卡组中卡名为「宝石骑士融合」且可以加入手牌的卡
function c64734090.filter(c)
	return c:IsCode(1264319) and c:IsAbleToHand()
end
-- 效果发动的目标检查与操作信息设置
function c64734090.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段，检查自己卡组是否存在可以加入手牌的「宝石骑士融合」
	if chk==0 then return Duel.IsExistingMatchingCard(c64734090.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息为：将卡组中的1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理的执行：从卡组选择「宝石骑士融合」加入手牌并给对方确认
function c64734090.op(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从自己卡组中选择1张「宝石骑士融合」
	local g=Duel.SelectMatchingCard(tp,c64734090.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡因效果加入玩家手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手牌的卡给对方玩家确认
		Duel.ConfirmCards(1-tp,g)
	end
end
