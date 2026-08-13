--廻生のベンガランゼス
-- 效果：
-- 植物族怪兽2只以上
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：双方的主要阶段，以对方场上1只效果怪兽为对象才能发动。自己受到那只怪兽的攻击力数值的伤害，那只怪兽回到持有者手卡。
-- ②：这张卡在墓地存在的场合，连接标记合计直到4为止从自己墓地把连接怪兽2只以上除外才能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
function c73345237.initial_effect(c)
	-- 为这张卡添加连接召唤手续：以2只以上植物族怪兽作为连接素材
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkRace,RACE_PLANT),2)
	c:EnableReviveLimit()
	-- ①：双方的主要阶段，以对方场上1只效果怪兽为对象才能发动。自己受到那只怪兽的攻击力数值的伤害，那只怪兽回到持有者手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(73345237,0))
	e1:SetCategory(CATEGORY_DAMAGE+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e1:SetCountLimit(1,73345237)
	e1:SetCondition(c73345237.thcon)
	e1:SetTarget(c73345237.thtg)
	e1:SetOperation(c73345237.thop)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在的场合，连接标记合计直到4为止从自己墓地把连接怪兽2只以上除外才能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(73345237,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,73345237)
	e2:SetCost(c73345237.spcost)
	e2:SetTarget(c73345237.sptg)
	e2:SetOperation(c73345237.spop)
	c:RegisterEffect(e2)
end
-- ①效果的发动条件：当前阶段是双方的主要阶段（主要阶段1或主要阶段2）
function c73345237.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前回合所处的阶段
	local ph=Duel.GetCurrentPhase()
	return ph==PHASE_MAIN1 or ph==PHASE_MAIN2
end
-- ①效果的对象过滤条件：对方场上表侧表示的、攻击力1以上的、可以回到手卡的效果怪兽
function c73345237.thfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_EFFECT) and c:IsAttackAbove(1) and c:IsAbleToHand()
end
-- ①效果的对象选择处理：确认对方场上存在满足条件的怪兽，让玩家选择1只作为效果对象，并设置伤害操作信息
function c73345237.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c73345237.thfilter(chkc) end
	-- 发动时检查：对方场上是否存在1只以上可以作为对象的满足条件的效果怪兽
	if chk==0 then return Duel.IsExistingTarget(c73345237.thfilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 向玩家提示「请选择要返回手牌的卡」
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 让对方场上的1只满足条件的效果怪兽成为效果对象
	local g=Duel.SelectTarget(tp,c73345237.thfilter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息：自己将受到对象怪兽攻击力数值的伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,tp,g:GetFirst():GetAttack())
end
-- ①效果的处理：自己受到对象怪兽攻击力数值的伤害，伤害成功处理后那只怪兽回到持有者手卡
function c73345237.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁的对象怪兽
	local tc=Duel.GetFirstTarget()
	-- 若对象怪兽仍与此效果相关，则自己受到那只怪兽攻击力数值的伤害，且伤害实际发生才继续处理
	if tc:IsRelateToEffect(e) and Duel.Damage(tp,tc:GetAttack(),REASON_EFFECT)~=0 then
		-- 把那只对象怪兽回到持有者的手卡
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
-- ②效果的代价过滤条件：可以作为代价除外的连接怪兽
function c73345237.costfilter(c)
	return c:IsType(TYPE_LINK) and c:IsAbleToRemoveAsCost()
end
-- ②效果的发动代价：从自己墓地选择连接标记合计为4的2只以上连接怪兽并除外
function c73345237.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 从自己墓地取得这张卡以外可以作为代价除外的连接怪兽
	local g=Duel.GetMatchingGroup(c73345237.costfilter,tp,LOCATION_GRAVE,0,e:GetHandler())
	if chk==0 then return g:CheckWithSumEqual(Card.GetLink,4,2,4) end
	-- 向玩家提示「请选择要除外的卡」
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local rg=g:SelectWithSumEqual(tp,Card.GetLink,4,2,4)
	-- 把选择的连接怪兽以表侧表示除外作为发动代价
	Duel.Remove(rg,POS_FACEUP,REASON_COST)
end
-- ②效果的目标处理：确认自己主要怪兽区有空位且这张卡可以特殊召唤，并设置特殊召唤操作信息
function c73345237.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 发动时检查：自己主要怪兽区存在可用空格，且这张卡满足特殊召唤的条件
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：将墓地的这张卡特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- ②效果的处理：把墓地的这张卡特殊召唤，并赋予其从场上离开的场合除外的永续效果
function c73345237.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 若这张卡仍与此效果相关，则将这张卡以表侧表示特殊召唤到自己场上
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- 这个效果特殊召唤的这张卡从场上离开的场合除外。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e1,true)
	end
end
