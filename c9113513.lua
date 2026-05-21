--オスティナート
-- 效果：
-- ①：自己场上没有怪兽存在的场合才能发动。从自己的手卡·卡组把「幻奏」融合怪兽卡决定的2只融合素材怪兽送去墓地，把那1只融合怪兽从额外卡组融合召唤。这个回合的结束阶段，这个效果融合召唤的怪兽破坏，若那一组融合素材怪兽在自己墓地齐集，可以把那一组特殊召唤。
function c9113513.initial_effect(c)
	-- ①：自己场上没有怪兽存在的场合才能发动。从自己的手卡·卡组把「幻奏」融合怪兽卡决定的2只融合素材怪兽送去墓地，把那1只融合怪兽从额外卡组融合召唤。这个回合的结束阶段，这个效果融合召唤的怪兽破坏，若那一组融合素材怪兽在自己墓地齐集，可以把那一组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON+CATEGORY_DECKDES+CATEGORY_GRAVE_SPSUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c9113513.condition)
	e1:SetTarget(c9113513.target)
	e1:SetOperation(c9113513.activate)
	c:RegisterEffect(e1)
end
-- 设置发动条件：自己场上没有怪兽存在。
function c9113513.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上的怪兽数量是否为0。
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
end
-- 过滤条件1：可以作为融合素材的怪兽，且存在能与之配合进行融合召唤的第二张素材。
function c9113513.filter1(c,e,tp,mg,f,chkf)
	return c:IsType(TYPE_MONSTER) and c:IsCanBeFusionMaterial()
		and mg:IsExists(c9113513.filter2,1,c,e,tp,c,f,chkf)
end
-- 过滤条件2：可以作为融合素材的怪兽，且与第一张素材组合时，额外卡组存在可融合召唤的「幻奏」融合怪兽。
function c9113513.filter2(c,e,tp,mc,f,chkf)
	local mg=Group.FromCards(c,mc)
	return c:IsType(TYPE_MONSTER) and c:IsCanBeFusionMaterial()
		-- 检查额外卡组是否存在可以使用当前素材组进行融合召唤的「幻奏」融合怪兽。
		and Duel.IsExistingMatchingCard(c9113513.ffilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg,f,chkf)
end
-- 融合怪兽过滤：额外卡组的「幻奏」融合怪兽，且可以被融合召唤，并且当前素材组满足其融合素材要求。
function c9113513.ffilter(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and c:IsSetCard(0x9b) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- 效果发动时的目标选择与合法性检测（检查手卡·卡组是否存在可用的融合素材）。
function c9113513.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		-- 获取自己手卡和卡组的所有卡片作为融合素材候选。
		local mg1=Duel.GetMatchingGroup(nil,tp,LOCATION_HAND+LOCATION_DECK,0,nil)
		local res=mg1:IsExists(c9113513.filter1,1,nil,e,tp,mg1,nil,chkf)
		if not res then
			-- 获取玩家受到的连锁素材效果（如「连锁素材」）。
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg2=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				res=mg2:IsExists(c9113513.filter1,1,nil,e,tp,mg2,mf,chkf)
			end
		end
		return res
	end
	-- 设置操作信息：从额外卡组特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 融合素材基础过滤：可以作为融合素材，且不受当前效果影响。
function c9113513.filter0(c,e)
	return c:IsCanBeFusionMaterial() and not c:IsImmuneToEffect(e)
end
-- 效果处理：从手卡·卡组选择融合素材送去墓地，将对应的「幻奏」融合怪兽融合召唤，并注册回合结束阶段的破坏及特殊召唤效果。
function c9113513.activate(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	-- 获取自己手卡·卡组中可以作为融合素材且不受此效果影响的卡片组。
	local mg1=Duel.GetMatchingGroup(c9113513.filter0,tp,LOCATION_HAND+LOCATION_DECK,0,nil,e)
	local g1=mg1:Filter(c9113513.filter1,nil,e,tp,mg1,nil,chkf)
	local mg2=nil
	local g2=nil
	-- 获取玩家受到的连锁素材效果。
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg2=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		g2=mg2:Filter(c9113513.filter1,nil,e,tp,mg2,mf,chkf)
	end
	local tc=nil
	-- 若存在「连锁素材」等效果允许的素材，且玩家选择使用或没有常规素材可用，则使用连锁素材效果进行融合。
	if g2~=nil and g2:GetCount()>0 and (g1:GetCount()==0 or Duel.SelectYesNo(tp,ce:GetDescription())) then
		local mf=ce:GetValue()
		-- 提示玩家选择第一张融合素材。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FMATERIAL)  --"请选择要作为融合素材的卡"
		local sg1=mg2:FilterSelect(tp,c9113513.filter1,1,1,nil,e,tp,mg2,mf,chkf)
		-- 提示玩家选择第二张融合素材。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FMATERIAL)  --"请选择要作为融合素材的卡"
		local sg2=mg2:FilterSelect(tp,c9113513.filter2,1,1,nil,e,tp,sg1:GetFirst(),mf,chkf)
		sg1:Merge(sg2)
		-- 提示玩家选择要特殊召唤的融合怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 让玩家从额外卡组选择1只满足条件的「幻奏」融合怪兽。
		local sg=Duel.SelectMatchingCard(tp,c9113513.ffilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,sg1,mf,chkf)
		tc=sg:GetFirst()
		local fop=ce:GetOperation()
		fop(ce,e,tp,tc,sg1)
	elseif g1:GetCount()>0 then
		-- 提示玩家选择第一张融合素材。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FMATERIAL)  --"请选择要作为融合素材的卡"
		local sg1=mg1:FilterSelect(tp,c9113513.filter1,1,1,nil,e,tp,mg1,nil,chkf)
		-- 提示玩家选择第二张融合素材。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FMATERIAL)  --"请选择要作为融合素材的卡"
		local sg2=mg1:FilterSelect(tp,c9113513.filter2,1,1,nil,e,tp,sg1:GetFirst(),nil,chkf)
		sg1:Merge(sg2)
		-- 提示玩家选择要特殊召唤的融合怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 让玩家从额外卡组选择1只满足条件的「幻奏」融合怪兽。
		local sg=Duel.SelectMatchingCard(tp,c9113513.ffilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,sg1,nil,chkf)
		tc=sg:GetFirst()
		tc:SetMaterial(sg1)
		-- 将选定的融合素材作为融合素材因效果送去墓地。
		Duel.SendtoGrave(sg1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
		-- 中断当前效果，使送墓与特殊召唤不视为同时处理。
		Duel.BreakEffect()
		-- 将融合怪兽以融合召唤的方式表侧表示特殊召唤。
		Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
	end
	if tc then
		tc:RegisterFlagEffect(9113513,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
		tc:CompleteProcedure()
		-- 这个回合的结束阶段，这个效果融合召唤的怪兽破坏，若那一组融合素材怪兽在自己墓地齐集，可以把那一组特殊召唤。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetCountLimit(1)
		e1:SetLabelObject(tc)
		e1:SetCondition(c9113513.descon)
		e1:SetOperation(c9113513.desop)
		e1:SetReset(RESET_PHASE+PHASE_END)
		-- 注册在回合结束阶段发动效果的全局延迟效果。
		Duel.RegisterEffect(e1,tp)
	end
end
-- 结束阶段效果的发动条件：被融合召唤的怪兽仍带有对应的标记。
function c9113513.descon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:GetFlagEffect(9113513)~=0 then
		return true
	else
		e:Reset()
		return false
	end
end
-- 墓地融合素材特殊召唤的过滤条件：属于当前玩家、在墓地、因作为该怪兽的融合素材送去墓地、可以特殊召唤，且满足该融合怪兽的素材构成。
function c9113513.mgfilter(c,e,tp,fusc,mg)
	return c:IsControler(tp) and c:IsLocation(LOCATION_GRAVE)
		and c:GetReason()&(REASON_FUSION+REASON_MATERIAL)==(REASON_FUSION+REASON_MATERIAL) and c:GetReasonCard()==fusc
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and fusc:CheckFusionMaterial(mg,c,PLAYER_NONE,true)
end
-- 结束阶段效果的处理：破坏融合召唤的怪兽，若素材在墓地齐集，则可以选择将那一组特殊召唤。
function c9113513.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	local mg=tc:GetMaterial()
	local sumtype=tc:GetSummonType()
	-- 尝试因效果破坏该融合怪兽，并检查是否破坏成功。
	if Duel.Destroy(tc,REASON_EFFECT)~=0
		and bit.band(sumtype,SUMMON_TYPE_FUSION)==SUMMON_TYPE_FUSION and mg:GetCount()>0
		-- 检查自己场上的怪兽区域空位数是否足够容纳那一组融合素材。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>=mg:GetCount()
		-- 检查那一组融合素材是否全部存在于墓地（不受王家长眠之谷影响）且均满足特殊召唤条件。
		and mg:IsExists(aux.NecroValleyFilter(c9113513.mgfilter),mg:GetCount(),nil,e,tp,tc,mg)
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		and not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 询问玩家是否发动效果将那一组融合素材特殊召唤。
		and Duel.SelectYesNo(tp,aux.Stringid(9113513,0)) then  --"是否把融合素材怪兽特殊召唤？"
		-- 将那一组融合素材怪兽在自己场上表侧表示特殊召唤。
		Duel.SpecialSummon(mg,0,tp,tp,false,false,POS_FACEUP)
	end
end
