--廻生のベンガランゼス
-- 效果：
-- 植物族怪兽2只以上
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：双方的主要阶段，以对方场上1只效果怪兽为对象才能发动。自己受到那只怪兽的攻击力数值的伤害，那只怪兽回到持有者手卡。
-- ②：这张卡在墓地存在的场合，连接标记合计直到4为止从自己墓地把连接怪兽2只以上除外才能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
function c73345237.initial_effect(c)
	-- 设置连接召唤条件为植物族怪兽2只以上
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
	-- ②：这张卡在墓地存在的场合，连接标记合计直到4为止从自己墓地把连接怪兽2只以上除外才能发动。这张卡特殊召唤。
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
-- 判断是否在双方的主要阶段
function c73345237.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前的游戏阶段
	local ph=Duel.GetCurrentPhase()
	return ph==PHASE_MAIN1 or ph==PHASE_MAIN2
end
-- 过滤场上表侧表示的且可以回到手牌的效果怪兽
function c73345237.thfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_EFFECT) and c:IsAttackAbove(1) and c:IsAbleToHand()
end
-- 回手牌效果的发动条件检测与靶向选择对象
function c73345237.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c73345237.thfilter(chkc) end
	-- 若为检测阶段，则判断对方场上是否存在满足过滤条件的效果怪兽
	if chk==0 then return Duel.IsExistingTarget(c73345237.thfilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要返回手牌的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择对方场上1只满足过滤条件的效果怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c73345237.thfilter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置效果处理的分类为给自己造成该怪兽攻击力数值伤害的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,tp,g:GetFirst():GetAttack())
end
-- 回手牌效果处理，自己受到该怪兽攻击力数值的伤害，若成功则将该怪兽送回手牌
function c73345237.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果对象怪兽
	local tc=Duel.GetFirstTarget()
	-- 如果效果对象依然有效，且自己成功受到了其攻击力数值的伤害
	if tc:IsRelateToEffect(e) and Duel.Damage(tp,tc:GetAttack(),REASON_EFFECT)~=0 then
		-- 将效果对象怪兽送回持有者手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
-- 过滤自己墓地中可以除外的连接怪兽
function c73345237.costfilter(c)
	return c:IsType(TYPE_LINK) and c:IsAbleToRemoveAsCost()
end
-- 特殊召唤的发动代价，从墓地除外连接标记合计为4的2只以上连接怪兽
function c73345237.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取自己墓地中除该卡以外的所有满足条件的连接怪兽
	local g=Duel.GetMatchingGroup(c73345237.costfilter,tp,LOCATION_GRAVE,0,e:GetHandler())
	if chk==0 then return g:CheckWithSumEqual(Card.GetLink,4,2,4) end
	-- 提示玩家选择要除外的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local rg=g:SelectWithSumEqual(tp,Card.GetLink,4,2,4)
	-- 将选中的怪兽除外以支付发动代价
	Duel.Remove(rg,POS_FACEUP,REASON_COST)
end
-- 特殊召唤效果的发动条件检测
function c73345237.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 若为检测阶段，则判断主要怪兽区是否有空位，且这张卡是否可以特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置效果处理的分类为将此卡特殊召唤的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 特殊召唤效果处理，将此卡特殊召唤，并添加离场除外的效果
function c73345237.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 如果此卡与效果有关且成功特殊召唤到场上
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
