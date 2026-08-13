--セクステット・サモン
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：从自己的手卡·墓地以及自己场上的表侧表示怪兽之中选原本种族相同的怪兽6种类（仪式·融合·同调·超量·灵摆·连接）各1只除外。那之后，原本种族和除外的怪兽相同的1只怪兽从卡组·额外卡组特殊召唤。
function c99162753.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：从自己的手卡·墓地以及自己场上的表侧表示怪兽之中选原本种族相同的怪兽6种类（仪式·融合·同调·超量·灵摆·连接）各1只除外。那之后，原本种族和除外的怪兽相同的1只怪兽从卡组·额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,99162753+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c99162753.target)
	e1:SetOperation(c99162753.activate)
	c:RegisterEffect(e1)
end
-- 生成6个判定函数，分别用于检测卡是否为仪式/融合/同调/超量/灵摆/连接怪兽，方便后续选出这6个种类各1只。
c99162753.spchecks=aux.CreateChecks(Card.IsType,{TYPE_RITUAL,TYPE_FUSION,TYPE_SYNCHRO,TYPE_XYZ,TYPE_PENDULUM,TYPE_LINK})
-- 定义可除外的候选卡条件：手卡·墓地的卡，或场上表侧表示的怪兽；且属于仪式/融合/同调/超量/灵摆/连接中的任一类型；并且可以被除外。
function c99162753.rmfilter(c)
	return (not c:IsLocation(LOCATION_MZONE) or c:IsFaceup()) and c:IsType(TYPE_RITUAL+TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ+TYPE_PENDULUM+TYPE_LINK) and c:IsAbleToRemove()
end
-- 定义子组选择目标：选出的6张卡必须原本种族相同（只有一种原种族），并且存在一张符合条件的卡可以从卡组或额外卡组被特殊召唤。
function c99162753.fgoal(g,e,tp)
	if g:GetClassCount(Card.GetOriginalRace)~=1 then return false end
	-- 检查是否存在满足特殊召唤过滤条件的卡：即存在一只原本种族与所选除外组相同且可被特殊召唤的怪兽。
	return Duel.IsExistingMatchingCard(c99162753.spfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,nil,e,tp,g)
end
-- 定义可被特殊召唤的怪兽过滤条件：其原本种族与已选出的除外组中某一卡的原种族相同，自身满足特殊召唤条件；若来自卡组，还需有可用怪兽区；若来自额外卡组，还需有可用的额外怪兽区。
function c99162753.spfilter(c,e,tp,g)
	-- 判断除外组中是否有与候选卡原本种族相同的卡，并且候选卡自身能够被特殊召唤。
	return g:IsExists(aux.FilterEqualFunction(Card.GetOriginalRace,c:GetOriginalRace()),1,nil) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 若候选卡位于卡组，则还需要在除外那6只怪兽后，自己场上存在可用的主要怪兽区。
		and (c:IsLocation(LOCATION_DECK) and Duel.GetMZoneCount(tp,g)>0
			-- 若候选卡位于额外卡组，则还需要在除外那6只怪兽后，自己场上存在可用的额外怪兽区（或能让额外怪兽出场的空格）。
			or c:IsLocation(LOCATION_EXTRA) and Duel.GetLocationCountFromEx(tp,tp,g,c)>0)
end
-- 发动时的目标处理：获取手卡·场上表侧·墓地的可选除外怪兽组；仅检查阶段判断能否选出6张满足种族和种类要求的卡；随后设置效果处理信息：将除外6张卡，并从卡组·额外卡组特殊召唤1只怪兽。
function c99162753.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 取自己手卡、场上表侧表示怪兽以及墓地中满足可除外条件的怪兽作为候选组。
	local g=Duel.GetMatchingGroup(c99162753.rmfilter,tp,LOCATION_HAND+LOCATION_MZONE+LOCATION_GRAVE,0,nil)
	if chk==0 then return g:CheckSubGroupEach(c99162753.spchecks,c99162753.fgoal,e,tp) end
	-- 设置操作信息：本次效果会从手卡·自己场上表侧表示·墓地中除外6张卡。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,6,tp,LOCATION_HAND+LOCATION_MZONE+LOCATION_GRAVE)
	-- 设置操作信息：本次效果会从卡组·额外卡组特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_EXTRA)
end
-- 效果处理时的操作：重新获取可除外候选组（应用王家长眠之谷的过滤），提示玩家选择要除外的卡，通过子组选择功能选出6张满足条件的卡并除外；若成功除外，则提示玩家选择要特殊召唤的卡，从卡组或额外卡组选出1只满足条件的怪兽，中断效果链后将其特殊召唤。
function c99162753.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取可除外的候选怪兽组，同时在过滤时考虑了王家长眠之谷的效果影响（不受其影响的卡才能除外）。
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(c99162753.rmfilter),tp,LOCATION_HAND+LOCATION_MZONE+LOCATION_GRAVE,0,nil)
	-- 弹出选择提示，让玩家从候选组中选择要除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local rg=g:SelectSubGroupEach(tp,c99162753.spchecks,false,c99162753.fgoal,e,tp)
	-- 若成功选出了6张卡，且实际除外成功，则继续执行后续的特殊召唤处理。
	if rg and rg:GetCount()==6 and Duel.Remove(rg,POS_FACEUP,REASON_EFFECT)~=0 then
		-- 弹出选择提示，让玩家选择要特殊召唤的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从自己的卡组·额外卡组中选1只满足特殊召唤过滤条件的怪兽（原本种族与已除外的6只相同，且能被特殊召唤）。
		local tg=Duel.SelectMatchingCard(tp,c99162753.spfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,1,nil,e,tp,rg)
		if tg:GetCount()>0 then
			-- 中断当前效果处理，使此后的特殊召唤与之前的除外处理视为不同时进行，避免错过时点。
			Duel.BreakEffect()
			-- 将选择的那只怪兽以表侧表示特殊召唤到自己场上；不检查其召唤条件，也不受苏生限制。
			Duel.SpecialSummon(tg,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
