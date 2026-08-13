--ネクロイド・シンクロ
-- 效果：
-- ①：调整1只和调整以外的怪兽最多2只从自己墓地除外，把持有和除外的怪兽的等级合计相同等级的1只「星尘」同调怪兽从额外卡组当作同调召唤作特殊召唤。这个效果特殊召唤的怪兽的效果无效化。
function c26194151.initial_effect(c)
	-- ①：调整1只和调整以外的怪兽最多2只从自己墓地除外，把持有和除外的怪兽的等级合计相同等级的1只「星尘」同调怪兽从额外卡组当作同调召唤作特殊召唤。这个效果特殊召唤的怪兽的效果无效化。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c26194151.target)
	e1:SetOperation(c26194151.activate)
	c:RegisterEffect(e1)
end
-- 筛选可作为同调召唤对象的「星尘」同调怪兽：获取其等级，要求其为「星尘」字段的同调怪兽、能以同调召唤方式特殊召唤、己方额外怪兽区有空位，且墓地中存在符合条件的调整怪兽（filter2）。
function c26194151.filter1(c,e,tp)
	local lv=c:GetLevel()
	return c:IsSetCard(0xa3) and c:IsType(TYPE_SYNCHRO)
		-- 检查该怪兽能否被当前效果以同调召唤方式特殊召唤，以及己方额外怪兽区是否有足够的空格供额外卡组的怪兽出场。
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_SYNCHRO,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
		-- 检查己方墓地是否存在至少1只满足filter2条件的调整怪兽：其等级小于目标同调怪兽等级，且剩余等级可由1~2只非调整怪兽补足，并能被除外。
		and Duel.IsExistingMatchingCard(c26194151.filter2,tp,LOCATION_GRAVE,0,1,nil,tp,lv)
end
-- 筛选可作为同调素材的调整怪兽：计算其与目标同调怪兽的等级差rlv，要求自身是调整、可除外、rlv大于0，且墓地中存在1~2只非调整怪兽（filter3）的等级合计等于rlv。
function c26194151.filter2(c,tp,lv)
	local rlv=lv-c:GetLevel()
	-- 获取己方墓地中除当前调整怪兽外的所有满足filter3条件的非调整怪兽，作为候选素材组。
	local rg=Duel.GetMatchingGroup(c26194151.filter3,tp,LOCATION_GRAVE,0,c)
	return rlv>0 and c:IsType(TYPE_TUNER) and c:IsAbleToRemove()
		and rg:CheckWithSumEqual(Card.GetLevel,rlv,1,2)
end
-- 筛选可作为同调素材的非调整怪兽：等级大于0、不是调整怪兽、且可以被除外。
function c26194151.filter3(c)
	return c:GetLevel()>0 and not c:IsType(TYPE_TUNER) and c:IsAbleToRemove()
end
-- 效果发动时的合法检测：确认没有『必须作为同调素材』效果的限制，且额外卡组中存在至少1只满足filter1条件的「星尘」同调怪兽可被特殊召唤。
function c26194151.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检测：确认场上/墓地没有怪兽被『必须作为同调素材』效果（如波动龙声子龙）限制，否则不能发动。
	if chk==0 then return aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_SMATERIAL)
		-- 并确认额外卡组存在至少1只满足filter1条件的「星尘」同调怪兽可供选择。
		and Duel.IsExistingMatchingCard(c26194151.filter1,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	-- 设置操作信息：声明本效果将进行特殊召唤，预定义从额外卡组特殊召唤1只怪兽（实际对象在效果处理时确定，因此目标组为nil）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果处理：从额外卡组选择1只符合条件的「星尘」同调怪兽；从墓地选择1只调整怪兽和1~2只非调整怪兽（合计等级等于目标怪兽等级）予以除外；将目标怪兽当作同调召唤特殊召唤，并使其效果无效化。
function c26194151.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理前再次确认没有『必须作为同调素材』效果的限制，若有则本效果不处理。
	if not aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_SMATERIAL) then return end
	-- 弹出提示，要求玩家选择要特殊召唤的卡（从额外卡组选择）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家从额外卡组中选择1只满足filter1条件的「星尘」同调怪兽作为特殊召唤对象。
	local g1=Duel.SelectMatchingCard(tp,c26194151.filter1,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
	local tc=g1:GetFirst()
	if tc then
		local lv=tc:GetLevel()
		-- 弹出提示，要求玩家选择要除外的卡（第一张：调整怪兽）。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		-- 玩家从墓地中选择1只满足filter2条件的调整怪兽作为同调素材（其等级必须小于目标怪兽等级且剩余等级可由非调整怪兽补足）。
		local g2=Duel.SelectMatchingCard(tp,c26194151.filter2,tp,LOCATION_GRAVE,0,1,1,nil,tp,lv)
		local rlv=lv-g2:GetFirst():GetLevel()
		-- 在墓地中检索除已选调整怪兽以外的、满足filter3条件的非调整怪兽，作为后续候选素材组。
		local rg=Duel.GetMatchingGroup(c26194151.filter3,tp,LOCATION_GRAVE,0,g2:GetFirst())
		-- 再次弹出提示，要求玩家选择要除外的非调整怪兽（最多2只）。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		local g3=rg:SelectWithSumEqual(tp,Card.GetLevel,rlv,1,2)
		g2:Merge(g3)
		-- 将已选择的调整怪兽和非调整怪兽（已合并入g2）以表侧表示除外，作为同调召唤的素材。
		Duel.Remove(g2,POS_FACEUP,REASON_EFFECT)
		tc:SetMaterial(nil)
		-- 以同调召唤方式将目标「星尘」同调怪兽特殊召唤到己方场上（分步处理的一步，不检查召唤条件与苏生限制）。
		Duel.SpecialSummonStep(tc,SUMMON_TYPE_SYNCHRO,tp,tp,false,false,POS_FACEUP)
		-- 这个效果特殊召唤的怪兽的效果无效化。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1,true)
		-- 这个效果特殊召唤的怪兽的效果无效化。
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2,true)
		tc:CompleteProcedure()
		-- 完成特殊召唤处理流程，结束SpecialSummonStep的批处理，触发召唤成功时点。
		Duel.SpecialSummonComplete()
	end
end
