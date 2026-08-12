--甲虫装機 ホッパー
-- 效果：
-- 1回合1次，可以从自己的手卡·墓地把1只名字带有「甲虫装机」的怪兽当作装备卡使用给这张卡装备。这张卡当作装备卡使用而装备中的场合，装备怪兽的等级上升4星。此外，可以通过把当作装备卡使用而装备中的这张卡送去墓地，这个回合装备怪兽可以直接攻击对方玩家。这个效果发动的回合，装备怪兽以外的怪兽不能攻击。
function c52601736.initial_effect(c)
	-- 1回合1次，可以从自己的手卡·墓地把1只名字带有「甲虫装机」的怪兽当作装备卡使用给这张卡装备。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetDescription(aux.Stringid(52601736,0))  --"装备"
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(c52601736.eqtg)
	e1:SetOperation(c52601736.eqop)
	c:RegisterEffect(e1)
	-- 这张卡当作装备卡使用而装备中的场合，装备怪兽的等级上升4星。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_LEVEL)
	e2:SetValue(4)
	c:RegisterEffect(e2)
	-- 此外，可以通过把当作装备卡使用而装备中的这张卡送去墓地，这个回合装备怪兽可以直接攻击对方玩家。这个效果发动的回合，装备怪兽以外的怪兽不能攻击。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(52601736,1))  --"直接攻击"
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCondition(c52601736.dacon)
	e3:SetCost(c52601736.dacost)
	e3:SetOperation(c52601736.daop)
	c:RegisterEffect(e3)
end
-- 过滤函数，用于筛选名字带有「甲虫装机」且为怪兽卡且未被禁止的卡片。
function c52601736.filter(c)
	return c:IsSetCard(0x56) and c:IsType(TYPE_MONSTER) and not c:IsForbidden()
end
-- 设置装备效果的发动条件，检查场上是否有空余的魔法陷阱区域，并且自己墓地或手牌中是否存在满足条件的怪兽卡。
function c52601736.eqtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家当前场上的魔法陷阱区域是否还有空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查玩家墓地或手牌中是否存在至少一张名字带有「甲虫装机」的怪兽卡。
		and Duel.IsExistingMatchingCard(c52601736.filter,tp,LOCATION_GRAVE+LOCATION_HAND,0,1,nil) end
	-- 设置连锁操作信息，表示将要从墓地或手牌中送走一张卡片。
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,nil,1,tp,LOCATION_GRAVE+LOCATION_HAND)
end
-- 装备效果的处理函数，执行装备操作并设置装备限制。
function c52601736.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查玩家场上是否还有空余的魔法陷阱区域用于装备。
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	if c:IsFacedown() or not c:IsRelateToEffect(e) then return end
	-- 提示玩家选择要装备的怪兽卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 从玩家墓地或手牌中选择一张名字带有「甲虫装机」的怪兽卡作为装备对象。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c52601736.filter),tp,LOCATION_GRAVE+LOCATION_HAND,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		-- 尝试将选中的怪兽卡装备到当前卡片上。
		if not Duel.Equip(tp,tc,c) then return end
		-- 设置装备限制效果，确保只有当前卡片能装备该怪兽卡。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(c52601736.eqlimit)
		tc:RegisterEffect(e1)
	end
end
-- 装备限制函数，判断目标怪兽是否为当前装备卡的持有者且未被禁用。
function c52601736.eqlimit(e,c)
	return e:GetOwner()==c and not c:IsDisabled()
end
-- 直接攻击效果发动条件检查函数，判断是否满足发动条件。
function c52601736.dacon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetEquipTarget()
	-- 检查回合玩家是否可以进入战斗阶段。
	return Duel.IsAbleToEnterBP()
		and tc and tc:IsAttackable() and tc:GetEffectCount(EFFECT_DIRECT_ATTACK)==0
end
-- 攻击禁止目标筛选函数，用于排除已装备此卡的怪兽。
function c52601736.ftarget(e,c)
	return e:GetLabel()~=c:GetFieldID()
end
-- 直接攻击效果的费用支付处理函数，将当前卡片送去墓地并设置攻击禁止效果。
function c52601736.dacost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	local tc=e:GetHandler():GetEquipTarget()
	-- 设置当前连锁处理的目标为装备中的怪兽卡。
	Duel.SetTargetCard(tc)
	-- 将当前卡片（装备卡）送去墓地作为发动费用。
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
	-- 注册一个场地区域的攻击禁止效果，使该回合其他怪兽不能攻击。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetProperty(EFFECT_FLAG_OATH)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(c52601736.ftarget)
	e1:SetLabel(tc:GetFieldID())
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将攻击禁止效果注册到全局环境。
	Duel.RegisterEffect(e1,tp)
end
-- 直接攻击效果的处理函数，为装备中的怪兽卡添加直接攻击能力。
function c52601736.daop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁处理的目标卡片（即装备中的怪兽）。
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 为装备中的怪兽卡添加直接攻击效果。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DIRECT_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
