--地縛神 Uru
-- 效果：
-- 名字带有「地缚神」的怪兽在场上只能有1只表侧表示存在。场上没有表侧表示场地魔法卡存在的场合这张卡破坏。对方不能选择这张卡作为攻击对象。这张卡可以直接攻击对方玩家。1回合1次，可以把这张卡以外的自己场上存在的1只怪兽解放，选择对方场上表侧表示存在的1只怪兽，直到这个回合的结束阶段时得到控制权。
function c15187079.initial_effect(c)
	-- 设置场上只能存在1只名字带有「地缚神」的怪兽
	c:SetUniqueOnField(1,1,aux.FilterBoolFunction(Card.IsSetCard,0x1021),LOCATION_MZONE)
	-- 场上没有表侧表示场地魔法卡存在的场合这张卡破坏
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCode(EFFECT_SELF_DESTROY)
	e4:SetCondition(c15187079.sdcon)
	c:RegisterEffect(e4)
	-- 对方不能选择这张卡作为攻击对象
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetCode(EFFECT_CANNOT_BE_BATTLE_TARGET)
	e5:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e5:SetRange(LOCATION_MZONE)
	-- 不能成为攻击对象的过滤函数的简单写法
	e5:SetValue(aux.imval1)
	c:RegisterEffect(e5)
	-- 这张卡可以直接攻击对方玩家
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_SINGLE)
	e6:SetCode(EFFECT_DIRECT_ATTACK)
	c:RegisterEffect(e6)
	-- 1回合1次，可以把这张卡以外的自己场上存在的1只怪兽解放，选择对方场上表侧表示存在的1只怪兽，直到这个回合的结束阶段时得到控制权
	local e7=Effect.CreateEffect(c)
	e7:SetDescription(aux.Stringid(15187079,0))  --"获得控制权"
	e7:SetCategory(CATEGORY_CONTROL)
	e7:SetType(EFFECT_TYPE_IGNITION)
	e7:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e7:SetRange(LOCATION_MZONE)
	e7:SetCountLimit(1)
	e7:SetCost(c15187079.ctcost)
	e7:SetTarget(c15187079.cttg)
	e7:SetOperation(c15187079.ctop)
	c:RegisterEffect(e7)
end
-- 当场上没有表侧表示的场地魔法卡时，此卡破坏
function c15187079.sdcon(e)
	-- 检查场上是否存在表侧表示的场地魔法卡
	return not Duel.IsExistingMatchingCard(Card.IsFaceup,0,LOCATION_FZONE,LOCATION_FZONE,1,nil)
end
-- 设置发动时的费用标记
function c15187079.ctcost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	return true
end
-- 过滤满足条件的怪兽，必须表侧表示且可以改变控制权
function c15187079.filter(c,check)
	return c:IsFaceup() and c:IsControlerCanBeChanged(check)
end
-- 检查是否满足解放条件的怪兽，包括怪兽区空位和目标怪兽
function c15187079.costfilter(c,tp)
	-- 检查是否有满足条件的怪兽可以解放并选择目标
	return Duel.GetMZoneCount(tp,c,tp,LOCATION_REASON_CONTROL)>0 and Duel.IsExistingTarget(c15187079.filter,tp,0,LOCATION_MZONE,1,c,true)
end
-- 处理效果的发动和目标选择逻辑
function c15187079.cttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c15187079.filter(chkc) end
	if chk==0 then
		if e:GetLabel()==1 then
			e:SetLabel(0)
			-- 检查是否可以解放满足条件的怪兽
			return Duel.CheckReleaseGroup(tp,c15187079.costfilter,1,c,tp)
		else
			-- 检查是否存在满足条件的对方怪兽作为目标
			return Duel.IsExistingTarget(c15187079.filter,tp,0,LOCATION_MZONE,1,nil,false)
		end
	end
	if e:GetLabel()==1 then
		e:SetLabel(0)
		-- 选择满足条件的怪兽进行解放
		local sg=Duel.SelectReleaseGroup(tp,c15187079.costfilter,1,1,c,tp)
		-- 以代价原因解放选择的怪兽
		Duel.Release(sg,REASON_COST)
	end
	-- 提示玩家选择目标怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)
	-- 选择对方场上的怪兽作为目标
	local g=Duel.SelectTarget(tp,c15187079.filter,tp,0,LOCATION_MZONE,1,1,nil,false)
	-- 设置效果操作信息，准备改变控制权
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,0,0)
end
-- 执行控制权转移效果
function c15187079.ctop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将目标怪兽的控制权转移给玩家，持续到结束阶段
		Duel.GetControl(tc,tp,PHASE_END,1)
	end
end
