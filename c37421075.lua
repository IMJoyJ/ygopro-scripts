--強制退化
-- 效果：
-- 把自己场上1只4星以上的恐龙族怪兽解放发动。从自己的手卡·墓地把2只3星以下的爬虫类族怪兽特殊召唤。
function c37421075.initial_effect(c)
	-- 效果发动条件设置：将效果注册为魔法卡的发动效果，自由连锁时点，消耗为解放1只4星以上恐龙族怪兽，目标为特殊召唤2只3星以下爬虫类怪兽，操作为特殊召唤效果
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
-- 过滤条件：判断卡是否为4星以上恐龙族怪兽
function c37421075.cfilter(c)
	return c:IsLevelAbove(4) and c:IsRace(RACE_DINOSAUR)
end
-- 效果消耗：设置发动时的消耗为解放1只满足条件的怪兽
function c37421075.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	-- 检查是否满足发动条件：检测场上是否存在满足条件的可解放怪兽
	if chk==0 then return Duel.CheckReleaseGroup(tp,c37421075.cfilter,1,nil) end
	-- 选择要解放的怪兽：从场上选择1只满足条件的怪兽进行解放
	local rg=Duel.SelectReleaseGroup(tp,c37421075.cfilter,1,1,nil)
	-- 执行解放操作：将选中的怪兽以支付代价的方式进行解放
	Duel.Release(rg,REASON_COST)
end
-- 过滤条件：判断卡是否为3星以下爬虫类怪兽且可以特殊召唤
function c37421075.spfilter(c,e,tp)
	return c:IsLevelBelow(3) and c:IsRace(RACE_REPTILE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果目标：检查是否满足发动条件，包括未受青眼精灵龙影响、手牌和墓地存在2只以上满足条件的怪兽、召唤区域足够
function c37421075.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=(e:GetLabel()==1)
		e:SetLabel(0)
		-- 获取可用召唤区域数量：获取玩家场上可用的怪兽区域数量
		local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		return not Duel.IsPlayerAffectedByEffect(tp,59822133)
			-- 检查是否存在满足条件的怪兽：检测手牌和墓地是否存在至少2只满足条件的怪兽
			and Duel.IsExistingMatchingCard(c37421075.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,2,nil,e,tp)
			and ((chkf and ft>0) or (not chkf and ft>1))
	end
	-- 设置操作信息：设置效果处理时将要特殊召唤的怪兽数量为2只，来源为手牌和墓地
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_HAND+LOCATION_GRAVE)
	e:SetLabel(0)
end
-- 效果发动：执行特殊召唤操作，包括检测青眼精灵龙影响、召唤区域是否足够、选择并特殊召唤2只满足条件的怪兽
function c37421075.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 检查召唤区域是否足够：检测场上是否至少有2个可用召唤区域
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<2 then return end
	-- 获取满足条件的怪兽组：从手牌和墓地中获取满足条件的怪兽组，排除受王家长眠之谷影响的怪兽
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(c37421075.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,nil,e,tp)
	if g:GetCount()>1 then
		-- 提示选择：提示玩家选择要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=g:Select(tp,2,2,nil)
		-- 执行特殊召唤：将选中的怪兽以正面表示的方式特殊召唤到场上
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
	end
end
