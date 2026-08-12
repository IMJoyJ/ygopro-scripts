--忍者マスター HANZO
-- 效果：
-- ①：这张卡召唤成功时才能发动。从卡组把1张「忍法」卡加入手卡。
-- ②：这张卡反转召唤·特殊召唤成功时才能发动。从卡组把「忍者头领 半藏」以外的1只「忍者」怪兽加入手卡。
function c95027497.initial_effect(c)
	-- ①：这张卡召唤成功时才能发动。从卡组把1张「忍法」卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(95027497,0))  --"检索"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c95027497.tg1)
	e1:SetOperation(c95027497.op1)
	c:RegisterEffect(e1)
	-- ②：这张卡反转召唤·特殊召唤成功时才能发动。从卡组把「忍者头领 半藏」以外的1只「忍者」怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(95027497,0))  --"检索"
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e2:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	e2:SetTarget(c95027497.tg2)
	e2:SetOperation(c95027497.op2)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
end
-- 过滤卡组中满足是「忍法」卡且能加入手卡的卡片
function c95027497.filter1(c)
	return c:IsSetCard(0x61) and c:IsAbleToHand()
end
-- 过滤卡组中满足是「忍者头领 半藏」以外的「忍者」怪兽且能加入手卡的卡片
function c95027497.filter2(c)
	return c:IsSetCard(0x2b) and not c:IsCode(95027497) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 效果①的发动准备与检测（检查卡组中是否存在可检索的「忍法」卡，并设置操作信息）
function c95027497.tg1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1张满足过滤条件1（「忍法」卡）且能加入手卡的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c95027497.filter1,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁处理的操作信息，表示该效果会将卡组中的1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果①的处理（从卡组选择1张「忍法」卡加入手卡并给对方确认）
function c95027497.op1(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组中选择1张满足过滤条件1（「忍法」卡）的卡
	local g=Duel.SelectMatchingCard(tp,c95027497.filter1,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡片因效果加入玩家手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手卡的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 效果②的发动准备与检测（检查卡组中是否存在可检索的「忍者」怪兽，并设置操作信息）
function c95027497.tg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1张满足过滤条件2（「忍者头领 半藏」以外的「忍者」怪兽）且能加入手卡的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c95027497.filter2,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁处理的操作信息，表示该效果会将卡组中的1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果②的处理（从卡组选择1张「忍者头领 半藏」以外的「忍者」怪兽加入手卡并给对方确认）
function c95027497.op2(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组中选择1张满足过滤条件2（「忍者头领 半藏」以外的「忍者」怪兽）的卡
	local g=Duel.SelectMatchingCard(tp,c95027497.filter2,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡片因效果加入玩家手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手卡的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
