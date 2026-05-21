--バグリエル・ド・ヌーベルズ
-- 效果：
-- 「食谱」卡降临。这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡特殊召唤成功的场合才能发动。对方场上的全部表侧表示的卡的效果直到回合结束时无效。「新式魔厨」怪兽的效果特殊召唤的场合，再把对方场上的怪兽尽可能解放。
-- ②：自己·对方回合，以对方场上1只攻击表示怪兽为对象才能发动。那只怪兽解放，从手卡·卡组把1只「饥饿的汉堡」特殊召唤。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含仪式召唤限制、①效果（特殊召唤成功时无效对方场上卡片并可能解放怪兽）和②效果（二速解放对方攻击表示怪兽特召「饥饿的汉堡」）。
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- ①：这张卡特殊召唤成功的场合才能发动。对方场上的全部表侧表示的卡的效果直到回合结束时无效。「新式魔厨」怪兽的效果特殊召唤的场合，再把对方场上的怪兽尽可能解放。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"对方卡无效"
	e1:SetCategory(CATEGORY_DISABLE+CATEGORY_RELEASE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	-- ②：自己·对方回合，以对方场上1只攻击表示怪兽为对象才能发动。那只怪兽解放，从手卡·卡组把1只「饥饿的汉堡」特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"从手卡·卡组特殊召唤"
	e2:SetCategory(CATEGORY_RELEASE+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
-- ①效果的发动准备与合法性检查函数，判断对方场上是否有可无效的卡，并记录此卡是否由「新式魔厨」怪兽效果特殊召唤。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方场上是否存在至少1张可以被无效的表侧表示卡片。
	if chk==0 then return Duel.IsExistingMatchingCard(aux.NegateAnyFilter,tp,0,LOCATION_ONFIELD,1,nil) end
	local c=e:GetHandler()
	local res=c:GetSpecialSummonInfo(SUMMON_INFO_TYPE)&TYPE_MONSTER~=0 and c:IsSpecialSummonSetCard(0x196) and 1 or 0
	e:SetLabel(res)
	-- 获取对方场上所有可以被无效的表侧表示卡片。
	local g=Duel.GetMatchingGroup(aux.NegateAnyFilter,tp,0,LOCATION_ONFIELD,nil)
	-- 设置连锁信息，表示该效果包含使对方场上所有表侧表示卡片效果无效的操作。
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,g:GetCount(),0,0)
end
-- ①效果的处理函数，使对方场上所有表侧表示卡片的效果无效，若是由「新式魔厨」怪兽效果特殊召唤的，则再将对方场上的怪兽尽可能解放。
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前对方场上所有可以被无效的表侧表示卡片。
	local g=Duel.GetMatchingGroup(aux.NegateAnyFilter,tp,0,LOCATION_ONFIELD,nil)
	if #g==0 then return end
	-- 遍历获取到的对方场上所有可无效的卡片。
	for tc in aux.Next(g) do
		-- 使与目标卡片相关的连锁无效化。
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		-- 对方场上的全部表侧表示的卡的效果直到回合结束时无效。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		tc:RegisterEffect(e2)
	end
	-- 立即刷新场上受影响卡片的无效状态。
	Duel.AdjustInstantly(c)
	-- 获取对方场上所有可以被效果解放的怪兽。
	local rg=Duel.GetMatchingGroup(Card.IsReleasableByEffect,tp,0,LOCATION_MZONE,nil)
	if e:GetLabel()>0 and #rg>0 then
		-- 中断当前效果处理，使后续的解放处理与无效处理不视为同时进行。
		Duel.BreakEffect()
		-- 将对方场上可以被效果解放的怪兽全部解放。
		Duel.Release(rg,REASON_EFFECT)
	end
end
-- 过滤条件：对方场上可以被效果解放的攻击表示怪兽。
function s.relfilter(c)
	return c:IsReleasableByEffect() and c:IsAttackPos()
end
-- 过滤条件：卡名为「饥饿的汉堡」且可以无视召唤条件特殊召唤的怪兽。
function s.spfilter(c,e,tp)
	return c:IsCode(30243636) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
-- ②效果的发动准备与目标选择函数，检查自己场上是否有空位、对方场上是否有可解放的攻击表示怪兽、手卡或卡组是否有「饥饿的汉堡」。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and s.relfilter(chkc) end
	-- 检查自己场上是否有可用于特殊召唤的怪兽区域空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查对方场上是否存在可以作为效果对象的攻击表示怪兽。
		and Duel.IsExistingTarget(s.relfilter,tp,0,LOCATION_MZONE,1,nil)
		-- 检查自己的手卡或卡组中是否存在可以特殊召唤的「饥饿的汉堡」。
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) end
	-- 提示玩家选择要解放的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	-- 让玩家选择对方场上1只攻击表示怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,s.relfilter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置连锁信息，表示该效果包含解放目标怪兽的操作。
	Duel.SetOperationInfo(0,CATEGORY_RELEASE,g,1,0,0)
	-- 设置连锁信息，表示该效果包含从手卡或卡组特殊召唤1只怪兽的操作。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- ②效果的处理函数，解放作为对象的怪兽，并从手卡或卡组特殊召唤1只「饥饿的汉堡」。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在发动时选择的作为对象的怪兽。
	local tc=Duel.GetFirstTarget()
	-- 检查对象怪兽是否仍适用此效果，将其解放，若解放成功且自己场上有空位，则继续处理。
	if tc:IsRelateToEffect(e) and Duel.Release(tc,REASON_EFFECT)~=0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 提示玩家选择要特殊召唤的怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从手卡或卡组选择1只「饥饿的汉堡」。
		local tc=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp):GetFirst()
		if tc then
			-- 将选择的「饥饿的汉堡」无视召唤条件表侧表示特殊召唤。
			Duel.SpecialSummon(tc,0,tp,tp,true,false,POS_FACEUP)
		end
	end
end
