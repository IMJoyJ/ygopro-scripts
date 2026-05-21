--D・リペアユニット
-- 效果：
-- ①：从手卡把1只「变形斗士」怪兽送去墓地，以自己墓地1只「变形斗士」怪兽为对象才能把这张卡发动。作为对象的怪兽特殊召唤，把这张卡装备。这张卡从场上离开时那只怪兽破坏。
-- ②：装备怪兽不能把表示形式变更。
function c90239723.initial_effect(c)
	-- ①：从手卡把1只「变形斗士」怪兽送去墓地，以自己墓地1只「变形斗士」怪兽为对象才能把这张卡发动。作为对象的怪兽特殊召唤，把这张卡装备。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCost(c90239723.cost)
	e1:SetTarget(c90239723.target)
	e1:SetOperation(c90239723.operation)
	c:RegisterEffect(e1)
	-- 这张卡从场上离开时那只怪兽破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetOperation(c90239723.desop)
	c:RegisterEffect(e2)
	-- ②：装备怪兽不能把表示形式变更。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
	c:RegisterEffect(e3)
end
-- 过滤手卡中满足送去墓地代价的「变形斗士」怪兽
function c90239723.cfilter(c)
	return c:IsSetCard(0x26) and c:IsType(TYPE_MONSTER) and c:IsAbleToGraveAsCost()
end
-- 发动代价：从手卡把1只「变形斗士」怪兽送去墓地
function c90239723.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡中是否存在满足送去墓地代价的「变形斗士」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c90239723.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择手卡中1只「变形斗士」怪兽
	local g=Duel.SelectMatchingCard(tp,c90239723.cfilter,tp,LOCATION_HAND,0,1,1,nil)
	-- 将选择的怪兽作为代价送去墓地
	Duel.SendtoGrave(g,REASON_COST)
end
-- 过滤墓地中可以特殊召唤的「变形斗士」怪兽
function c90239723.filter(c,e,tp)
	return c:IsSetCard(0x26) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动时的对象选择与操作信息设置
function c90239723.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c90239723.filter(chkc,e,tp) end
	-- 检查自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在可以特殊召唤的「变形斗士」怪兽
		and Duel.IsExistingTarget(c90239723.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只「变形斗士」怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,c90239723.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置特殊召唤的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
	-- 设置装备卡的操作信息
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 装备限制：只有这张卡（变形斗士·修复装置）可以装备
function c90239723.eqlimit(e,c)
	return e:GetOwner()==c
end
-- 效果处理：将作为对象的怪兽特殊召唤，并把这张卡装备
function c90239723.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取发动时选择的特殊召唤对象
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) then
		-- 将目标怪兽特殊召唤，若特殊召唤失败则结束处理
		if Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)==0 then return end
		-- 将这张卡装备给特殊召唤的怪兽
		Duel.Equip(tp,c,tc)
		e:SetLabelObject(tc)
		tc:CreateRelation(c,RESET_EVENT+RESETS_STANDARD)
		-- 把这张卡装备。
		local e1=Effect.CreateEffect(tc)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(c90239723.eqlimit)
		c:RegisterEffect(e1)
	end
end
-- 这张卡从场上离开时，破坏装备的怪兽
function c90239723.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetFirstCardTarget()
	if tc and tc:IsLocation(LOCATION_MZONE) then
		-- 破坏装备的怪兽
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
