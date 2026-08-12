--眩月龍セレグレア
-- 效果：
-- 这个卡名的③的效果1回合只能使用1次。
-- ①：这张卡可以不用解放作通常召唤。
-- ②：这张卡的①的方法通常召唤的这张卡的原本攻击力变成1500。
-- ③：自己·对方的主要阶段，以持有这张卡的攻击力以下的攻击力的对方场上1只怪兽为对象才能发动。场上的这张卡回到手卡，作为对象的怪兽的控制权直到结束阶段得到。
function c29303524.initial_effect(c)
	-- ①：这张卡可以不用解放作通常召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(29303524,0))  --"不用解放作通常召唤"
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SUMMON_PROC)
	e1:SetCondition(c29303524.ntcon)
	e1:SetOperation(c29303524.ntop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_SET_PROC)
	c:RegisterEffect(e2)
	-- ③：自己·对方的主要阶段，以持有这张卡的攻击力以下的攻击力的对方场上1只怪兽为对象才能发动。场上的这张卡回到手卡，作为对象的怪兽的控制权直到结束阶段得到。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(29303524,1))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_CONTROL)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,29303524)
	e3:SetHintTiming(0,TIMING_MAIN_END)
	e3:SetCondition(c29303524.ctcon)
	e3:SetTarget(c29303524.cttg)
	e3:SetOperation(c29303524.ctop)
	c:RegisterEffect(e3)
end
-- 判断是否满足不需解放的通常召唤条件，即等级不低于5且场上怪兽区有空位。
function c29303524.ntcon(e,c,minc)
	if c==nil then return true end
	-- 等级不低于5且场上怪兽区有空位。
	return minc==0 and c:IsLevelAbove(5) and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
end
-- 设置自身原本攻击力为1500。
function c29303524.ntop(e,tp,eg,ep,ev,re,r,rp,c)
	-- 设置自身原本攻击力为1500。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetReset(RESET_EVENT+0xff0000)
	e1:SetCode(EFFECT_SET_BASE_ATTACK)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(1500)
	c:RegisterEffect(e1)
end
-- 判断是否处于主要阶段1或主要阶段2。
function c29303524.ctcon(e,tp,eg,ep,ev,re,r,rp)
	-- 处于主要阶段1或主要阶段2。
	return Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2
end
-- 筛选对方场上攻击力低于或等于自身攻击力且可以改变控制权的怪兽。
function c29303524.ctfilter(c,atk)
	return c:IsFaceup() and c:IsAttackBelow(atk) and c:IsControlerCanBeChanged(true)
end
-- 设置效果的发动条件，包括自身可以回到手卡、对方场上存在符合条件的怪兽。
function c29303524.cttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	local atk=c:GetAttack()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c29303524.ctfilter(chkc,atk) end
	if chk==0 then return c:IsAbleToHand()
		-- 确保己方场上存在可用于放置怪兽的区域。
		and Duel.GetMZoneCount(tp,c,tp,LOCATION_REASON_CONTROL)>0
		-- 确保对方场上存在符合条件的怪兽。
		and Duel.IsExistingTarget(c29303524.ctfilter,tp,0,LOCATION_MZONE,1,nil,atk) end
	-- 提示玩家选择要改变控制权的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
	-- 选择对方场上攻击力低于或等于自身攻击力的怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,c29303524.ctfilter,tp,0,LOCATION_MZONE,1,1,nil,atk)
	-- 设置效果处理时将自身送入手牌的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,c,1,0,0)
	-- 设置效果处理时改变对象怪兽控制权的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,0,0)
end
-- 执行效果处理，将自身送入手牌并改变对象怪兽的控制权。
function c29303524.ctop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果的对象怪兽。
	local tc=Duel.GetFirstTarget()
	-- 确认自身和对象怪兽均有效且自身成功送入手牌。
	if c:IsRelateToEffect(e) and Duel.SendtoHand(c,nil,REASON_EFFECT)~=0
		and c:IsLocation(LOCATION_HAND) and tc:IsRelateToEffect(e) then
		-- 将对象怪兽的控制权交给发动者，持续到结束阶段。
		Duel.GetControl(tc,tp,PHASE_END,1)
	end
end
