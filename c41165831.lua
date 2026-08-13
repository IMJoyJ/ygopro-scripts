--破械神シャバラ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡在手卡存在的场合，自己·对方的主要阶段，以自己场上1只恶魔族怪兽或1张里侧表示卡为对象才能发动。那张卡破坏，这张卡特殊召唤。只要这个效果特殊召唤的这张卡在怪兽区域表侧表示存在，自己不是恶魔族怪兽不能特殊召唤。
-- ②：这张卡被送去墓地的场合才能发动。从卡组把1张「破械」魔法·陷阱卡在自己场上盖放。
function c41165831.initial_effect(c)
	-- 这个卡名的①②的效果1回合各能使用1次。①：这张卡在手卡存在的场合，自己·对方的主要阶段，以自己场上1只恶魔族怪兽或1张里侧表示卡为对象才能发动。那张卡破坏，这张卡特殊召唤。只要这个效果特殊召唤的这张卡在怪兽区域表侧表示存在，自己不是恶魔族怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e1:SetCountLimit(1,41165831)
	e1:SetCondition(c41165831.spdcon)
	e1:SetTarget(c41165831.spdtg)
	e1:SetOperation(c41165831.spdop)
	c:RegisterEffect(e1)
	-- ②：这张卡被送去墓地的场合才能发动。从卡组把1张「破械」魔法·陷阱卡在自己场上盖放。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCategory(CATEGORY_SSET)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,41165832)
	e2:SetTarget(c41165831.settg)
	e2:SetOperation(c41165831.setop)
	c:RegisterEffect(e2)
end
-- 效果发动条件：当前阶段为双方的主要阶段（主要阶段1或主要阶段2），满足①效果的发动时点。
function c41165831.spdcon(e,tp,eg,ep,ev,re,r,rp)
	-- 当前阶段为主要阶段1或主要阶段2时才允许发动。
	return Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2
end
-- 选择对象的过滤条件：自己场上的表侧表示恶魔族怪兽或里侧表示卡，且该卡被破坏后自己场上仍有可用的怪兽区域。
function c41165831.desfilter(c,tp)
	return (c:IsLocation(LOCATION_MZONE) and c:IsFaceup() and c:IsRace(RACE_FIEND) or c:IsFacedown())
		-- 破坏该对象后自己场上仍有可用的怪兽区域，保证后续可以特殊召唤这张卡。
		and Duel.GetMZoneCount(tp,c)>0
end
-- ①效果发动时的目标选择处理：确认手牌的这张卡可以特殊召唤，并选择自己场上1只恶魔族怪兽或1张里侧表示卡作为效果对象。
function c41165831.spdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsOnField() and chkc:IsControler(tp) and c41165831.desfilter(chkc,tp) end
	if chk==0 then return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 场上存在至少1张满足条件的对象卡可供选择。
		and Duel.IsExistingTarget(c41165831.desfilter,tp,LOCATION_ONFIELD,0,1,nil,tp) end
	-- 向操作者弹出“请选择要破坏的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择1张符合条件的卡作为效果对象，并将该卡登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,c41165831.desfilter,tp,LOCATION_ONFIELD,0,1,1,nil,tp)
	-- 登记连锁操作信息：本次效果将破坏1张对象卡。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 登记连锁操作信息：本次效果将特殊召唤手牌的这张卡。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- ①效果处理：破坏对象卡；若对象卡被破坏且这张卡仍与效果关联，则将其从手牌特殊召唤；特殊召唤成功后为自己附加只能特殊召唤恶魔族怪兽的自肃效果。
function c41165831.spdop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果发动时选择的对象卡（要破坏的卡）。
	local tc=Duel.GetFirstTarget()
	-- 若对象卡仍与效果关联，则将其破坏；只有实际破坏成功才继续处理。
	if tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)~=0
		-- 若这张卡仍与效果关联，则将其从手牌特殊召唤到自己场上；特殊召唤成功后才继续附加自肃效果。
		and c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- 只要这个效果特殊召唤的这张卡在怪兽区域表侧表示存在，自己不是恶魔族怪兽不能特殊召唤。②：这张卡被送去墓地的场合才能发动。从卡组把1张「破械」魔法·陷阱卡在自己场上盖放。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetRange(LOCATION_MZONE)
		e1:SetAbsoluteRange(tp,1,0)
		e1:SetTarget(c41165831.splimit)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1,true)
	end
end
-- 自肃过滤函数：不是恶魔族怪兽的怪兽不能特殊召唤。
function c41165831.splimit(e,c)
	return not c:IsRace(RACE_FIEND)
end
-- ②效果检索的过滤条件：卡组中的「破械」魔法·陷阱卡，且该卡可以被盖放。
function c41165831.setfilter(c)
	return c:IsSetCard(0x130) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSSetable()
end
-- ②效果发动时的条件判断：卡组中是否存在满足条件的「破械」魔法·陷阱卡。
function c41165831.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动确认时，检查卡组中是否有可以盖放的「破械」魔法·陷阱卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c41165831.setfilter,tp,LOCATION_DECK,0,1,nil) end
end
-- ②效果处理：从卡组选择1张「破械」魔法·陷阱卡盖放到自己场上。
function c41165831.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 向操作者弹出“请选择要盖放的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 从卡组选择1张符合条件的「破械」魔法·陷阱卡。
	local g=Duel.SelectMatchingCard(tp,c41165831.setfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		-- 将选择的卡以里侧表示盖放到自己的魔法·陷阱区域。
		Duel.SSet(tp,g)
	end
end
