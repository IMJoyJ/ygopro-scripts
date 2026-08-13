--レスキューヘッジホッグ
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：把场上的这张卡除外才能发动。3星以下而种族·属性·等级相同的通常怪兽和效果怪兽各1只从卡组特殊召唤。这个效果特殊召唤的怪兽的效果无效化，结束阶段破坏。
local s,id,o=GetID()
-- 定义卡的初始效果函数，创建①效果（起动效果）并注册到卡上，包含效果说明、特殊召唤分类、起动类型、发动区域、1回合1次限制、除外自身cost、发动条件和处理函数。
function s.initial_effect(c)
	-- 这个卡名的效果1回合只能使用1次。①：把场上的这张卡除外才能发动。3星以下而种族·属性·等级相同的通常怪兽和效果怪兽各1只从卡组特殊召唤。这个效果特殊召唤的怪兽的效果无效化，结束阶段破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	-- 设置效果发动代价为把场上的这张卡除外，使用系统辅助函数aux.bfgcost（在判定时检查可除外，在代价阶段除外）。
	e1:SetCost(aux.bfgcost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
-- 定义特殊召唤候选怪兽的过滤函数：等级在3以下，并且能被当前效果以表侧表示特殊召唤。
function s.filter(c,e,tp)
	return c:IsLevelBelow(3) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 定义选组校验函数：检查2张卡是否种族、属性、等级各自相同，且其中一张为通常怪兽、另一张为效果怪兽（顺序不限），满足才返回真。
function s.chk(g)
	if g:GetClassCount(Card.GetRace)>1 or g:GetClassCount(Card.GetAttribute)>1 or g:GetClassCount(Card.GetLevel)>1 then return false end
	local fc=g:GetFirst()
	local sc=g:GetNext()
	return fc:IsType(TYPE_NORMAL) and sc:IsType(TYPE_EFFECT) or sc:IsType(TYPE_NORMAL) and fc:IsType(TYPE_EFFECT)
end
-- 效果发动条件判定：先从卡组筛选所有候选卡；在无代价确认（chk==0）时，要求己方没有被青眼精灵龙限制同时特殊召唤2只以上怪兽，且怪兽区可用格数大于1，并且卡组中存在一组满足s.chk的2张卡。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取卡组中所有等级3以下且能被特殊召唤的怪兽集合，作为后续选组和条件判断的候选。
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_DECK,0,nil,e,tp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 继续发动条件：确认己方怪兽区可用数量大于1（因为要召唤2只），且卡组中确实存在一组种族·属性·等级相同且由通常怪兽和效果怪兽各1只构成的2张卡。
		and Duel.GetMZoneCount(tp,e:GetHandler())>1 and g:CheckSubGroup(s.chk,2,2) end
	-- 设置连锁操作信息：声明本效果属于特殊召唤分类，预计从卡组特殊召唤2只怪兽，供其他卡的效果检测使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_DECK)
end
-- 效果处理开始：再次获取卡组候选卡；如果此时己方受青眼精灵龙限制、怪兽区空格不足2个，或卡组中已无符合条件的2张卡，则直接终止效果处理。
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 在效果处理时重新从卡组筛选可特殊召唤的等级3以下怪兽集合，用于实际选择。
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_DECK,0,nil,e,tp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) or Duel.GetLocationCount(tp,LOCATION_MZONE)<2
		or not g:CheckSubGroup(s.chk,2,2) then return end
	local c=e:GetHandler()
	local fid=c:GetFieldID()
	-- 给玩家发送选择提示，显示“请选择要特殊召唤的卡”，并配合选择系统让玩家选出符合条件的2张怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	local sg=g:SelectSubGroup(tp,s.chk,false,2,2)
	if not sg then return end
	-- 遍历玩家选择的2张怪兽，逐张进行连续特殊召唤的处理。
	for tc in aux.Next(sg) do
		-- 将当前怪兽以表侧表示加入特殊召唤流程（不检查苏生限制、不限制数量），如果特殊召唤成功则继续执行无效化处理并记录标记。
		if Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
			-- 这个效果特殊召唤的怪兽的效果无效化。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
			local e2=e1:Clone()
			e2:SetCode(EFFECT_DISABLE_CHAIN)
			e2:SetValue(RESET_TURN_SET)
			tc:RegisterEffect(e2)
			tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1,fid)
		end
	end
	-- 结束连续特殊召唤流程，确认所有怪兽特殊召唤成功，并触发所有相关时点。
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
	e3:SetCondition(s.descon)
	e3:SetOperation(s.desop)
	-- 将“结束阶段破坏”的持续效果注册给场上的该效果（不入连锁），使满足条件的怪兽在结束阶段被破坏。
	Duel.RegisterEffect(e3,tp)
end
-- 定义破坏筛选函数：只选择带有本次效果特殊召唤时记录的flag标记（fid）的怪兽。
function s.desfilter(c,fid)
	return c:GetFlagEffectLabel(id)==fid
end
-- 破坏效果的条件判定：若记录组中仍存在带对应标记的怪兽，则正常执行破坏；否则清除记录组并重置该效果。
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	if not g:IsExists(s.desfilter,1,nil,e:GetLabel()) then
		g:DeleteGroup()
		e:Reset()
		return false
	else return true end
end
-- 定义破坏操作：获取记录组中所有带对应标记的怪兽，作为要破坏的目标。
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	local tg=g:Filter(s.desfilter,nil,e:GetLabel())
	-- 以效果破坏的方式将这些怪兽破坏并送入墓地。
	Duel.Destroy(tg,REASON_EFFECT)
end
