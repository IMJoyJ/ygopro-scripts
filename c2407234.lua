--No.69 紋章神コート・オブ・アームズ
-- 效果：
-- 4星怪兽×3
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：这张卡特殊召唤的场合发动。这张卡以外的场上的全部超量怪兽的效果无效化。
-- ②：以场上1只其他的超量怪兽为对象才能发动。这张卡直到结束阶段得到和那只怪兽的原本的卡名·效果相同的卡名·效果。
function c2407234.initial_effect(c)
	-- 添加XYZ召唤手续，使用4星怪兽3只进行叠放
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
-- 设置该卡的超量编号为69
aux.xyz_number[2407234]=69
-- 定义过滤函数，用于筛选可被无效化的超量怪兽
function c2407234.negfilter(c)
	-- 筛选条件：怪兽表侧表示、未被无效化且为超量怪兽
	return aux.NegateMonsterFilter(c) and c:IsType(TYPE_XYZ)
end
-- 处理效果无效化操作，为满足条件的怪兽添加无效化效果
function c2407234.negop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取场上除自身外所有满足条件的怪兽
	local g=Duel.GetMatchingGroup(c2407234.negfilter,tp,LOCATION_MZONE,LOCATION_MZONE,aux.ExceptThisCard(e))
	local tc=g:GetFirst()
	while tc do
		-- 为选中的怪兽添加无效化效果
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 为选中的怪兽添加无效化效果（针对效果）
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
		tc=g:GetNext()
	end
end
-- 定义过滤函数，用于筛选可作为目标的超量怪兽
function c2407234.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ)
end
-- 设置效果目标选择逻辑，选择场上的超量怪兽
function c2407234.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c2407234.filter(chkc) and chkc~=e:GetHandler() end
	-- 检查是否存在满足条件的目标怪兽
	if chk==0 then return Duel.IsExistingTarget(c2407234.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,e:GetHandler()) end
	-- 提示玩家选择表侧表示的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择目标怪兽
	Duel.SelectTarget(tp,c2407234.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,e:GetHandler())
end
-- 处理效果复制操作，将目标怪兽的效果复制到自身
function c2407234.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc and c:IsRelateToEffect(e) and c:IsFaceup() and tc:IsFaceup() and tc:IsRelateToEffect(e) then
		local code=tc:GetOriginalCode()
		-- 为自身添加卡名改变效果，使其获得目标怪兽的卡名
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
