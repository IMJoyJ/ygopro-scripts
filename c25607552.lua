--華信龍－ノウルーズ・エリーズ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡在墓地存在的场合，从手卡把1只5星以上的怪兽送去墓地才能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
-- ②：这张卡被战斗或者对方的效果破坏的场合，以对方场上1张卡为对象才能发动。那张卡除外。
function c25607552.initial_effect(c)
	-- ①：这张卡在墓地存在的场合，从手卡把1只5星以上的怪兽送去墓地才能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCountLimit(1,25607552)
	e1:SetCost(c25607552.spcost)
	e1:SetTarget(c25607552.sptg)
	e1:SetOperation(c25607552.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡被战斗或者对方的效果破坏的场合，以对方场上1张卡为对象才能发动。那张卡除外。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,25607553)
	e2:SetCondition(c25607552.rmcon)
	e2:SetTarget(c25607552.rmtg)
	e2:SetOperation(c25607552.rmop)
	c:RegisterEffect(e2)
end
-- 该过滤函数用于筛选可以作为①效果代价从手卡送去墓地的怪兽：必须是等级5以上、是怪兽卡且能够作为代价送去墓地。
function c25607552.cfilter(c)
	return c:IsLevelAbove(5) and c:IsType(TYPE_MONSTER) and c:IsAbleToGraveAsCost()
end
-- ①效果的代价处理函数：在代价确认阶段检查手卡中是否存在符合条件的怪兽；存在则选择并丢弃1张5星以上的怪兽作为发动代价。
function c25607552.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检查（chk==0）：确认手卡中是否存在至少1张满足cfilter条件的怪兽（5星以上怪兽且可作为代价送入墓地）。
	if chk==0 then return Duel.IsExistingMatchingCard(c25607552.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 实际执行代价：从手卡丢弃1张满足cfilter条件的怪兽卡（5星以上怪兽）作为代价。
	Duel.DiscardHand(tp,c25607552.cfilter,1,1,REASON_COST)
end
-- ①效果的发动目标判定：确认自己主要怪兽区有空位且这张卡能够被特殊召唤，满足后将本次特殊召唤信息登记到连锁处理中。
function c25607552.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 目标判定之一：检查自己场上主要怪兽区是否存在可用的空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：声明本效果将特殊召唤1只怪兽（即这张卡），供后续规则检测使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①效果处理：若这张卡仍与效果关联，将其表侧特殊召唤；特殊召唤成功后给它附加“从场上离开的场合除外”的永续效果。
function c25607552.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断这张卡仍与当前效果关联，并且特殊召唤成功（返回数量不为0）时才执行后续的离场除外效果赋予。
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 这个效果特殊召唤的这张卡从场上离开的场合除外。②：这张卡被战斗或者对方的效果破坏的场合，以对方场上1张卡为对象才能发动。那张卡除外。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e1,true)
	end
end
-- ②效果的发动条件判定：这张卡因战斗被破坏，或者被对方控制的效果破坏且破坏前由自己控制时，条件满足。
function c25607552.rmcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_BATTLE)
		or (rp==1-tp and c:IsReason(REASON_EFFECT) and c:IsPreviousControler(tp))
end
-- ②效果的目标选择函数：选择对方场上1张可以被除外的卡作为对象（取对象），并设置除外操作信息。
function c25607552.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and chkc:IsAbleToRemove() end
	-- 目标检查：确认对方场上是否存在至少1张能够被除外的卡可以成为效果对象。
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 向玩家发送选择提示消息，显示“请选择要除外的卡”的文字，供选择目标时参考。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从对方场上选择1张能够被除外的卡，并将其设置为当前连锁的对象。
	local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置操作信息：声明本效果将除外1张卡（即所选对象），供规则检测使用。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- ②效果处理：取出连锁对象，若该卡仍与效果关联，则将其表侧表示除外。
function c25607552.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁中登记的第一个（也是唯一一个）效果对象，即要除外的对方卡片。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象卡片以表侧表示除外，除外原因为效果。
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end
