--猛吹雪
-- 效果：
-- 自己的陷阱卡被对方控制的卡的效果破坏，从场地送去墓地时才能发动。场上的1张魔法·陷阱卡破坏。
function c473469.initial_effect(c)
	-- 自己的陷阱卡被对方控制的卡的效果破坏，从场地送去墓地时才能发动。场上的1张魔法·陷阱卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCondition(c473469.condition)
	e1:SetTarget(c473469.target)
	e1:SetOperation(c473469.activate)
	c:RegisterEffect(e1)
end
-- 筛选被效果破坏的陷阱卡：必须是我方陷阱卡，且是从场上送去墓地，且破坏原因是被对方效果破坏（REASON_DESTROY+REASON_EFFECT）。
function c473469.filter(c,tp)
	return c:IsType(TYPE_TRAP) and c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsPreviousControler(tp)
		and bit.band(c:GetReason(),0x41)==0x41
end
-- 发动条件判定：此次破坏的触发者（rp）必须是对方，且这次送去墓地的卡组中存在至少1张满足上述筛选条件（我方场上的陷阱卡被对方效果破坏）的卡。
function c473469.condition(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and eg:IsExists(c473469.filter,1,nil,tp)
end
-- 取对象目标的筛选函数：选择场上存在的魔法·陷阱卡（包括永续魔法、场地魔法、装备魔法、通常陷阱等，不区分表侧里侧）。
function c473469.desfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 效果发动时的目标选择处理：先处理选发时的对象合法性，再检查是否存在合法目标；若可发动，提示玩家选择1张场上魔法·陷阱卡作为对象，并写入破坏的操作信息。
function c473469.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and c473469.desfilter(chkc) and chkc~=e:GetHandler() end
	-- 发动合法性检查：在未启动时确认是否存在至少1张场上的魔法·陷阱卡可以作为对象（且不能选择效果发动者自身）。
	if chk==0 then return Duel.IsExistingTarget(c473469.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler()) end
	-- 弹出选择提示，让玩家从候选卡中选取要破坏的魔法·陷阱卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 玩家选择场上1张魔法·陷阱卡（不能选择本卡）作为效果对象，并将该卡登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,c473469.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,e:GetHandler())
	-- 设置本次连锁的操作信息：将执行破坏效果，对象为已选择的1张卡，总数1，用于后续如星尘龙等效果的时点检测。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果处理阶段：获取对象卡，若对象仍与本次效果关联（未被无效、离场等），则将其破坏。
function c473469.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的那1张对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将以效果破坏这一原因，将对象卡破坏并送去墓地。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
