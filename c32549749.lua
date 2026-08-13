--武装再生
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：可以从以下效果选择1个发动。
-- ●以自己场上1只表侧表示怪兽为对象才能发动。那只怪兽的攻击力直到回合结束时上升800。
-- ●以自己或者对方的墓地1张装备魔法卡为对象才能发动。那张卡在自己场上盖放或给可以把那张卡装备的自己场上1只怪兽装备。
function c32549749.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：可以从以下效果选择1个发动。●以自己场上1只表侧表示怪兽为对象才能发动。那只怪兽的攻击力直到回合结束时上升800。●以自己或者对方的墓地1张装备魔法卡为对象才能发动。那张卡在自己场上盖放或给可以把那张卡装备的自己场上1只怪兽装备。
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
-- 过滤函数：判断目标卡是否为装备魔法卡，且该卡可以被盖放，或自己场上有表侧表示怪兽可以装备它。
function c32549749.filter(c,tp)
	if not c:IsType(TYPE_EQUIP) then return false end
	return c:IsSSetable(true)
		-- 或存在1只自己场上表侧表示且能够装备这张卡的怪兽，使该装备魔法卡可作为对象。
		or Duel.IsExistingMatchingCard(c32549749.eqfilter,tp,LOCATION_MZONE,0,1,nil,c,tp)
end
-- 装备对象过滤器：选择自己场上1只表侧表示怪兽，要求该装备魔法卡未被禁止装备、不违反同名卡限制且可以装备给该怪兽。
function c32549749.eqfilter(c,ec,tp)
	if c:IsFacedown() then return false end
	return not ec:IsForbidden() and ec:CheckUniqueOnField(tp) and ec:CheckEquipTarget(c)
end
-- 效果发动时的目标处理：根据两个可选分支分别检查合法对象；若两个分支都可用，由玩家选择执行哪个，否则自动确定，并设置对应的效果分类和对象。
function c32549749.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		if e:GetLabel()==0 then
			return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and chkc:IsFaceup()
		else
			return chkc:IsLocation(LOCATION_GRAVE) and c32549749.filter(chkc,tp)
		end
	end
	-- 获取自己魔陷区的可用空格数量，用于判断能否盖放墓地装备魔法卡。
	local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) and not e:GetHandler():IsLocation(LOCATION_SZONE) then ft=ft-1 end
	-- 调用伤害步骤条件限制，判断是否允许选择攻击力上升分支（非伤害步骤或伤害计算前才可发动）。
	local b1=aux.dscon(e,tp,eg,ep,ev,re,r,rp)
		-- 确认自己场上有1只表侧表示怪兽可以作为攻击力上升效果的对象。
		and Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,0,1,nil)
	-- 第二分支的可用条件之一：当前不是伤害步骤，且魔陷区有空位可以盖放装备魔法卡。
	local b2=Duel.GetCurrentPhase()~=PHASE_DAMAGE and ft>0
		-- 确认双方墓地存在1张符合条件的装备魔法卡可以作为对象。
		and Duel.IsExistingTarget(c32549749.filter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil,tp)
	if chk==0 then return b1 or b2 end
	local op=0
	if b1 and b2 then
		-- 两个分支都可用时，弹出选项让玩家选择：0=攻击力上升，1=回收装备魔法卡。
		op=Duel.SelectOption(tp,aux.Stringid(32549749,0),aux.Stringid(32549749,1))  --"攻击力上升/回收装备魔法卡"
	elseif b1 then
		-- 仅攻击力上升分支可用时，弹出唯一选项并选定该分支。
		op=Duel.SelectOption(tp,aux.Stringid(32549749,0))  --"攻击力上升"
	else
		-- 仅回收装备魔法卡分支可用时，弹出唯一选项，将返回值0加1赋给op以便与分支编号一致（op=1）。
		op=Duel.SelectOption(tp,aux.Stringid(32549749,1))+1  --"回收装备魔法卡"
	end
	e:SetLabel(op)
	if op==0 then
		e:SetCategory(CATEGORY_ATKCHANGE)
		-- 提示玩家从场上选择表侧表示怪兽，用于攻击力上升分支。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
		-- 选择自己场上1只表侧表示怪兽作为攻击力上升效果的对象。
		Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,0,1,1,nil,tp)
	else
		e:SetCategory(CATEGORY_SSET)
		-- 提示玩家选择效果的对象，用于装备魔法卡分支。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
		-- 从自己或对方的墓地选择1张符合条件的装备魔法卡作为对象。
		local g=Duel.SelectTarget(tp,c32549749.filter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil,tp)
		-- 设置操作信息，标明该效果处理会使对象卡从墓地离开，供相关连锁效果（如王家长眠之谷）检测。
		Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
	end
end
-- 效果处理：根据发动时选择的分支执行——攻击力上升分支给对象怪兽攻击力上升800；装备魔法卡分支将对象卡盖放或装备给自己场上1只怪兽。
function c32549749.activate(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==0 then
		-- 取回发动时选择的对象卡（攻击力上升分支的怪兽）。
		local tc=Duel.GetFirstTarget()
		if not (tc:IsRelateToEffect(e) and tc:IsFaceup()) then return end
		-- 那只怪兽的攻击力直到回合结束时上升800。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(800)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	else
		-- 取回发动时选择的对象卡（墓地装备魔法卡）。
		local tc=Duel.GetFirstTarget()
		if not tc:IsRelateToEffect(e) then return end
		-- 再次获取自己魔陷区的可用空格数量，用于判断是否还能盖放。
		local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
		local b1=tc:IsSSetable(true) and ft>0
		-- 检查自己场上是否存在1只可以装备这张装备魔法卡的表侧表示怪兽，以决定是否提供装备选项。
		local b2=Duel.IsExistingMatchingCard(c32549749.eqfilter,tp,LOCATION_MZONE,0,1,nil,tc,tp)
		local op=0
		if b1 and b2 then
			-- 盖放和装备两个选项都可用时，弹出选项让玩家选择：0=盖放，1=装备。
			op=Duel.SelectOption(tp,aux.Stringid(32549749,2),aux.Stringid(32549749,3))  --"在场上盖放/给怪兽装备"
		elseif b1 then
			-- 仅盖放选项可用时，弹出唯一选项并选定盖放分支。
			op=Duel.SelectOption(tp,aux.Stringid(32549749,2))  --"在场上盖放"
		elseif b2 then
			-- 仅装备选项可用时，弹出唯一选项，将返回值0加1赋给op以便与分支编号一致（op=1）。
			op=Duel.SelectOption(tp,aux.Stringid(32549749,3))+1  --"给怪兽装备"
		else
			return
		end
		if op==0 then
			-- 将选择的装备魔法卡盖放到自己魔陷区。
			Duel.SSet(tp,tc)
		else
			-- 提示玩家选择要装备的怪兽，用于装备分支。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
			-- 从自己场上选择1只可以装备该装备魔法卡的表侧表示怪兽，并取出该卡。
			local tgc=Duel.SelectMatchingCard(tp,c32549749.eqfilter,tp,LOCATION_MZONE,0,1,1,nil,tc,tp):GetFirst()
			if not tgc then return end
			-- 将装备魔法卡装备给选择的自己场上怪兽。
			Duel.Equip(tp,tc,tgc)
		end
	end
end
