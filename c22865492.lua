--V・HERO インクリース
-- 效果：
-- 这个卡名的①②③的效果1回合各能使用1次。
-- ①：自己因战斗·效果受到伤害的场合才能发动。墓地的这张卡当作永续陷阱卡使用在自己的魔法与陷阱区域表侧表示放置。
-- ②：这张卡是当作永续陷阱卡使用的场合，自己·对方的主要阶段，把自己场上1只「英雄」怪兽解放才能发动。这张卡特殊召唤。
-- ③：这张卡从魔法与陷阱区域特殊召唤的场合才能发动。从卡组把1只4星以下的「幻影英雄」怪兽特殊召唤。
function c22865492.initial_effect(c)
	-- ①：自己因战斗·效果受到伤害的场合才能发动。墓地的这张卡当作永续陷阱卡使用在自己的魔法与陷阱区域表侧表示放置。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(22865492,0))  --"这张卡当作永续陷阱卡放置"
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL+EFFECT_FLAG_DELAY)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCountLimit(1,22865492)
	e1:SetCondition(c22865492.condition)
	e1:SetTarget(c22865492.target)
	e1:SetOperation(c22865492.operation)
	c:RegisterEffect(e1)
	-- ②：这张卡是当作永续陷阱卡使用的场合，自己·对方的主要阶段，把自己场上1只「英雄」怪兽解放才能发动。这张卡特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(22865492,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCountLimit(1,22865493)
	e2:SetHintTiming(0,TIMING_MAIN_END)
	e2:SetCondition(c22865492.spcon1)
	e2:SetCost(c22865492.spcost1)
	e2:SetTarget(c22865492.sptg1)
	e2:SetOperation(c22865492.spop1)
	c:RegisterEffect(e2)
	-- ③：这张卡从魔法与陷阱区域特殊召唤的场合才能发动。从卡组把1只4星以下的「幻影英雄」怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(22865492,2))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,22865494)
	e3:SetCondition(c22865492.spcon2)
	e3:SetTarget(c22865492.sptg2)
	e3:SetOperation(c22865492.spop2)
	c:RegisterEffect(e3)
end
-- 判断是否为己方受到战斗或效果伤害
function c22865492.condition(e,tp,eg,ep,ev,re,r,rp)
	return ep==tp and bit.band(r,REASON_BATTLE+REASON_EFFECT)~=0
end
-- 判断是否能将卡移至魔法与陷阱区域
function c22865492.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否能将卡移至魔法与陷阱区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0 end
	-- 设置操作信息为将卡移出墓地
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
end
-- 将卡移至魔法与陷阱区域并改变其类型为永续陷阱
function c22865492.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 尝试将卡移至魔法与陷阱区域
	if Duel.MoveToField(c,tp,tp,LOCATION_SZONE,POS_FACEUP,true) then
		-- 将卡的类型更改为永续陷阱
		local e1=Effect.CreateEffect(c)
		e1:SetCode(EFFECT_CHANGE_TYPE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
		e1:SetValue(TYPE_TRAP+TYPE_CONTINUOUS)
		c:RegisterEffect(e1)
	end
end
-- 判断是否在主要阶段且卡处于永续陷阱状态
function c22865492.spcon1(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前阶段
	local ph=Duel.GetCurrentPhase()
	return (ph==PHASE_MAIN1 or ph==PHASE_MAIN2) and e:GetHandler():GetType()==TYPE_TRAP+TYPE_CONTINUOUS
end
-- 判断是否为英雄卡且能解放
function c22865492.cfilter1(c,tp)
	-- 判断是否为英雄卡且能解放
	return c:IsSetCard(0x8) and Duel.GetMZoneCount(tp,c)>0 and (c:IsFaceup() or c:IsControler(tp))
end
-- 检查并选择解放的英雄怪兽
function c22865492.spcost1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否有可解放的英雄怪兽
	if chk==0 then return Duel.CheckReleaseGroup(tp,c22865492.cfilter1,1,nil,tp) end
	-- 选择要解放的英雄怪兽
	local g=Duel.SelectReleaseGroup(tp,c22865492.cfilter1,1,1,nil,tp)
	-- 解放选择的怪兽
	Duel.Release(g,REASON_COST)
end
-- 判断是否可以特殊召唤此卡
function c22865492.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否可以特殊召唤此卡
	if chk==0 then return Duel.IsPlayerCanSpecialSummonMonster(tp,22865492,0x5008,TYPE_MONSTER+TYPE_EFFECT,900,1100,3,RACE_WARRIOR,ATTRIBUTE_DARK) end
	-- 设置操作信息为特殊召唤此卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 执行特殊召唤操作
function c22865492.spop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将卡特殊召唤到场上
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- 判断是否从魔法与陷阱区域特殊召唤
function c22865492.spcon2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_SZONE) and c:GetPreviousSequence()<5
end
-- 判断是否为幻影英雄且等级不超过4
function c22865492.spfilter2(c,e,tp)
	return c:IsLevelBelow(4) and c:IsSetCard(0x5008) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 判断是否可以发动效果并检索幻影英雄怪兽
function c22865492.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断场上是否有足够怪兽区
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断卡组中是否存在符合条件的幻影英雄怪兽
		and Duel.IsExistingMatchingCard(c22865492.spfilter2,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置操作信息为特殊召唤幻影英雄怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 执行特殊召唤幻影英雄怪兽
function c22865492.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 判断场上是否有足够怪兽区
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择要特殊召唤的幻影英雄怪兽
	local g=Duel.SelectMatchingCard(tp,c22865492.spfilter2,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的幻影英雄怪兽特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
