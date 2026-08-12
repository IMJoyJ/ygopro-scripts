--無限起動ブルータルドーザー
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：把自己场上1只机械族·地属性怪兽解放才能发动。这张卡从手卡守备表示特殊召唤。
-- ②：这张卡从手卡的特殊召唤成功的场合才能发动。从卡组把「无限起动 残暴推土机」以外的1只「无限起动」怪兽效果无效守备表示特殊召唤。这个效果的发动后，直到回合结束时自己不是机械族·地属性怪兽不能特殊召唤。
function c76830505.initial_effect(c)
	-- ①：把自己场上1只机械族·地属性怪兽解放才能发动。这张卡从手卡守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(76830505,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,76830505)
	e1:SetCost(c76830505.spcost1)
	e1:SetTarget(c76830505.sptg1)
	e1:SetOperation(c76830505.spop1)
	c:RegisterEffect(e1)
	-- ②：这张卡从手卡的特殊召唤成功的场合才能发动。从卡组把「无限起动 残暴推土机」以外的1只「无限起动」怪兽效果无效守备表示特殊召唤。这个效果的发动后，直到回合结束时自己不是机械族·地属性怪兽不能特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(76830505,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,76830506)
	e2:SetCondition(c76830505.spcon2)
	e2:SetTarget(c76830505.sptg2)
	e2:SetOperation(c76830505.spop2)
	c:RegisterEffect(e2)
end
-- 过滤条件：自己场上的地属性·机械族怪兽，且解放后能腾出怪兽区域
function c76830505.costfilter(c,tp)
	-- 检查卡片是否为机械族、地属性，且解放该卡后自己场上有可用于特殊召唤的怪兽区域
	return c:IsRace(RACE_MACHINE) and c:IsAttribute(ATTRIBUTE_EARTH) and Duel.GetMZoneCount(tp,c)>0
end
-- 效果①的代价值判定与支付函数
function c76830505.spcost1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段（chk==0）检查自己场上是否存在至少1只满足过滤条件的可解放怪兽
	if chk==0 then return Duel.CheckReleaseGroup(tp,c76830505.costfilter,1,nil,tp) end
	-- 让玩家选择1只满足过滤条件的可解放怪兽
	local g=Duel.SelectReleaseGroup(tp,c76830505.costfilter,1,1,nil,tp)
	-- 解放选中的怪兽作为发动的代价
	Duel.Release(g,REASON_COST)
end
-- 效果①的发动准备与目标确认函数
function c76830505.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE) end
	-- 设置效果处理信息：将自身特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 效果①的效果处理（特殊召唤自身）函数
function c76830505.spop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡从手卡表侧守备表示特殊召唤
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
-- 效果②的发动条件：检查这张卡是否是从手卡特殊召唤成功
function c76830505.spcon2(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_HAND)
end
-- 过滤条件：卡组中「无限起动 残暴推土机」以外的「无限起动」怪兽，且可以守备表示特殊召唤
function c76830505.spfilter(c,e,tp)
	return c:IsSetCard(0x127) and not c:IsCode(76830505) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 效果②的发动准备与目标确认函数
function c76830505.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段（chk==0）检查自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 且检查卡组中是否存在至少1只满足过滤条件的怪兽
		and Duel.IsExistingMatchingCard(c76830505.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置效果处理信息：从卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果②的效果处理（从卡组特殊召唤并施加限制）函数
function c76830505.spop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查自己场上是否有空余的怪兽区域
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 从卡组选择1只满足过滤条件的怪兽
		local g=Duel.SelectMatchingCard(tp,c76830505.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		local tc=g:GetFirst()
		-- 若成功选出怪兽，则尝试将其表侧守备表示特殊召唤（分解步骤）
		if tc and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE) then
			-- 效果无效
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1,true)
			-- 效果无效
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			e2:SetValue(RESET_TURN_SET)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e2,true)
		end
		-- 完成特殊召唤的后续处理
		Duel.SpecialSummonComplete()
	end
	-- 这个效果的发动后，直到回合结束时自己不是机械族·地属性怪兽不能特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e3:SetTargetRange(1,0)
	e3:SetTarget(c76830505.splimit)
	e3:SetReset(RESET_PHASE+PHASE_END)
	-- 将不能特殊召唤非地属性·机械族怪兽的限制效果注册给玩家
	Duel.RegisterEffect(e3,tp)
end
-- 特殊召唤限制：不能特殊召唤非地属性或非机械族的怪兽
function c76830505.splimit(e,c)
	return not c:IsAttribute(ATTRIBUTE_EARTH) or not c:IsRace(RACE_MACHINE)
end
