--慧炎星－コサンジャク
-- 效果：
-- 「炎星」怪兽2只
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：只要这张卡所连接区有「炎星」怪兽存在，对方不能选择这张卡作为攻击对象。
-- ②：这张卡的攻击宣言时把自己场上1张表侧表示的「炎舞」魔法·陷阱卡送去墓地，以对方场上1只怪兽为对象才能发动。直到结束阶段，那只对方怪兽在这张卡所连接区放置得到控制权。这个效果得到控制权的怪兽不能攻击宣言。
function c20265095.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加连接召唤手续，需要2个以上满足过滤条件的「炎星」怪兽作为连接素材
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkSetCard,0x79),2,2)
	-- ①：只要这张卡所连接区有「炎星」怪兽存在，对方不能选择这张卡作为攻击对象。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_CANNOT_BE_BATTLE_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c20265095.btcon)
	-- 设置效果值为不会成为攻击对象的过滤函数
	e1:SetValue(aux.imval1)
	c:RegisterEffect(e1)
	-- ②：这张卡的攻击宣言时把自己场上1张表侧表示的「炎舞」魔法·陷阱卡送去墓地，以对方场上1只怪兽为对象才能发动。直到结束阶段，那只对方怪兽在这张卡所连接区放置得到控制权。这个效果得到控制权的怪兽不能攻击宣言。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(20265095,0))
	e2:SetCategory(CATEGORY_CONTROL)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetCountLimit(1,20265095)
	e2:SetCost(c20265095.ctcost)
	e2:SetTarget(c20265095.cttg)
	e2:SetOperation(c20265095.ctop)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于判断是否为表侧表示的「炎星」怪兽
function c20265095.btfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x79)
end
-- 条件函数，用于判断这张卡的连接区是否存在「炎星」怪兽
function c20265095.btcon(e)
	return e:GetHandler():GetLinkedGroup():IsExists(c20265095.btfilter,1,nil)
end
-- 过滤函数，用于判断是否为表侧表示的「炎舞」魔法或陷阱卡
function c20265095.costfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x7c) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToGraveAsCost()
end
-- 检查是否满足发动条件，包括场上是否存在满足条件的卡或是否受到特定效果影响
function c20265095.ctcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在满足条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c20265095.costfilter,tp,LOCATION_ONFIELD,0,1,nil)
		-- 检查玩家是否受到特定效果影响
		or Duel.IsPlayerAffectedByEffect(tp,46241344) end
	-- 检查场上是否存在满足条件的卡
	if Duel.IsExistingMatchingCard(c20265095.costfilter,tp,LOCATION_ONFIELD,0,1,nil)
		-- 若场上存在满足条件的卡且未受特定效果影响，则询问是否不把卡送去墓地发动
		and (not Duel.IsPlayerAffectedByEffect(tp,46241344) or not Duel.SelectYesNo(tp,aux.Stringid(46241344,0))) then  --"是否不把卡送去墓地发动？"
		-- 提示玩家选择要送去墓地的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		-- 选择满足条件的1张卡
		local g=Duel.SelectMatchingCard(tp,c20265095.costfilter,tp,LOCATION_ONFIELD,0,1,1,nil)
		-- 将选中的卡送去墓地作为代价
		Duel.SendtoGrave(g,REASON_COST)
	end
end
-- 设置选择目标的过滤条件，确保目标为对方场上的怪兽且能改变控制权
function c20265095.cttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local zone=bit.band(e:GetHandler():GetLinkedZone(),0x1f)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsControlerCanBeChanged(false,zone) end
	-- 检查是否满足选择目标的条件
	if chk==0 then return Duel.IsExistingTarget(Card.IsControlerCanBeChanged,tp,0,LOCATION_MZONE,1,nil,false,zone) end
	-- 提示玩家选择要改变控制权的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
	-- 选择满足条件的1只对方怪兽
	local g=Duel.SelectTarget(tp,Card.IsControlerCanBeChanged,tp,0,LOCATION_MZONE,1,1,nil,false,zone)
	-- 设置操作信息，记录将要改变控制权的怪兽
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,0,0)
end
-- 处理效果的执行逻辑，包括获得控制权并设置不能攻击宣言的效果
function c20265095.ctop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁的目标卡
	local tc=Duel.GetFirstTarget()
	local zone=bit.band(c:GetLinkedZone(),0x1f)
	-- 判断目标卡是否有效且成功获得控制权
	if tc:IsRelateToEffect(e) and Duel.GetControl(tc,tp,PHASE_END,1,zone)~=0 then
		-- 为获得控制权的怪兽添加不能攻击宣言的效果
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
