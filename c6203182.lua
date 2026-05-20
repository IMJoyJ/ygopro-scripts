--一惜二跳
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：以对方墓地1只怪兽为对象才能把这张卡发动。那只怪兽在对方场上效果无效特殊召唤，把这张卡装备。这张卡从场上离开时那只怪兽破坏。
-- ②：装备怪兽不能攻击，不会成为攻击对象。
-- ③：装备怪兽成为融合·同调·超量·连接召唤的素材让这张卡被送去墓地的场合才能发动。得到融合·同调·超量·连接召唤的那只怪兽的控制权。
function c6203182.initial_effect(c)
	-- ①：以对方墓地1只怪兽为对象才能把这张卡发动。那只怪兽在对方场上效果无效特殊召唤，把这张卡装备。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,6203182+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c6203182.target)
	e1:SetOperation(c6203182.operation)
	c:RegisterEffect(e1)
	-- ②：装备怪兽不能攻击
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_CANNOT_ATTACK)
	c:RegisterEffect(e2)
	-- 不会成为攻击对象。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_CANNOT_BE_BATTLE_TARGET)
	-- 设置不会成为攻击对象的过滤函数，防止装备怪兽因不受效果影响而导致规则冲突
	e3:SetValue(aux.imval1)
	c:RegisterEffect(e3)
	-- ③：装备怪兽成为融合·同调·超量·连接召唤的素材让这张卡被送去墓地的场合才能发动。得到融合·同调·超量·连接召唤的那只怪兽的控制权。
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_CONTROL)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetCondition(c6203182.ctcon)
	e4:SetTarget(c6203182.cttg)
	e4:SetOperation(c6203182.ctop)
	c:RegisterEffect(e4)
	-- 这张卡从场上离开时那只怪兽破坏。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e5:SetCode(EVENT_LEAVE_FIELD)
	e5:SetOperation(c6203182.desop)
	c:RegisterEffect(e5)
end
-- 过滤对方墓地中可以特殊召唤到对方场上的怪兽
function c6203182.spfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,1-tp)
end
-- 效果①的发动准备：检查对方场上是否有空位，以及对方墓地是否有可特殊召唤的怪兽
function c6203182.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(1-tp) and c6203182.spfilter(chkc,e,tp) end
	-- 检查对方场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0
		-- 检查对方墓地是否存在满足特殊召唤条件的怪兽
		and Duel.IsExistingTarget(c6203182.spfilter,tp,0,LOCATION_GRAVE,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择对方墓地1只怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c6203182.spfilter,tp,0,LOCATION_GRAVE,1,1,nil,e,tp)
	-- 设置特殊召唤的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
	-- 设置装备卡的操作信息
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 效果①的处理：特殊召唤目标怪兽，将其效果无效并装备这张卡
function c6203182.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取发动的对象怪兽
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e)
		-- 将目标怪兽以表侧表示特殊召唤到对方场上
		and Duel.SpecialSummonStep(tc,0,tp,1-tp,false,false,POS_FACEUP) then
		-- 将这张卡装备给特殊召唤的怪兽
		Duel.Equip(tp,c,tc)
		-- 把这张卡装备。
		local e1=Effect.CreateEffect(tc)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(c6203182.eqlimit)
		c:RegisterEffect(e1)
		-- 效果无效
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_DISABLE)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e3)
		-- 效果无效
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
	end
	-- 完成特殊召唤的流程
	Duel.SpecialSummonComplete()
end
-- 装备限制：只能装备给由该卡效果特殊召唤的怪兽
function c6203182.eqlimit(e,c)
	return e:GetOwner()==c
end
-- 效果③的发动条件：装备怪兽作为融合·同调·超量·连接召唤的素材导致此卡因失去装备对象而送去墓地
function c6203182.ctcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ec=c:GetPreviousEquipTarget()
	return ec and ec:GetReasonCard() and c:IsReason(REASON_LOST_TARGET) and ec:IsReason(REASON_MATERIAL)
		and (ec:IsReason(REASON_FUSION) or ec:IsReason(REASON_SYNCHRO) or ec:IsReason(REASON_XYZ) or ec:IsReason(REASON_LINK))
end
-- 效果③的目标选择：确认召唤出的怪兽可以改变控制权
function c6203182.cttg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ec=e:GetHandler():GetPreviousEquipTarget()
	local rc=ec:GetReasonCard()
	if chk==0 then return rc:IsControlerCanBeChanged() end
	rc:CreateEffectRelation(e)
	-- 设置转移控制权的操作信息
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,rc,1,0,0)
end
-- 效果③的处理：得到该召唤出的怪兽的控制权
function c6203182.ctop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ec=c:GetPreviousEquipTarget()
	local rc=ec:GetReasonCard()
	if rc and rc:IsRelateToEffect(e) then
		-- 获得该怪兽的控制权
		Duel.GetControl(rc,tp)
	end
end
-- 装备卡离场时的处理：破坏装备过的怪兽
function c6203182.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetFirstCardTarget()
	if tc and tc:IsLocation(LOCATION_MZONE) then
		-- 因效果破坏该怪兽
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
