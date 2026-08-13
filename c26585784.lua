--K9－EW特殊解除実験
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：从自己的手卡·墓地把1只「K9」怪兽特殊召唤。那之后，可以把1只「K9」超量怪兽在这个效果特殊召唤的怪兽上面重叠当作超量召唤从额外卡组特殊召唤。这个效果从额外卡组特殊召唤的怪兽在下个回合的结束阶段破坏。
-- ②：自己·对方的结束阶段，把墓地的这张卡除外，以自己墓地1张「K9」速攻魔法卡为对象才能发动。那张卡在自己场上盖放。
local s,id,o=GetID()
-- 创建并注册本卡的两个效果：①效果为发动型的魔法卡效果，可特殊召唤「K9」怪兽并可选进行超量召唤；②效果为在墓地可发动的二速效果，在结束阶段除外自身并盖放墓地的「K9」速攻魔法卡；两者各自1回合1次。
function s.initial_effect(c)
	-- ①：从自己的手卡·墓地把1只「K9」怪兽特殊召唤。那之后，可以把1只「K9」超量怪兽在这个效果特殊召唤的怪兽上面重叠当作超量召唤从额外卡组特殊召唤。这个效果从额外卡组特殊召唤的怪兽在下个回合的结束阶段破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END+TIMING_END_PHASE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：自己·对方的结束阶段，把墓地的这张卡除外，以自己墓地1张「K9」速攻魔法卡为对象才能发动。那张卡在自己场上盖放。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"盖放"
	e2:SetCategory(CATEGORY_SSET)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetHintTiming(TIMING_END_PHASE)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.setcon)
	-- 设置②效果的发动COST为将墓地的这张卡除外（aux.bfgcost）。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.settg)
	e2:SetOperation(s.setop)
	c:RegisterEffect(e2)
end
-- 定义①效果中可特殊召唤的怪兽过滤条件：必须是「K9」怪兽，且能被当前效果特殊召唤。
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x1cb) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①效果发动时的合法性检测：自己主要怪兽区有空位，且在手卡·墓地存在1只满足特殊召唤条件的「K9」怪兽。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上主要怪兽区是否有可用空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己的手卡·墓地是否存在至少1只满足s.spfilter条件的「K9」怪兽。
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置操作信息：本效果将进行特殊召唤，对象数量为1，来源为手卡·墓地。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- 定义超量召唤的过滤条件：额外卡组的「K9」超量怪兽可以以刚特殊召唤的怪兽为超量素材，并能够以超量召唤方式特殊召唤，且额外怪兽区域有空位（考虑素材移走后）。
function s.xyzfilter(c,e,tp,mc)
	return c:IsSetCard(0x1cb) and mc:IsCanBeXyzMaterial(c)
		-- 额外卡组的「K9」超量怪兽必须可以以超量召唤方式特殊召唤，且额外怪兽区域有空位（素材离场后仍够）。
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0
end
-- ①效果处理：先从手卡·墓地选1只「K9」怪兽特殊召唤，成功后询问是否进行超量召唤；若进行，则选择额外卡组的「K9」超量怪兽叠放在其上方超量召唤，并为该超量怪兽注册在下个结束阶段破坏的效果。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时再次确认主要怪兽区有空位，否则结束效果处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 给玩家显示提示消息，要求选择要特殊召唤的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己的手卡·墓地选择1只满足条件的「K9」怪兽（过滤时排除受王家长眠之谷影响的卡）。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	-- 将选择的怪兽表侧攻击表示特殊召唤；若特殊召唤成功则继续处理。
	if tc and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- 刷新场地信息，使后续判断基于最新状态。
		Duel.AdjustAll()
		-- 确认刚特殊召唤的怪兽可以作为超量素材，且额外卡组中存在可进行超量召唤的「K9」超量怪兽。
		if aux.MustMaterialCheck(tc,tp,EFFECT_MUST_BE_XMATERIAL) and Duel.IsExistingMatchingCard(s.xyzfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,tc)
			-- 询问玩家是否要发动追加的超量召唤效果。
			and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否超量召唤？"
			-- 中断当前效果处理，使之后的超量召唤作为不同时点处理，避免错过时点。
			Duel.BreakEffect()
			-- 给玩家显示提示消息，要求选择要超量召唤的卡片。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			-- 从额外卡组选择1只满足条件的「K9」超量怪兽。
			local sg=Duel.SelectMatchingCard(tp,s.xyzfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,tc)
			local sc=sg:GetFirst()
			if sc then
				local mg=tc:GetOverlayGroup()
				if mg:GetCount()~=0 then
					-- 若原来怪兽下方已有超量素材，先将这些素材移到新超量怪兽下方。
					Duel.Overlay(sc,mg)
				end
				sc:SetMaterial(Group.FromCards(tc))
				-- 将刚特殊召唤的怪兽作为超量素材叠放在新超量怪兽下方。
				Duel.Overlay(sc,Group.FromCards(tc))
				-- 以超量召唤方式将选择的超量怪兽特殊召唤到自己的额外怪兽区域。
				Duel.SpecialSummon(sc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)
				sc:CompleteProcedure()
				sc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,2)
				-- 这个效果从额外卡组特殊召唤的怪兽在下个回合的结束阶段破坏。②：自己·对方的结束阶段，把墓地的这张卡除外，以自己墓地1张「K9」速攻魔法卡为对象才能发动。那张卡在自己场上盖放。
				local e1=Effect.CreateEffect(e:GetHandler())
				e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
				e1:SetCode(EVENT_PHASE+PHASE_END)
				e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
				e1:SetCondition(s.descon)
				e1:SetOperation(s.desop)
				e1:SetReset(RESET_PHASE+PHASE_END,2)
				e1:SetCountLimit(1)
				-- 记录当前回合数，用于判断‘下个回合’的结束阶段（只有回合数变化后才触发破坏）。
				e1:SetLabel(Duel.GetTurnCount())
				e1:SetLabelObject(sc)
				-- 将破坏效果注册到场地，使其在结束阶段时点生效。
				Duel.RegisterEffect(e1,tp)
			end
		end
	end
end
-- 破坏效果的发动条件：已进入下个回合（当前回合数不等于记录值），且被特殊召唤的怪兽仍持有本效果标记。
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	-- 当前回合数已变化（已到下个回合）且该怪兽带有此效果标记。
	return Duel.GetTurnCount()~=e:GetLabel() and tc:GetFlagEffect(id)>0
end
-- 破坏效果处理：将标记的超量怪兽破坏。
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	-- 以效果原因将那只怪兽破坏。
	Duel.Destroy(tc,REASON_EFFECT)
end
-- 定义②效果可选择盖放的卡过滤条件：自己墓地的「K9」速攻魔法卡且可以盖放。
function s.setfilter(c)
	return c:IsSetCard(0x1cb) and c:IsType(TYPE_QUICKPLAY) and c:IsSSetable()
end
-- ②效果的发动条件：当前为结束阶段（自己或对方的结束阶段均可）。
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	-- 当前阶段是结束阶段。
	return Duel.GetCurrentPhase()==PHASE_END
end
-- ②效果的取对象处理：从自己墓地选择1张「K9」速攻魔法卡作为对象，并设置让对象离墓地的操作信息。
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and s.setfilter(chkc) end
	-- 检查自己墓地是否存在1张满足条件的「K9」速攻魔法卡可作为对象。
	if chk==0 then return Duel.IsExistingTarget(s.setfilter,tp,LOCATION_GRAVE,0,1,c) end
	-- 给玩家显示提示消息，要求选择要盖放的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 从自己墓地选择1张满足条件的「K9」速攻魔法卡作为效果对象。
	local g=Duel.SelectTarget(tp,s.setfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置操作信息：该对象会离开墓地，用于后续盖放处理。
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
end
-- ②效果处理：取得对象卡，若仍与效果相关且不受王家长眠之谷影响，则将其盖放到自己场上。
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得②效果选择的墓地对象卡。
	local tc=Duel.GetFirstTarget()
	-- 确认对象仍在墓地且与效果保持关联，且不受王家长眠之谷影响。
	if tc:IsRelateToEffect(e) and aux.NecroValleyFilter()(tc) then
		-- 将那张「K9」速攻魔法卡盖放到自己场上。
		Duel.SSet(tp,tc)
	end
end
