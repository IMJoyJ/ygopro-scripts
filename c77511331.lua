--カラテ魂 KURO－OBI
-- 效果：
-- ←9 【灵摆】 9→
-- ①：场上有怪兽灵摆召唤的场合发动。灵摆区域的这张卡回到持有者手卡。
-- 【怪兽效果】
-- ①：这张卡召唤成功时才能发动。和自己的灵摆区域的卡相同纵列的对方的魔法·陷阱卡全部送去墓地。
-- ②：这张卡召唤·反转的回合的结束阶段发动。这张卡回到持有者手卡。
function c77511331.initial_effect(c)
	-- 为这张卡添加灵摆怪兽属性（注册灵摆召唤和作为灵摆卡发动等基本规则）
	aux.EnablePendulumAttribute(c)
	-- 为这张卡添加灵魂怪兽在召唤或翻转的回合结束阶段回到持有者手卡的效果
	aux.EnableSpiritReturn(c,EVENT_SUMMON_SUCCESS,EVENT_FLIP)
	-- ①：场上有怪兽灵摆召唤的场合发动。灵摆区域的这张卡回到持有者手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCondition(c77511331.thcon)
	e1:SetTarget(c77511331.thtg)
	e1:SetOperation(c77511331.thop)
	c:RegisterEffect(e1)
	-- ①：这张卡召唤成功时才能发动。和自己的灵摆区域的卡相同纵列的对方的魔法·陷阱卡全部送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetTarget(c77511331.gytg)
	e2:SetOperation(c77511331.gyop)
	c:RegisterEffect(e2)
end
-- 检查是否有怪兽通过灵摆召唤特殊召唤成功
function c77511331.thcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsSummonType,1,nil,SUMMON_TYPE_PENDULUM)
end
-- 灵摆效果回到手卡效果的靶向/发动准备函数，设置将自身送回手卡的操作信息
function c77511331.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置当前连锁的处理信息为将这张卡（灵摆区域的自身）送回手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- 灵摆效果回到手卡效果的执行函数，若此卡仍在场则将其送回手卡
function c77511331.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将这张卡送回持有者的手卡
	Duel.SendtoHand(c,nil,REASON_EFFECT)
end
-- 过滤自身灵摆区域的卡，条件是：对方场上存在至少一张与其处于相同纵列的魔法·陷阱卡
function c77511331.tgfilter(c,tp)
	-- 检查对方场上是否存在与该灵摆卡相同纵列的魔法·陷阱卡
	return Duel.IsExistingMatchingCard(c77511331.gyfilter,tp,0,LOCATION_ONFIELD,1,nil,c:GetColumnGroup())
end
-- 过滤对方场上的魔法·陷阱卡，条件是：该卡包含在指定的纵列卡片组中
function c77511331.gyfilter(c,g)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and g:IsContains(c)
end
-- 召唤成功时送去墓地效果的靶向/发动准备函数，检查是否存在符合条件的灵摆卡，并设置将对方场上卡片送去墓地的操作信息
function c77511331.gytg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己的灵摆区域是否存在符合条件（其相同纵列有对方魔陷）的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c77511331.tgfilter,tp,LOCATION_PZONE,0,1,nil,tp) end
	-- 设置当前连锁的处理信息为将对方场上的卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,0,1-tp,LOCATION_ONFIELD)
end
-- 召唤成功时送去墓地效果的执行函数，收集所有与自己灵摆区域卡片相同纵列的对方魔陷并送去墓地
function c77511331.gyop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己灵摆区域中所有符合条件（相同纵列有对方魔陷）的卡片组
	local pg=Duel.GetMatchingGroup(c77511331.tgfilter,tp,LOCATION_PZONE,0,nil,tp)
	if pg:GetCount()==0 then return end
	local g=Group.CreateGroup()
	-- 遍历这些符合条件的灵摆卡
	for pc in aux.Next(pg) do
		-- 将与当前遍历到的灵摆卡相同纵列的对方魔法·陷阱卡合并到目标卡片组中
		g:Merge(Duel.GetMatchingGroup(c77511331.gyfilter,tp,0,LOCATION_ONFIELD,nil,pc:GetColumnGroup()))
	end
	-- 将收集到的所有目标魔法·陷阱卡送去墓地
	Duel.SendtoGrave(g,REASON_EFFECT)
end
