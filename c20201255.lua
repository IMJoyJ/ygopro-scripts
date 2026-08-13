--再起する剣闘獣
-- 效果：
-- ①：从自己的手卡·墓地选相同种族的怪兽不在自己场上存在的1只「剑斗兽」怪兽特殊召唤。这个效果特殊召唤的怪兽不会被战斗破坏。
function c20201255.initial_effect(c)
	-- ①：从自己的手卡·墓地选相同种族的怪兽不在自己场上存在的1只「剑斗兽」怪兽特殊召唤。这个效果特殊召唤的怪兽不会被战斗破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c20201255.target)
	e1:SetOperation(c20201255.activate)
	c:RegisterEffect(e1)
end
-- 定义选择候选怪兽的过滤条件：该卡必须是「剑斗兽」字段的怪兽、能被当前效果特殊召唤，并且自己场上不存在与它相同种族的表侧表示怪兽。
function c20201255.filter(c,e,tp)
	return c:IsSetCard(0x1019) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 排除自己场上有相同种族表侧表示怪兽的候选：若己方主要怪兽区已存在与候选卡相同种族的表侧表示怪兽，则该候选不满足条件。
		and not Duel.IsExistingMatchingCard(c20201255.filter1,tp,LOCATION_MZONE,0,1,c,c:GetRace())
end
-- 定义辅助过滤函数：判断场上存在的怪兽是否为表侧表示且种族与指定的种族相同。
function c20201255.filter1(c,race)
	return c:IsFaceup() and c:IsRace(race)
end
-- 发动时的合法性判定：检查己方主要怪兽区是否有可用空格，并且手卡·墓地是否存在至少1张满足特殊召唤条件的「剑斗兽」怪兽。
function c20201255.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查己方主要怪兽区是否有空闲区域可供特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡·墓地中是否存在至少1张满足过滤条件的候选「剑斗兽」怪兽（nil表示不排除任何卡，e和tp作为额外参数传给过滤函数）。
		and Duel.IsExistingMatchingCard(c20201255.filter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置操作信息：声明本效果处理时将进行特殊召唤，数量为1，来源区域为手卡·墓地。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- 效果处理时的执行函数：先确认怪兽区空格，再让玩家筛选符合条件的卡进行特殊召唤，若特殊召唤成功则给该怪兽赋予不会被战斗破坏的效果。
function c20201255.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时再次确认己方主要怪兽区仍有空格，若没有可用的怪兽区域则效果处理终止。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 弹出选择提示，引导玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家从自己的手卡·墓地选择1张符合c20201255.filter且不受王家长眠之谷影响的「剑斗兽」怪兽（aux.NecroValleyFilter防止墓地效果被无效）。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c20201255.filter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 若成功选择了卡且特殊召唤成功（返回实际特殊召唤数量不为0），则继续为那只怪兽附加后续的不会被战斗破坏的效果。
	if g:GetCount()>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 这个效果特殊召唤的怪兽不会被战斗破坏。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		g:GetFirst():RegisterEffect(e1)
	end
end
