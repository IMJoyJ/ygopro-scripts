--ステイセイラ・ロマリン
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：以自己场上1只表侧表示怪兽为对象才能发动。选那只怪兽以外的自己场上1只植物族怪兽送去墓地，作为对象的怪兽在这个回合只有1次不会被战斗·效果破坏。这个效果在对方回合也能发动。
-- ②：这张卡被效果送去墓地的场合才能发动。从卡组·额外卡组把1只5星以下的植物族怪兽送去墓地。
function c49964567.initial_effect(c)
	-- ①：以自己场上1只表侧表示怪兽为对象才能发动。选那只怪兽以外的自己场上1只植物族怪兽送去墓地，作为对象的怪兽在这个回合只有1次不会被战斗·效果破坏。这个效果在对方回合也能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(49964567,0))
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCountLimit(1,49964567)
	e1:SetTarget(c49964567.indtg)
	e1:SetOperation(c49964567.indop)
	c:RegisterEffect(e1)
	-- ②：这张卡被效果送去墓地的场合才能发动。从卡组·额外卡组把1只5星以下的植物族怪兽送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(49964567,1))
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,49964568)
	e2:SetCondition(c49964567.tgcon)
	e2:SetTarget(c49964567.tgtg)
	e2:SetOperation(c49964567.tgop)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于判断目标怪兽是否满足条件（表侧表示且自己场上存在至少一只植物族怪兽）
function c49964567.indfilter(c,tp)
	-- 返回目标怪兽是否为表侧表示且自己场上存在至少一只植物族怪兽
	return c:IsFaceup() and Duel.IsExistingMatchingCard(c49964567.cfilter,tp,LOCATION_MZONE,0,1,c)
end
-- 过滤函数，用于筛选自己场上满足条件的植物族怪兽（表侧表示且能送去墓地）
function c49964567.cfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_PLANT) and c:IsAbleToGrave()
end
-- 设置①效果的目标选择处理逻辑，检查是否存在符合条件的目标怪兽并进行选择
function c49964567.indtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c49964567.indfilter(chkc,tp) end
	-- 判断是否满足①效果发动的条件，即自己场上是否存在符合条件的目标怪兽
	if chk==0 then return Duel.IsExistingTarget(c49964567.indfilter,tp,LOCATION_MZONE,0,1,nil,tp) end
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择目标怪兽，要求为己方场上的表侧表示怪兽且满足indfilter条件
	Duel.SelectTarget(tp,c49964567.indfilter,tp,LOCATION_MZONE,0,1,1,nil,tp)
	-- 设置操作信息，表明该效果将把一张卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_MZONE)
end
-- ①效果的处理函数，执行将目标怪兽以外的植物族怪兽送去墓地并使目标怪兽在本回合内不会被战斗或效果破坏
function c49964567.indop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中选择的目标怪兽
	local tc=Duel.GetFirstTarget()
	local exc=nil
	if tc:IsRelateToEffect(e) then exc=tc end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从己方场上选择一只满足条件的植物族怪兽（不包括已选目标怪兽）
	local g=Duel.SelectMatchingCard(tp,c49964567.cfilter,tp,LOCATION_MZONE,0,1,1,exc)
	local sc=g:GetFirst()
	if sc then
		-- 显示所选卡被选为对象的动画效果
		Duel.HintSelection(g)
		-- 将选定的植物族怪兽送去墓地，并判断是否成功以及目标怪兽是否仍然有效
		if Duel.SendtoGrave(sc,REASON_EFFECT)~=0 and sc:IsLocation(LOCATION_GRAVE) and tc:IsRelateToEffect(e) then
			-- 创建一个永续效果，使目标怪兽在本回合内不会被战斗或效果破坏
			local e1=Effect.CreateEffect(c)
			e1:SetDescription(aux.Stringid(49964567,2))  --"「支索帆水手·航海迷迭香」效果适用中"
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
			e1:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
			e1:SetCountLimit(1)
			e1:SetValue(c49964567.valcon)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e1)
		end
	end
end
-- 设定该效果仅对战斗或效果破坏生效
function c49964567.valcon(e,re,r,rp)
	return bit.band(r,REASON_BATTLE+REASON_EFFECT)~=0
end
-- ②效果的发动条件，判断此卡是否因效果而送去墓地
function c49964567.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_EFFECT)
end
-- 过滤函数，用于筛选卡组或额外卡组中满足条件的植物族怪兽（等级不超过5星且能送去墓地）
function c49964567.tgfilter(c)
	return c:IsLevelBelow(5) and c:IsRace(RACE_PLANT) and c:IsAbleToGrave()
end
-- 设置②效果的目标选择处理逻辑，检查是否存在符合条件的卡并进行选择
function c49964567.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足②效果发动的条件，即自己卡组或额外卡组中是否存在符合条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c49964567.tgfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,nil) end
	-- 设置操作信息，表明该效果将把一张卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK+LOCATION_EXTRA)
end
-- ②效果的处理函数，从卡组或额外卡组选择一只植物族怪兽并将其送去墓地
function c49964567.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从己方卡组或额外卡组中选择一只满足条件的植物族怪兽
	local g=Duel.SelectMatchingCard(tp,c49964567.tgfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选定的卡送去墓地，原因标记为效果
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
