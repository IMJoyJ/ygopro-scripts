--慧炎星－コサンジャク
-- 效果：
-- 「炎星」怪兽2只
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：只要这张卡所连接区有「炎星」怪兽存在，对方不能选择这张卡作为攻击对象。
-- ②：这张卡的攻击宣言时把自己场上1张表侧表示的「炎舞」魔法·陷阱卡送去墓地，以对方场上1只怪兽为对象才能发动。直到结束阶段，那只对方怪兽在这张卡所连接区放置得到控制权。这个效果得到控制权的怪兽不能攻击宣言。
function c20265095.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡添加连接召唤手续，要求以2只「炎星」怪兽作为连接素材。
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkSetCard,0x79),2,2)
	-- ①：只要这张卡所连接区有「炎星」怪兽存在，对方不能选择这张卡作为攻击对象。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_CANNOT_BE_BATTLE_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c20265095.btcon)
	-- 设置「不能成为攻击对象」效果的判定值，使用aux.imval1函数，即对方怪兽不免疫此效果时本卡不能成为攻击对象。
	e1:SetValue(aux.imval1)
	c:RegisterEffect(e1)
	-- 这个卡名的②的效果1回合只能使用1次。②：这张卡的攻击宣言时把自己场上1张表侧表示的「炎舞」魔法·陷阱卡送去墓地，以对方场上1只怪兽为对象才能发动。直到结束阶段，那只对方怪兽在这张卡所连接区放置得到控制权。这个效果得到控制权的怪兽不能攻击宣言。
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
-- 定义过滤函数btfilter，用于筛选表侧表示且具有「炎星」字段的怪兽。
function c20265095.btfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x79)
end
-- 定义①效果的适用条件：这张卡的连接区存在至少1只表侧表示的「炎星」怪兽。
function c20265095.btcon(e)
	return e:GetHandler():GetLinkedGroup():IsExists(c20265095.btfilter,1,nil)
end
-- 定义代价过滤函数costfilter，用于选择表侧表示、属于「炎舞」字段且可作为代价送去墓地的魔法·陷阱卡。
function c20265095.costfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x7c) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToGraveAsCost()
end
-- 定义②效果的代价函数：检测是否满足发动代价，即存在可送去墓地的「炎舞」卡，或己方受「炎星仙-鹫真人」效果影响可不送墓发动。
function c20265095.ctcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检测阶段，确认自己场上是否存在至少1张满足costfilter条件的表侧「炎舞」魔法·陷阱卡，以判断能否支付代价。
	if chk==0 then return Duel.IsExistingMatchingCard(c20265095.costfilter,tp,LOCATION_ONFIELD,0,1,nil)
		-- 检测【炎星仙-鹫真人】(46241344)的效果是否生效中。若在生效中，自己把「炎星」怪兽的效果发动的场合，也能不把自己的手卡·场上的「炎星」卡以及「炎舞」卡送去墓地来发动。
		or Duel.IsPlayerAffectedByEffect(tp,46241344) end
	-- 代价执行阶段，确认自己场上是否存在满足costfilter条件的「炎舞」魔法·陷阱卡，作为实际选择送墓的前提。
	if Duel.IsExistingMatchingCard(c20265095.costfilter,tp,LOCATION_ONFIELD,0,1,nil)
		-- 检测【炎星仙-鹫真人】(46241344)的效果是否生效中。若在生效中，自己把「炎星」怪兽的效果发动的场合，也能不把自己的手卡·场上的「炎星」卡以及「炎舞」卡送去墓地来发动。
		and (not Duel.IsPlayerAffectedByEffect(tp,46241344) or not Duel.SelectYesNo(tp,aux.Stringid(46241344,0))) then  --"是否不把卡送去墓地发动？"
		-- 给玩家显示选择提示，要求选择1张要送去墓地的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		-- 让玩家从自己场上选择1张满足costfilter条件的「炎舞」魔法·陷阱卡。
		local g=Duel.SelectMatchingCard(tp,c20265095.costfilter,tp,LOCATION_ONFIELD,0,1,1,nil)
		-- 将选中的卡送去墓地，作为发动②效果所支付的代价。
		Duel.SendtoGrave(g,REASON_COST)
	end
end
-- 定义②效果的目标函数：根据本卡连接区计算可转移到的怪兽区域，选择对方场上1只能改变控制权到该区域的怪兽作为对象，并设置操作信息。
function c20265095.cttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local zone=bit.band(e:GetHandler():GetLinkedZone(),0x1f)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsControlerCanBeChanged(false,zone) end
	-- 目标检测阶段，确认对方场上是否存在至少1只可被改变控制权到本卡连接区的怪兽。
	if chk==0 then return Duel.IsExistingTarget(Card.IsControlerCanBeChanged,tp,0,LOCATION_MZONE,1,nil,false,zone) end
	-- 给玩家显示选择提示，要求选择要改变控制权的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
	-- 让玩家从对方场上选择1只满足条件的怪兽作为效果对象，并记录为当前连锁的对象。
	local g=Duel.SelectTarget(tp,Card.IsControlerCanBeChanged,tp,0,LOCATION_MZONE,1,1,nil,false,zone)
	-- 设置操作信息为改变控制权（CATEGORY_CONTROL），用于后续效果处理及连锁检测。
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,0,0)
end
-- 定义②效果的处理操作：将对象怪兽的控制权转移给自己，指定放到本卡的连接区直至结束阶段，并给该怪兽附加不能攻击的效果。
function c20265095.ctop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取通过②效果选择的目标怪兽。
	local tc=Duel.GetFirstTarget()
	local zone=bit.band(c:GetLinkedZone(),0x1f)
	-- 确认目标怪兽仍与此效果关联，并执行控制权转移（到本卡连接区，持续到结束阶段）；若转移成功，则继续附加不能攻击效果。
	if tc:IsRelateToEffect(e) and Duel.GetControl(tc,tp,PHASE_END,1,zone)~=0 then
		-- 这个效果得到控制权的怪兽不能攻击宣言。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
