--W：Pファンシーボール
-- 效果：
-- 效果怪兽2只以上
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：对方把场上·墓地的怪兽的效果发动时，把这个回合特殊召唤的这张卡直到结束阶段除外才能发动。那个效果无效并除外。
-- ②：对方主要阶段才能发动（双方不能对应这个发动把连接怪兽的效果发动）。进行1只连接怪兽的连接召唤。把自己场上的这张卡作为连接素材的场合，对方场上1只连接2以下的连接怪兽也能作为连接素材。
local s,id,o=GetID()
-- 初始化卡片效果，设置连接召唤手续，并注册2个效果：场上/墓地怪兽效果发动时将其无效并除外的诱发即时效果（效果①）、对方主要阶段进行连接召唤且可使用对方连接怪兽为素材的二速效果（效果②）。
function s.initial_effect(c)
	-- 设置连接召唤的素材要求：效果怪兽2只以上。
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkType,TYPE_EFFECT),2)
	c:EnableReviveLimit()
	-- ①：对方把场上·墓地的怪兽的效果发动时，把这个回合特殊召唤的这张卡直到结束阶段除外才能发动。那个效果无效并除外。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"无效"
	e1:SetCategory(CATEGORY_DISABLE+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.discon)
	e1:SetCost(s.discost)
	e1:SetTarget(s.distg)
	e1:SetOperation(s.disop)
	c:RegisterEffect(e1)
	-- ②：对方主要阶段才能发动（双方不能对应这个发动把连接怪兽的效果发动）。进行1只连接怪兽的连接召唤。把自己场上的这张卡作为连接素材的场合，对方场上1只连接2以下的连接怪兽也能作为连接素材。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"连接召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.lkcon)
	e2:SetTarget(s.lktg)
	e2:SetOperation(s.lkop)
	c:RegisterEffect(e2)
end
-- 效果①的发动条件判断函数：判断是否是对方玩家发动场上或墓地怪兽的效果，且该效果是可以被无效的。
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取触发效果发生的位置。
	local loc=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)
	return ep~=tp and (LOCATION_ONFIELD+LOCATION_GRAVE)&loc~=0
		-- 判断发动效果的是否是怪兽且该效果可以被无效。
		and re:IsActiveType(TYPE_MONSTER) and Duel.IsChainDisablable(ev)
end
-- 效果①的cost检测与处理函数：检查自身在当前回合是否为特殊召唤状态、是否可以被除外。在发动时，将自身暂时除外，并注册一个在结束阶段将自身返回场上的效果。
function s.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsStatus(STATUS_SPSUMMON_TURN) and c:IsAbleToRemoveAsCost() end
	-- 判断除外是否成功，且卡片的原始卡号是否匹配。
	if Duel.Remove(c,0,REASON_COST+REASON_TEMPORARY)~=0 and c:GetOriginalCode()==id then
		c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,2))  --"直到结束阶段除外"
		-- 在全局注册在当前回合结束阶段将自身返回场上的延迟效果。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetReset(RESET_PHASE+PHASE_END)
		e1:SetLabelObject(c)
		e1:SetCountLimit(1)
		e1:SetOperation(s.retop)
		-- 将临时效果注册给当前玩家。
		Duel.RegisterEffect(e1,tp)
	end
end
-- 结束阶段将除外状态的自身返回场上的延迟效果的实际处理函数。
function s.retop(e,tp,eg,ep,ev,re,r,rp)
	-- 将由于自身cost暂时除外的此卡返回场上。
	Duel.ReturnToField(e:GetLabelObject())
end
-- 效果①的靶向检测函数：判断被无效的效果是否满足“无效并除外”的规则判定条件，并设置无效和除外的操作信息。
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否能够满足无效并除外的条件限制。
	if chk==0 then return aux.nbcon(tp,re) end
	-- 设置使连锁效果无效的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
	if re:GetHandler():IsRelateToEffect(re) then
		-- 设置除外操作的操作信息。
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,eg,1,0,0)
	end
	if re:GetActivateLocation()==LOCATION_GRAVE then
		e:SetCategory(e:GetCategory()|CATEGORY_GRAVE_ACTION)
	else
		e:SetCategory(e:GetCategory()&~CATEGORY_GRAVE_ACTION)
	end
end
-- 效果①的实际处理函数：使对方发动的效果无效，并把该卡除外。
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否成功使对方效果无效，以及对方的卡片是否仍关联于该连锁。
	if Duel.NegateEffect(ev) and re:GetHandler():IsRelateToChain(ev) then
		-- 将对应怪兽卡片表侧表示除外。
		Duel.Remove(eg,POS_FACEUP,REASON_EFFECT)
	end
end
-- 效果②的发动条件判断函数：必须在对方回合的主要阶段才能发动。
function s.lkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 限制在对方回合的主要阶段才能发动。
	return Duel.GetTurnPlayer()~=tp and Duel.IsMainPhase()
end
-- 过滤函数：用于判断卡片是否可以被连接召唤。
function s.lkfilter(c)
	return c:IsLinkSummonable(nil)
end
-- 限制条件过滤函数：选择自己场上表侧表示且连接2以下的怪兽。
function s.mattg(e,c)
	return c:IsFaceup() and c:IsLinkBelow(2)
end
-- 效果②的靶向检测函数：注册一个临时的允许将对方怪兽作为连接素材的效果，检测在这一规则修改下己方是否能够进行任何怪兽的连接召唤。若能，则设置连接召唤的操作信息，并设置连锁限制。
function s.lktg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local fid=c:GetFieldID()
	-- 在全局注册允许将符合条件的对方怪兽作为连接素材的临时效果，若符合则在chktg中判断是否可以连接召唤，并在完成后重置。
	local le=Effect.CreateEffect(c)
	le:SetType(EFFECT_TYPE_FIELD)
	le:SetCode(EFFECT_EXTRA_LINK_MATERIAL)
	le:SetTargetRange(0,LOCATION_MZONE)
	le:SetLabel(fid)
	le:SetLabelObject(c)
	le:SetTarget(s.mattg)
	le:SetValue(s.matval)
	-- 注册临时材料效果给当前玩家。
	Duel.RegisterEffect(le,tp)
	-- 检索额外卡组中是否存在满足此时连接召唤条件的怪兽。
	local res=Duel.IsExistingMatchingCard(s.lkfilter,tp,LOCATION_EXTRA,0,1,nil)
	le:Reset()
	c:ResetFlagEffect(id)
	if chk==0 then return res end
	-- 设置特殊召唤的操作信息，预计进行1次特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
	-- 设置连锁限制，防止双方对应这个发动把连接怪兽的效果发动。
	Duel.SetChainLimit(s.chainlm)
end
-- 连锁限制判定函数：若所发动的效果是连接怪兽的效果，则限制其不能连锁。
function s.chainlm(e,rp,tp)
	return not e:GetHandler():IsAllTypes(TYPE_LINK+TYPE_MONSTER)
end
-- 效果②的实际处理函数：再次注册允许将符合条件的对方怪兽作为连接素材的效果，并让玩家从额外卡组选择1只满足连接召唤条件的怪兽，以场上的怪兽为素材进行连接召唤。
function s.lkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() and c:IsControler(tp) and c:IsFaceup() then
		local fid=c:GetFieldID()
		-- 在全局注册允许将符合条件的对方怪兽作为连接素材的临时效果，该效果在当前主要阶段内有效，并执行连接召唤的后续处理。
		local le=Effect.CreateEffect(c)
		le:SetType(EFFECT_TYPE_FIELD)
		le:SetCode(EFFECT_EXTRA_LINK_MATERIAL)
		le:SetTargetRange(0,LOCATION_MZONE)
		le:SetLabel(fid)
		le:SetLabelObject(c)
		le:SetTarget(s.mattg)
		le:SetValue(s.matval)
		le:SetReset(RESET_PHASE+PHASE_MAIN1+PHASE_MAIN2)
		-- 在全局注册素材使用的临时效果。
		Duel.RegisterEffect(le,tp)
	end
	-- 提示玩家选择要特殊召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从额外卡组中选择1只当前可以连接召唤的怪兽。
	local g=Duel.SelectMatchingCard(tp,s.lkfilter,tp,LOCATION_EXTRA,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		-- 让玩家对选择的怪兽进行连接召唤手续。
		Duel.LinkSummon(tp,tc,nil)
	end
end

-- 判断所选择的对方场上的怪兽在当前规则下是否符合用作「W：P变幻舞夜」连接召唤素材的判定逻辑函数。
function s.matval(e,lc,mg,c,tp)
	local wp=e:GetLabelObject()
	local fid=e:GetLabel()
	if wp:GetFieldID()~=fid then return false,nil end

	if wp:GetControler()~=tp then
		return false,nil
	end

	if not s.wp_eligible_opp_link2(c,tp) then
		return false,nil
	end

	if not mg or not mg:IsContains(wp) then
		return true,false
	end

	if mg:IsExists(s.wp_eligible_opp_link2,1,c,tp) then
		return true,false
	end

	return true,true
end

-- 判断对方场上的表侧怪兽是否属于连接2以下的怪兽。
function s.wp_eligible_opp_link2(c,tp)
	return c:IsControler(1-tp) and c:IsFaceup() and c:IsLinkBelow(2)
end
