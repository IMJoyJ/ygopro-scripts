--ナチュル・フライトフライ
-- 效果：
-- 只要这张卡在自己场上表侧表示存在，对方场上表侧表示存在的怪兽的攻击力·守备力下降自己场上表侧表示存在的名字带有「自然」的怪兽数量×300的数值。1回合1次，可以把对方场上表侧表示存在的1只守备力是0的怪兽的控制权直到结束阶段时得到。
function c11390349.initial_effect(c)
	-- 只要这张卡在自己场上表侧表示存在，对方场上表侧表示存在的怪兽的攻击力·守备力下降自己场上表侧表示存在的名字带有「自然」的怪兽数量×300的数值。
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
-- 过滤函数，用于判断是否为场上表侧表示且名字带有「自然」的怪兽
function c11390349.vfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x2a)
end
-- 计算攻击力/守备力下降值，为场上名字带有「自然」的怪兽数量乘以-300
function c11390349.val(e,c)
	-- 返回场上名字带有「自然」的怪兽数量乘以-300的结果
	return Duel.GetMatchingGroupCount(c11390349.vfilter,e:GetOwnerPlayer(),LOCATION_MZONE,0,nil)*-300
end
-- 过滤函数，用于判断是否为场上表侧表示且守备力为0且可以改变控制权的怪兽
function c11390349.filter(c)
	return c:IsFaceup() and c:IsDefense(0) and c:IsControlerCanBeChanged()
end
-- 设置控制权效果的发动条件和目标选择函数
function c11390349.ctltg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c11390349.filter(chkc) end
	-- 检查是否有满足条件的对方怪兽可以成为目标
	if chk==0 then return Duel.IsExistingTarget(c11390349.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 向玩家提示选择要改变控制权的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)
	-- 选择满足条件的对方怪兽作为目标
	local g=Duel.SelectTarget(tp,c11390349.filter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息，表示将要改变目标怪兽的控制权
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,0,0)
end
-- 控制权效果的处理函数
function c11390349.ctlop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsDefense(0) then
		-- 让玩家获得目标怪兽的控制权直到结束阶段
		Duel.GetControl(tc,tp,PHASE_END,1)
	end
end
