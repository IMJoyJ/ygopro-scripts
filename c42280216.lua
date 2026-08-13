--太陽の神官
-- 效果：
-- ①：只有对方场上才有怪兽存在的场合，这张卡可以从手卡特殊召唤。
-- ②：场上的这张卡被破坏送去墓地时才能发动。从卡组把1只「赤蚁」或者「苏帕伊」加入手卡。
function c42280216.initial_effect(c)
	-- ①：只有对方场上才有怪兽存在的场合，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c42280216.spcon)
	c:RegisterEffect(e1)
	-- ②：场上的这张卡被破坏送去墓地时才能发动。从卡组把1只「赤蚁」或者「苏帕伊」加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(42280216,0))  --"检索"
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCondition(c42280216.shcon)
	e2:SetTarget(c42280216.shtg)
	e2:SetOperation(c42280216.shop)
	c:RegisterEffect(e2)
end
-- 特殊召唤规则效果的条件函数：判定是否满足“只有对方场上才有怪兽存在的场合”且自己场上有可用空格，从而允许这张卡从手卡特殊召唤。
function c42280216.spcon(e,c)
	if c==nil then return true end
	-- 检查这张卡的控制者自己主要怪兽区没有怪兽（自己场上没有怪兽）。
	return Duel.GetFieldGroupCount(c:GetControler(),LOCATION_MZONE,0)==0
		-- 检查对方主要怪兽区存在怪兽（只有对方场上才有怪兽存在的场合）。
		and	Duel.GetFieldGroupCount(c:GetControler(),0,LOCATION_MZONE)>0
		-- 检查自己主要怪兽区有空余位置，可供这张卡特殊召唤。
		and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
end
-- ②效果的发动条件：这张卡之前在场地区域，并且因破坏被送去墓地，满足“场上的这张卡被破坏送去墓地时才能发动”的条件。
function c42280216.shcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD) and e:GetHandler():IsReason(REASON_DESTROY)
end
-- 检索过滤条件：卡名是「赤蚁」（78275321）或「苏帕伊」（78552773），且可以被加入手卡。
function c42280216.filter(c)
	return c:IsCode(78275321,78552773) and c:IsAbleToHand()
end
-- ②效果的发动目标与操作信息设定：先确认卡组是否存在符合条件的检索对象，若存在则设置将1张卡加入手卡的操作信息。
function c42280216.shtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查：卡组中是否存在至少1张符合条件的卡，若不存在则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c42280216.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：本次效果处理将把1张卡从卡组加入手卡，用于配合其他卡片对效果的连锁与判定。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ②效果处理时：玩家选择1张符合条件的卡加入手卡，并向对方确认加入手卡的卡。
function c42280216.shop(e,tp,eg,ep,ev,re,r,rp)
	-- 弹出选择提示：请选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选出1张满足条件的卡（「赤蚁」或「苏帕伊」）。
	local g=Duel.SelectMatchingCard(tp,c42280216.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入其持有者的手卡，原因为效果处理。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家确认加入手卡的卡片，以公开检索结果。
		Duel.ConfirmCards(1-tp,g)
	end
end
