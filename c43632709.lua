--Cerynemesia, Mystical Beast of the Forest
-- 效果：
-- 这张卡召唤·特殊召唤的场合：可以从自己的手卡·场上（表侧表示）把1只兽族怪兽直到结束阶段以表侧除外；从自己的卡组·墓地把持有那只怪兽原本等级以下等级的1只兽族·地属性怪兽特殊召唤，那之后，对方可以从手卡把1只怪兽特殊召唤。
-- 「森之圣兽 龙面花牝鹿」的这个效果1回合只能使用1次。
-- 可以攻击的对方怪兽必须向自己场上攻击力最高的怪兽作出攻击。
local s,id,o=GetID()
-- 初始化并注册全部效果：①效果是召唤·特殊召唤成功时诱发选发的特殊召唤效果（1回合1次，需支付除外代价），②效果是使对方可攻击的怪兽必须攻击、且必须向自己攻击力最高怪兽攻击的永续效果。
function s.initial_effect(c)
	-- 这张卡召唤·特殊召唤的场合：可以从自己的手卡·场上（表侧表示）把1只兽族怪兽直到结束阶段以表侧除外；从自己的卡组·墓地把持有那只怪兽原本等级以下等级的1只兽族·地属性怪兽特殊召唤，那之后，对方可以从手卡把1只怪兽特殊召唤。「森之圣兽 龙面花牝鹿」的这个效果1回合只能使用1次。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.cost)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- 可以攻击的对方怪兽必须向自己场上攻击力最高的怪兽作出攻击。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_MUST_ATTACK)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(0,LOCATION_MZONE)
	e3:SetCondition(s.macon)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_MUST_ATTACK_MONSTER)
	e4:SetValue(s.atklimit)
	c:RegisterEffect(e4)
end
-- 可作为代价除外的怪兽的过滤条件：手卡·场上表侧表示的兽族怪兽、可以作为代价除外、其离场后自己仍有可用怪兽区，且卡组·墓地存在持有其原本等级以下等级的可特殊召唤的兽族·地属性怪兽。
function s.rmfilter(c,e,tp)
	return c:IsFaceupEx() and c:IsRace(RACE_BEAST) and c:IsAbleToRemoveAsCost()
		-- 确认该怪兽离开怪兽区后自己仍有至少1个可用的主要怪兽区（若在怪兽区还需通过覆盖检测）。
		and Duel.GetMZoneCount(tp,c)>0 and (not c:IsLocation(LOCATION_MZONE) or aux.covcheck(c))
		-- 检查自己卡组·墓地是否存在持有该怪兽原本等级以下等级、可以被特殊召唤的兽族·地属性怪兽。
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp,c:GetOriginalLevel())
end
-- 特殊召唤对象的过滤条件：原本等级在被除外怪兽原本等级以下的兽族·地属性怪兽，且可以被特殊召唤。
function s.spfilter(c,e,tp,olv)
	return c:GetOriginalLevel()<=olv and c:IsAttribute(ATTRIBUTE_EARTH) and c:IsRace(RACE_BEAST) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 代价处理：从自己手卡·场上（表侧表示）选1只兽族怪兽以表侧表示暂时除外，记录其原本等级，并注册在结束阶段把该怪兽返回的持续效果。
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己手卡·场上是否存在可以作为代价除外的符合条件的兽族怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(s.rmfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil,e,tp) end
	local c=e:GetHandler()
	-- 向自己玩家提示「请选择要除外的卡」。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让自己玩家从手卡·场上（表侧表示）选择1只满足条件的兽族怪兽作为代价。
	local g=Duel.SelectMatchingCard(tp,s.rmfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil,e,tp)
	-- 把选择的怪兽以表侧表示暂时除外（作为代价，结束阶段返回）。
	Duel.Remove(g,POS_FACEUP,REASON_COST+REASON_TEMPORARY)
	local tc=g:GetFirst()
	e:SetLabel(tc:GetOriginalLevel())
	local fid=c:GetFieldID()
	tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,EFFECT_FLAG_CLIENT_HINT,1,fid,aux.Stringid(id,2))  --"直到结束阶段除外"
	-- 把那只怪兽直到结束阶段以表侧除外；从自己的卡组·墓地把持有那只怪兽原本等级以下等级的1只兽族·地属性怪兽特殊召唤，那之后，对方可以从手卡把1只怪兽特殊召唤。可以攻击的对方怪兽必须向自己场上攻击力最高的怪兽作出攻击。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetCountLimit(1)
	e1:SetLabel(fid)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetLabelObject(tc)
	e1:SetCondition(s.retcon)
	e1:SetOperation(s.retop)
	-- 把结束阶段触发的持续效果注册给全局环境，用于将暂时除外的怪兽返回。
	Duel.RegisterEffect(e1,tp)
end
-- 效果发动的目标设定：确认代价已支付，并设置从自己卡组·墓地特殊召唤1只怪兽的操作信息。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:IsCostChecked() end
	-- 设置连锁操作信息：预计从自己卡组·墓地特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
-- 效果处理：从自己卡组·墓地选1只等级在被除外怪兽原本等级以下的兽族·地属性怪兽特殊召唤，成功后对方可以选择从手卡把1只怪兽特殊召唤。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local lv=e:GetLabel()
	-- 若自己没有可用的主要怪兽区则不进行处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向自己玩家提示「请选择要特殊召唤的卡」。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己卡组·墓地选择1只满足条件且不受王家长眠之谷影响的兽族·地属性怪兽。
	local sg=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp,lv)
	-- 将选择的怪兽以表侧表示特殊召唤到自己场上，成功则继续处理对方的特殊召唤。
	if sg:GetCount()>0 and Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 检索对方手卡中所有可以被特殊召唤的怪兽。
		local tg=Duel.GetMatchingGroup(Card.IsCanBeSpecialSummoned,tp,0,LOCATION_HAND,nil,e,0,1-tp,false,false)
		-- 确认对方手卡存在可特殊召唤的怪兽且对方场上有可用的主要怪兽区。
		if tg:GetCount()>0 and Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0
			-- 询问对方是否从手卡把1只怪兽特殊召唤。
			and Duel.SelectYesNo(1-tp,aux.Stringid(id,1)) then  --"是否特殊召唤？"
			-- 中断当前效果处理，使对方的特殊召唤视为不同时处理。
			Duel.BreakEffect()
			-- 向对方玩家提示「请选择要特殊召唤的卡」。
			Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			local ssg=tg:Select(1-tp,1,1,nil)
			-- 对方将选择的1只怪兽以表侧表示特殊召唤到对方场上。
			Duel.SpecialSummon(ssg,0,1-tp,1-tp,false,false,POS_FACEUP)
		end
	end
end
-- 结束阶段持续效果的触发条件：确认被除外怪兽的标记与记录一致则触发，否则重置该效果不再触发。
function s.retcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:GetFlagEffectLabel(id)==e:GetLabel() then
		return true
	else
		e:Reset()
		return false
	end
end
-- 结束阶段处理：若被除外的怪兽原本在怪兽区则返回场上，否则（来自手卡）送去持有者手卡。
function s.retop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:IsPreviousLocation(LOCATION_MZONE) then
		-- 把暂时除外的怪兽返回到场上。
		Duel.ReturnToField(tc)
	else
		-- 把被除外的怪兽以效果处理送去持有者的手卡。
		Duel.SendtoHand(tc,tp,REASON_EFFECT)
	end
end
-- 永续效果的适用条件：自己场上存在表侧表示的怪兽。
function s.macon(e)
	-- 检查自己场上是否存在至少1只表侧表示的怪兽。
	return Duel.IsExistingMatchingCard(Card.IsFaceup,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
-- 攻击对象限制：对方怪兽必须向自己场上攻击力最高的表侧表示怪兽作出攻击。
function s.atklimit(e,c)
	-- 取得自己场上表侧表示怪兽中攻击力最高的一组怪兽。
	local g=Duel.GetMatchingGroup(Card.IsFaceup,e:GetHandlerPlayer(),LOCATION_MZONE,0,nil):GetMaxGroup(Card.GetAttack)
	return g and g:IsContains(c)
end
