--アーティファクト－ダグザ
-- 效果：
-- 卡名不同的怪兽2只
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡以外的场上的卡的效果发动时才能发动。从手卡·卡组选1只「古遗物」怪兽当作魔法卡使用在自己的魔法与陷阱区域盖放。这个效果盖放的卡在下次的对方结束阶段破坏。
-- ②：连接召唤的这张卡在对方回合被破坏的场合才能发动。从自己墓地选1只「古遗物」怪兽守备表示特殊召唤。
function c7480763.initial_effect(c)
	-- 为卡片添加连接召唤手续，需要2只怪兽作为素材，且素材需满足lcheck过滤条件（卡名不同）。
	aux.AddLinkProcedure(c,nil,2,2,c7480763.lcheck)
	c:EnableReviveLimit()
	-- ①：这张卡以外的场上的卡的效果发动时才能发动。从手卡·卡组选1只「古遗物」怪兽当作魔法卡使用在自己的魔法与陷阱区域盖放。这个效果盖放的卡在下次的对方结束阶段破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(7480763,0))
	e1:SetCategory(CATEGORY_SSET)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,7480763)
	e1:SetCondition(c7480763.stcon)
	e1:SetTarget(c7480763.sttg)
	e1:SetOperation(c7480763.stop)
	c:RegisterEffect(e1)
	-- ②：连接召唤的这张卡在对方回合被破坏的场合才能发动。从自己墓地选1只「古遗物」怪兽守备表示特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(7480763,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,7480764)
	e2:SetCondition(c7480763.spcon)
	e2:SetTarget(c7480763.sptg)
	e2:SetOperation(c7480763.spop)
	c:RegisterEffect(e2)
end
-- 连接素材的过滤条件：用于检测选取的连接素材卡名是否各不相同。
function c7480763.lcheck(g,lc)
	return g:GetClassCount(Card.GetLinkCode)==g:GetCount()
end
-- 效果①的发动条件函数：检测是否有这张卡以外的场上的卡的效果发动。
function c7480763.stcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查触发连锁的效果发动位置是否在场上，且发动效果的卡不是这张卡自身。
	return bit.band(Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION),LOCATION_ONFIELD)~=0 and re:GetHandler()~=e:GetHandler()
end
-- 效果①的过滤条件：检索手卡或卡组中可以盖放的「古遗物」怪兽卡。
function c7480763.stfilter(c)
	return c:IsSetCard(0x97) and c:IsType(TYPE_MONSTER) and c:IsSSetable()
end
-- 效果①的发动目标函数：检测手卡或卡组中是否存在至少1只可盖放的「古遗物」怪兽。
function c7480763.sttg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡或卡组中是否存在至少1张满足过滤条件的「古遗物」怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c7480763.stfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil) end
end
-- 效果①的效果处理函数：从手卡或卡组选1只「古遗物」怪兽在魔陷区盖放，并注册在下次对方结束阶段将其破坏的延迟效果。
function c7480763.stop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要盖放的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 让玩家从手卡或卡组选择1张满足过滤条件的「古遗物」怪兽。
	local g=Duel.SelectMatchingCard(tp,c7480763.stfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的怪兽当作魔法卡在自己的魔法与陷阱区域盖放。
		local ct=Duel.SSet(tp,g)
		if ct~=0 then
			local tc=g:GetFirst()
			-- 这个效果盖放的卡在下次的对方结束阶段破坏。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e1:SetCode(EVENT_PHASE+PHASE_END)
			e1:SetCountLimit(1)
			e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
			e1:SetLabelObject(tc)
			e1:SetCondition(c7480763.descon)
			e1:SetOperation(c7480763.desop)
			-- 判断当前是否已经是对方回合的结束阶段（如果是，则需要将破坏时点延后到下一次对方的结束阶段）。
			if Duel.GetTurnPlayer()==1-tp and Duel.GetCurrentPhase()==PHASE_END then
				e1:SetReset(RESET_PHASE+PHASE_END+RESET_OPPO_TURN,2)
				-- 将当前回合数记录在效果的Value中，用于后续判断是否是“下次”对方结束阶段。
				e1:SetValue(Duel.GetTurnCount())
				tc:RegisterFlagEffect(7480763,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_OPPO_TURN,0,2)
			else
				e1:SetReset(RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
				e1:SetValue(0)
				tc:RegisterFlagEffect(7480763,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_OPPO_TURN,0,1)
			end
			-- 注册该全局时点效果，用于在对方结束阶段执行破坏处理。
			Duel.RegisterEffect(e1,tp)
		end
	end
end
-- 延迟破坏效果的发动条件函数：检测是否为对方回合的结束阶段，且不是盖放当回合的结束阶段，并且该卡仍带有标记。
function c7480763.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 如果当前不是对方回合，或者当前回合数等于盖放时的回合数（即盖放当回合的对方结束阶段），则不满足破坏条件。
	if Duel.GetTurnPlayer()~=1-tp or Duel.GetTurnCount()==e:GetValue() then return false end
	return e:GetLabelObject():GetFlagEffect(7480763)~=0
end
-- 延迟破坏效果的处理函数：将盖放的卡破坏。
function c7480763.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 因效果将目标卡片破坏。
	Duel.Destroy(e:GetLabelObject(),REASON_EFFECT)
end
-- 效果②的发动条件函数：检测这张卡是否是连接召唤且在对方回合从怪兽区被破坏。
function c7480763.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查当前是否为对方回合，且这张卡之前在怪兽区域，并且是以连接召唤的方式登场。
	return Duel.GetTurnPlayer()==1-tp and c:IsSummonType(SUMMON_TYPE_LINK) and c:IsPreviousLocation(LOCATION_MZONE)
end
-- 效果②的过滤条件：检索墓地中可以守备表示特殊召唤的「古遗物」怪兽。
function c7480763.spfilter(c,e,tp)
	return c:IsSetCard(0x97) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 效果②的发动目标函数：检测自身怪兽区域是否有空位，且墓地中是否存在可特殊召唤的「古遗物」怪兽，并设置特殊召唤的操作信息。
function c7480763.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用于特殊召唤的怪兽区域空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并且检查自己墓地中是否存在至少1只满足过滤条件的「古遗物」怪兽。
		and Duel.IsExistingMatchingCard(c7480763.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置连锁处理的操作信息，表明此效果包含从墓地特殊召唤1只怪兽的操作。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
-- 效果②的效果处理函数：从自己墓地选择1只「古遗物」怪兽守备表示特殊召唤。
function c7480763.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否有可用的怪兽区域空位，若无则不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己墓地选择1张满足过滤条件且不受「王家之谷」影响的「古遗物」怪兽。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c7480763.spfilter),tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧守备表示特殊召唤到自己场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
