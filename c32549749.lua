--武装再生
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：可以从以下效果选择1个发动。
-- ●以自己场上1只表侧表示怪兽为对象才能发动。那只怪兽的攻击力直到回合结束时上升800。
-- ●以自己或者对方的墓地1张装备魔法卡为对象才能发动。那张卡在自己场上盖放或给可以把那张卡装备的自己场上1只怪兽装备。
function c32549749.initial_effect(c)
	-- 创建效果对象，设置效果分类为攻击力变化和盖放，设置效果类型为发动，设置提示时点为伤害步骤，设置效果属性为取对象和伤害步骤，设置效果代码为自由连锁，设置发动次数限制为1次，设置效果目标函数为c32549749.target，设置效果处理函数为c32549749.activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_SSET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetHintTiming(TIMING_DAMAGE_STEP,TIMINGS_CHECK_MONSTER+TIMING_DAMAGE_STEP)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,32549749+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c32549749.target)
	e1:SetOperation(c32549749.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数，检查是否为装备魔法卡，若为装备魔法卡则返回是否可以盖放或是否可以装备给场上怪兽
function c32549749.filter(c,tp)
	if not c:IsType(TYPE_EQUIP) then return false end
	return c:IsSSetable(true)
		-- 检查是否可以装备给场上怪兽
		or Duel.IsExistingMatchingCard(c32549749.eqfilter,tp,LOCATION_MZONE,0,1,nil,c,tp)
end
-- 装备过滤函数，检查场上怪兽是否表侧表示，装备魔法卡是否可以装备给该怪兽
function c32549749.eqfilter(c,ec,tp)
	if c:IsFacedown() then return false end
	return not ec:IsForbidden() and ec:CheckUniqueOnField(tp) and ec:CheckEquipTarget(c)
end
-- 效果处理函数，根据选择的选项设置效果目标，若选择攻击力上升则选择场上表侧表示怪兽，若选择回收装备魔法卡则选择墓地装备魔法卡
function c32549749.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		if e:GetLabel()==0 then
			return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and chkc:IsFaceup()
		else
			return chkc:IsLocation(LOCATION_GRAVE) and c32549749.filter(chkc,tp)
		end
	end
	-- 获取玩家场上魔陷区可用空格数
	local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) and not e:GetHandler():IsLocation(LOCATION_SZONE) then ft=ft-1 end
	-- 调用辅助函数判断是否可以发动效果
	local b1=aux.dscon(e,tp,eg,ep,ev,re,r,rp)
		-- 检查场上是否存在表侧表示怪兽
		and Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,0,1,nil)
	-- 检查当前阶段是否不是伤害步骤
	local b2=Duel.GetCurrentPhase()~=PHASE_DAMAGE and ft>0
		-- 检查墓地是否存在装备魔法卡
		and Duel.IsExistingTarget(c32549749.filter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil,tp)
	if chk==0 then return b1 or b2 end
	local op=0
	if b1 and b2 then
		-- 选择效果选项，选项0为攻击力上升，选项1为回收装备魔法卡
		op=Duel.SelectOption(tp,aux.Stringid(32549749,0),aux.Stringid(32549749,1))  --"攻击力上升/回收装备魔法卡"
	elseif b1 then
		-- 选择效果选项，选项0为攻击力上升
		op=Duel.SelectOption(tp,aux.Stringid(32549749,0))  --"攻击力上升"
	else
		-- 选择效果选项，选项1为回收装备魔法卡
		op=Duel.SelectOption(tp,aux.Stringid(32549749,1))+1  --"回收装备魔法卡"
	end
	e:SetLabel(op)
	if op==0 then
		e:SetCategory(CATEGORY_ATKCHANGE)
		-- 提示玩家选择表侧表示的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
		-- 选择场上表侧表示怪兽作为效果对象
		Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,0,1,1,nil,tp)
	else
		e:SetCategory(CATEGORY_SSET)
		-- 提示玩家选择效果的对象
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
		-- 选择墓地装备魔法卡作为效果对象
		local g=Duel.SelectTarget(tp,c32549749.filter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil,tp)
		-- 设置操作信息，记录将要离开墓地的卡
		Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
	end
end
-- 效果处理函数，根据选择的选项执行效果，若选择攻击力上升则给目标怪兽攻击力上升800，若选择回收装备魔法卡则进行盖放或装备
function c32549749.activate(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==0 then
		-- 获取效果对象
		local tc=Duel.GetFirstTarget()
		if not (tc:IsRelateToEffect(e) and tc:IsFaceup()) then return end
		-- 创建攻击力变化效果，使目标怪兽攻击力上升800，效果在回合结束时消失
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(800)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	else
		-- 获取效果对象
		local tc=Duel.GetFirstTarget()
		if not tc:IsRelateToEffect(e) then return end
		-- 获取玩家场上魔陷区可用空格数
		local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
		local b1=tc:IsSSetable(true) and ft>0
		-- 检查是否可以装备给场上怪兽
		local b2=Duel.IsExistingMatchingCard(c32549749.eqfilter,tp,LOCATION_MZONE,0,1,nil,tc,tp)
		local op=0
		if b1 and b2 then
			-- 选择效果选项，选项0为在场上盖放，选项1为给怪兽装备
			op=Duel.SelectOption(tp,aux.Stringid(32549749,2),aux.Stringid(32549749,3))  --"在场上盖放/给怪兽装备"
		elseif b1 then
			-- 选择效果选项，选项0为在场上盖放
			op=Duel.SelectOption(tp,aux.Stringid(32549749,2))  --"在场上盖放"
		elseif b2 then
			-- 选择效果选项，选项1为给怪兽装备
			op=Duel.SelectOption(tp,aux.Stringid(32549749,3))+1  --"给怪兽装备"
		else
			return
		end
		if op==0 then
			-- 将装备魔法卡在自己场上盖放
			Duel.SSet(tp,tc)
		else
			-- 提示玩家选择要装备的怪兽
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
			-- 选择可以装备的怪兽作为装备对象
			local tgc=Duel.SelectMatchingCard(tp,c32549749.eqfilter,tp,LOCATION_MZONE,0,1,1,nil,tc,tp):GetFirst()
			if not tgc then return end
			-- 将装备魔法卡装备给目标怪兽
			Duel.Equip(tp,tc,tgc)
		end
	end
end
