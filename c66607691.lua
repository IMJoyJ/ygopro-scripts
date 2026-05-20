--フォトン・ジェネレーター・ユニット
-- 效果：
-- 把自己场上2只「电子龙」作为祭品才能发动。从自己的手卡·卡组·墓地特殊召唤1只「电子镭射龙」。
function c66607691.initial_effect(c)
	-- 把自己场上2只「电子龙」作为祭品才能发动。从自己的手卡·卡组·墓地特殊召唤1只「电子镭射龙」。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c66607691.cost)
	e1:SetTarget(c66607691.target)
	e1:SetOperation(c66607691.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数：检查卡片是否为「电子龙」，且由自己控制或在场上表侧表示。
function c66607691.rfilter(c,tp)
	return c:IsCode(70095154) and (c:IsControler(tp) or c:IsFaceup())
end
-- 发动代价（Cost）函数：解放自己场上的2只「电子龙」。
function c66607691.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	-- 获取玩家可解放的卡片组，并过滤出属于自己的或表侧表示的「电子龙」。
	local rg=Duel.GetReleaseGroup(tp):Filter(c66607691.rfilter,nil,tp)
	-- 步骤0（检查）：检查是否能选出2只满足解放后仍有空余怪兽区域条件的「电子龙」进行解放。
	if chk==0 then return rg:CheckSubGroup(aux.mzctcheckrel,2,2,tp) end
	-- 给玩家发送提示信息：请选择要解放的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	-- 让玩家选择2只满足解放后有空余怪兽区域条件的「电子龙」。
	local g=rg:SelectSubGroup(tp,aux.mzctcheckrel,false,2,2,tp)
	-- 强制使用代替解放效果（如「暗影敌托邦」）的次数。
	aux.UseExtraReleaseCount(g,tp)
	-- 解放选中的怪兽作为发动代价。
	Duel.Release(g,REASON_COST)
end
-- 过滤函数：检查卡片是否为「电子镭射龙」且可以被特殊召唤（无视召唤条件和苏生限制）。
function c66607691.spfilter(c,e,tp)
	return c:IsCode(4162088) and c:IsCanBeSpecialSummoned(e,0,tp,true,true)
end
-- 效果的目标（Target）函数：检查并确定特殊召唤「电子镭射龙」的操作信息。
function c66607691.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查怪兽区域是否有空位（若在Cost中已通过检查，则直接视为有空位）。
	local res=e:GetLabel()==1 or Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	if chk==0 then
		e:SetLabel(0)
		-- 检查自己的手卡、卡组、墓地中是否存在至少1只可以特殊召唤的「电子镭射龙」。
		return res and Duel.IsExistingMatchingCard(c66607691.spfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp)
	end
	-- 设置当前处理的连锁操作信息为：从手卡、卡组、墓地特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE)
end
-- 效果处理（Operation）函数：执行从手卡、卡组、墓地特殊召唤「电子镭射龙」的处理。
function c66607691.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检查怪兽区域是否仍有空位，若无则不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 给玩家发送提示信息：请选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡、卡组、墓地中选择1只「电子镭射龙」（适用王家长眠之谷的过滤）。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c66607691.spfilter),tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤（无视召唤条件和苏生限制）。
		Duel.SpecialSummon(g,0,tp,tp,true,true,POS_FACEUP)
		g:GetFirst():CompleteProcedure()
	end
end
