--リオート・ミグラトリー
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡在手卡存在，场上有水属性超量怪兽存在的场合才能发动。这张卡特殊召唤。
-- ②：自己主要阶段才能发动。自己场上1个超量素材取除。那之后，可以从自己的手卡·墓地把1只3·4星的水属性怪兽效果无效特殊召唤。这个回合，把这个效果特殊召唤的怪兽在水属性怪兽的超量召唤使用的场合，可以把那个等级当作5星使用。
local s,id,o=GetID()
-- 注册卡片效果：①手卡特殊召唤，②去除超量素材并从手卡·墓地效果无效特殊召唤。
function s.initial_effect(c)
	-- ①：这张卡在手卡存在，场上有水属性超量怪兽存在的场合才能发动。这张卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"手卡特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：自己主要阶段才能发动。自己场上1个超量素材取除。那之后，可以从自己的手卡·墓地把1只3·4星的水属性怪兽效果无效特殊召唤。这个回合，把这个效果特殊召唤的怪兽在水属性怪兽的超量召唤使用的场合，可以把那个等级当作5星使用。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"效果无效特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_GRAVE_SPSUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.sptg2)
	e2:SetOperation(s.spop2)
	c:RegisterEffect(e2)
end
-- 过滤条件：场上表侧表示的水属性超量怪兽。
function s.cfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:IsAttribute(ATTRIBUTE_WATER)
end
-- 效果①的发动条件：场上有水属性超量怪兽存在。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查双方场上是否存在至少1只满足过滤条件（表侧表示的水属性超量怪兽）的卡。
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
end
-- 效果①的发动准备与合法性检查。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤的操作信息，目标为自身。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果①的处理：将自身特殊召唤。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 效果②的发动准备与合法性检查。
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在可以因效果取除的超量素材。
	if chk==0 then return Duel.CheckRemoveOverlayCard(tp,1,0,1,REASON_EFFECT) end
	-- 设置特殊召唤的操作信息，预计从手卡或墓地特殊召唤1张卡。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- 过滤条件：手卡·墓地中可以特殊召唤的3·4星水属性怪兽。
function s.spfilter(c,e,tp)
	return c:IsLevel(3,4) and c:IsAttribute(ATTRIBUTE_WATER)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②的处理：取除超量素材，并可以从手卡·墓地将1只3·4星水属性怪兽效果无效特殊召唤，且该怪兽用于水属性超量召唤时可当作5星使用。
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 成功取除自己场上1个超量素材。
	if Duel.RemoveOverlayCard(tp,1,0,1,1,REASON_EFFECT)~=0
		-- 且自己场上有可用的怪兽区域。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 且手卡·墓地存在满足条件（不受王家之谷影响的3·4星水属性怪兽）的卡。
		and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp)
		-- 询问玩家是否选择进行特殊召唤。
		and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否把怪兽特殊召唤？"
		-- 提示玩家选择要特殊召唤的卡片。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 玩家从手卡·墓地选择1张满足过滤条件的卡。
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
		local tc=g:GetFirst()
		if tc then
			-- 中断当前效果，使后续的特殊召唤处理与取除素材不视为同时进行。
			Duel.BreakEffect()
			-- 逐步特殊召唤选中的怪兽（表侧表示）。
			Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
			-- 效果无效
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
			local e2=e1:Clone()
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			e2:SetValue(RESET_TURN_SET)
			tc:RegisterEffect(e2)
			-- 这个回合，把这个效果特殊召唤的怪兽在水属性怪兽的超量召唤使用的场合，可以把那个等级当作5星使用。
			local e3=Effect.CreateEffect(e:GetHandler())
			e3:SetType(EFFECT_TYPE_SINGLE)
			e3:SetCode(EFFECT_XYZ_LEVEL)
			e3:SetValue(s.xyzlv)
			e3:SetLabel(5)
			e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e3,true)
		end
		-- 完成特殊召唤的最终处理。
		Duel.SpecialSummonComplete()
	end
end
-- 辅助函数：若用于水属性怪兽的超量召唤，则将该怪兽的等级当作5星使用。
function s.xyzlv(e,c,rc)
	if rc:IsAttribute(ATTRIBUTE_WATER) then
		return c:GetLevel()+0x10000*e:GetLabel()
	else
		return c:GetLevel()
	end
end
