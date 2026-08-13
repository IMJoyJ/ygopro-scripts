--荒魂
-- 效果：
-- 这张卡不能特殊召唤。
-- ①：这张卡召唤·反转时才能发动。从卡组把「荒魂」以外的1只灵魂怪兽加入手卡。
-- ②：这张卡召唤·反转的回合的结束阶段发动。这张卡回到手卡。
function c16889337.initial_effect(c)
	-- 给这张卡赋予灵魂怪兽共通的“召唤·反转的回合的结束阶段回到手卡”效果，对应②的文字处理。
	aux.EnableSpiritReturn(c,EVENT_SUMMON_SUCCESS,EVENT_FLIP)
	-- 这张卡不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 将特殊召唤条件的判定值固定为false，使这张卡无法通过任何效果或规则被特殊召唤。
	e1:SetValue(aux.FALSE)
	c:RegisterEffect(e1)
	-- ①：这张卡召唤·反转时才能发动。从卡组把「荒魂」以外的1只灵魂怪兽加入手卡。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(16889337,0))  --"返回手卡"
	e4:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_SUMMON_SUCCESS)
	e4:SetTarget(c16889337.thtg)
	e4:SetOperation(c16889337.thop)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EVENT_FLIP)
	c:RegisterEffect(e5)
end
-- 检索筛选条件：从卡组中寻找1只灵魂怪兽，且卡名不是「荒魂」，并能够加入手卡。
function c16889337.filter(c)
	return c:IsType(TYPE_SPIRIT) and not c:IsCode(16889337) and c:IsAbleToHand()
end
-- 诱发选发效果的发动判定与操作信息设置：在召唤成功时点检查是否存在合法检索目标，并登记将卡加入手卡的处理信息。
function c16889337.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动合法性检查阶段，确认卡组中是否存在至少1只符合条件的灵魂怪兽；若不存在则效果不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c16889337.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置当前连锁的操作信息，标明本次效果处理包含从卡组将1张卡加入手卡的分类，供相关卡牌效果检测。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：从卡组选1只符合条件的灵魂怪兽加入手卡，并向对方展示加入手卡的卡。
function c16889337.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 弹出选择卡片的提示，提示当前玩家选择一张要加入手卡的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 玩家从自己卡组中选出1张满足filter条件的卡（灵魂怪兽、不是「荒魂」、可加入手卡）。
	local g=Duel.SelectMatchingCard(tp,c16889337.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选出的卡以效果原因送去持有者的手卡，即加入手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手卡的卡展示给对方玩家确认，确保信息公开。
		Duel.ConfirmCards(1-tp,g)
	end
end
