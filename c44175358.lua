--分裂するプラナリア
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：把场上的这张卡除外才能发动。从卡组把2只同名的昆虫族·3星怪兽特殊召唤。这个效果特殊召唤的怪兽的效果无效化，结束阶段除外。
local s,id,o=GetID()
-- 定义卡片的初始效果函数：创建①效果e1，设置其描述、分类（特殊召唤）、类型（起动效果）、发动区域（主要怪兽区）、1回合1次限制、发动代价（除外自身）、发动条件和处理操作，并注册给卡片。
function s.initial_effect(c)
	-- 这个卡名的效果1回合只能使用1次。①：把场上的这张卡除外才能发动。从卡组把2只同名的昆虫族·3星怪兽特殊召唤。这个效果特殊召唤的怪兽的效果无效化，结束阶段除外。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	-- 设置效果的发动代价为“把场上的这张卡除外”。
	e1:SetCost(aux.bfgcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
end
-- 定义筛选函数：筛选出等级为3、种族为昆虫族、并且能够被特殊召唤的怪兽，作为从卡组选择的对象条件。
function s.filter(c,e,tp)
	return c:IsLevel(3) and c:IsRace(RACE_INSECT) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 定义选组条件：选出的怪兽组中不同卡名的种类数为1，即两张怪兽卡名相同，以满足“2只同名的昆虫族·3星怪兽”。
function s.fselect(g)
	return g:GetClassCount(Card.GetCode)==1
end
-- 效果发动时的条件判定：检查我方是否不受禁止同时特殊召唤2只以上怪兽的效果影响（青眼精灵龙），可用怪兽区域大于1，且卡组中确有满足条件的2只同名怪兽，满足才可发动。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取卡组中所有满足s.filter条件的昆虫族·3星怪兽，组成候选组。
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_DECK,0,nil,e,tp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 检查我方场上除发动效果的本卡外，可用的怪兽区域数量是否大于1，确保有足够空格特殊召唤2只怪兽。
		and Duel.GetMZoneCount(tp,e:GetHandler())>1
		and g:CheckSubGroup(s.fselect,2,2) end
	-- 设置连锁处理的操作信息：本次效果将以卡组为对象，特殊召唤2只怪兽，供后续相关效果检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_DECK)
end
-- 效果处理函数：在效果处理时再次确认不受青眼精灵龙限制且有足够空位，从卡组选出2只同名昆虫族·3星怪兽，以表侧表示特殊召唤，给它们附加效果无效化状态，并设置结束阶段除外的延迟处理。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 效果处理时再次检查我方怪兽区域是否至少有2个空格，若不足则直接终止处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<2 then return end
	local c=e:GetHandler()
	-- 获取卡组中所有满足s.filter条件的昆虫族·3星怪兽，组成候选组。
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_DECK,0,nil,e,tp)
	-- 发送选择提示消息，提示玩家接下来要选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	local sg=g:SelectSubGroup(tp,s.fselect,false,2,2)
	if sg:GetCount()==2 then
		local fid=e:GetHandler():GetFieldID()
		-- 发送选择提示消息，提示玩家从符合条件的一组卡中选择要特殊召唤的卡（选择界面用）。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 遍历已选出的2张卡组，逐一进行特殊召唤处理。
		for tc in aux.Next(sg) do
			-- 将当前怪兽以表侧表示特殊召唤到tp的场上，作为连续特殊召唤中的一步。
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
			tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1,fid)
		end
		-- 完成整个特殊召唤处理，使之前所有SpecialSummonStep的召唤正式成立。
		Duel.SpecialSummonComplete()
		sg:KeepAlive()
		-- 结束阶段除外。
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e3:SetCode(EVENT_PHASE+PHASE_END)
		e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e3:SetCountLimit(1)
		e3:SetLabel(fid)
		e3:SetLabelObject(sg)
		e3:SetCondition(s.descon)
		e3:SetOperation(s.desop)
		-- 将结束阶段除外的延迟效果注册到玩家tp，使该效果在结束阶段时处理。
		Duel.RegisterEffect(e3,tp)
	end
end
-- 定义过滤函数：检查怪兽是否带有所需的标记（fid），即是否为这次效果特殊召唤的怪兽。
function s.desfilter(c,fid)
	return c:GetFlagEffectLabel(id)==fid
end
-- 定义延迟效果的发动条件：若这次特殊召唤的怪兽仍有留在场上的，则条件成立；否则清理记录并重置该效果。
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	if not g:IsExists(s.desfilter,1,nil,e:GetLabel()) then
		g:DeleteGroup()
		e:Reset()
		return false
	else return true end
end
-- 定义延迟效果的处理操作：在结束阶段取出仍带标记的怪兽组，将其除外。
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	local tg=g:Filter(s.desfilter,nil,e:GetLabel())
	-- 将标记过的特殊召唤怪兽以表侧表示除外，实现“结束阶段除外”。
	Duel.Remove(tg,POS_FACEUP,REASON_EFFECT)
end
