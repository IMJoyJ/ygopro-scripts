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
	-- 这个卡名的③的效果1回合只能使用1次。③：自己·对方的主要阶段，以持有这张卡的攻击力以下的攻击力的对方场上1只怪兽为对象才能发动。场上的这张卡回到手卡，作为对象的怪兽的控制权直到结束阶段得到。
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
-- 无解放召唤的条件判定：若怪兽c为nil（询问是否可适用该召唤手续）则返回true；否则要求无需解放（minc==0）、怪兽等级不低于5且其控制者场上有空余怪兽区。
function c29303524.ntcon(e,c,minc)
	if c==nil then return true end
	-- 判定条件：不需要解放（minc==0）、该怪兽等级在5以上、其控制者场上有可用怪兽区。
	return minc==0 and c:IsLevelAbove(5) and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
end
-- 无解放召唤成功后的处理：给该怪兽注册一个仅在怪兽区适用的效果，将其原本攻击力变成1500，并在怪兽状态变化（如离场等）时自动重置。
function c29303524.ntop(e,tp,eg,ep,ev,re,r,rp,c)
	-- ②：这张卡的①的方法通常召唤的这张卡的原本攻击力变成1500。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetReset(RESET_EVENT+0xff0000)
	e1:SetCode(EFFECT_SET_BASE_ATTACK)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(1500)
	c:RegisterEffect(e1)
end
-- ③效果的发动条件：当前阶段为主要阶段1或主要阶段2（即自己·对方的主要阶段）。
function c29303524.ctcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前是否处于主要阶段1或主要阶段2，满足其中之一即可发动③效果。
	return Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2
end
-- ③效果取对象时的筛选条件：对象是对方场上表侧表示的怪兽，攻击力不高于这张卡的当前攻击力，且控制权可以被变更。
function c29303524.ctfilter(c,atk)
	return c:IsFaceup() and c:IsAttackBelow(atk) and c:IsControlerCanBeChanged(true)
end
-- ③效果发动时的目标处理：先获取这张卡的攻击力；检查对象时要求对象所在位置、控制者和筛选条件均正确；检查发动条件时要求这张卡可回手牌、这张卡若离场后自己场上有空余怪兽区可容纳控制权转移来的怪兽，并且对方场上有符合条件的对象可供选择。
function c29303524.cttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	local atk=c:GetAttack()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c29303524.ctfilter(chkc,atk) end
	if chk==0 then return c:IsAbleToHand()
		-- 用于确保将自身返回手牌后，自己场上仍有至少1个空余怪兽区，以便放置将获得控制权的对象怪兽。
		and Duel.GetMZoneCount(tp,c,tp,LOCATION_REASON_CONTROL)>0
		-- 检查对方场上是否存在至少1只满足ctfilter条件的怪兽，能够作为取对象目标。
		and Duel.IsExistingTarget(c29303524.ctfilter,tp,0,LOCATION_MZONE,1,nil,atk) end
	-- 弹出选择提示，提示玩家“请选择要改变控制权的怪兽”（HINTMSG_CONTROL）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
	-- 让玩家从对方场上选择1只满足条件的怪兽作为效果对象，并将其登记为当前连锁的处理对象。
	local g=Duel.SelectTarget(tp,c29303524.ctfilter,tp,0,LOCATION_MZONE,1,1,nil,atk)
	-- 设置操作信息：本连锁中的“回手牌”类别，预定处理对象为这张卡自身，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,c,1,0,0)
	-- 设置操作信息：本连锁中的“改变控制权”类别，预定处理对象为选择的对象怪兽，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,0,0)
end
-- 效果处理：若这张卡仍与效果关联，先将这张卡返回手牌；返回成功且这张卡位于手牌、对象怪兽仍与效果关联时，获得对象怪兽的控制权直到结束阶段。
function c29303524.ctop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得本效果发动时选择的对象怪兽（将要变更控制权的对方怪兽）。
	local tc=Duel.GetFirstTarget()
	-- 判断这张卡仍与效果关联，并且将这张卡返回手牌的操作成功（返回手牌的数量不为0）。
	if c:IsRelateToEffect(e) and Duel.SendtoHand(c,nil,REASON_EFFECT)~=0
		and c:IsLocation(LOCATION_HAND) and tc:IsRelateToEffect(e) then
		-- 将对象怪兽的控制权转移给发动玩家tp，持续到结束阶段（PHASE_END）并在此后重置归还。
		Duel.GetControl(tc,tp,PHASE_END,1)
	end
end
