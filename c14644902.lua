--幻想召喚師
-- 效果：
-- ①：这张卡反转的场合发动。这张卡以外的自己场上1只怪兽解放，从额外卡组把1只融合怪兽特殊召唤。这个效果特殊召唤的怪兽在这个回合的结束阶段破坏。
function c14644902.initial_effect(c)
	-- ①：这张卡反转的场合发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(14644902,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_RELEASE+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP)
	e1:SetTarget(c14644902.target)
	e1:SetOperation(c14644902.operation)
	c:RegisterEffect(e1)
end
-- 设置连锁处理时的提示信息，表示将要特殊召唤一张来自额外卡组的怪兽。
function c14644902.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁处理时的提示信息，表示将要特殊召唤一张来自额外卡组的怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 用于筛选可以被解放的怪兽，排除自身并检查是否能从额外卡组特殊召唤融合怪兽。
function c14644902.rfilter(c,e,tp)
	return not c:IsImmuneToEffect(e)
		-- 检查在额外卡组中是否存在满足条件的融合怪兽。
		and Duel.IsExistingMatchingCard(c14644902.filter,tp,LOCATION_EXTRA,0,1,nil,e,tp,c)
end
-- 用于筛选额外卡组中可以特殊召唤的融合怪兽。
function c14644902.filter(c,e,tp,mc)
	-- 判断目标怪兽是否为融合怪兽、是否可以特殊召唤，并且场上是否有足够的位置。
	return c:IsType(TYPE_FUSION) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0
end
-- 用于筛选可以被解放的怪兽，检查其是否能为融合怪兽提供召唤空间。
function c14644902.rfilter2(c,tp)
	-- 判断目标怪兽是否能为融合怪兽提供召唤空间。
	return Duel.GetLocationCountFromEx(tp,tp,c,TYPE_FUSION)>0
end
-- 效果处理函数，执行反转效果的处理流程。
function c14644902.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 选择场上一只满足条件的怪兽进行解放。
	local rg=Duel.SelectReleaseGroupEx(tp,c14644902.rfilter,1,1,REASON_EFFECT,false,aux.ExceptThisCard(e),e,tp)
	-- 如果成功解放怪兽，则继续执行后续操作。
	if Duel.Release(rg,REASON_EFFECT)>0 then
		-- 提示玩家选择要特殊召唤的融合怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		-- 从额外卡组中选择一只满足条件的融合怪兽。
		local sg=Duel.SelectMatchingCard(tp,c14644902.filter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
		if sg:GetCount()>0 then
			-- 将选中的融合怪兽特殊召唤到场上。
			Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
			local fid=c:GetFieldID()
			sg:GetFirst():RegisterFlagEffect(14644902,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1,fid)
			-- 创建一个在结束阶段触发的效果，用于破坏特殊召唤的融合怪兽。
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
			-- 将创建的破坏效果注册到场上。
			Duel.RegisterEffect(e1,tp)
		end
	end
	if #rg==0 then
		-- 当第一次选择解放失败时，再次尝试选择一只怪兽进行解放。
		rg=Duel.SelectReleaseGroupEx(tp,c14644902.rfilter2,1,1,REASON_EFFECT,false,aux.ExceptThisCard(e),tp)
		if #rg>0 then
			-- 对选中的怪兽进行解放。
			Duel.Release(rg,REASON_EFFECT)
		end
	end
end
-- 判断是否需要破坏特殊召唤的融合怪兽。
function c14644902.descon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	return tc:GetFlagEffectLabel(14644902)==e:GetLabel()
end
-- 执行破坏操作，将融合怪兽破坏。
function c14644902.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 将融合怪兽从场上破坏。
	Duel.Destroy(e:GetLabelObject(),REASON_EFFECT)
end
