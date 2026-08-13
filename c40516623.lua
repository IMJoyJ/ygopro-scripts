--スモウ魂 YOKO－ZUNA
-- 效果：
-- ←1 【灵摆】 1→
-- ①：场上有怪兽灵摆召唤的场合发动。灵摆区域的这张卡回到持有者手卡。
-- 【怪兽效果】
-- ①：这张卡召唤成功时才能发动。和自己的灵摆区域的卡相同纵列的对方怪兽全部送去墓地。
-- ②：这张卡召唤·反转的回合的结束阶段发动。这张卡回到持有者手卡。
function c40516623.initial_effect(c)
	-- 为这张卡添加灵摆怪兽属性，使其可作为灵摆卡从手牌发动到灵摆区，并能进行灵摆召唤。
	aux.EnablePendulumAttribute(c)
	-- 为这张卡添加灵魂怪兽的返回效果：在通常召唤或反转的回合结束阶段，这张卡回到持有者手卡。
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
-- 判断这次特殊召唤成功的怪兽中是否存在灵摆召唤的怪兽（作为灵摆效果的发动条件）。
function c40516623.thcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsSummonType,1,nil,SUMMON_TYPE_PENDULUM)
end
-- 灵摆效果的发动目标处理：判定可发动后，设置将灵摆区的这张卡加入手卡的操作信息。
function c40516623.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息，登记该效果为“把灵摆区的这张卡加入持有者手卡”的分类。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- 灵摆效果处理时，确认这张卡仍与效果关联，若关联则将其送回持有者手卡。
function c40516623.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 实际执行：把这张卡加入持有者手卡（以效果原因）。
	Duel.SendtoHand(c,nil,REASON_EFFECT)
end
-- 判断某张灵摆卡是否满足条件：对方场上存在与其同一纵列的怪兽（用于筛选灵摆卡）。
function c40516623.tgfilter(c,tp)
	-- 检查对方怪兽区是否存在至少1张与这张灵摆卡处于同一纵列的怪兽。
	return Duel.IsExistingMatchingCard(c40516623.gyfilter,tp,0,LOCATION_MZONE,1,nil,c:GetColumnGroup())
end
-- 过滤函数：判断某怪兽是否属于传入的同纵列卡组g中。
function c40516623.gyfilter(c,g)
	return g:IsContains(c)
end
-- 怪兽效果①的发动条件与操作信息：检查自己灵摆区是否有符合条件的灵摆卡，并设置将对方怪兽送去墓地的操作信息。
function c40516623.gytg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查：确认自己的灵摆区域存在至少一张满足“与对方怪兽同纵列”条件的灵摆卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c40516623.tgfilter,tp,LOCATION_PZONE,0,1,nil,tp) end
	-- 设置操作信息，登记该效果为“将对方场上的怪兽送去墓地”的分类，目标为对方怪兽区。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,0,1-tp,LOCATION_MZONE)
end
-- 处理怪兽效果①：收集所有符合条件的灵摆卡的同纵列对方怪兽，将其全部送去墓地。
function c40516623.gyop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己灵摆区中所有满足“存在同纵列对方怪兽”条件的灵摆卡组。
	local pg=Duel.GetMatchingGroup(c40516623.tgfilter,tp,LOCATION_PZONE,0,nil,tp)
	if pg:GetCount()==0 then return end
	local g=Group.CreateGroup()
	-- 遍历上一步获得的灵摆卡组中的每一张灵摆卡。
	for pc in aux.Next(pg) do
		-- 将当前灵摆卡同一纵列的对方怪兽并入总卡组g，作为待送去墓地的对象。
		g:Merge(Duel.GetMatchingGroup(c40516623.gyfilter,tp,0,LOCATION_MZONE,nil,pc:GetColumnGroup()))
	end
	-- 将收集到的全部对方怪兽以效果原因送去墓地。
	Duel.SendtoGrave(g,REASON_EFFECT)
end
