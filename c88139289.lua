--サイコガンナーMk-Ⅱ
-- 效果：
-- 念动力族调整＋调整以外的念动力族怪兽1只以上
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：以自己或对方的除外状态的1只怪兽为对象才能发动。那只怪兽在自己场上特殊召唤。
-- ②：自己·对方的主要阶段，从自己墓地把1只怪兽除外，以场上1只其他的表侧表示怪兽为对象才能发动。那只怪兽除外。那之后，自己基本分回复除外的怪兽的原本攻击力的数值。
local s,id,o=GetID()
-- 注册卡片的同调召唤手续、①效果（起动效果，特召除外怪兽）和②效果（二速效果，除外场上怪兽并回复生命值）。
function s.initial_effect(c)
	-- 设置同调召唤条件：念动力族调整＋调整以外的念动力族怪兽1只以上。
	aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsRace,RACE_PSYCHO),aux.NonTuner(Card.IsRace,RACE_PSYCHO),1)
	c:EnableReviveLimit()
	-- ①：以自己或对方的除外状态的1只怪兽为对象才能发动。那只怪兽在自己场上特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：自己·对方的主要阶段，从自己墓地把1只怪兽除外，以场上1只其他的表侧表示怪兽为对象才能发动。那只怪兽除外。那之后，自己基本分回复除外的怪兽的原本攻击力的数值。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"除外"
	e2:SetCategory(CATEGORY_REMOVE+CATEGORY_RECOVER)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetHintTiming(0,TIMING_MAIN_END)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.rmcon)
	e2:SetCost(s.rmcost)
	e2:SetTarget(s.rmtg)
	e2:SetOperation(s.rmop)
	c:RegisterEffect(e2)
end
-- 过滤除外状态且可以特殊召唤的怪兽。
function s.spfilter(c,e,tp)
	return c:IsFaceupEx() and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP)
end
-- ①效果的发动准备与合法性检测，包括判断是否满足特殊召唤的怪兽区域和除外区目标。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and s.spfilter(chkc,e,tp) end
	-- 检查自己场上是否有空余的怪兽区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查双方除外状态中是否存在至少1只可以特殊召唤的怪兽。
		and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_REMOVED,LOCATION_REMOVED,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择双方除外状态的1只怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_REMOVED,LOCATION_REMOVED,1,1,nil,e,tp)
	-- 设置连锁信息，表示该效果包含特殊召唤1张卡的操作。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- ①效果的处理：将作为对象的除外怪兽在自己场上特殊召唤。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果发动的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() then
		-- 将目标怪兽以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- ②效果的发动条件：自己或对方的主要阶段。
function s.rmcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前是否为主要阶段。
	return Duel.IsMainPhase()
end
-- 过滤墓地中可以作为除外Cost的怪兽卡。
function s.cfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
end
-- ②效果的Cost处理：从自己墓地将1只怪兽除外。
function s.rmcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己墓地是否存在至少1只可以除外的怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 玩家选择自己墓地中的1只怪兽。
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将选中的墓地怪兽除外作为发动Cost。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 过滤场上表侧表示且可以被效果除外的卡。
function s.rmfilter(c)
	return c:IsFaceup() and c:IsAbleToRemove()
end
-- ②效果的目标选择：选择场上1只其他的表侧表示怪兽。
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc~=e:GetHandler() and chkc:IsLocation(LOCATION_MZONE) and s.rmfilter(chkc) end
	-- 检查场上是否存在除自身以外的表侧表示怪兽。
	if chk==0 then return Duel.IsExistingTarget(s.rmfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,e:GetHandler()) end
	-- 提示玩家选择要除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择场上1只其他的表侧表示怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,s.rmfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,e:GetHandler())
	-- 设置连锁信息，表示该效果包含除外1张卡的操作。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- ②效果的处理：将对象怪兽除外，之后回复其原本攻击力数值的生命值。
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的怪兽。
	local tc=Duel.GetFirstTarget()
	-- 检查对象怪兽是否仍存在于连锁中，若是怪兽则将其除外，并判断是否成功除外。
	if tc:IsRelateToChain() and tc:IsType(TYPE_MONSTER) and Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)>0
		and tc:IsLocation(LOCATION_REMOVED) then
		local atk=tc:GetTextAttack()
		if atk>0 then
			-- 中断当前效果，使后续的回复生命值处理不与除外同时进行。
			Duel.BreakEffect()
			-- 回复自身等同于被除外怪兽原本攻击力数值的生命值。
			Duel.Recover(tp,atk,REASON_EFFECT)
		end
	end
end
