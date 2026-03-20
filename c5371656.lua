--魂喰らいの魔刀
-- 效果：
-- 这张卡只能装备在自己场上存在的3星以下的通常怪兽身上。这张卡发动时，祭掉自己场上除装备这张卡的怪兽以外的所有通常怪兽（衍生物除外）。每祭掉1只通常怪兽，装备这张卡的怪兽攻击力上升1000点。
function c5371656.initial_effect(c)
	-- 效果原文：这张卡只能装备在自己场上存在的3星以下的通常怪兽身上。这张卡发动时，祭掉自己场上除装备这张卡的怪兽以外的所有通常怪兽（衍生物除外）。每祭掉1只通常怪兽，装备这张卡的怪兽攻击力上升1000点。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c5371656.target)
	e1:SetOperation(c5371656.operation)
	c:RegisterEffect(e1)
	-- 效果原文：这张卡只能装备在自己场上存在的3星以下的通常怪兽身上。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_EQUIP_LIMIT)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetValue(c5371656.eqlimit)
	c:RegisterEffect(e2)
end
-- 检查目标是否为3星以下的通常怪兽且为我方控制
function c5371656.eqlimit(e,c)
	return c:IsType(TYPE_NORMAL) and c:IsLevelBelow(3) and c:IsControler(e:GetHandlerPlayer())
end
-- 过滤函数，用于筛选场上3星以下的通常怪兽
function c5371656.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_NORMAL) and c:IsLevelBelow(3)
end
-- 过滤函数，用于筛选可以被解放的通常怪兽（排除衍生物）
function c5371656.rfilter(c)
	local tpe=c:GetType()
	return bit.band(tpe,TYPE_NORMAL)~=0 and bit.band(tpe,TYPE_TOKEN)==0 and c:IsReleasable()
end
-- 过滤函数，用于筛选可以作为装备对象的3星以下通常怪兽，并且该怪兽场上有可解放的通常怪兽
function c5371656.tgfilter(c,tp)
	-- 筛选可以装备的怪兽，且该怪兽场上有可解放的通常怪兽
	return c5371656.filter(c) and Duel.IsExistingMatchingCard(c5371656.rfilter,tp,LOCATION_MZONE,0,1,c)
end
-- 设置发动时的目标选择和处理逻辑，包括提示选择装备对象、获取可解放怪兽并进行解放操作
function c5371656.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c5371656.filter(chkc) end
	-- 检查是否满足发动条件，即我方场上存在符合条件的装备对象
	if chk==0 then return Duel.IsExistingTarget(c5371656.tgfilter,tp,LOCATION_MZONE,0,1,nil,tp) end
	-- 提示玩家选择要装备的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择一个符合条件的怪兽作为装备对象
	local g=Duel.SelectTarget(tp,c5371656.tgfilter,tp,LOCATION_MZONE,0,1,1,nil,tp)
	-- 获取所有可以被解放的通常怪兽（除装备对象外）
	local rg=Duel.GetMatchingGroup(c5371656.rfilter,tp,LOCATION_MZONE,0,g:GetFirst())
	-- 将符合条件的通常怪兽进行解放作为发动代价
	Duel.Release(rg,REASON_COST)
	e:SetLabel(rg:GetCount()*1000)
	-- 设置操作信息，表示本次连锁将要进行装备操作
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 装备效果的处理函数，用于执行装备和攻击力加成
function c5371656.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsControler(tp) then
		-- 将装备卡装备给目标怪兽
		Duel.Equip(tp,e:GetHandler(),tc)
		-- 效果原文：每祭掉1只通常怪兽，装备这张卡的怪兽攻击力上升1000点。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_EQUIP)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(e:GetLabel())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
	end
end
