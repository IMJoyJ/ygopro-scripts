--蒼眼の銀龍
-- 效果：
-- 调整＋调整以外的通常怪兽1只以上
-- ①：这张卡特殊召唤的场合发动。自己场上的全部龙族怪兽直到下个回合的结束时不会被效果破坏，双方直到下个回合的结束时不能把那些作为效果的对象。
-- ②：自己准备阶段，以自己墓地1只通常怪兽为对象才能发动。那只怪兽特殊召唤。
function c40908371.initial_effect(c)
	-- 为这张卡添加同调召唤手续：需要1只调整怪兽和1只以上调整以外的通常怪兽作为素材。
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(Card.IsSynchroType,TYPE_NORMAL),1)
	c:EnableReviveLimit()
	-- ①：这张卡特殊召唤的场合发动。自己场上的全部龙族怪兽直到下个回合的结束时不会被效果破坏，双方直到下个回合的结束时不能把那些作为效果的对象。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(40908371,0))  --"效果耐性"
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetOperation(c40908371.effop)
	c:RegisterEffect(e1)
	-- ②：自己准备阶段，以自己墓地1只通常怪兽为对象才能发动。那只怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(40908371,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e2:SetCountLimit(1)
	e2:SetCondition(c40908371.spcon)
	e2:SetTarget(c40908371.sptg)
	e2:SetOperation(c40908371.spop)
	c:RegisterEffect(e2)
end
-- 过滤函数：判断怪兽是否为表侧表示且为龙族，用于筛选自己场上符合条件的龙族怪兽。
function c40908371.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_DRAGON)
end
-- 效果①的处理：特殊召唤成功时，获取自己场上所有表侧表示的龙族怪兽，并为每只怪兽赋予“不会被效果破坏”和“不能成为效果的对象”的耐性，持续到下个回合结束。
function c40908371.effop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得自己场上所有表侧表示且为龙族的怪兽，作为要赋予耐性的对象集合。
	local g=Duel.GetMatchingGroup(c40908371.filter,tp,LOCATION_MZONE,0,nil)
	local tc=g:GetFirst()
	while tc do
		-- 自己场上的全部龙族怪兽直到下个回合的结束时不会被效果破坏。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,2)
		tc:RegisterEffect(e1)
		-- 双方直到下个回合的结束时不能把那些作为效果的对象。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetValue(1)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,2)
		tc:RegisterEffect(e2)
		tc=g:GetNext()
	end
end
-- 效果②的发动条件：仅在己方的准备阶段才能发动（当前回合玩家为自己）。
function c40908371.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为自己，从而确认处于自己的准备阶段。
	return Duel.GetTurnPlayer()==tp
end
-- 过滤函数：判断墓地中的怪兽是否为通常怪兽，且能够被当前效果特殊召唤。
function c40908371.spfilter(c,e,tp)
	return c:IsType(TYPE_NORMAL) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②的目标选择：确认对象时必须是自己墓地且由自己控制的通常怪兽；发动时检查自己主要怪兽区有空位且墓地存在符合条件的通常怪兽。
function c40908371.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c40908371.spfilter(chkc,e,tp) end
	-- 发动时检查（chk==0）自己主要怪兽区是否有可用的空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并且墓地中存在1只满足条件的通常怪兽可以作为效果的对象。
		and Duel.IsExistingTarget(c40908371.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向玩家显示选择提示，提示内容为“请选择要特殊召唤的卡”，用于后续从墓地选择怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己墓地选择1只满足条件的通常怪兽，并将其设为当前连锁的效果对象。
	local g=Duel.SelectTarget(tp,c40908371.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置本次效果处理的操作信息：声明将对选中的怪兽进行特殊召唤，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果②的处理：取得选择的对象怪兽，若对象仍与该效果关联，则将其特殊召唤到自己场上。
function c40908371.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁的效果对象（即选中的墓地通常怪兽）。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 将对象怪兽以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
