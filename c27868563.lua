--百鬼羅刹 神速ブーン
-- 效果：
-- ①：这张卡在手卡·墓地存在的场合，自己·对方的主要阶段才能发动。场上1个超量素材取除，这张卡特殊召唤。这个效果的发动后，直到下个回合的结束时自己不能把「百鬼罗刹 神速布恩」特殊召唤。
function c27868563.initial_effect(c)
	-- ①：这张卡在手卡·墓地存在的场合，自己·对方的主要阶段才能发动。场上1个超量素材取除，这张卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(27868563,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e1:SetCountLimit(1,EFFECT_COUNT_CODE_CHAIN)
	e1:SetCondition(c27868563.spcon)
	e1:SetTarget(c27868563.sptg)
	e1:SetOperation(c27868563.spop)
	c:RegisterEffect(e1)
end
-- 效果发动条件判定：检查当前回合阶段是否为主要阶段1或主要阶段2，以符合“自己·对方的主要阶段才能发动”的限制。
function c27868563.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前游戏阶段并保存到ph变量，用于随后判断是否为允许发动的主要阶段。
	local ph=Duel.GetCurrentPhase()
	return ph==PHASE_MAIN1 or ph==PHASE_MAIN2
end
-- 效果发动时的合法性检查：确认场上有可取除的超量素材、自己场上有特殊召唤空位、且此卡满足特殊召唤条件。
function c27868563.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动判定（chk==0）时，检查自己能否以效果原因取除场上1个超量素材，以及自己主要怪兽区是否有空位。
	if chk==0 then return Duel.CheckRemoveOverlayCard(tp,1,1,1,REASON_EFFECT) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 将本次连锁要进行的处理登记为特殊召唤，并指定对象为此效果的处理卡（即这张卡本身）数量为1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理阶段：取除场上1个超量素材，成功且该卡仍与效果关联时将其特殊召唤；随后给控制者附加直到下个回合结束不能特殊召唤「百鬼罗刹 神速布恩」的自肃效果。
function c27868563.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 执行取除场上1个超量素材，并确认此卡是否仍然与发动时的效果保持关联（未因离场而失效）。
	if Duel.RemoveOverlayCard(tp,1,1,1,1,REASON_EFFECT)~=0 and c:IsRelateToEffect(e) then
		-- 将此卡以表侧表示特殊召唤到控制者的场上。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
	-- 这个效果的发动后，直到下个回合的结束时自己不能把「百鬼罗刹 神速布恩」特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c27868563.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END,2)
	-- 将上述自肃效果注册给当前玩家，使其在下个回合结束前持续适用。
	Duel.RegisterEffect(e1,tp)
end
-- 判断被特殊召唤的怪兽是否为「百鬼罗刹 神速布恩」，若是则不允许其特殊召唤。
function c27868563.splimit(e,c)
	return c:IsCode(27868563)
end
