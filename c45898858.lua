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
-- 创建三个卡号判定函数，分别验证卡片是否为氢素龙、氢素龙、氧素龙，用于后续选择解放素材时精确凑齐2张氢素龙和1张氧素龙。
c45898858.spchecks=aux.CreateChecks(Card.IsCode,{22587018,22587018,58071123})
-- 定义解放素材过滤条件：卡片必须是「氢素龙」或「氧素龙」，且满足可解放条件（控制者为己方或表侧表示），用于从可解放的怪兽中筛出候选。
function c45898858.costfilter(c,tp)
	return c:IsCode(22587018,58071123) and (c:IsControler(tp) or c:IsFaceup())
end
-- 发动代价处理：先检查能否从可解放怪兽中选出2只氢素龙和1只氧素龙且解放后主怪兽区仍有空位；随后让玩家选择要解放的怪兽并解放，作为发动效果的代价。
function c45898858.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	-- 获取己方可解放的怪兽组，并用costfilter过滤出包含「氢素龙」或「氧素龙」的候选解放素材组。
	local g=Duel.GetReleaseGroup(tp):Filter(c45898858.costfilter,nil,tp)
	-- 在合法性检查中，确认候选组里存在一个子组能同时满足2只氢素龙和1只氧素龙的数量要求，且解放后主怪兽区仍有空位。
	if chk==0 then return g:CheckSubGroupEach(c45898858.spchecks,aux.mzctcheckrel,tp) end
	-- 向玩家显示提示消息，要求选择要解放的卡片（HINTMSG_RELEASE）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	-- 让玩家从候选素材中选出一组满足2氢素龙+1氧素龙的卡片，且解放后不影响主怪兽区空位，作为本次解放的素材。
	local rg=g:SelectSubGroupEach(tp,c45898858.spchecks,false,aux.mzctcheckrel,tp)
	-- 如果有代替解放次数效果的卡片（如暗影敌托邦等），消耗相应的额外解放次数，保证解放手续正确。
	aux.UseExtraReleaseCount(rg,tp)
	-- 将选中的卡片以代价（REASON_COST）解放，完成发动所需的解放cost。
	Duel.Release(rg,REASON_COST)
end
-- 定义特殊召唤对象过滤器：卡片必须是「水龙」（卡号85066822），且可以被当前效果以无召唤条件、无苏生限制的方式特殊召唤。
function c45898858.filter(c,e,tp)
	return c:IsCode(85066822) and c:IsCanBeSpecialSummoned(e,0,tp,true,true)
end
-- 发动目标检查：在cost确认后或主怪兽区有空位的前提下，检查手卡·卡组·墓地是否存在可特殊召唤的「水龙」；若存在则登记特殊召唤操作。
function c45898858.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 计算主怪兽区空位是否满足：若cost已经执行（标记为1）则视为有空位，否则检查当前主怪兽区空位数是否大于0。
	local res=e:GetLabel()==1 or Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	if chk==0 then
		e:SetLabel(0)
		-- 发动合法性判定：空位条件满足，且在己方手卡·卡组·墓地中至少存在1张满足特殊召唤条件的「水龙」。
		return res and Duel.IsExistingMatchingCard(c45898858.filter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp)
	end
	-- 登记连锁操作信息：本次效果将进行特殊召唤，检索范围为手卡·卡组·墓地，数量为1，供后续效果（如星尘龙等）参照。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE)
end
-- 效果处理：在保证主怪兽区有空位的前提下，从手卡·卡组·墓地选择1张「水龙」特殊召唤到己方场上，并为其补记完成正规召唤手续。
function c45898858.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理开始前再次确认主怪兽区空位，若无空位则终止本次特殊召唤处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家显示提示消息，要求选择要特殊召唤的卡片（HINTMSG_SPSUMMON）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从己方的手卡·卡组·墓地中筛选出1张「水龙」，并应用王家长眠之谷的过滤，让玩家选择要特殊召唤的那张卡。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c45898858.filter),tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的「水龙」以表侧表示特殊召唤到己方怪兽区，本次特殊召唤无视召唤条件和苏生限制。
		Duel.SpecialSummon(g,0,tp,tp,true,true,POS_FACEUP)
		g:GetFirst():CompleteProcedure()
	end
end
