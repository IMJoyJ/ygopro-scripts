--甲虫装機 ウィーグ
-- 效果：
-- 1回合1次，可以从自己的手卡·墓地把1只名字带有「甲虫装机」的怪兽当作装备卡使用给这张卡装备。这张卡当作装备卡使用而装备中的场合，装备怪兽的攻击力·守备力上升这张卡的各自数值。此外，给怪兽装备的这张卡被送去墓地时，装备过的怪兽的攻击力直到结束阶段时上升1000。
function c38450736.initial_effect(c)
	-- 1回合1次，可以从自己的手卡·墓地把1只名字带有「甲虫装机」的怪兽当作装备卡使用给这张卡装备。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetDescription(aux.Stringid(38450736,0))  --"装备"
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(c38450736.eqtg)
	e1:SetOperation(c38450736.eqop)
	c:RegisterEffect(e1)
	-- 这张卡当作装备卡使用而装备中的场合，装备怪兽的攻击力上升这张卡的攻击力数值。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(1000)
	c:RegisterEffect(e2)
	-- 这张卡当作装备卡使用而装备中的场合，装备怪兽的守备力上升这张卡的守备力数值。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	e3:SetValue(1000)
	c:RegisterEffect(e3)
	-- 此外，给怪兽装备的这张卡被送去墓地时，装备过的怪兽的攻击力直到结束阶段时上升1000。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(38450736,1))  --"攻击上升"
	e3:SetCategory(CATEGORY_ATKCHANGE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_LEAVE_FIELD)
	e3:SetCondition(c38450736.atkcon)
	e3:SetTarget(c38450736.atktg)
	e3:SetOperation(c38450736.atkop)
	c:RegisterEffect(e3)
end
-- 过滤函数，用于筛选名字带有「甲虫装机」的怪兽卡且未被禁止的卡。
function c38450736.filter(c)
	return c:IsSetCard(0x56) and c:IsType(TYPE_MONSTER) and not c:IsForbidden()
end
-- 效果处理时的判断条件，检查玩家场上是否有空余的魔陷区域，并且手卡或墓地是否存在满足条件的怪兽卡。
function c38450736.eqtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家场上是否有空余的魔陷区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查手卡或墓地是否存在满足条件的怪兽卡。
		and Duel.IsExistingMatchingCard(c38450736.filter,tp,LOCATION_GRAVE+LOCATION_HAND,0,1,nil) end
	-- 设置操作信息，表示该效果会从手卡或墓地将一张卡送入墓地。
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,nil,1,tp,LOCATION_GRAVE+LOCATION_HAND)
end
-- 效果处理函数，执行装备操作，选择一张满足条件的怪兽卡并将其装备给自身。
function c38450736.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查玩家场上是否有空余的魔陷区域，若无则返回。
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	if c:IsFacedown() or not c:IsRelateToEffect(e) then return end
	-- 提示玩家选择要装备的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 从手卡或墓地中选择一张满足条件的怪兽卡。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c38450736.filter),tp,LOCATION_GRAVE+LOCATION_HAND,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		-- 尝试将选中的怪兽卡装备给自身，若失败则返回。
		if not Duel.Equip(tp,tc,c) then return end
		-- 为装备的怪兽卡设置装备限制效果，确保只有自身可以装备该怪兽卡。
		local e1=Effect.CreateEffect(c)
		e1:SetProperty(EFFECT_FLAG_OWNER_RELATE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(c38450736.eqlimit)
		tc:RegisterEffect(e1)
	end
end
-- 装备限制效果的判断函数，确保只有自身可以装备该怪兽卡。
function c38450736.eqlimit(e,c)
	return e:GetOwner()==c
end
-- 触发效果的条件判断函数，判断装备的怪兽卡是否在场且自身被送入墓地。
function c38450736.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ec=c:GetEquipTarget()
	e:SetLabelObject(ec)
	return ec and c:IsLocation(LOCATION_GRAVE) and ec:IsFaceup() and ec:IsLocation(LOCATION_MZONE)
end
-- 触发效果的目标设定函数，设置装备的怪兽卡为目标。
function c38450736.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local ec=e:GetLabelObject()
	-- 设置当前处理的连锁的目标为装备的怪兽卡。
	Duel.SetTargetCard(ec)
end
-- 触发效果的处理函数，使装备的怪兽卡在结束阶段时攻击力上升1000。
function c38450736.atkop(e,tp,eg,ep,ev,re,r,rp)
	local ec=e:GetLabelObject()
	if ec:IsLocation(LOCATION_MZONE) and ec:IsFaceup() and ec:IsRelateToEffect(e) then
		-- 为装备的怪兽卡添加攻击力上升1000的效果，并在结束阶段重置。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(1000)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		ec:RegisterEffect(e1)
	end
end
