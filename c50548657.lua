--プロンプトホーン
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：把自己场上1只4星以下的电子界族怪兽解放才能发动。等级合计直到变成和解放的怪兽的等级相同为止，从自己的卡组·墓地选电子界族通常怪兽任意数量特殊召唤。这个效果特殊召唤的怪兽在结束阶段除外。
function c50548657.initial_effect(c)
	-- 这个卡名的效果1回合只能使用1次。①：把自己场上1只4星以下的电子界族怪兽解放才能发动。等级合计直到变成和解放的怪兽的等级相同为止，从自己的卡组·墓地选电子界族通常怪兽任意数量特殊召唤。这个效果特殊召唤的怪兽在结束阶段除外。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(50548657,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,50548657)
	e1:SetCost(c50548657.spcost)
	e1:SetTarget(c50548657.sptg)
	e1:SetOperation(c50548657.spop)
	c:RegisterEffect(e1)
end
-- 定义解放候补的过滤条件：被解放的怪兽必须是4星以下电子界族，且解放后场上仍有可用怪兽区；同时卡组·墓地中必须存在等级合计等于该怪兽等级的电子界族通常怪兽组合，且组合数量在1到可特殊召唤上限之间。
function c50548657.costfilter(c,e,tp,g,ft)
	local lv=c:GetLevel()
	-- 判断被解放怪兽本身满足4星以下、电子界族，并且解放后仍有空格可供特殊召唤，且该怪兽是自己控制或表侧表示。
	return c:IsLevelBelow(4) and c:IsRace(RACE_CYBERSE) and Duel.GetMZoneCount(tp,c)>0 and (c:IsControler(tp) or c:IsFaceup())
		and g:CheckWithSumEqual(Card.GetLevel,lv,1,ft+1)
end
-- 定义可特殊召唤的怪兽的过滤条件：电子界族通常怪兽，并且满足通过效果进行特殊召唤的常规限制。
function c50548657.spfilter(c,e,tp)
	return c:IsRace(RACE_CYBERSE) and c:IsType(TYPE_NORMAL) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果的代价处理：从自己场上选择1只4星以下的电子界族怪兽解放，同时确认卡组·墓地中有足够怪兽可特殊召唤；将解放怪兽的等级存入效果标签，供后续处理使用。若场上受“青眼精灵龙”效果影响，则可用怪兽区上限视为1。
function c50548657.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 取得自己卡组和墓地中所有满足特殊召唤条件的电子界族通常怪兽集合，用于检查等级合计是否可达。
	local g=Duel.GetMatchingGroup(c50548657.spfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,nil,e,tp)
	-- 获取自己场上当前可用的怪兽区空格数，用于限制后续特殊召唤的数量。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if ft>1 and Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 在发动合法性检查时，确认存在1只可解放的怪兽，解放后仍有至少1个可用怪兽区，并且卡组·墓地中存在等级合计等于解放怪兽等级的组合。
	if chk==0 then return ft>-1 and Duel.CheckReleaseGroup(tp,c50548657.costfilter,1,nil,e,tp,g,ft) end
	-- 让玩家从自己场上选择1只满足解放条件的电子界族怪兽作为代价。
	local sg=Duel.SelectReleaseGroup(tp,c50548657.costfilter,1,1,nil,e,tp,g,ft)
	e:SetLabel(sg:GetFirst():GetLevel())
	-- 将选择的怪兽作为发动代价解放。
	Duel.Release(sg,REASON_COST)
end
-- 效果发动时的目标设定：效果必定可发动，并将本次操作登记为包含特殊召唤的处理。
function c50548657.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 在连锁处理信息中登记本次效果将进行特殊召唤，并标明涉及的区域为卡组和墓地。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
-- 效果处理：在可用怪兽区数量的限制下，从卡组·墓地选择等级合计等于解放怪兽等级的电子界族通常怪兽（1只以上任意数量）进行特殊召唤，并对每只特殊召唤的怪兽附加结束阶段除外的标记与处理效果。
function c50548657.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上当前可用的怪兽区空格数，用于限制特殊召唤的数量。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if ft>1 and Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 从自己卡组和墓地取得满足特殊召唤条件的电子界族通常怪兽集合，并使用“王家长眠之谷”过滤，使受其影响无法从墓地特殊召唤的卡不会被选择。
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(c50548657.spfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,nil,e,tp)
	if ft<=0 or g:GetCount()==0 then return end
	-- 提示玩家进入特殊召唤怪兽的选择界面，并显示“请选择要特殊召唤的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	local sg=g:SelectWithSumEqual(tp,Card.GetLevel,e:GetLabel(),1,ft)
	if sg:GetCount()>0 then
		local fid=e:GetHandler():GetFieldID()
		local tc=sg:GetFirst()
		while tc do
			-- 将选中怪兽以表侧表示特殊召唤，作为多只连续特殊召唤流程中的一步。
			Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
			tc:RegisterFlagEffect(50548657,RESET_EVENT+RESETS_STANDARD,0,1,fid)
			tc=sg:GetNext()
		end
		-- 结束连续特殊召唤处理，完成所有怪兽的特殊召唤。
		Duel.SpecialSummonComplete()
		sg:KeepAlive()
		-- 这个效果特殊召唤的怪兽在结束阶段除外。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetCountLimit(1)
		e1:SetLabel(fid)
		e1:SetLabelObject(sg)
		e1:SetCondition(c50548657.rmcon)
		e1:SetOperation(c50548657.rmop)
		-- 将结束阶段除外效果注册到场上，使其在结束阶段触发并执行除外处理。
		Duel.RegisterEffect(e1,tp)
	end
end
-- 判断怪兽是否带有本次特殊召唤时赋予的标记 fid，用于筛选出“这个效果特殊召唤的怪兽”。
function c50548657.rmfilter(c,fid)
	return c:GetFlagEffectLabel(50548657)==fid
end
-- 结束阶段除外效果的发动条件：若场上仍存在带有对应标记的怪兽则执行除外；若已不存在则清理无用的组并重置该效果。
function c50548657.rmcon(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	if not g:IsExists(c50548657.rmfilter,1,nil,e:GetLabel()) then
		g:DeleteGroup()
		e:Reset()
		return false
	else return true end
end
-- 结束阶段除外效果的处理函数：从保存的怪兽组中筛选出带有对应标记的怪兽，执行除外。
function c50548657.rmop(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	local tg=g:Filter(c50548657.rmfilter,nil,e:GetLabel())
	-- 将满足条件的怪兽以表侧表示方式除外，除外理由是效果处理。
	Duel.Remove(tg,POS_FACEUP,REASON_EFFECT)
end
