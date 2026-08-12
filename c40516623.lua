--スモウ魂 YOKO－ZUNA
-- 效果：
-- ←1 【灵摆】 1→
-- ①：场上有怪兽灵摆召唤的场合发动。灵摆区域的这张卡回到持有者手卡。
-- 【怪兽效果】
-- ①：这张卡召唤成功时才能发动。和自己的灵摆区域的卡相同纵列的对方怪兽全部送去墓地。
-- ②：这张卡召唤·反转的回合的结束阶段发动。这张卡回到持有者手卡。
function c40516623.initial_effect(c)
	-- 为该卡添加灵摆怪兽属性，使其可以灵摆召唤和发动灵摆卡
	aux.EnablePendulumAttribute(c)
	-- 为该卡添加在召唤或反转时结束阶段回到手卡的效果
	aux.EnableSpiritReturn(c,EVENT_SUMMON_SUCCESS,EVENT_FLIP)
	-- ①：场上有怪兽灵摆召唤的场合发动。灵摆区域的这张卡回到持有者手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCondition(c40516623.thcon)
	e1:SetTarget(c40516623.thtg)
	e1:SetOperation(c40516623.thop)
	c:RegisterEffect(e1)
	-- ①：这张卡召唤成功时才能发动。和自己的灵摆区域的卡相同纵列的对方怪兽全部送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetTarget(c40516623.gytg)
	e2:SetOperation(c40516623.gyop)
	c:RegisterEffect(e2)
end
-- 判断是否有怪兽通过灵摆召唤成功
function c40516623.thcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsSummonType,1,nil,SUMMON_TYPE_PENDULUM)
end
-- 设置效果处理时将自身送回手卡的操作信息
function c40516623.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息中涉及将自身送回手卡的分类
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- 效果处理函数：将自身送回手卡
function c40516623.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将自身以效果原因送回手卡
	Duel.SendtoHand(c,nil,REASON_EFFECT)
end
-- 筛选函数：判断是否存在与灵摆区域卡片同纵列的对方怪兽
function c40516623.tgfilter(c,tp)
	-- 检查是否存在满足条件的对方怪兽
	return Duel.IsExistingMatchingCard(c40516623.gyfilter,tp,0,LOCATION_MZONE,1,nil,c:GetColumnGroup())
end
-- 筛选函数：判断对方怪兽是否在指定纵列中
function c40516623.gyfilter(c,g)
	return g:IsContains(c)
end
-- 设置效果处理时将对方怪兽送入墓地的操作信息
function c40516623.gytg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否存在满足条件的灵摆区域卡片
	if chk==0 then return Duel.IsExistingMatchingCard(c40516623.tgfilter,tp,LOCATION_PZONE,0,1,nil,tp) end
	-- 设置操作信息中涉及将对方怪兽送入墓地的分类
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,0,1-tp,LOCATION_MZONE)
end
-- 效果处理函数：将与灵摆区域卡片同纵列的对方怪兽送入墓地
function c40516623.gyop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取满足条件的灵摆区域卡片组
	local pg=Duel.GetMatchingGroup(c40516623.tgfilter,tp,LOCATION_PZONE,0,nil,tp)
	if pg:GetCount()==0 then return end
	local g=Group.CreateGroup()
	-- 遍历灵摆区域卡片组中的每张卡片
	for pc in aux.Next(pg) do
		-- 获取与当前灵摆区域卡片同纵列的对方怪兽并合并到目标组
		g:Merge(Duel.GetMatchingGroup(c40516623.gyfilter,tp,0,LOCATION_MZONE,nil,pc:GetColumnGroup()))
	end
	-- 将目标组中的怪兽以效果原因送入墓地
	Duel.SendtoGrave(g,REASON_EFFECT)
end
