--ナチュル・フライトフライ
-- 效果：
-- 只要这张卡在自己场上表侧表示存在，对方场上表侧表示存在的怪兽的攻击力·守备力下降自己场上表侧表示存在的名字带有「自然」的怪兽数量×300的数值。1回合1次，可以把对方场上表侧表示存在的1只守备力是0的怪兽的控制权直到结束阶段时得到。
function c11390349.initial_effect(c)
	-- 只要这张卡在自己场上表侧表示存在，对方场上表侧表示存在的怪兽的攻击力·守备力下降自己场上表侧表示存在的名字带有「自然」的怪兽数量×300的数值。（本段对应其中攻击力下降部分的实现，守备力由克隆效果e2实现）
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(c11390349.val)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e2)
	-- 1回合1次，可以把对方场上表侧表示存在的1只守备力是0的怪兽的控制权直到结束阶段时得到。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(11390349,0))  --"获得控制权"
	e3:SetCategory(CATEGORY_CONTROL)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetTarget(c11390349.ctltg)
	e3:SetOperation(c11390349.ctlop)
	c:RegisterEffect(e3)
end
-- 筛选自己场上表侧表示且卡名含有「自然」字段的怪兽，作为攻击力·守备力下降数值的计算对象。
function c11390349.vfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x2a)
end
-- 统计自己场上表侧表示的名字带有「自然」的怪兽数量，乘以-300作为攻击力·守备力的增减值。
function c11390349.val(e,c)
	-- 计算符合条件的「自然」怪兽数量并乘以-300后返回，负值表示对方怪兽的攻击力·守备力下降。
	return Duel.GetMatchingGroupCount(c11390349.vfilter,e:GetOwnerPlayer(),LOCATION_MZONE,0,nil)*-300
end
-- 筛选对方场上表侧表示、守备力为0且控制权可以变更的怪兽，作为取对象效果的可选目标。
function c11390349.filter(c)
	return c:IsFaceup() and c:IsDefense(0) and c:IsControlerCanBeChanged()
end
-- 控制权变更效果的发动条件与目标选择：确认存在符合条件的对方怪兽，选择1只作为对象，并设定操作信息为变更控制权。
function c11390349.ctltg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c11390349.filter(chkc) end
	-- 效果发动时检查对方场上是否存在至少1只符合条件的怪兽，若不存在则无法发动。
	if chk==0 then return Duel.IsExistingTarget(c11390349.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 向操作者显示选择提示，提示文字为“请选择要改变控制权的怪兽”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
	-- 从对方场上选择1只符合条件的表侧表示且守备力为0的怪兽作为效果对象，同时将其登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,c11390349.filter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设定本连锁的处理信息为变更控制权，目标为已选择的怪兽，数量为1，供后续效果处理及卡片互动参考。
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,0,0)
end
-- 效果处理时取得之前选择的对象怪兽；若该怪兽仍与效果关联且仍为表侧表示、守备力为0，则将其控制权移给自己直到结束阶段。
function c11390349.ctlop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得本效果发动时选择的对象怪兽（此处仅选择1只，故直接取第一张）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsDefense(0) then
		-- 将对象怪兽的控制权变更为自己，持续到结束阶段（PHASE_END，仅1次）。
		Duel.GetControl(tc,tp,PHASE_END,1)
	end
end
