--V・HERO ポイズナー
-- 效果：
-- 这个卡名的①②③的效果1回合各能使用1次。
-- ①：自己因战斗·效果受到伤害的场合才能发动。墓地的这张卡当作永续陷阱卡使用在自己的魔法与陷阱区域表侧表示放置。
-- ②：这张卡是当作永续陷阱卡使用的场合，双方的主要阶段，把自己场上1只「英雄」怪兽解放才能发动。这张卡特殊召唤。
-- ③：这张卡从魔法与陷阱区域的特殊召唤成功的场合才能发动。选场上1只怪兽，那个攻击力变成一半。
function c83414006.initial_effect(c)
	-- ①：自己因战斗·效果受到伤害的场合才能发动。墓地的这张卡当作永续陷阱卡使用在自己的魔法与陷阱区域表侧表示放置。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(83414006,0))  --"这张卡当作永续陷阱卡放置"
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL+EFFECT_FLAG_DELAY)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCountLimit(1,83414006)
	e1:SetCondition(c83414006.condition)
	e1:SetTarget(c83414006.target)
	e1:SetOperation(c83414006.operation)
	c:RegisterEffect(e1)
	-- ②：这张卡是当作永续陷阱卡使用的场合，双方的主要阶段，把自己场上1只「英雄」怪兽解放才能发动。这张卡特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(83414006,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCountLimit(1,83414007)
	e2:SetHintTiming(0,TIMING_MAIN_END)
	e2:SetCondition(c83414006.spcon1)
	e2:SetCost(c83414006.spcost1)
	e2:SetTarget(c83414006.sptg1)
	e2:SetOperation(c83414006.spop1)
	c:RegisterEffect(e2)
	-- ③：这张卡从魔法与陷阱区域的特殊召唤成功的场合才能发动。选场上1只怪兽，那个攻击力变成一半。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(83414006,2))
	e3:SetCategory(CATEGORY_ATKCHANGE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,83414008)
	e3:SetCondition(c83414006.atkcon)
	e3:SetTarget(c83414006.atktg)
	e3:SetOperation(c83414006.atkop)
	c:RegisterEffect(e3)
end
-- 判断自己是否因战斗或效果受到伤害
function c83414006.condition(e,tp,eg,ep,ev,re,r,rp)
	return ep==tp and bit.band(r,REASON_BATTLE+REASON_EFFECT)~=0
end
-- 检查魔法与陷阱区域是否有空位，并设置此卡离开墓地的操作信息
function c83414006.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上的魔法与陷阱区域是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0 end
	-- 设置此卡离开墓地的操作信息
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
end
-- 将墓地的这张卡移动到魔法与陷阱区域表侧表示放置，并使其当作永续陷阱卡使用
function c83414006.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将此卡移动到自己的魔法与陷阱区域表侧表示放置
	if Duel.MoveToField(c,tp,tp,LOCATION_SZONE,POS_FACEUP,true) then
		-- 当作永续陷阱卡使用
		local e1=Effect.CreateEffect(c)
		e1:SetCode(EFFECT_CHANGE_TYPE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
		e1:SetValue(TYPE_TRAP+TYPE_CONTINUOUS)
		c:RegisterEffect(e1)
	end
end
-- 检查当前是否为双方的主要阶段，且这张卡是否当作永续陷阱卡使用
function c83414006.spcon1(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前的阶段
	local ph=Duel.GetCurrentPhase()
	return (ph==PHASE_MAIN1 or ph==PHASE_MAIN2) and e:GetHandler():GetType()==TYPE_TRAP+TYPE_CONTINUOUS
end
-- 过滤自己场上可以解放的「英雄」怪兽，且解放后有足够的怪兽区域用于特殊召唤
function c83414006.cfilter1(c,tp)
	-- 检查卡片是否为「英雄」怪兽，且解放该卡后自己场上有可用的怪兽区域，并且该卡在场上表侧表示（或由自己控制）
	return c:IsSetCard(0x8) and Duel.GetMZoneCount(tp,c)>0 and (c:IsFaceup() or c:IsControler(tp))
end
-- 解放自己场上1只「英雄」怪兽作为发动的代价
function c83414006.spcost1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在至少1只满足条件的「英雄」怪兽可以解放
	if chk==0 then return Duel.CheckReleaseGroup(tp,c83414006.cfilter1,1,nil,tp) end
	-- 选择自己场上1只满足条件的「英雄」怪兽
	local g=Duel.SelectReleaseGroup(tp,c83414006.cfilter1,1,1,nil,tp)
	-- 将选择的怪兽解放
	Duel.Release(g,REASON_COST)
end
-- 检查是否可以特殊召唤此卡，并设置特殊召唤的操作信息
function c83414006.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否能将此卡作为怪兽特殊召唤
	if chk==0 then return Duel.IsPlayerCanSpecialSummonMonster(tp,83414006,0x5008,TYPE_MONSTER+TYPE_EFFECT,900,1100,3,RACE_WARRIOR,ATTRIBUTE_DARK) end
	-- 设置特殊召唤此卡的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 将这张卡特殊召唤
function c83414006.spop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将这张卡表侧表示特殊召唤
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- 检查这张卡是否是从魔法与陷阱区域（非场地区）特殊召唤成功
function c83414006.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_SZONE) and c:GetPreviousSequence()<5
end
-- 检查场上是否存在攻击力不为0的表侧表示怪兽
function c83414006.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查双方场上是否存在至少1只攻击力不为0的表侧表示怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(aux.nzatk,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
end
-- 选择场上1只表侧表示怪兽，使其攻击力变成一半
function c83414006.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择表侧表示的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让玩家选择双方场上1只攻击力不为0的表侧表示怪兽
	local tc=Duel.SelectMatchingCard(tp,aux.nzatk,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil):GetFirst()
	if tc then
		-- 那个攻击力变成一半
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(math.ceil(tc:GetAttack()/2))
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
