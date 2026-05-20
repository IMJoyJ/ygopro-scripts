--ケンドウ魂 KAI－DEN
-- 效果：
-- ←9 【灵摆】 9→
-- ①：场上有怪兽灵摆召唤的场合发动。灵摆区域的这张卡回到持有者手卡。
-- 【怪兽效果】
-- ①：这张卡召唤成功时才能发动。选自己的灵摆区域1张卡，和那张卡相同纵列的对方的卡全部送去墓地。
-- ②：这张卡召唤·反转的回合的结束阶段发动。这张卡回到持有者手卡。
function c71614230.initial_effect(c)
	-- 为卡片注册灵摆怪兽的固有属性（灵摆召唤、作为灵摆卡发动）
	aux.EnablePendulumAttribute(c)
	-- 注册灵魂怪兽在召唤·反转的回合结束阶段回到持有者手卡的效果
	aux.EnableSpiritReturn(c,EVENT_SUMMON_SUCCESS,EVENT_FLIP)
	-- ①：场上有怪兽灵摆召唤的场合发动。灵摆区域的这张卡回到持有者手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCondition(c71614230.thcon)
	e1:SetTarget(c71614230.thtg)
	e1:SetOperation(c71614230.thop)
	c:RegisterEffect(e1)
	-- ①：这张卡召唤成功时才能发动。选自己的灵摆区域1张卡，和那张卡相同纵列的对方的卡全部送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetTarget(c71614230.gytg)
	e2:SetOperation(c71614230.gyop)
	c:RegisterEffect(e2)
end
-- 检查是否有怪兽进行过灵摆召唤，作为灵摆效果的发动条件
function c71614230.thcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsSummonType,1,nil,SUMMON_TYPE_PENDULUM)
end
-- 灵摆效果的Target函数，确认效果处理时将自身加入手卡
function c71614230.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息，表示此效果会将灵摆区域的这张卡送回手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- 灵摆效果的Operation函数，将灵摆区域的这张卡送回持有者手卡
function c71614230.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将这张卡因效果送回持有者的手卡
	Duel.SendtoHand(c,nil,REASON_EFFECT)
end
-- 过滤函数：筛选自己灵摆区域中，其相同纵列存在对方场上卡的卡片
function c71614230.tgfilter(c,tp)
	-- 检查对方场上是否存在与该灵摆卡处于相同纵列的卡
	return Duel.IsExistingMatchingCard(c71614230.gyfilter,tp,0,LOCATION_ONFIELD,1,nil,c:GetColumnGroup())
end
-- 过滤函数：检查卡片是否在选定灵摆卡的相同纵列
function c71614230.gyfilter(c,g)
	return g:IsContains(c)
end
-- 怪兽效果①的Target函数，检查自己灵摆区是否存在符合条件的卡，并设置送去墓地的操作信息
function c71614230.gytg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段，检查自己灵摆区域是否存在至少1张其相同纵列有对方卡片的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c71614230.tgfilter,tp,LOCATION_PZONE,0,1,nil,tp) end
	-- 设置操作信息，表示此效果会将对方场上的卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,0,1-tp,LOCATION_ONFIELD)
end
-- 怪兽效果①的Operation函数，让玩家选择自己灵摆区的一张卡，并将其相同纵列的对方卡片全部送去墓地
function c71614230.gyop(e,tp,eg,ep,ev,re,r,rp)
	-- 让玩家选择自己灵摆区域的1张符合条件的卡
	local pg=Duel.SelectMatchingCard(tp,c71614230.tgfilter,tp,LOCATION_PZONE,0,1,1,nil,tp)
	if pg:GetCount()==0 then return end
	-- 获取对方场上与所选灵摆卡处于相同纵列的所有卡片
	local g=Duel.GetMatchingGroup(c71614230.gyfilter,tp,0,LOCATION_ONFIELD,nil,pg:GetFirst():GetColumnGroup())
	-- 将获取到的对方卡片全部送去墓地
	Duel.SendtoGrave(g,REASON_EFFECT)
end
