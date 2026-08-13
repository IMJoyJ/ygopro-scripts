--No.69 紋章神コート・オブ・アームズ
-- 效果：
-- 4星怪兽×3
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：这张卡特殊召唤的场合发动。这张卡以外的场上的全部超量怪兽的效果无效化。
-- ②：以场上1只其他的超量怪兽为对象才能发动。这张卡直到结束阶段得到和那只怪兽的原本的卡名·效果相同的卡名·效果。
function c2407234.initial_effect(c)
	-- 为这张卡添加XYZ召唤手续：以3只4星怪兽为素材叠放进行超量召唤（对应“4星怪兽×3”）。
	aux.AddXyzProcedure(c,nil,4,3)
	c:EnableReviveLimit()
	-- ①：这张卡特殊召唤的场合发动。这张卡以外的场上的全部超量怪兽的效果无效化。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(2407234,0))  --"效果无效"
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetOperation(c2407234.negop)
	c:RegisterEffect(e1)
	-- ②：以场上1只其他的超量怪兽为对象才能发动。这张卡直到结束阶段得到和那只怪兽的原本的卡名·效果相同的卡名·效果。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(2407234,1))  --"获得效果"
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,2407234)
	e2:SetTarget(c2407234.target)
	e2:SetOperation(c2407234.operation)
	c:RegisterEffect(e2)
end
-- 将这张卡登记为No.69，使卡名/字段可作为“No.69”被相关效果识别。
aux.xyz_number[2407234]=69
-- 定义①效果的无转化对象筛选函数：筛选出表侧表示、效果未被无效且为超量怪兽的卡。
function c2407234.negfilter(c)
	-- 判断卡c是否为表侧表示、效果未被无效（或原本为效果怪兽）的超量怪兽，用于筛出①效果需要无效的对象。
	return aux.NegateMonsterFilter(c) and c:IsType(TYPE_XYZ)
end
-- ①效果处理：特殊召唤成功时，获取场上除自身以外的全部超量怪兽，对每只怪兽分别赋予“怪兽效果无效”（EFFECT_DISABLE）和“效果无效化”（EFFECT_DISABLE_EFFECT）状态，并随怪兽离场等标准时机重置。
function c2407234.negop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取双方场上除这张卡自身以外的全部满足negfilter条件的超量怪兽，作为①效果中“这张卡以外的场上的全部超量怪兽”。
	local g=Duel.GetMatchingGroup(c2407234.negfilter,tp,LOCATION_MZONE,LOCATION_MZONE,aux.ExceptThisCard(e))
	local tc=g:GetFirst()
	while tc do
		-- ①：这张卡特殊召唤的场合发动。这张卡以外的场上的全部超量怪兽的效果无效化。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- ①：这张卡特殊召唤的场合发动。这张卡以外的场上的全部超量怪兽的效果无效化。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
		tc=g:GetNext()
	end
end
-- ②效果的对象过滤条件：对象必须是表侧表示的超量怪兽（且不能是这张卡自身，通过调用时传入的ex参数排除）。
function c2407234.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ)
end
-- ②效果的发动时处理：检测场上是否存在除自身以外的表侧表示超量怪兽；若存在，则提示玩家选择1只作为取对象效果的对象。
function c2407234.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c2407234.filter(chkc) and chkc~=e:GetHandler() end
	-- 在发动合法性判定时，确认场上是否存在1只除自身以外的表侧表示超量怪兽可以作为对象，否则②效果不能发动。
	if chk==0 then return Duel.IsExistingTarget(c2407234.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,e:GetHandler()) end
	-- 向玩家显示“请选择表侧表示的卡”的选择提示，为接下来的选卡提供UI引导。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让玩家选择1只除自身以外的表侧表示超量怪兽，并将选择结果设置为当前连锁的效果对象（取对象）。
	Duel.SelectTarget(tp,c2407234.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,e:GetHandler())
end
-- ②效果的实际处理：在发动者自身和目标怪兽都仍在场上且与效果关联时，获取目标怪兽的原本卡号，先给自己赋予不可被无效的卡名变更效果（卡名变为目标原本卡名），再复制目标怪兽的原本效果，这些状态持续到结束阶段重置。
function c2407234.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取出当前连锁中记录的对象怪兽（即②效果选择的那1只其他超量怪兽）。
	local tc=Duel.GetFirstTarget()
	if tc and c:IsRelateToEffect(e) and c:IsFaceup() and tc:IsFaceup() and tc:IsRelateToEffect(e) then
		local code=tc:GetOriginalCode()
		-- ②：以场上1只其他的超量怪兽为对象才能发动。这张卡直到结束阶段得到和那只怪兽的原本的卡名·效果相同的卡名·效果。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_CHANGE_CODE)
		e1:SetValue(code)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
		c:CopyEffect(code,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,1)
	end
end
