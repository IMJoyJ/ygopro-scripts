--スターダスト・ドラゴン／バスター
-- 效果：
-- 这张卡不能通常召唤，用「爆裂模式」的效果（以及这张卡的②的效果）才能特殊召唤。
-- ①：魔法·陷阱·怪兽的效果发动时，把这张卡解放才能发动。那个发动无效并破坏。
-- ②：这张卡的①的效果适用的回合的结束阶段才能发动。为那个效果发动而解放的这张卡从墓地特殊召唤。
-- ③：场上的这张卡被破坏时，以自己墓地1只「星尘龙」为对象才能发动。那只怪兽特殊召唤。
function c61257789.initial_effect(c)
	-- 注册卡片记有「爆裂模式」和「星尘龙」的卡名。
	aux.AddCodeList(c,80280737,44508094)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤，用「爆裂模式」的效果（以及这张卡的②的效果）才能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(c61257789.splimit)
	c:RegisterEffect(e1)
	-- ①：魔法·陷阱·怪兽的效果发动时，把这张卡解放才能发动。那个发动无效并破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(61257789,0))  --"效果发动无效并破坏"
	e2:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c61257789.negcon)
	e2:SetCost(c61257789.negcost)
	e2:SetTarget(c61257789.negtg)
	e2:SetOperation(c61257789.negop)
	c:RegisterEffect(e2)
	-- ②：这张卡的①的效果适用的回合的结束阶段才能发动。为那个效果发动而解放的这张卡从墓地特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(61257789,1))  --"特殊召唤"
	e3:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_FIELD)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1)
	e3:SetTarget(c61257789.sumtg)
	e3:SetOperation(c61257789.sumop)
	c:RegisterEffect(e3)
	-- ③：场上的这张卡被破坏时，以自己墓地1只「星尘龙」为对象才能发动。那只怪兽特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(61257789,2))  --"特殊召唤「星尘龙」"
	e4:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetCode(EVENT_DESTROYED)
	e4:SetCondition(c61257789.spcon)
	e4:SetTarget(c61257789.sptg)
	e4:SetOperation(c61257789.spop)
	c:RegisterEffect(e4)
end
c61257789.assault_name=44508094
-- 定义特殊召唤限制的条件函数。
function c61257789.splimit(e,se,sp,st)
	-- 限制只能通过「爆裂模式」的效果或者自身的效果进行特殊召唤。
	return aux.AssaultModeLimit(e,se,sp,st) or se:GetHandler()==e:GetHandler()
end
-- 定义无效效果发动的发动条件函数。
function c61257789.negcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自身未被战斗破坏，且当前连锁的效果可以被无效。
	return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and Duel.IsChainNegatable(ev)
end
-- 定义无效效果发动的发动代价（Cost）函数。
function c61257789.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 解放自身作为发动的代价。
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 定义无效效果发动的效果目标（Target）确定函数。
function c61257789.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置效果处理信息为“使该连锁的发动无效”。
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 若发动的卡可以被破坏，则设置效果处理信息为“破坏该卡”。
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 定义无效效果发动的效果处理（Operation）函数。
function c61257789.negop(e,tp,eg,ep,ev,re,r,rp)
	-- 若成功使该连锁的发动无效，且该卡在场上/原区域存在。
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re)then
		-- 破坏该发动无效的卡。
		Duel.Destroy(eg,REASON_EFFECT)
	end
	e:GetHandler():RegisterFlagEffect(61257789,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,0)
end
-- 定义自身特殊召唤效果的发动目标（Target）确定函数。
function c61257789.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查怪兽区域是否有空位，且本回合自身已适用过①的效果（带有对应的标记）。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:GetFlagEffect(61257789)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置效果处理信息为“将自身特殊召唤”。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 定义自身特殊召唤效果的效果处理（Operation）函数。
function c61257789.sumop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		-- 将墓地的自身以表侧表示特殊召唤。
		Duel.SpecialSummon(e:GetHandler(),0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 定义特殊召唤「星尘龙」效果的发动条件函数（检查是否从场上被破坏）。
function c61257789.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 过滤出墓地中可以特殊召唤的「星尘龙」的过滤函数。
function c61257789.spfilter(c,e,tp)
	return c:IsCode(44508094) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 定义特殊召唤「星尘龙」效果的发动目标（Target）确定函数。
function c61257789.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c61257789.spfilter(chkc,e,tp) end
	-- 检查怪兽区域是否有空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在可以作为效果对象的「星尘龙」。
		and Duel.IsExistingTarget(c61257789.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只「星尘龙」作为效果对象。
	local g=Duel.SelectTarget(tp,c61257789.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置效果处理信息为“将选择的对象特殊召唤”。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 定义特殊召唤「星尘龙」效果的效果处理（Operation）函数。
function c61257789.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果处理时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将选择的对象怪兽表侧表示特殊召唤。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
