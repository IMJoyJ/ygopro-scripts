--地縛神 Uru
-- 效果：
-- 名字带有「地缚神」的怪兽在场上只能有1只表侧表示存在。场上没有表侧表示场地魔法卡存在的场合这张卡破坏。对方不能选择这张卡作为攻击对象。这张卡可以直接攻击对方玩家。1回合1次，可以把这张卡以外的自己场上存在的1只怪兽解放，选择对方场上表侧表示存在的1只怪兽，直到这个回合的结束阶段时得到控制权。
function c15187079.initial_effect(c)
	-- 设置场上只能有1只表侧表示的名字带有「地缚神」的怪兽，且适用于双方怪兽区域。
	c:SetUniqueOnField(1,1,aux.FilterBoolFunction(Card.IsSetCard,0x1021),LOCATION_MZONE)
	-- 场上没有表侧表示场地魔法卡存在的场合这张卡破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCode(EFFECT_SELF_DESTROY)
	e4:SetCondition(c15187079.sdcon)
	c:RegisterEffect(e4)
	-- 对方不能选择这张卡作为攻击对象。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetCode(EFFECT_CANNOT_BE_BATTLE_TARGET)
	e5:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e5:SetRange(LOCATION_MZONE)
	-- 设置“不能成为攻击对象”效果的判定函数，使这张卡在未免疫该效果时不能被对方选为攻击对象。
	e5:SetValue(aux.imval1)
	c:RegisterEffect(e5)
	-- 这张卡可以直接攻击对方玩家。
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_SINGLE)
	e6:SetCode(EFFECT_DIRECT_ATTACK)
	c:RegisterEffect(e6)
	-- 1回合1次，可以把这张卡以外的自己场上存在的1只怪兽解放，选择对方场上表侧表示存在的1只怪兽，直到这个回合的结束阶段时得到控制权。
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
-- 定义自我破坏效果的条件：当场上不存在表侧表示的场地魔法卡时，满足条件并触发自我破坏。
function c15187079.sdcon(e)
	-- 检查双方场地区是否存在至少1张表侧表示的场地魔法卡；若不存在则返回 true，即这张卡没有场地魔法卡保护时需要破坏。
	return not Duel.IsExistingMatchingCard(Card.IsFaceup,0,LOCATION_FZONE,LOCATION_FZONE,1,nil)
end
-- 起动效果的代价函数：设置标记 label=1，表示解放代价将在目标选择阶段具体处理，并返回 true 使效果可以发动。
function c15187079.ctcost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	return true
end
-- 定义控制权转移的目标过滤条件：怪兽必须表侧表示，并根据 check 参数决定是否忽略转移控制权后对方怪兽区的空位限制。
function c15187079.filter(c,check)
	return c:IsFaceup() and c:IsControlerCanBeChanged(check)
end
-- 定义可解放怪兽的过滤函数：解放这张卡后，己方场上仍有可用怪兽区，且对方场上有表侧表示且可变更控制权的怪兽可供选择。
function c15187079.costfilter(c,tp)
	-- 检查解放候选怪兽后己方怪兽区仍有空位，并且对方场上有至少1只满足 filter 的表侧表示怪兽，以此作为解放代价是否可支付的条件。
	return Duel.GetMZoneCount(tp,c,tp,LOCATION_REASON_CONTROL)>0 and Duel.IsExistingTarget(c15187079.filter,tp,0,LOCATION_MZONE,1,c,true)
end
-- 目标选择函数：若 chkc 存在则验证是否为对方怪兽区表侧表示且可变更控制权的怪兽；发动时若存在代价标记则先选择解放1只“这张卡以外的自己怪兽”，再选择对方场上1只表侧表示怪兽作为控制权对象；最后设置操作信息。
function c15187079.cttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c15187079.filter(chkc) end
	if chk==0 then
		if e:GetLabel()==1 then
			e:SetLabel(0)
			-- 检查己方场上是否存在至少1只满足 costfilter 的可解放怪兽，即能否支付解放代价。
			return Duel.CheckReleaseGroup(tp,c15187079.costfilter,1,c,tp)
		else
			-- 检查对方场上是否存在至少1只表侧表示且可变更控制权的怪兽，用于选择控制权转移对象。
			return Duel.IsExistingTarget(c15187079.filter,tp,0,LOCATION_MZONE,1,nil,false)
		end
	end
	if e:GetLabel()==1 then
		e:SetLabel(0)
		-- 选择己方场上1只满足 costfilter 的怪兽作为解放代价（不包括这张卡自身）。
		local sg=Duel.SelectReleaseGroup(tp,c15187079.costfilter,1,1,c,tp)
		-- 将选择的怪兽解放，解放原因标记为 REASON_COST（作为发动效果支付的代价）。
		Duel.Release(sg,REASON_COST)
	end
	-- 向玩家发送选择提示消息，提示其选择要改变控制权的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
	-- 选择对方场上1只表侧表示且可变更控制权的怪兽，并将其设置为该效果的取对象目标。
	local g=Duel.SelectTarget(tp,c15187079.filter,tp,0,LOCATION_MZONE,1,1,nil,false)
	-- 设置连锁操作信息：本次效果处理涉及改变控制权，目标为 g，数量为 1。
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,0,0)
end
-- 效果处理函数：获取目标怪兽，若目标仍与效果相关且为表侧表示，则获得其控制权，持续到结束阶段。
function c15187079.ctop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的第一个对象卡，即之前选择的那只对方怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 获得目标怪兽的控制权，直到结束阶段（PHASE_END）时归还，持续次数为1。
		Duel.GetControl(tc,tp,PHASE_END,1)
	end
end
