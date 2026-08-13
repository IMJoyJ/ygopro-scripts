--レスキューキャット
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：把场上的这张卡送去墓地才能发动。从卡组把2只3星以下的兽族怪兽特殊召唤。这个效果特殊召唤的怪兽的效果无效化，结束阶段破坏。
function c14878871.initial_effect(c)
	-- 这个卡名的效果1回合只能使用1次。①：把场上的这张卡送去墓地才能发动。从卡组把2只3星以下的兽族怪兽特殊召唤。这个效果特殊召唤的怪兽的效果无效化，结束阶段破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(14878871,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,14878871)
	e1:SetCost(c14878871.spcost)
	e1:SetTarget(c14878871.sptg)
	e1:SetOperation(c14878871.spop)
	c:RegisterEffect(e1)
end
-- 发动代价的判定与支付：效果发动时检查此卡能否作为代价送入墓地，可以则将其送入墓地作为发动代价。
function c14878871.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 将此卡（救援猫）从场上送去墓地，作为发动效果的代价。
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 定义可特殊召唤的怪兽的筛选条件：等级3以下、兽族、并且可以被当前效果特殊召唤。
function c14878871.filter(c,e,tp)
	return c:IsLevelBelow(3) and c:IsRace(RACE_BEAST) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动前的合法性检查：确认没有青眼精灵龙禁止同时特殊召唤2只以上怪兽的效果生效、自己场上有可用怪兽区、卡组存在至少2只符合条件的兽族怪兽，满足才可发动。
function c14878871.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 检查自己场上是否存在可用的怪兽区域空位（至少1个）。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在至少2只满足条件的兽族怪兽（等级3以下、兽族、可特殊召唤）。
		and Duel.IsExistingMatchingCard(c14878871.filter,tp,LOCATION_DECK,0,2,nil,e,tp) end
	-- 将本次连锁的操作信息设定为“从卡组特殊召唤2只怪兽”，供其他卡的效果（如星尘龙等）进行对应检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_DECK)
end
-- 效果处理：再次确认无青眼精灵龙限制且场上至少有2个可用怪兽区，然后从卡组选出2只符合条件的兽族怪兽，用SpecialSummonStep逐只特殊召唤，为它们附加效果无效化状态并标记本回合结束阶段破坏，最后注册结束阶段的破坏效果。
function c14878871.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 处理时若自己场上可用怪兽区不足2个，则这次特殊召唤不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<2 then return end
	local c=e:GetHandler()
	-- 从卡组中取得所有满足条件的兽族怪兽（等级3以下、兽族且可特殊召唤）的集合。
	local g=Duel.GetMatchingGroup(c14878871.filter,tp,LOCATION_DECK,0,nil,e,tp)
	if g:GetCount()>=2 then
		local fid=e:GetHandler():GetFieldID()
		-- 给玩家弹出选择提示，要求选择要特殊召唤的怪兽卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=g:Select(tp,2,2,nil)
		local tc=sg:GetFirst()
		while tc do
			-- 将选中的怪兽以表侧表示特殊召唤到自己的场上（分步特殊召唤中的一步）。
			Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
			-- 这个效果特殊召唤的怪兽的效果无效化。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
			-- 这个效果特殊召唤的怪兽的效果无效化。
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			e2:SetValue(RESET_TURN_SET)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e2)
			tc:RegisterFlagEffect(14878871,RESET_EVENT+RESETS_STANDARD,0,1,fid)
			tc=sg:GetNext()
		end
		-- 完成整个特殊召唤流程，使之前通过SpecialSummonStep进行的特殊召唤正式成立。
		Duel.SpecialSummonComplete()
		sg:KeepAlive()
		-- 结束阶段破坏。
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e3:SetCode(EVENT_PHASE+PHASE_END)
		e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e3:SetCountLimit(1)
		e3:SetLabel(fid)
		e3:SetLabelObject(sg)
		e3:SetCondition(c14878871.descon)
		e3:SetOperation(c14878871.desop)
		-- 将结束阶段时破坏这些怪兽的持续效果注册到场上，使其在结束阶段可以触发。
		Duel.RegisterEffect(e3,tp)
	end
end
-- 判定某只怪兽是否属于本次效果特殊召唤的怪兽（带有对应的标记id）。
function c14878871.desfilter(c,fid)
	return c:GetFlagEffectLabel(14878871)==fid
end
-- 结束阶段破坏效果的发动条件：若标记的怪兽已经不在场上，则清除记录并终止该效果；否则允许破坏执行。
function c14878871.descon(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	if not g:IsExists(c14878871.desfilter,1,nil,e:GetLabel()) then
		g:DeleteGroup()
		e:Reset()
		return false
	else return true end
end
-- 处理结束阶段破坏：从被记录的特殊召唤怪兽中筛选出仍具有对应标记的怪兽，执行破坏。
function c14878871.desop(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	local tg=g:Filter(c14878871.desfilter,nil,e:GetLabel())
	-- 以效果原因将目标怪兽破坏。
	Duel.Destroy(tg,REASON_EFFECT)
end
