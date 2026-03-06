--白銀の翼
-- 效果：
-- 8星以上的龙族同调怪兽才能装备。装备怪兽1回合最多2次不会被战斗破坏。装备怪兽被卡的效果破坏的场合，可以作为代替把这张卡破坏。
function c25231813.initial_effect(c)
	-- 装备怪兽1回合最多2次不会被战斗破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c25231813.target)
	e1:SetOperation(c25231813.operation)
	c:RegisterEffect(e1)
	-- 8星以上的龙族同调怪兽才能装备。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_EQUIP_LIMIT)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetValue(c25231813.eqlimit)
	c:RegisterEffect(e2)
	-- 装备怪兽被卡的效果破坏的场合，可以作为代替把这张卡破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
	e3:SetCountLimit(2)
	e3:SetValue(c25231813.indval)
	c:RegisterEffect(e3)
	-- 效果作用
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_EQUIP)
	e4:SetCode(EFFECT_DESTROY_REPLACE)
	e4:SetTarget(c25231813.reptg2)
	e4:SetOperation(c25231813.repop2)
	c:RegisterEffect(e4)
end
-- 判断装备对象是否满足8星以上龙族同调怪兽的条件
function c25231813.eqlimit(e,c)
	return c:IsLevelAbove(8) and c:IsRace(RACE_DRAGON) and c:IsType(TYPE_SYNCHRO)
end
-- 筛选场上满足8星以上龙族同调怪兽条件的怪兽
function c25231813.filter(c)
	return c:IsFaceup() and c:IsLevelAbove(8) and c:IsRace(RACE_DRAGON) and c:IsType(TYPE_SYNCHRO)
end
-- 选择装备目标怪兽
function c25231813.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c25231813.filter(chkc) end
	-- 判断是否存在满足条件的装备目标
	if chk==0 then return Duel.IsExistingTarget(c25231813.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要装备的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择装备目标怪兽
	Duel.SelectTarget(tp,c25231813.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置效果操作信息为装备
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 执行装备操作
function c25231813.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取选择的装备目标
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将装备卡装备给目标怪兽
		Duel.Equip(tp,c,tc)
	end
end
-- 判断是否为战斗破坏
function c25231813.indval(e,re,r,rp)
	return bit.band(r,REASON_BATTLE)~=0
end
-- 判断是否可以发动代替破坏效果
function c25231813.reptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:GetEquipTarget():IsReason(REASON_EFFECT) and not c:GetEquipTarget():IsReason(REASON_REPLACE)
		and c:IsDestructable(e) and not c:IsStatus(STATUS_DESTROY_CONFIRMED) end
	-- 询问玩家是否发动代替破坏效果
	if Duel.SelectEffectYesNo(tp,c,96) then
		c:SetStatus(STATUS_DESTROY_CONFIRMED,true)
		return true
	else return false end
end
-- 执行代替破坏效果
function c25231813.repop2(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():SetStatus(STATUS_DESTROY_CONFIRMED,false)
	-- 将装备卡破坏
	Duel.Destroy(e:GetHandler(),REASON_EFFECT+REASON_REPLACE)
end
