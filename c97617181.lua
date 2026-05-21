--銀河零式
-- 效果：
-- 「银河零式」在1回合只能发动1张。
-- ①：以自己墓地1只「光子」怪兽或者「银河」怪兽为对象才能把这张卡发动。那只怪兽攻击表示特殊召唤，把这张卡装备。装备怪兽不能攻击，效果也不能发动。
-- ②：装备怪兽在战斗阶段被战斗·效果破坏的场合，可以作为代替把这张卡破坏。
-- ③：表侧表示的这张卡从场上离开的场合发动。这张卡装备过的怪兽的攻击力变成0。
function c97617181.initial_effect(c)
	-- ①：以自己墓地1只「光子」怪兽或者「银河」怪兽为对象才能把这张卡发动。那只怪兽攻击表示特殊召唤，把这张卡装备。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,97617181+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c97617181.target)
	e1:SetOperation(c97617181.operation)
	c:RegisterEffect(e1)
	-- 装备怪兽不能攻击
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_CANNOT_ATTACK)
	c:RegisterEffect(e2)
	-- 效果也不能发动。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_CANNOT_TRIGGER)
	c:RegisterEffect(e3)
	-- ②：装备怪兽在战斗阶段被战斗·效果破坏的场合，可以作为代替把这张卡破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_EQUIP+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EFFECT_DESTROY_REPLACE)
	e4:SetTarget(c97617181.desreptg)
	e4:SetOperation(c97617181.desrepop)
	c:RegisterEffect(e4)
	-- ③：表侧表示的这张卡从场上离开的场合发动。这张卡装备过的怪兽的攻击力变成0。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(97617181,0))  --"攻击变成0"
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e5:SetCode(EVENT_LEAVE_FIELD)
	e5:SetCondition(c97617181.atkcon)
	e5:SetOperation(c97617181.atkop)
	c:RegisterEffect(e5)
end
-- 过滤自己墓地中可以攻击表示特殊召唤的「光子」或「银河」怪兽
function c97617181.spfilter(c,e,tp)
	return c:IsSetCard(0x55,0x7b) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK)
end
-- ①效果的发动准备：检查并选择自己墓地1只符合条件的怪兽作为对象
function c97617181.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c97617181.spfilter(chkc,e,tp) end
	-- 检查自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在可以作为效果对象的符合条件的怪兽
		and Duel.IsExistingTarget(c97617181.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向玩家发送提示信息，要求选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只符合条件的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c97617181.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置在效果处理时将选择的对象特殊召唤的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
	-- 设置在效果处理时将这张卡装备给目标怪兽的操作信息
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 限制这张卡只能装备给通过此效果特殊召唤的怪兽
function c97617181.eqlimit(e,c)
	return e:GetLabelObject()==c
end
-- ①效果的处理：将目标怪兽特殊召唤并装备这张卡，同时添加装备限制
function c97617181.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取发动时选择的效果对象怪兽
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) then
		-- 将目标怪兽以表侧攻击表示特殊召唤，若特殊召唤失败则结束处理
		if Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_ATTACK)==0 then return end
		-- 将这张卡装备给特殊召唤的怪兽
		Duel.Equip(tp,c,tc)
		-- 把这张卡装备。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(c97617181.eqlimit)
		e1:SetLabelObject(tc)
		c:RegisterEffect(e1)
	end
end
-- 检查这张卡离场时，其原本装备的怪兽是否仍在怪兽区表侧表示存在，并将其记录为效果目标
function c97617181.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=c:GetFirstCardTarget()
	if tc and tc:IsLocation(LOCATION_MZONE) and tc:IsFaceup() then
		e:SetLabelObject(tc)
		tc:CreateEffectRelation(e)
		return true
	else return false end
end
-- ③效果的处理：将这张卡装备过的怪兽的攻击力变成0
function c97617181.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=e:GetLabelObject()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 这张卡装备过的怪兽的攻击力变成0。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(0)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
-- 代替破坏效果的条件检查与目标选择：检查是否在战斗阶段，且装备怪兽因战斗或效果将被破坏，并询问玩家是否用这张卡代替破坏
function c97617181.desreptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local ec=c:GetEquipTarget()
	-- 获取当前的阶段
	local ph=Duel.GetCurrentPhase()
	if chk==0 then return (ph>PHASE_MAIN1 and ph<PHASE_MAIN2)
		and c:IsDestructable(e) and not c:IsStatus(STATUS_DESTROY_CONFIRMED)
		and ec:IsReason(REASON_BATTLE+REASON_EFFECT) and not ec:IsReason(REASON_REPLACE) end
	-- 询问玩家是否发动代替破坏的效果
	return Duel.SelectEffectYesNo(tp,c,96)
end
-- 代替破坏效果的处理：将这张卡破坏
function c97617181.desrepop(e,tp,eg,ep,ev,re,r,rp)
	-- 将这张卡作为代替破坏
	Duel.Destroy(e:GetHandler(),REASON_EFFECT+REASON_REPLACE)
end
