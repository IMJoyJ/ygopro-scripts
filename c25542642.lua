--幻影霧剣
-- 效果：
-- 以场上1只效果怪兽为对象才能把这张卡发动。这个卡名的②的效果1回合只能使用1次。
-- ①：作为对象的怪兽不能攻击，效果无效化，双方怪兽不能选择作为对象的怪兽作为攻击对象。那只怪兽从场上离开时这张卡破坏。
-- ②：把墓地的这张卡除外，以自己墓地1只「幻影骑士团」怪兽为对象才能发动。那只怪兽特殊召唤。这个效果特殊召唤的怪兽从场上离开的场合除外。
function c25542642.initial_effect(c)
	-- 以场上1只效果怪兽为对象才能把这张卡发动。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DISABLE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e1:SetTarget(c25542642.target)
	e1:SetOperation(c25542642.tgop)
	c:RegisterEffect(e1)
	-- 作为对象的怪兽不能攻击
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_TARGET)
	e3:SetCode(EFFECT_CANNOT_ATTACK)
	e3:SetRange(LOCATION_SZONE)
	c:RegisterEffect(e3)
	local e5=e3:Clone()
	e5:SetCode(EFFECT_DISABLE)
	c:RegisterEffect(e5)
	-- 双方怪兽不能选择作为对象的怪兽作为攻击对象。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e4:SetRange(LOCATION_SZONE)
	e4:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e4:SetValue(c25542642.tgval)
	c:RegisterEffect(e4)
	-- 作为对象的怪兽从场上离开时这张卡破坏。
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e6:SetRange(LOCATION_SZONE)
	e6:SetCode(EVENT_LEAVE_FIELD)
	e6:SetCondition(c25542642.descon)
	e6:SetOperation(c25542642.desop)
	c:RegisterEffect(e6)
	-- 这个卡名的②的效果1回合只能使用1次。②：把墓地的这张卡除外，以自己墓地1只「幻影骑士团」怪兽为对象才能发动。那只怪兽特殊召唤。这个效果特殊召唤的怪兽从场上离开的场合除外。
	local e7=Effect.CreateEffect(c)
	e7:SetDescription(aux.Stringid(25542642,0))
	e7:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e7:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e7:SetType(EFFECT_TYPE_QUICK_O)
	e7:SetCode(EVENT_FREE_CHAIN)
	e7:SetRange(LOCATION_GRAVE)
	e7:SetCountLimit(1,25542642)
	-- 把墓地的这张卡除外作为发动代价。
	e7:SetCost(aux.bfgcost)
	e7:SetTarget(c25542642.sptg)
	e7:SetOperation(c25542642.spop)
	c:RegisterEffect(e7)
end
-- 过滤函数：选择场上表侧表示的效果怪兽。
function c25542642.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_EFFECT)
end
-- 发动时的目标选择函数：从双方怪兽区选择1只表侧表示的效果怪兽作为对象，并设定此次操作涉及无效化效果。
function c25542642.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c25542642.filter(chkc) end
	-- 发动合法性检查：自己或对方场上是否存在1只表侧表示的效果怪兽可以成为对象。
	if chk==0 then return Duel.IsExistingTarget(c25542642.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向玩家提示“请选择表侧表示的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让发动玩家从双方怪兽区选择1只表侧表示的效果怪兽，并将其设为这张卡的对象。
	local g=Duel.SelectTarget(tp,c25542642.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 记录本次操作含无效效果，对象数量为1，为后续时点判定提供信息。
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
end
-- 发动处理时的操作函数：若这张卡和对象仍与效果关联且对象表侧表示，则让这张卡持续以该怪兽为对象（建立持续对象关系）。
function c25542642.tgop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取这张卡发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsRelateToEffect(e) then
		c:SetCardTarget(tc)
	end
end
-- 判定某只怪兽是否为这张卡持续对象的目标，用于“不能选择为攻击对象”效果。
function c25542642.tgval(e,c)
	return e:GetHandler():IsHasCardTarget(c)
end
-- 破坏条件的判定：若这张卡当前持续对象的那只怪兽出现在离场事件组中，则满足条件。
function c25542642.descon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=c:GetFirstCardTarget()
	return tc and eg:IsContains(tc)
end
-- 破坏效果的处理：以效果原因破坏这张卡。
function c25542642.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 以效果原因破坏这张卡（幻影雾剑自身）。
	Duel.Destroy(e:GetHandler(),REASON_EFFECT)
end
-- 过滤函数：选择自己墓地中满足‘幻影骑士团’字段且可以被特殊召唤的怪兽。
function c25542642.spfilter(c,e,tp)
	return c:IsSetCard(0x10db) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②的效果目标选择函数：从自己墓地选择1只符合条件且可特殊召唤的「幻影骑士团」怪兽为对象，并设定特殊召唤操作。
function c25542642.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c25542642.spfilter(chkc,e,tp) end
	-- 发动合法性检查：自己场上必须有至少1个可用的主要怪兽区空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 且自己墓地存在1只符合条件的「幻影骑士团」怪兽可以成为对象。
		and Duel.IsExistingTarget(c25542642.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向玩家提示“请选择要特殊召唤的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让发动玩家从自己墓地选择1只符合条件的「幻影骑士团」怪兽，并设为对象。
	local g=Duel.SelectTarget(tp,c25542642.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 记录本次操作含特殊召唤，对象数量为1，为后续时点判定提供信息。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- ②效果处理函数：检查怪兽区空格，取对象，若对象仍关联则将其表侧攻击表示特殊召唤，并为那只怪兽附加‘从场上离开的场合除外’的效果。
function c25542642.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 如果自己场上没有可用的主要怪兽区空格，则处理中止。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 获取②效果选择的墓地怪兽。
	local tc=Duel.GetFirstTarget()
	-- 若对象仍与效果关联，则将其以表侧表示特殊召唤；若特殊召唤成功，继续附加离场除外效果。
	if tc:IsRelateToEffect(e) and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- 这个效果特殊召唤的怪兽从场上离开的场合除外。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		tc:RegisterEffect(e1,true)
	end
end
