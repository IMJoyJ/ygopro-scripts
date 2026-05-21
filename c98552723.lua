--再臨の帝王
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：以自己墓地1只攻击力2400/守备力1000的怪兽或者攻击力2800/守备力1000的怪兽为对象才能把这张卡发动。那只怪兽效果无效守备表示特殊召唤，把这张卡装备。这张卡从场上离开时那只怪兽破坏。
-- ②：怪兽上级召唤的场合，装备怪兽可以作为2只的数量解放。
function c98552723.initial_effect(c)
	-- ①：以自己墓地1只攻击力2400/守备力1000的怪兽或者攻击力2800/守备力1000的怪兽为对象才能把这张卡发动。那只怪兽效果无效守备表示特殊召唤，把这张卡装备。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,98552723+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c98552723.target)
	e1:SetOperation(c98552723.operation)
	c:RegisterEffect(e1)
	-- 这张卡从场上离开时那只怪兽破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_LEAVE_FIELD_P)
	e2:SetOperation(c98552723.checkop)
	c:RegisterEffect(e2)
	-- 这张卡从场上离开时那只怪兽破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e3:SetCode(EVENT_LEAVE_FIELD)
	e3:SetOperation(c98552723.desop)
	e3:SetLabelObject(e2)
	c:RegisterEffect(e3)
	-- ②：怪兽上级召唤的场合，装备怪兽可以作为2只的数量解放。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_EQUIP)
	e4:SetCode(EFFECT_DOUBLE_TRIBUTE)
	e4:SetValue(c98552723.condition)
	c:RegisterEffect(e4)
end
-- 过滤自己墓地中攻击力2400或2800且守备力1000、可以特殊召唤的怪兽
function c98552723.spfilter(c,e,tp)
	return c:IsAttack(2400,2800) and c:IsDefense(1000) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动的对象选择与合法性检测
function c98552723.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c98552723.spfilter(chkc,e,tp) end
	-- 检查自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在满足条件的、可作为效果对象的怪兽
		and Duel.IsExistingTarget(c98552723.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只满足条件的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c98552723.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置特殊召唤的操作信息，包含目标怪兽组
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
	-- 设置装备的操作信息，包含这张卡自身
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 限制装备卡的装备对象为这张卡自身
function c98552723.eqlimit(e,c)
	return e:GetOwner()==c
end
-- 效果处理的执行函数，处理特殊召唤、装备以及无效化效果
function c98552723.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中被选择为对象的怪兽
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) then
		-- 尝试将目标怪兽以表侧守备表示特殊召唤，若失败则结束处理
		if not Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE) then return end
		-- 将这张卡装备给特殊召唤的怪兽
		Duel.Equip(tp,c,tc)
		-- 把这张卡装备。
		local e1=Effect.CreateEffect(tc)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(c98552723.eqlimit)
		c:RegisterEffect(e1)
		-- 那只怪兽效果无效
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
		local e3=e2:Clone()
		e3:SetCode(EFFECT_DISABLE_EFFECT)
		e3:SetValue(RESET_TURN_SET)
		tc:RegisterEffect(e3)
		-- 完成特殊召唤的后续处理
		Duel.SpecialSummonComplete()
	end
end
-- 在装备卡离场前，检查其是否处于效果被无效的状态，并记录在Label中
function c98552723.checkop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsDisabled() then
		e:SetLabel(1)
	else e:SetLabel(0) end
end
-- 装备卡离场时，若未被无效，则破坏其装备的怪兽
function c98552723.desop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabelObject():GetLabel()~=0 then return end
	local tc=e:GetHandler():GetFirstCardTarget()
	if tc and tc:IsLocation(LOCATION_MZONE) then
		-- 因效果破坏装备的怪兽
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- 限制该双祭品效果仅在怪兽进行上级召唤时适用
function c98552723.condition(e,c)
	return c:IsType(TYPE_MONSTER)
end
