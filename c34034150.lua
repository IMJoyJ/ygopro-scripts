--分裂するマザー・スパイダー
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：自己场上没有怪兽存在的场合，这张卡可以从手卡特殊召唤。
-- ②：把这张卡解放才能发动。从手卡·卡组把最多3只「小蜘蛛」特殊召唤。这个效果特殊召唤的怪兽等级变成5星，作为超量召唤的素材的场合，不是暗属性怪兽的超量召唤不能使用。这个效果的发动后，直到回合结束时自己不是超量怪兽不能从额外卡组特殊召唤。
function c34034150.initial_effect(c)
	-- ①：自己场上没有怪兽存在的场合，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c34034150.sprcon)
	c:RegisterEffect(e1)
	-- ②：把这张卡解放才能发动。从手卡·卡组把最多3只「小蜘蛛」特殊召唤。这个效果特殊召唤的怪兽等级变成5星，作为超量召唤的素材的场合，不是暗属性怪兽的超量召唤不能使用。这个效果的发动后，直到回合结束时自己不是超量怪兽不能从额外卡组特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(34034150,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,34034150)
	e2:SetCost(c34034150.spcost)
	e2:SetTarget(c34034150.sptg)
	e2:SetOperation(c34034150.spop)
	c:RegisterEffect(e2)
end
-- 判断手卡的这张卡是否满足特殊召唤条件，即自己场上没有怪兽且有空怪兽区
function c34034150.sprcon(e,c)
	if c==nil then return true end
	-- 判断自己场上是否没有怪兽
	return Duel.GetFieldGroupCount(c:GetControler(),LOCATION_MZONE,0)==0
		-- 判断自己场上是否有空怪兽区
		and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
end
-- 支付效果代价，将自身解放
function c34034150.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 判断是否满足支付代价的条件，即自身可被解放且有空怪兽区
	if chk==0 then return c:IsReleasable() and Duel.GetMZoneCount(tp,c)>0 end
	-- 执行将自身解放的操作
	Duel.Release(c,REASON_COST)
end
-- 过滤函数，用于筛选「小蜘蛛」怪兽
function c34034150.spfilter(c,e,tp)
	return c:IsCode(60023855) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置效果发动时的处理信息，确定要特殊召唤的卡
function c34034150.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足发动条件，即自己手卡或卡组中存在「小蜘蛛」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c34034150.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置效果发动时的处理信息，确定要特殊召唤的卡的数量和位置
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- 处理效果发动后的操作，包括设置不能特殊召唤的效果、选择并特殊召唤「小蜘蛛」怪兽
function c34034150.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 设置发动效果后直到回合结束时，自己不能从额外卡组特殊召唤非超量怪兽的效果
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c34034150.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将设置的不能特殊召唤的效果注册到游戏环境
	Duel.RegisterEffect(e1,tp)
	-- 获取自己场上可用的怪兽区数量
	local ft=Duel.GetMZoneCount(tp)
	-- 获取自己手卡和卡组中所有「小蜘蛛」怪兽的集合
	local g=Duel.GetMatchingGroup(c34034150.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,nil,e,tp)
	if ft<=0 or #g==0 then return end
	if ft>3 then ft=3 end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	local sg=g:Select(tp,1,ft,nil)
	-- 遍历选择的卡组，对每张卡执行特殊召唤操作
	for tc in aux.Next(sg) do
		-- 执行特殊召唤单张卡的操作
		Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
		-- 设置特殊召唤的怪兽等级变为5星
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetValue(5)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 设置特殊召唤的怪兽不能作为超量召唤的素材，除非是暗属性怪兽
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_CANNOT_BE_XYZ_MATERIAL)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
		e2:SetValue(c34034150.xyzlimit)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
	end
	-- 完成所有特殊召唤操作
	Duel.SpecialSummonComplete()
end
-- 限制不能从额外卡组特殊召唤非超量怪兽
function c34034150.splimit(e,c)
	return not c:IsType(TYPE_XYZ) and c:IsLocation(LOCATION_EXTRA)
end
-- 限制作为超量召唤素材的怪兽必须是暗属性
function c34034150.xyzlimit(e,c)
	if not c then return false end
	return not c:IsAttribute(ATTRIBUTE_DARK)
end
