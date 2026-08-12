--魔サイの戦士
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：只要这张卡在怪兽区域存在，「魔犀族战士」以外的自己场上的恶魔族怪兽不会被战斗·效果破坏。
-- ②：这张卡被送去墓地的场合才能发动。从卡组把「魔犀族战士」以外的1只恶魔族怪兽送去墓地。
function c81035362.initial_effect(c)
	-- ①：只要这张卡在怪兽区域存在，「魔犀族战士」以外的自己场上的恶魔族怪兽不会被战斗破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(c81035362.indtg)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	c:RegisterEffect(e2)
	-- ②：这张卡被送去墓地的场合才能发动。从卡组把「魔犀族战士」以外的1只恶魔族怪兽送去墓地。这个卡名的②的效果1回合只能使用1次。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(81035362,0))
	e3:SetCategory(CATEGORY_TOGRAVE+CATEGORY_DECKDES)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCountLimit(1,81035362)
	e3:SetTarget(c81035362.tgtg)
	e3:SetOperation(c81035362.tgop)
	c:RegisterEffect(e3)
end
-- 过滤出「魔犀族战士」以外的自己场上的恶魔族怪兽作为不会被战斗破坏的适用对象
function c81035362.indtg(e,c)
	return c:IsRace(RACE_FIEND) and not c:IsCode(81035362)
end
-- 过滤出卡组中「魔犀族战士」以外的、可以送去墓地的恶魔族怪兽
function c81035362.tgfilter(c)
	return c:IsRace(RACE_FIEND) and not c:IsCode(81035362) and c:IsAbleToGrave()
end
-- 效果②的发动准备与合法性检测（检查卡组中是否存在符合条件的卡，并设置送去墓地的操作信息）
function c81035362.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段，检查卡组中是否存在至少1张「魔犀族战士」以外的恶魔族怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c81035362.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁处理的操作信息，表示该效果会将卡组的1张卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 效果②的效果处理（从卡组选择1只「魔犀族战士」以外的恶魔族怪兽送去墓地）
function c81035362.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 给玩家发送提示信息，要求选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从卡组选择1张满足过滤条件的恶魔族怪兽
	local g=Duel.SelectMatchingCard(tp,c81035362.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡因效果送去墓地
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
