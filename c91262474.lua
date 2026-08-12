--スターダスト・ヴルム
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡在手卡·墓地存在，自己场上有8星以上的龙族同调怪兽存在的场合才能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
-- ②：把这张卡解放才能发动。从自己的手卡·墓地选「星尘亚龙」以外的最多2只龙族·光属性·1星怪兽特殊召唤。这个效果特殊召唤的怪兽不能把效果发动。
function c91262474.initial_effect(c)
	-- ①：这张卡在手卡·墓地存在，自己场上有8星以上的龙族同调怪兽存在的场合才能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(91262474,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetCountLimit(1,91262474)
	e1:SetCondition(c91262474.spcon)
	e1:SetTarget(c91262474.sptg)
	e1:SetOperation(c91262474.spop)
	c:RegisterEffect(e1)
	-- ②：把这张卡解放才能发动。从自己的手卡·墓地选「星尘亚龙」以外的最多2只龙族·光属性·1星怪兽特殊召唤。这个效果特殊召唤的怪兽不能把效果发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(91262474,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,91262475)
	e2:SetCost(c91262474.spcost)
	e2:SetTarget(c91262474.sptg2)
	e2:SetOperation(c91262474.spop2)
	c:RegisterEffect(e2)
end
-- 过滤条件：表侧表示、8星以上、龙族同调怪兽
function c91262474.spfilter(c)
	return c:IsFaceup() and c:IsLevelAbove(8) and c:IsRace(RACE_DRAGON) and c:IsType(TYPE_SYNCHRO)
end
-- 效果①的发动条件：自己场上存在满足过滤条件的怪兽
function c91262474.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在至少1只表侧表示的8星以上的龙族同调怪兽
	return Duel.IsExistingMatchingCard(c91262474.spfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 效果①的发动准备：检查怪兽区域空位及自身是否能特殊召唤，并设置特殊召唤的操作信息
function c91262474.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动检查阶段，确认自己场上有可用的怪兽区域，且这张卡可以特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁信息：将自身特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果①的效果处理：将自身特殊召唤，并添加离场时除外的效果
function c91262474.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 尝试将这张卡以表侧表示特殊召唤
		if Duel.SpecialSummonStep(c,0,tp,tp,false,false,POS_FACEUP) then
			-- 这个效果特殊召唤的这张卡从场上离开的场合除外。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
			e1:SetValue(LOCATION_REMOVED)
			c:RegisterEffect(e1)
		end
		-- 完成特殊召唤的流程
		Duel.SpecialSummonComplete()
	end
end
-- 效果②的代价值：检查自身是否能解放，并将其解放
function c91262474.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 在发动检查阶段，确认自身解放后有可用的怪兽区域，且自身可以被解放
	if chk==0 then return Duel.GetMZoneCount(tp,c)>0 and c:IsReleasable() end
	-- 将自身解放作为发动的代价
	Duel.Release(c,REASON_COST)
end
-- 过滤条件：除「星尘亚龙」以外的龙族·光属性·1星且可以特殊召唤的怪兽
function c91262474.spfilter2(c,e,tp)
	return not c:IsCode(91262474) and c:IsRace(RACE_DRAGON) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsLevel(1) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②的发动准备：检查手卡·墓地是否存在满足条件的怪兽，并设置特殊召唤的操作信息
function c91262474.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动检查阶段，确认自己的手卡或墓地存在至少1只满足过滤条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c91262474.spfilter2,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置连锁信息：从手卡·墓地特殊召唤怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- 效果②的效果处理：从手卡·墓地选择最多2只满足条件的怪兽特殊召唤，并使其不能发动效果
function c91262474.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上可用的怪兽区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	ft=math.min(ft,2)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if ft>1 and Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡·墓地选择最多ft张满足过滤条件且不受王家长眠之谷影响的怪兽
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c91262474.spfilter2),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,ft,nil,e,tp)
	local tc=g:GetFirst()
	while tc do
		-- 尝试将选中的怪兽以表侧表示特殊召唤
		if Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
			-- 这个效果特殊召唤的怪兽不能把效果发动。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CANNOT_TRIGGER)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
		end
		tc=g:GetNext()
	end
	-- 完成特殊召唤的流程
	Duel.SpecialSummonComplete()
end
