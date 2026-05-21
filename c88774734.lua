--螺旋竜バルジ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡在手卡·墓地存在，自己场上有光·暗属性的龙族怪兽2只以上存在的场合才能发动。这张卡守备表示特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
-- ②：自己主要阶段才能发动。自己场上的全部怪兽的等级直到回合结束时变成8星。
function c88774734.initial_effect(c)
	-- ①：这张卡在手卡·墓地存在，自己场上有光·暗属性的龙族怪兽2只以上存在的场合才能发动。这张卡守备表示特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(88774734,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetCountLimit(1,88774734)
	e1:SetCondition(c88774734.spcon)
	e1:SetTarget(c88774734.sptg)
	e1:SetOperation(c88774734.spop)
	c:RegisterEffect(e1)
	-- ②：自己主要阶段才能发动。自己场上的全部怪兽的等级直到回合结束时变成8星。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(88774734,1))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,88774735)
	e2:SetTarget(c88774734.lvtg)
	e2:SetOperation(c88774734.lvop)
	c:RegisterEffect(e2)
end
-- 过滤条件：自己场上表侧表示的光·暗属性龙族怪兽
function c88774734.cfilter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_LIGHT+ATTRIBUTE_DARK) and c:IsRace(RACE_DRAGON)
end
-- 效果①的发动条件：自己场上有光·暗属性的龙族怪兽2只以上存在
function c88774734.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在至少2只表侧表示的光·暗属性龙族怪兽
	return Duel.IsExistingMatchingCard(c88774734.cfilter,tp,LOCATION_MZONE,0,2,nil)
end
-- 效果①的发动准备：检查怪兽区域空位及自身是否能特殊召唤，并设置特殊召唤的操作信息
function c88774734.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上的主要怪兽区域是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE) end
	-- 设置特殊召唤的操作信息，表示将自身特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果①的效果处理：将自身守备表示特殊召唤，并添加离场时除外的效果
function c88774734.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查此卡是否仍与效果相关，并尝试将其以表侧守备表示特殊召唤
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP_DEFENSE)~=0 then
		-- 这个效果特殊召唤的这张卡从场上离开的场合除外。②：自己主要阶段才能发动。自己场上的全部怪兽的等级直到回合结束时变成8星。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e1,true)
	end
end
-- 过滤条件：自己场上表侧表示、等级不为8且等级大于0的怪兽
function c88774734.lvfilter(c)
	return c:IsFaceup() and not c:IsLevel(8) and c:GetLevel()>0
end
-- 效果②的发动准备：检查自己场上是否存在至少1只等级不为8且等级大于0的表侧表示怪兽
function c88774734.lvtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在至少1只等级不为8且等级大于0的表侧表示怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c88774734.lvfilter,tp,LOCATION_MZONE,0,1,nil) end
end
-- 效果②的效果处理：获取自己场上所有等级不为8且等级大于0的表侧表示怪兽，并将其等级直到回合结束时变成8星
function c88774734.lvop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上所有等级不为8且等级大于0的表侧表示怪兽
	local g=Duel.GetMatchingGroup(c88774734.lvfilter,tp,LOCATION_MZONE,0,nil)
	local tc=g:GetFirst()
	while tc do
		-- 直到回合结束时变成8星。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetValue(8)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		tc=g:GetNext()
	end
end
