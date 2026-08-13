--強制退化
-- 效果：
-- 把自己场上1只4星以上的恐龙族怪兽解放发动。从自己的手卡·墓地把2只3星以下的爬虫类族怪兽特殊召唤。
function c37421075.initial_effect(c)
	-- 把自己场上1只4星以上的恐龙族怪兽解放发动。从自己的手卡·墓地把2只3星以下的爬虫类族怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetCost(c37421075.cost)
	e1:SetTarget(c37421075.target)
	e1:SetOperation(c37421075.activate)
	c:RegisterEffect(e1)
end
-- 过滤出等级4以上且恐龙族的怪兽，作为解放的候选。
function c37421075.cfilter(c)
	return c:IsLevelAbove(4) and c:IsRace(RACE_DINOSAUR)
end
-- 发动代价：从自己场上选择1只4星以上的恐龙族怪兽解放。
function c37421075.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	-- 在发动合法性检查时，确认场上是否存在1只满足条件的恐龙族怪兽可作为解放代价。
	if chk==0 then return Duel.CheckReleaseGroup(tp,c37421075.cfilter,1,nil) end
	-- 选择1只满足条件的恐龙族怪兽用于解放。
	local rg=Duel.SelectReleaseGroup(tp,c37421075.cfilter,1,1,nil)
	-- 将选择的怪兽解放，作为卡牌发动的代价。
	Duel.Release(rg,REASON_COST)
end
-- 过滤出等级3以下、爬虫类族且可以被特殊召唤的怪兽，作为特殊召唤的候选。
function c37421075.spfilter(c,e,tp)
	return c:IsLevelBelow(3) and c:IsRace(RACE_REPTILE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 发动条件判定：若场上没有【青眼精灵龙】的“双方不能把2只以上的怪兽同时特殊召唤”效果，且手卡·墓地存在至少2只满足条件的爬虫类族怪兽；若代价已支付（已解放1只）则需要1个空格，否则需要2个空格。条件满足后设置特殊召唤2只怪兽的操作信息。
function c37421075.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=(e:GetLabel()==1)
		e:SetLabel(0)
		-- 获取自己场上可用的主要怪兽区域空格数。
		local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		return not Duel.IsPlayerAffectedByEffect(tp,59822133)
			-- 检查手卡·墓地是否存在至少2只满足特殊召唤过滤条件的爬虫类族怪兽。
			and Duel.IsExistingMatchingCard(c37421075.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,2,nil,e,tp)
			and ((chkf and ft>0) or (not chkf and ft>1))
	end
	-- 设置本次效果处理为：从手卡·墓地特殊召唤2只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_HAND+LOCATION_GRAVE)
	e:SetLabel(0)
end
-- 效果处理：若场上没有【青眼精灵龙】的禁止同时特殊召唤2只以上怪兽效果，且自己可用怪兽区域不少于2个，则从手卡·墓地选择2只满足条件的爬虫类族怪兽特殊召唤。
function c37421075.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 自己可用怪兽区域不足2个时，效果处理不执行。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<2 then return end
	-- 获取手卡·墓地中满足条件的爬虫类族怪兽集合，并通过王家长眠之谷过滤器排除不能特殊召唤的卡。
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(c37421075.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,nil,e,tp)
	if g:GetCount()>1 then
		-- 显示选择提示，让玩家选择要特殊召唤的卡片。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=g:Select(tp,2,2,nil)
		-- 将选择的2只怪兽以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
	end
end
