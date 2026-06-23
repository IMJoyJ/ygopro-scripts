--伝説のフィッシャーマン二世
-- 效果：
-- ①：这张卡的卡名只要在场上·墓地存在当作「传说的渔人」使用。
-- ②：只要场上有「海」存在，场上的这张卡不受其他怪兽的效果影响。
-- ③：表侧表示的这张卡因对方的效果从场上离开的场合或者被战斗破坏的场合才能发动。从卡组把1只水属性·7星怪兽加入手卡。
function c19801646.initial_effect(c)
	-- 记录该卡视为「传说的渔人」的效果
	aux.AddCodeList(c,22702055)
	-- 使该卡在场上或墓地时视为「传说的渔人二世」
	aux.EnableChangeCode(c,3643300,LOCATION_MZONE+LOCATION_GRAVE)
	-- 只要场上有「海」存在，场上的这张卡不受其他怪兽的效果影响
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_IMMUNE_EFFECT)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c19801646.econ)
	e2:SetValue(c19801646.efilter)
	c:RegisterEffect(e2)
	-- 表侧表示的这张卡因对方的效果从场上离开的场合或者被战斗破坏的场合才能发动。从卡组把1只水属性·7星怪兽加入手卡
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(19801646,0))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_LEAVE_FIELD)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY+EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCondition(c19801646.thcon)
	e3:SetTarget(c19801646.thtg)
	e3:SetOperation(c19801646.thop)
	c:RegisterEffect(e3)
end
-- 效果过滤函数，用于判断是否免疫怪兽效果
function c19801646.efilter(e,te)
	return te:IsActiveType(TYPE_MONSTER) and te:GetOwner()~=e:GetOwner()
end
-- 环境检测函数，判断是否场上有「海」存在
function c19801646.econ(e)
	-- 检查场地卡号是否为「海」
	return Duel.IsEnvironment(22702055)
end
-- 效果发动条件函数，判断是否满足发动条件
function c19801646.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return (c:IsReason(REASON_BATTLE) or (c:GetReasonPlayer()==1-tp and c:IsReason(REASON_EFFECT)))
		and c:IsPreviousPosition(POS_FACEUP)
end
-- 检索过滤函数，用于筛选水属性7星怪兽
function c19801646.thfilter(c)
	return c:IsLevel(7) and c:IsAttribute(ATTRIBUTE_WATER) and c:IsAbleToHand()
end
-- 设置效果处理信息，准备从卡组检索水属性7星怪兽
function c19801646.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否卡组存在满足条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c19801646.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息，指定将要处理的卡组中的怪兽
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理函数，执行检索并加入手牌
function c19801646.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的水属性7星怪兽
	local g=Duel.SelectMatchingCard(tp,c19801646.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的怪兽送入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认送入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
