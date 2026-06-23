--プロンプトホーン
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：把自己场上1只4星以下的电子界族怪兽解放才能发动。等级合计直到变成和解放的怪兽的等级相同为止，从自己的卡组·墓地选电子界族通常怪兽任意数量特殊召唤。这个效果特殊召唤的怪兽在结束阶段除外。
function c50548657.initial_effect(c)
	-- 创建效果，设置效果描述、分类、类型、适用区域、使用次数限制、费用、目标和效果处理函数
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
-- 过滤满足条件的可解放怪兽，包括等级不超过4星、种族为电子界、场上存在可用区域且满足等级合计条件
function c50548657.costfilter(c,e,tp,g,ft)
	local lv=c:GetLevel()
	-- 检查怪兽是否等级不超过4星、种族为电子界、场上存在可用区域且为己方控制或正面表示
	return c:IsLevelBelow(4) and c:IsRace(RACE_CYBERSE) and Duel.GetMZoneCount(tp,c)>0 and (c:IsControler(tp) or c:IsFaceup())
		and g:CheckWithSumEqual(Card.GetLevel,lv,1,ft+1)
end
-- 过滤满足条件的电子界通常怪兽，用于特殊召唤
function c50548657.spfilter(c,e,tp)
	return c:IsRace(RACE_CYBERSE) and c:IsType(TYPE_NORMAL) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 处理效果费用，检索满足条件的卡组/墓地中的电子界通常怪兽，并选择一只4星以下的电子界族怪兽进行解放
function c50548657.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取玩家卡组和墓地中所有符合条件的电子界通常怪兽
	local g=Duel.GetMatchingGroup(c50548657.spfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,nil,e,tp)
	-- 获取玩家场上可用的怪兽区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if ft>1 and Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 检查是否满足费用条件，即场上存在可解放的怪兽且满足等级合计要求
	if chk==0 then return ft>-1 and Duel.CheckReleaseGroup(tp,c50548657.costfilter,1,nil,e,tp,g,ft) end
	-- 选择一只满足条件的怪兽进行解放
	local sg=Duel.SelectReleaseGroup(tp,c50548657.costfilter,1,1,nil,e,tp,g,ft)
	e:SetLabel(sg:GetFirst():GetLevel())
	-- 将选中的怪兽从场上解放作为效果的费用
	Duel.Release(sg,REASON_COST)
end
-- 设置效果目标，确定特殊召唤的卡牌数量和来源位置
function c50548657.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息，表示将从卡组或墓地特殊召唤电子界通常怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
-- 处理效果发动后的操作，包括检索符合条件的怪兽并特殊召唤，以及在结束阶段除外这些怪兽
function c50548657.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取玩家场上可用的怪兽区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if ft>1 and Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 获取玩家卡组和墓地中所有不受王家长眠之谷影响的电子界通常怪兽
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(c50548657.spfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,nil,e,tp)
	if ft<=0 or g:GetCount()==0 then return end
	-- 提示玩家选择要特殊召唤的卡牌
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	local sg=g:SelectWithSumEqual(tp,Card.GetLevel,e:GetLabel(),1,ft)
	if sg:GetCount()>0 then
		local fid=e:GetHandler():GetFieldID()
		local tc=sg:GetFirst()
		while tc do
			-- 将一张怪兽特殊召唤到场上
			Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
			tc:RegisterFlagEffect(50548657,RESET_EVENT+RESETS_STANDARD,0,1,fid)
			tc=sg:GetNext()
		end
		-- 完成一次或多次特殊召唤操作
		Duel.SpecialSummonComplete()
		sg:KeepAlive()
		-- 创建一个在结束阶段触发的效果，用于除外通过此效果特殊召唤的怪兽
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetCountLimit(1)
		e1:SetLabel(fid)
		e1:SetLabelObject(sg)
		e1:SetCondition(c50548657.rmcon)
		e1:SetOperation(c50548657.rmop)
		-- 注册该效果至玩家的全局环境
		Duel.RegisterEffect(e1,tp)
	end
end
-- 判断一张卡是否为本次效果特殊召唤的怪兽
function c50548657.rmfilter(c,fid)
	return c:GetFlagEffectLabel(50548657)==fid
end
-- 判断是否满足除外条件，即是否有特殊召唤的怪兽存在
function c50548657.rmcon(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	if not g:IsExists(c50548657.rmfilter,1,nil,e:GetLabel()) then
		g:DeleteGroup()
		e:Reset()
		return false
	else return true end
end
-- 将符合条件的怪兽从场上除外
function c50548657.rmop(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	local tg=g:Filter(c50548657.rmfilter,nil,e:GetLabel())
	-- 将目标怪兽以正面表示形式除外
	Duel.Remove(tg,POS_FACEUP,REASON_EFFECT)
end
