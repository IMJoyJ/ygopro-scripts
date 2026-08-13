--超量機獣エアロボロス
-- 效果：
-- 4星怪兽×2
-- ①：没有超量素材的这张卡不能攻击。
-- ②：1回合1次，把这张卡1个超量素材取除，以这张卡以外的场上1只表侧表示怪兽为对象才能发动。那只怪兽变成里侧守备表示。这张卡有「超级量子战士 绿光层」在作为超量素材的场合，这个效果在对方回合也能发动。
-- ③：1回合1次，自己主要阶段才能发动。选自己的手卡·场上1只「超级量子战士」怪兽在这张卡下面重叠作为超量素材。
function c11646785.initial_effect(c)
	-- 记录这张卡上记载着卡名「超级量子战士 绿光层」（卡号85374678）的事实，用于关联检索。
	aux.AddCodeList(c,85374678)
	-- 为这张卡添加超量召唤手续：用等级4的怪兽2只作为超量素材进行超量召唤（即效果原文的“4星怪兽×2”）。
	aux.AddXyzProcedure(c,nil,4,2)
	c:EnableReviveLimit()
	-- ①：没有超量素材的这张卡不能攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetCondition(c11646785.atcon)
	c:RegisterEffect(e1)
	-- ②：1回合1次，把这张卡1个超量素材取除，以这张卡以外的场上1只表侧表示怪兽为对象才能发动。那只怪兽变成里侧守备表示。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(11646785,0))  --"里侧守备表示"
	e2:SetCategory(CATEGORY_POSITION+CATEGORY_MSET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,EFFECT_COUNT_CODE_SINGLE)
	e2:SetCondition(c11646785.setcon1)
	e2:SetCost(c11646785.setcost)
	e2:SetTarget(c11646785.settg)
	e2:SetOperation(c11646785.setop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e3:SetCondition(c11646785.setcon2)
	c:RegisterEffect(e3)
	-- ③：1回合1次，自己主要阶段才能发动。选自己的手卡·场上1只「超级量子战士」怪兽在这张卡下面重叠作为超量素材。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(11646785,1))  --"超量素材"
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1)
	e4:SetTarget(c11646785.mttg)
	e4:SetOperation(c11646785.mtop)
	c:RegisterEffect(e4)
end
-- 判断这张卡的超量素材数量是否为0，用于①效果“没有超量素材的这张卡不能攻击”的条件判定。
function c11646785.atcon(e)
	return e:GetHandler():GetOverlayCount()==0
end
-- 判断这张卡没有把「超级量子战士 绿光层」作为超量素材，此时②效果只在主要阶段作为起动效果发动。
function c11646785.setcon1(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():GetOverlayGroup():IsExists(Card.IsCode,1,nil,85374678)
end
-- 判断这张卡有把「超级量子战士 绿光层」作为超量素材，此时②效果可以作为诱发即时效果在对方回合发动。
function c11646785.setcon2(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetOverlayGroup():IsExists(Card.IsCode,1,nil,85374678)
end
-- 发动②效果时，从这张卡上取除1个超量素材作为代价；代价检查时确认素材足够。
function c11646785.setcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 选择对象的过滤条件：表侧表示且可以被变成里侧守备表示的怪兽。
function c11646785.setfilter(c)
	return c:IsFaceup() and c:IsCanTurnSet()
end
-- ②效果的发动目标处理：检查合法对象、选择对象并设置操作信息。
function c11646785.settg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c11646785.setfilter(chkc) and chkc~=e:GetHandler() end
	-- 发动时确认场上存在1只这张卡以外的、满足条件的表侧表示怪兽可以作为对象。
	if chk==0 then return Duel.IsExistingTarget(c11646785.setfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,e:GetHandler()) end
	-- 向玩家显示“请选择要改变表示形式的怪兽”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
	-- 从双方怪兽区选择1只满足条件的表侧表示怪兽作为效果对象，并自动登记为连锁对象。
	local g=Duel.SelectTarget(tp,c11646785.setfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,e:GetHandler())
	-- 设置连锁操作信息，声明本次效果将执行改变表示形式（CATEGORY_POSITION）的操作，目标为刚才选择的对象，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
end
-- ②效果处理：取得对象后，若对象仍表侧表示且与效果相关，则将其变成里侧守备表示。
function c11646785.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得②效果发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 将目标怪兽的表示形式改为里侧守备表示。
		Duel.ChangePosition(tc,POS_FACEDOWN_DEFENSE)
	end
end
-- ③效果选择素材的过滤条件：自己手卡或场上的「超级量子战士」怪兽，且可作为超量素材；若传入效果，还要排除对该效果免疫的卡。
function c11646785.mtfilter(c,e)
	return c:IsFaceupEx() and c:IsType(TYPE_MONSTER) and c:IsSetCard(0x10dc) and c:IsCanOverlay() and not (e and c:IsImmuneToEffect(e))
end
-- ③效果发动条件：这张卡是超量怪兽，且自己手卡·场上有1只满足条件的「超级量子战士」怪兽可作为素材。
function c11646785.mttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsType(TYPE_XYZ)
		-- 确认自己手卡·场上存在至少1只可选的「超级量子战士」怪兽作为超量素材。
		and Duel.IsExistingMatchingCard(c11646785.mtfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil) end
end
-- ③效果处理：选择自己手卡·场上1只「超级量子战士」怪兽，将其（及原有超量素材按规则处理）重叠在这张卡下面作为超量素材。
function c11646785.mtop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 向玩家显示“请选择要作为超量素材的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)  --"请选择要作为超量素材的卡"
	-- 从自己手卡·场上选择1只满足条件的「超级量子战士」怪兽，作为本次要叠放的超量素材。
	local g=Duel.SelectMatchingCard(tp,c11646785.mtfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil,e)
	if g:GetCount()>0 then
		local mg=g:GetFirst():GetOverlayGroup()
		if mg:GetCount()>0 then
			-- 若选中的怪兽本身带有超量素材，则将这些原有素材按规则全部送去墓地。
			Duel.SendtoGrave(mg,REASON_RULE)
		end
		-- 把选择的怪兽作为超量素材叠放在这张卡下面。
		Duel.Overlay(c,g)
	end
end
