--幻想召喚師
-- 效果：
-- ①：这张卡反转的场合发动。这张卡以外的自己场上1只怪兽解放，从额外卡组把1只融合怪兽特殊召唤。这个效果特殊召唤的怪兽在这个回合的结束阶段破坏。
function c14644902.initial_effect(c)
	-- ①：这张卡反转的场合发动。这张卡以外的自己场上1只怪兽解放，从额外卡组把1只融合怪兽特殊召唤。这个效果特殊召唤的怪兽在这个回合的结束阶段破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(14644902,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_RELEASE+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP)
	e1:SetTarget(c14644902.target)
	e1:SetOperation(c14644902.operation)
	c:RegisterEffect(e1)
end
-- 反转发动的效果发动时的条件判定：没有额外的发动条件限制，通过后登记从额外卡组特殊召唤1只融合怪兽的操作信息。
function c14644902.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置本次连锁的操作信息，标明效果包含特殊召唤，计划从额外卡组特殊召唤1只怪兽，具体对象在处理时选择。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 解放素材的过滤函数：候选怪兽不能免疫当前效果，且解放它后能从额外卡组特殊召唤出符合条件的融合怪兽。
function c14644902.rfilter(c,e,tp)
	return not c:IsImmuneToEffect(e)
		-- 检查额外卡组中是否存在满足特殊召唤条件的融合怪兽，并以当前候选怪兽作为解放后的空位判断条件。
		and Duel.IsExistingMatchingCard(c14644902.filter,tp,LOCATION_EXTRA,0,1,nil,e,tp,c)
end
-- 融合怪兽的过滤函数：必须是融合怪兽、能被当前效果特殊召唤，且解放候选怪兽后额外怪兽区域仍有可用空格。
function c14644902.filter(c,e,tp,mc)
	-- 同时判断三个条件：属于融合怪兽、能够被效果特殊召唤、解放素材后融合怪兽有格子可出场。
	return c:IsType(TYPE_FUSION) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0
end
-- 备选解放素材的过滤函数：仅检查解放该怪兽后是否有足够空格容纳融合怪兽，用于某些情况下重新选择解放对象。
function c14644902.rfilter2(c,tp)
	-- 检查解放该候选怪兽后，额外卡组的融合怪兽是否能有可用特殊召唤区域。
	return Duel.GetLocationCountFromEx(tp,tp,c,TYPE_FUSION)>0
end
-- 效果的解决处理：选择并解放这张卡以外的自己场上1只怪兽，从额外卡组选1只融合怪兽特殊召唤，并为其设置结束阶段破坏的效果；若第一次解放未成功则重新选择解放素材并解放。
function c14644902.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 选择1只这张卡以外的自己场上的怪兽作为解放对象，该怪兽需要满足能配合额外卡组的融合怪兽进行特殊召唤。
	local rg=Duel.SelectReleaseGroupEx(tp,c14644902.rfilter,1,1,REASON_EFFECT,false,aux.ExceptThisCard(e),e,tp)
	-- 解放所选择的怪兽；若实际解放成功（数量大于0）则继续执行后续特殊召唤处理。
	if Duel.Release(rg,REASON_EFFECT)>0 then
		-- 提示玩家从额外卡组选择要特殊召唤的融合怪兽，显示“请选择要特殊召唤的卡”。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从自己的额外卡组选择1只符合条件的融合怪兽作为特殊召唤对象。
		local sg=Duel.SelectMatchingCard(tp,c14644902.filter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
		if sg:GetCount()>0 then
			-- 将选择的融合怪兽以表侧表示特殊召唤到自己的场上。
			Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
			local fid=c:GetFieldID()
			sg:GetFirst():RegisterFlagEffect(14644902,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1,fid)
			-- 这个效果特殊召唤的怪兽在这个回合的结束阶段破坏。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e1:SetCode(EVENT_PHASE+PHASE_END)
			e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
			e1:SetLabel(fid)
			e1:SetLabelObject(sg:GetFirst())
			e1:SetCondition(c14644902.descon)
			e1:SetOperation(c14644902.desop)
			e1:SetReset(RESET_PHASE+PHASE_END)
			e1:SetCountLimit(1)
			-- 将用于在结束阶段破坏特殊召唤怪兽的持续效果注册到当前决斗中。
			Duel.RegisterEffect(e1,tp)
		end
	end
	if #rg==0 then
		-- 若之前的解放未能成功，则尝试重新选择1只可解放的怪兽（不检查能否特殊召唤融合怪兽，仅检查区域空位）。
		rg=Duel.SelectReleaseGroupEx(tp,c14644902.rfilter2,1,1,REASON_EFFECT,false,aux.ExceptThisCard(e),tp)
		if #rg>0 then
			-- 将重新选择的怪兽解放。
			Duel.Release(rg,REASON_EFFECT)
		end
	end
end
-- 破坏判定条件：检查结束阶段时，被特殊召唤的怪兽仍然带着本次效果的标记（即仍未离场且确实是本效果特殊召唤的怪兽）。
function c14644902.descon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	return tc:GetFlagEffectLabel(14644902)==e:GetLabel()
end
-- 破坏处理函数：对带有对应标记的怪兽执行破坏。
function c14644902.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 实际将被特殊召唤的怪兽以效果原因破坏。
	Duel.Destroy(e:GetLabelObject(),REASON_EFFECT)
end
