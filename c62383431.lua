--溟界の黄昏－カース
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡在墓地存在的场合，把自己场上1只怪兽解放才能发动。这张卡特殊召唤。那之后，对方可以从自身墓地选1只怪兽效果无效特殊召唤。
-- ②：这张卡特殊召唤成功的场合，以自己墓地1只4星以下的「溟界」怪兽为对象才能发动。那只怪兽特殊召唤。这个效果特殊召唤的怪兽从场上离开的场合除外。
function c62383431.initial_effect(c)
	-- ①：这张卡在墓地存在的场合，把自己场上1只怪兽解放才能发动。这张卡特殊召唤。那之后，对方可以从自身墓地选1只怪兽效果无效特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(62383431,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_GRAVE_SPSUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCountLimit(1,62383431)
	e1:SetCost(c62383431.spcost)
	e1:SetTarget(c62383431.sptg)
	e1:SetOperation(c62383431.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡特殊召唤成功的场合，以自己墓地1只4星以下的「溟界」怪兽为对象才能发动。那只怪兽特殊召唤。这个效果特殊召唤的怪兽从场上离开的场合除外。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(62383431,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,62383432)
	e2:SetTarget(c62383431.sptg2)
	e2:SetOperation(c62383431.spop2)
	c:RegisterEffect(e2)
end
-- 效果①的发动代价（Cost）函数：解放自己场上1只怪兽
function c62383431.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取玩家可解放的怪兽卡组
	local g=Duel.GetReleaseGroup(tp)
	-- 检查是否存在1只解放后能腾出足够怪兽区域空位的怪兽
	if chk==0 then return g:CheckSubGroup(aux.mzctcheckrel,1,1,tp) end
	-- 提示玩家选择要解放的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	-- 玩家选择1只满足解放后有空位条件的怪兽
	local rg=g:SelectSubGroup(tp,aux.mzctcheckrel,false,1,1,tp)
	-- 应用代替解放的效果
	aux.UseExtraReleaseCount(rg,tp)
	-- 解放选中的怪兽
	Duel.Release(rg,REASON_COST)
end
-- 效果①的靶向（Target）函数：检查自身是否能特殊召唤并设置特殊召唤的操作信息
function c62383431.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤自身的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 过滤对方墓地中可以被特殊召唤的怪兽
function c62383431.spfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,1-tp,false,false)
end
-- 效果①的效果处理（Operation）函数：特殊召唤自身，之后对方可选择从其墓地特殊召唤1只效果无效的怪兽
function c62383431.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 自身卡片仍有关联且成功将自身特殊召唤
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0
		-- 并且对方场上有可用的怪兽区域
		and Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0
		-- 并且对方墓地存在可以特殊召唤的怪兽（受王家长眠之谷影响）
		and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(c62383431.spfilter),tp,0,LOCATION_GRAVE,1,nil,e,tp)
		-- 并且对方玩家选择“是”（从自身墓地特殊召唤1只怪兽）
		and Duel.SelectYesNo(1-tp,aux.Stringid(62383431,2)) then  --"是否从墓地选怪兽效果无效特殊召唤？"
		-- 中断当前效果处理，使后续特殊召唤视为不同时处理
		Duel.BreakEffect()
		-- 提示对方玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 对方玩家从其墓地选择1只可特殊召唤的怪兽
		local tc=Duel.SelectMatchingCard(1-tp,aux.NecroValleyFilter(c62383431.spfilter),tp,0,LOCATION_GRAVE,1,1,nil,e,tp):GetFirst()
		-- 尝试将选中的怪兽特殊召唤到对方场上
		if Duel.SpecialSummonStep(tc,0,1-tp,1-tp,false,false,POS_FACEUP) then
			-- 效果无效
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
			-- 效果无效
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			e2:SetValue(RESET_TURN_SET)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e2)
		end
		-- 完成特殊召唤的最终处理
		Duel.SpecialSummonComplete()
	end
end
-- 过滤自己墓地4星以下的「溟界」怪兽
function c62383431.spfilter2(c,e,tp)
	return c:IsLevelBelow(4) and c:IsSetCard(0x161) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②的靶向（Target）函数：检查并选择自己墓地1只4星以下的「溟界」怪兽为对象
function c62383431.sptg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c62383431.spfilter2(chkc,e,tp) end
	-- 检查自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并且自己墓地是否存在符合条件的怪兽
		and Duel.IsExistingTarget(c62383431.spfilter2,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家选择自己墓地1只符合条件的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c62383431.spfilter2,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置特殊召唤该对象怪兽的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果②的效果处理（Operation）函数：特殊召唤对象怪兽，并添加离场时除外的限制
function c62383431.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 尝试将对象怪兽特殊召唤到自己场上
		if Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
			-- 这个效果特殊召唤的怪兽从场上离开的场合除外。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
			e1:SetValue(LOCATION_REMOVED)
			tc:RegisterEffect(e1)
		end
		-- 完成特殊召唤的最终处理
		Duel.SpecialSummonComplete()
	end
end
