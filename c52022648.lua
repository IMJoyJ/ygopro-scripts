--妖精伝姫－シンデレラ
-- 效果：
-- ①：只要这张卡在怪兽区域存在，双方不能把场上的其他怪兽作为魔法卡的效果的对象。
-- ②：1回合1次，从手卡丢弃1张魔法卡才能发动。把这张卡可以装备的1张装备魔法卡从自己的手卡·卡组·墓地装备。那张装备魔法卡在结束阶段回到手卡。
function c52022648.initial_effect(c)
	-- ①：只要这张卡在怪兽区域存在，双方不能把场上的其他怪兽作为魔法卡的效果的对象。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SET_AVAILABLE)
	e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1:SetTarget(c52022648.tglimit)
	e1:SetValue(c52022648.tgval)
	c:RegisterEffect(e1)
	-- ②：1回合1次，从手卡丢弃1张魔法卡才能发动。把这张卡可以装备的1张装备魔法卡从自己的手卡·卡组·墓地装备。那张装备魔法卡在结束阶段回到手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(52022648,0))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetCountLimit(1)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCost(c52022648.eqcost)
	e2:SetTarget(c52022648.eqtg)
	e2:SetOperation(c52022648.eqop)
	c:RegisterEffect(e2)
end
-- 效果作用：限制目标怪兽不能成为魔法卡的效果对象
function c52022648.tglimit(e,c)
	return c~=e:GetHandler()
end
-- 效果作用：使魔法卡的效果无法指定该怪兽为对象
function c52022648.tgval(e,re,rp)
	return re:IsActiveType(TYPE_SPELL)
end
-- 过滤函数：满足条件的卡必须是魔法卡且可丢弃，并且场上存在可以装备的装备魔法卡
function c52022648.costfilter(c,ec,tp)
	return c:IsType(TYPE_SPELL) and c:IsDiscardable()
		-- 检查是否存在可以装备的装备魔法卡
		and Duel.IsExistingMatchingCard(c52022648.eqfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,c,ec)
end
-- 效果作用：丢弃1张魔法卡作为发动代价
function c52022648.eqcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足丢弃魔法卡的条件
	if chk==0 then return Duel.IsExistingMatchingCard(c52022648.costfilter,tp,LOCATION_HAND,0,1,nil,e:GetHandler(),tp) end
	-- 执行丢弃1张魔法卡的操作
	Duel.DiscardHand(tp,c52022648.costfilter,1,1,REASON_COST+REASON_DISCARD,nil,e:GetHandler(),tp)
end
-- 过滤函数：检查卡是否为装备魔法卡且能装备给指定怪兽
function c52022648.eqfilter(c,ec)
	return c:IsType(TYPE_EQUIP) and c:CheckEquipTarget(ec)
end
-- 效果作用：判断是否可以进行装备操作
function c52022648.eqtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断场上是否有足够的魔法陷阱区域进行装备
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0 end
end
-- 效果作用：选择并装备一张装备魔法卡，结束后返回手卡
function c52022648.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断是否满足装备条件（场地空位、卡片状态等）
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 or c:IsFacedown() or not c:IsRelateToEffect(e) then return end
	-- 提示玩家选择要装备的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 从手牌·卡组·墓地选择一张可装备的装备魔法卡
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c52022648.eqfilter),tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,c)
	local tc=g:GetFirst()
	if tc then
		-- 将选中的装备魔法卡装备给辛德瑞拉
		Duel.Equip(tp,tc,c)
		-- ②：1回合1次，从手卡丢弃1张魔法卡才能发动。把这张卡可以装备的1张装备魔法卡从自己的手卡·卡组·墓地装备。那张装备魔法卡在结束阶段回到手卡。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetCountLimit(1)
		e1:SetRange(LOCATION_SZONE)
		e1:SetOperation(c52022648.thop)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
-- 效果作用：在结束阶段将装备卡送回手卡
function c52022648.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 将装备卡送回玩家手卡
	Duel.SendtoHand(e:GetHandler(),nil,REASON_EFFECT)
end
