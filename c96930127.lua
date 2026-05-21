--チェーンドッグ
-- 效果：
-- 自己场上是兽族怪兽表侧表示2只存在的场合，可以把这张卡从墓地特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合，从游戏中除外。把这张卡作为同调素材的场合，不是兽族怪兽的同调召唤不能使用。
function c96930127.initial_effect(c)
	-- 自己场上是兽族怪兽表侧表示2只存在的场合，可以把这张卡从墓地特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合，从游戏中除外。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(96930127,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCondition(c96930127.condition)
	e1:SetTarget(c96930127.target)
	e1:SetOperation(c96930127.operation)
	c:RegisterEffect(e1)
	-- 把这张卡作为同调素材的场合，不是兽族怪兽的同调召唤不能使用。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetValue(c96930127.synlimit)
	c:RegisterEffect(e2)
end
-- 过滤条件：场上表侧表示的兽族怪兽
function c96930127.cfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_BEAST)
end
-- 发动条件：自己场上表侧表示的兽族怪兽数量刚好为2只
function c96930127.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 计算自己场上表侧表示的兽族怪兽数量，并判断是否等于2
	return Duel.GetMatchingGroupCount(c96930127.cfilter,tp,LOCATION_MZONE,0,nil)==2
end
-- 发动准备：检查怪兽区域空位及自身是否能特殊召唤，并设置特殊召唤的操作信息
function c96930127.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动检测阶段，检查自己场上是否有可用的怪兽区域空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：将自身特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理：将自身特殊召唤，并注册离场时除外的效果
function c96930127.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 若此卡仍与效果相关，则将其特殊召唤，并判断是否特殊召唤成功
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- 这个效果特殊召唤的这张卡从场上离开的场合，从游戏中除外。把这张卡作为同调素材的场合，不是兽族怪兽的同调召唤不能使用。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e1,true)
	end
end
-- 同调素材限制：不能作为兽族以外怪兽的同调素材
function c96930127.synlimit(e,c)
	if not c then return false end
	return not c:IsRace(RACE_BEAST)
end
