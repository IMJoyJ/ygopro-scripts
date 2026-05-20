--精神統一
-- 效果：
-- 从卡组中选择1张「精神统一」加入手卡。这张卡1回合只能使用1张。
function c7512044.initial_effect(c)
	-- 从卡组中选择1张「精神统一」加入手卡。这张卡1回合只能使用1张。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,7512044+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c7512044.target)
	e1:SetOperation(c7512044.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数：检查卡片是否为「精神统一」且可以加入手卡
function c7512044.filter(c)
	return c:IsCode(7512044) and c:IsAbleToHand()
end
-- 效果发动的目标选择与检测函数
function c7512044.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段（chk==0）检测卡组中是否存在可加入手卡的「精神统一」
	if chk==0 then return Duel.IsExistingMatchingCard(c7512044.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息，表示此效果包含将卡组中的1张卡加入手卡的操作
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理（发动）函数，执行具体的检索和加入手卡操作
function c7512044.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 给发动效果的玩家发送提示信息，提示其选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组中选择1张「精神统一」
	local g=Duel.SelectMatchingCard(tp,c7512044.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡片因效果加入手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手卡的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
