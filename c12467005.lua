--タックルセイダー
-- 效果：
-- 这张卡被送去墓地的场合，可以从以下效果选择1个发动。
-- ●选择对方场上表侧表示存在的1只怪兽变成里侧守备表示。
-- ●选择对方场上表侧表示存在的1张魔法·陷阱卡回到持有者手卡。这个回合，对方不能把这个效果回到手卡的卡以及那些同名卡发动。
function c12467005.initial_effect(c)
	-- 这张卡被送去墓地的场合，可以从以下效果选择1个发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(12467005,0))  --"选择效果发动"
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetTarget(c12467005.target)
	e1:SetOperation(c12467005.operation)
	c:RegisterEffect(e1)
end
-- 过滤出对方场上表侧表示且可变为里侧守备表示的怪兽，作为第一个选项的对象候选。
function c12467005.filter1(c)
	return c:IsFaceup() and c:IsCanTurnSet()
end
-- 过滤出对方场上表侧表示且属于魔法·陷阱卡并能加入手卡的卡，作为第二个选项的对象候选。
function c12467005.filter2(c)
	return c:IsFaceup() and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- 效果发动时的目标选择处理：分别检测两种可选目标是否存在；若至少一种存在则可发动；若两种都存在则让玩家选择一种，然后根据选项选择对应对象、设置效果分类与操作信息。
function c12467005.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 检查对方主要怪兽区是否存在1张以上满足filter1的怪兽，作为“怪兽变成里侧守备表示”选项可用的判定。
	local b1=Duel.IsExistingTarget(c12467005.filter1,tp,0,LOCATION_MZONE,1,nil)
	-- 检查对方场上是否存在1张以上满足filter2的魔法·陷阱卡，作为“魔法·陷阱卡回到手卡”选项可用的判定。
	local b2=Duel.IsExistingTarget(c12467005.filter2,tp,0,LOCATION_ONFIELD,1,nil)
	if chk==0 then return b1 or b2 end
	local op=0
	-- 两种选项都可用时，弹出选择菜单，让玩家选择“怪兽变成里侧守备表示”或“魔法·陷阱卡回到手卡”，选择结果作为标签值保存。
	if b1 and b2 then op=Duel.SelectOption(tp,aux.Stringid(12467005,1),aux.Stringid(12467005,2))  --"怪兽变成里侧守备表示/魔法·陷阱卡回到手卡"
	-- 只有怪兽选项可用时，直接选择该项，Duel.SelectOption返回0，因此op保持为0。
	elseif b1 then op=Duel.SelectOption(tp,aux.Stringid(12467005,1))  --"怪兽变成里侧守备表示"
	-- 只有魔法·陷阱卡选项可用时，Duel.SelectOption返回0，加1后op=1，表示选择回手效果。
	else op=Duel.SelectOption(tp,aux.Stringid(12467005,2))+1 end  --"魔法·陷阱卡回到手卡"
	e:SetLabel(op)
	if op==0 then
		-- 向玩家发送选择提示，提示内容为“请选择要改变表示形式的怪兽”。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
		-- 从对方主要怪兽区选择1只满足filter1的怪兽作为效果对象。
		local g=Duel.SelectTarget(tp,c12467005.filter1,tp,0,LOCATION_MZONE,1,1,nil)
		e:SetCategory(CATEGORY_POSITION+CATEGORY_MSET)
		-- 设置本连锁的操作信息：这次操作包含改变表示形式，对象为已选择的怪兽，数量为1。
		Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
	else
		-- 向玩家发送选择提示，提示内容为“请选择要返回手牌的卡”。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
		-- 从对方场上选择1张满足filter2的魔法·陷阱卡作为效果对象。
		local g=Duel.SelectTarget(tp,c12467005.filter2,tp,0,LOCATION_ONFIELD,1,1,nil)
		e:SetCategory(CATEGORY_TOHAND)
		-- 设置本连锁的操作信息：这次操作包含返回手牌，对象为已选择的卡，数量为1。
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
	end
end
-- 效果处理：先取得对象并确认其仍与该效果关联；若对象无效则直接结束。然后根据之前选择的标签：0则把对象怪兽变为里侧守备表示；1则把对象魔陷送回手卡，并给对手附加本回合禁止发动该卡及其同名卡的效果。
function c12467005.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁中通过SelectTarget选择的那张对象卡。
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	if e:GetLabel()==0 then
		-- 将对象怪兽的表示形式变为里侧守备表示。
		Duel.ChangePosition(tc,POS_FACEDOWN_DEFENSE)
	else
		local code=tc:GetCode()
		-- 将对象魔法·陷阱卡以效果原因返回其持有者的手卡。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 这个回合，对方不能把这个效果回到手卡的卡以及那些同名卡发动。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetCode(EFFECT_CANNOT_ACTIVATE)
		e1:SetTargetRange(0,1)
		e1:SetValue(c12467005.aclimit)
		e1:SetLabel(code)
		e1:SetReset(RESET_PHASE+PHASE_END)
		-- 将新建的禁止发动效果注册到场上，持续到回合结束，作用于对方玩家，使其不能发动被标记卡名的魔法·陷阱卡。
		Duel.RegisterEffect(e1,tp)
	end
end
-- 禁止发动效果的判定函数：对方发动的效果必须是魔法·陷阱卡的发动，且发动卡片的卡号与效果标签中记录的卡号一致。
function c12467005.aclimit(e,re,tp)
	return re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:GetHandler():IsCode(e:GetLabel())
end
