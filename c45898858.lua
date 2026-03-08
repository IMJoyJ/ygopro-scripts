--ボンディング－H2O
-- 效果：
-- ①：把自己场上2只「氢素龙」和1只「氧素龙」解放才能发动。从自己的手卡·卡组·墓地把1只「水龙」特殊召唤。
function c45898858.initial_effect(c)
	-- ①：把自己场上2只「氢素龙」和1只「氧素龙」解放才能发动。从自己的手卡·卡组·墓地把1只「水龙」特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c45898858.cost)
	e1:SetTarget(c45898858.target)
	e1:SetOperation(c45898858.activate)
	c:RegisterEffect(e1)
end
-- 创建一个检查函数数组，用于验证是否满足解放2只「氢素龙」和1只「氧素龙」的条件
c45898858.spchecks=aux.CreateChecks(Card.IsCode,{22587018,22587018,58071123})
-- 过滤函数，用于筛选场上满足条件的「氢素龙」或「氧素龙」怪兽
function c45898858.costfilter(c,tp)
	return c:IsCode(22587018,58071123) and (c:IsControler(tp) or c:IsFaceup())
end
-- 效果发动时的费用处理，检查是否满足解放条件并选择要解放的怪兽
function c45898858.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	-- 获取玩家可解放的怪兽组，并筛选出符合条件的「氢素龙」或「氧素龙」
	local g=Duel.GetReleaseGroup(tp):Filter(c45898858.costfilter,nil,tp)
	-- 检查所选怪兽组是否满足解放条件
	if chk==0 then return g:CheckSubGroupEach(c45898858.spchecks,aux.mzctcheckrel,tp) end
	-- 提示玩家选择要解放的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	-- 选择满足条件的怪兽组用于解放
	local rg=g:SelectSubGroupEach(tp,c45898858.spchecks,false,aux.mzctcheckrel,tp)
	-- 使用代替解放次数，处理如暗影敌托邦等效果
	aux.UseExtraReleaseCount(rg,tp)
	-- 实际执行解放操作
	Duel.Release(rg,REASON_COST)
end
-- 过滤函数，用于筛选可特殊召唤的「水龙」
function c45898858.filter(c,e,tp)
	return c:IsCode(85066822) and c:IsCanBeSpecialSummoned(e,0,tp,true,true)
end
-- 效果的发动条件判断，检查是否有满足条件的「水龙」可特殊召唤
function c45898858.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足特殊召唤的条件
	local res=e:GetLabel()==1 or Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	if chk==0 then
		e:SetLabel(0)
		-- 检查场上是否有满足条件的「水龙」可特殊召唤
		return res and Duel.IsExistingMatchingCard(c45898858.filter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp)
	end
	-- 设置效果处理信息，确定特殊召唤的目标
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE)
end
-- 效果的发动处理，选择并特殊召唤「水龙」
function c45898858.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否有足够的召唤位置
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的「水龙」
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的「水龙」用于特殊召唤
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c45898858.filter),tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的「水龙」特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,true,true,POS_FACEUP)
		g:GetFirst():CompleteProcedure()
	end
end
