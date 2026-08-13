--潜伏するG
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：对方对怪兽的特殊召唤成功时才能发动。这张卡从手卡里侧守备表示特殊召唤。这个效果特殊召唤的这张卡在这个回合的结束阶段变成表侧守备表示。
-- ②：这张卡在结束阶段反转的场合发动。场上的特殊召唤的怪兽全部破坏。
local s,id,o=GetID()
-- 定义卡片的初始效果注册函数：创建并注册①和②两个效果，①从手卡里侧守备特殊召唤并在结束阶段表侧守备，②在结束阶段反转时破坏场上所有特殊召唤怪兽。
function s.initial_effect(c)
	-- 这个卡名的①的效果1回合只能使用1次。①：对方对怪兽的特殊召唤成功时才能发动。这张卡从手卡里侧守备表示特殊召唤。这个效果特殊召唤的这张卡在这个回合的结束阶段变成表侧守备表示。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_MSET)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡在结束阶段反转的场合发动。场上的特殊召唤的怪兽全部破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_FLIP)
	e2:SetCondition(s.descon)
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
end
-- 检查这次特殊召唤成功的怪兽中是否存在由对方玩家特殊召唤的怪兽，以满足“对方对怪兽的特殊召唤成功时”的发动条件。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsSummonPlayer,1,nil,1-tp)
end
-- 发动时合法性判定：自己场上有可用的主要怪兽区域，且这张卡能够被里侧守备表示特殊召唤。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查自己场上主要怪兽区域是否有空位，若无空位则①效果不能发动。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE) end
	-- 向系统登记本次效果处理将进行特殊召唤操作，对象为这张卡，数量为1，供连锁判定与相关效果检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- ①效果处理：若此卡仍与连锁关联，则将其以里侧守备表示特殊召唤；成功后向对方展示此卡，给它打上特殊召唤标记，并注册一个结束阶段翻转效果，最后完成特殊召唤处理。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 确认这张卡仍与当前连锁有联系（未被移除或无效），并尝试将其以里侧守备表示特殊召唤，成功则执行后续处理。
	if c:IsRelateToChain() and Duel.SpecialSummonStep(c,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE) then
		-- 向对方玩家展示这张卡，使其确认被特殊召唤的是这张卡。
		Duel.ConfirmCards(1-tp,c)
		c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1)
		-- 这个效果特殊召唤的这张卡在这个回合的结束阶段变成表侧守备表示。②：这张卡在结束阶段反转的场合发动。场上的特殊召唤的怪兽全部破坏。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetLabelObject(c)
		e1:SetOperation(s.flipup)
		e1:SetReset(RESET_PHASE+PHASE_END)
		-- 将结束阶段翻转效果注册到当前玩家，使其在本回合结束阶段触发翻转。
		Duel.RegisterEffect(e1,tp)
	end
	-- 完成特殊召唤处理，宣告这组特殊召唤成功并触发相关时点。
	Duel.SpecialSummonComplete()
end
-- 结束阶段翻转效果的处理：若该卡仍带有①效果的特殊召唤标记，则将其变为表侧守备表示；此翻转同时满足②的发动条件，随后重置该效果。
function s.flipup(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetLabelObject()
	-- 检查这张卡是否仍带有①效果给予的标记，若是则将其从里侧守备表示改为表侧守备表示。
	if c:GetFlagEffect(id)>0 then Duel.ChangePosition(c,POS_FACEUP_DEFENSE) end
	e:Reset()
end
-- ②效果的发动条件：仅在当前阶段为结束阶段时才允许发动。
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前是否为结束阶段，是则满足②效果的发动时机。
	return Duel.GetCurrentPhase()==PHASE_END
end
-- ②效果发动时：登记破坏对象为场上所有特殊召唤怪兽（双方），并设置破坏信息，不取对象。
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取双方场上所有通过特殊召唤方式出场的怪兽，作为②效果可能破坏的对象集合。
	local g=Duel.GetMatchingGroup(Card.IsSummonType,tp,LOCATION_MZONE,LOCATION_MZONE,nil,SUMMON_TYPE_SPECIAL)
	-- 向系统登记本次效果处理将破坏这些特殊召唤怪兽以及数量，用于连锁检测。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end
-- ②效果处理：重新获取场上所有特殊召唤怪兽并全部破坏，实际破坏以处理时的场况为准。
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取双方场上所有特殊召唤怪兽的集合。
	local g=Duel.GetMatchingGroup(Card.IsSummonType,tp,LOCATION_MZONE,LOCATION_MZONE,nil,SUMMON_TYPE_SPECIAL)
	-- 将获取到的所有特殊召唤怪兽以效果原因全部破坏。
	Duel.Destroy(g,REASON_EFFECT)
end
