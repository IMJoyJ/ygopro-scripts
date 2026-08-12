--シルクボムモース
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡在手卡存在，自己墓地有风属性怪兽2只以上存在的场合才能发动。这张卡特殊召唤，从自己墓地让1只风属性怪兽回到卡组。
-- ②：这张卡召唤·特殊召唤的场合才能发动。对方卡组最上面的卡给双方确认，那个种类的以下效果适用。
-- ●怪兽：确认的卡当作永续魔法卡使用在对方的魔法与陷阱区域表侧表示放置。
-- ●魔法·陷阱：确认的卡除外。
local s,id,o=GetID()
-- 注册这张卡的三个效果：效果①为手卡的起动效果（特殊召唤+回卡组），效果②为召唤成功时触发的诱发选发效果（除外类，确认对方卡组），效果③是效果②的复制、触发时机改为特殊召唤成功时。
function s.initial_effect(c)
	-- ①：这张卡在手卡存在，自己墓地有风属性怪兽2只以上存在的场合才能发动。这张卡特殊召唤，从自己墓地让1只风属性怪兽回到卡组。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡召唤·特殊召唤的场合才能发动。对方卡组最上面的卡给双方确认，那个种类的以下效果适用。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"确认卡组"
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.dktg)
	e2:SetOperation(s.dkop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
end
-- 效果①的发动条件判断：确认自己墓地是否存在2只以上风属性怪兽。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己墓地是否存在至少2只风属性怪兽，作为效果发动的前提条件。
	return Duel.IsExistingMatchingCard(Card.IsAttribute,tp,LOCATION_GRAVE,0,2,nil,ATTRIBUTE_WIND)
end
-- 回卡组对象的过滤器：是风属性怪兽并且能够回到卡组。
function s.tdfilter(c)
	return c:IsAttribute(ATTRIBUTE_WIND) and c:IsAbleToDeck()
end
-- 效果①的目标函数：取得自己墓地可回卡组的风属性怪兽组，并检查自己怪兽区域有空位、这张卡可以特殊召唤且墓地有满足条件的卡。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 取得自己墓地中所有风属性且能回到卡组的卡组成的卡片组。
	local dg=Duel.GetMatchingGroup(s.tdfilter,tp,LOCATION_GRAVE,0,nil)
	-- 发动可行性检查：自己怪兽区域有空位、这张卡能被特殊召唤、且墓地存在可回卡组的风属性怪兽。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and #dg>0 end
	-- 设置操作信息：此效果将特殊召唤这张卡本身1只。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
	-- 设置操作信息：此效果将把自己墓地的1只风属性怪兽返回卡组。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,dg,1,tp,LOCATION_GRAVE)
end
-- 效果①的处理：若这张卡仍关联本连锁则将其特殊召唤，成功后让自己从墓地选1只风属性怪兽（不受王家长眠之谷影响）返回卡组并洗牌。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 若这张卡还关联着当前连锁，则把它以表侧表示特殊召唤到自己场上，成功才继续后续处理。
	if c:IsRelateToChain() and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 向自己显示选卡提示：请选择要返回卡组的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
		-- 让自己从自己墓地选择1只风属性且能回到卡组、且不受王家长眠之谷影响的怪兽。
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.tdfilter),tp,LOCATION_GRAVE,0,1,1,nil)
		if g:GetCount()>0 then
			-- 为选中的卡显示被选为对象的动画并记录选择。
			Duel.HintSelection(g)
			-- 把选中的卡返回持有者卡组并洗切卡组，作为效果处理。
			Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
		end
	end
end
-- 效果②的目标函数：检查对方卡组至少有1张卡，且对方魔法与陷阱区域有空位（怪兽的情况）或自己能除外卡（魔法·陷阱的情况）。
function s.dktg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动可行性检查：对方卡组最上方至少有1张卡可供确认。
	if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_DECK)>0
		-- 发动可行性检查：对方魔法与陷阱区域有空位可放置，或者自己能够执行除外。
		and (Duel.GetLocationCount(tp,LOCATION_SZONE,1-tp,r)>0 or Duel.IsPlayerCanRemove(tp))
	end
	-- 把当前连锁的对象玩家设置为自己（发动者），供效果处理时读取。
	Duel.SetTargetPlayer(tp)
end
-- 怪兽放置用的过滤器：该卡没有被禁止移动、满足场上唯一性限制，且对方魔法与陷阱区域有空位。
function s.filter(c,p)
	local r=LOCATION_REASON_TOFIELD
	return not c:IsForbidden() and c:CheckUniqueOnField(c:GetOwner())
		-- 检查对方（以持有者视角）的魔法与陷阱区域是否还有空位可供放置。
		and Duel.GetLocationCount(p,LOCATION_SZONE,1-p,r)>0
end
-- 效果②的处理：确认对方卡组最上面的卡；若是怪兽则当作永续魔法卡表侧表示放置到对方魔法与陷阱区域（无法放置则按规则送去墓地），若是魔法·陷阱则将其除外。
function s.dkop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁的对象玩家（即发动者），用于确定处理双方。
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 给双方确认对方卡组最上面的1张卡。
	Duel.ConfirmDecktop(1-p,1)
	-- 取得对方卡组最上面的1张卡组成的卡片组。
	local g=Duel.GetDecktopGroup(1-p,1)
	if g:IsExists(Card.IsType,1,nil,TYPE_MONSTER) then
		if g:IsExists(s.filter,1,nil,1-p,p) then
			local tc=g:GetFirst()
			-- 把确认的怪兽表侧表示移动到对方的魔法与陷阱区域，并立即适用其状态。
			Duel.MoveToField(tc,p,1-p,LOCATION_SZONE,POS_FACEUP,true)
			-- ●怪兽：确认的卡当作永续魔法卡使用在对方的魔法与陷阱区域表侧表示放置。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetCode(EFFECT_CHANGE_TYPE)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
			e1:SetValue(TYPE_SPELL+TYPE_CONTINUOUS)
			tc:RegisterEffect(e1)
		else
			-- 无法放置的场合，按规则把确认的卡送去墓地。
			Duel.SendtoGrave(g,REASON_RULE,p)
		end
	elseif g:IsExists(Card.IsType,1,nil,TYPE_SPELL+TYPE_TRAP) and g:IsExists(Card.IsAbleToRemove,1,nil,p) then
		-- ●魔法·陷阱：确认的卡除外。
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT,p)
	end
end
