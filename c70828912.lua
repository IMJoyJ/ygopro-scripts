--早すぎた埋葬
-- 效果：
-- ①：支付800基本分，以自己墓地1只怪兽为对象才能把这张卡发动。那只怪兽攻击表示特殊召唤，把这张卡装备。这张卡破坏时那只怪兽破坏。
function c70828912.initial_effect(c)
	-- ①：支付800基本分，以自己墓地1只怪兽为对象才能把这张卡发动。那只怪兽攻击表示特殊召唤，把这张卡装备。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCost(c70828912.cost)
	e1:SetTarget(c70828912.target)
	e1:SetOperation(c70828912.operation)
	c:RegisterEffect(e1)
	-- 这张卡破坏时那只怪兽破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetOperation(c70828912.desop)
	c:RegisterEffect(e2)
end
-- 检查并支付800基本分作为发动的代价
function c70828912.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否能够支付800基本分
	if chk==0 then return Duel.CheckLPCost(tp,800)
	-- 扣除800基本分
	else Duel.PayLPCost(tp,800)	end
end
-- 过滤自己墓地可以表侧攻击表示特殊召唤的怪兽
function c70828912.spfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK)
end
-- 发动时的对象选择与效果分类等信息设置
function c70828912.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c70828912.spfilter(chkc,e,tp) end
	-- 检查自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在可以特殊召唤的合法对象
		and Duel.IsExistingTarget(c70828912.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只怪兽作为对象
	local g=Duel.SelectTarget(tp,c70828912.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置连锁信息：包含特殊召唤选定怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
	-- 设置连锁信息：包含装备这张卡的操作
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 装备限制：只能装备给作为对象的怪兽
function c70828912.eqlimit(e,c)
	return e:GetLabelObject()==c
end
-- 发动时的效果处理：特殊召唤目标怪兽并装备这张卡，同时添加装备限制
function c70828912.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取发动时选择的对象怪兽
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
		e1:SetValue(c70828912.eqlimit)
		e1:SetLabelObject(tc)
		c:RegisterEffect(e1)
	end
end
-- 这张卡被破坏时，破坏装备的怪兽
function c70828912.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=c:GetFirstCardTarget()
	if c:IsReason(REASON_DESTROY) and tc and tc:IsLocation(LOCATION_MZONE) then
		-- 因效果破坏该怪兽
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
