--V・HERO ミニマム・レイ
-- 效果：
-- 这个卡名的①②③的效果1回合各能使用1次。
-- ①：自己因战斗·效果受到伤害的场合才能发动。墓地的这张卡当作永续陷阱卡使用在自己的魔法与陷阱区域表侧表示放置。
-- ②：这张卡是当作永续陷阱卡使用的场合，双方的主要阶段，把自己场上1只「英雄」怪兽解放才能发动。这张卡特殊召唤。
-- ③：这张卡从魔法与陷阱区域的特殊召唤成功的场合才能发动。选对方场上1只4星以下的怪兽破坏。
function c61320914.initial_effect(c)
	-- ①：自己因战斗·效果受到伤害的场合才能发动。墓地的这张卡当作永续陷阱卡使用在自己的魔法与陷阱区域表侧表示放置。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(61320914,0))  --"这张卡当作永续陷阱卡放置"
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL+EFFECT_FLAG_DELAY)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCountLimit(1,61320914)
	e1:SetCondition(c61320914.condition)
	e1:SetTarget(c61320914.target)
	e1:SetOperation(c61320914.operation)
	c:RegisterEffect(e1)
	-- ②：这张卡是当作永续陷阱卡使用的场合，双方的主要阶段，把自己场上1只「英雄」怪兽解放才能发动。这张卡特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(61320914,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCountLimit(1,61320915)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e2:SetCondition(c61320914.spcon1)
	e2:SetCost(c61320914.spcost1)
	e2:SetTarget(c61320914.sptg1)
	e2:SetOperation(c61320914.spop1)
	c:RegisterEffect(e2)
	-- ③：这张卡从魔法与陷阱区域的特殊召唤成功的场合才能发动。选对方场上1只4星以下的怪兽破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(61320914,2))
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,61320916)
	e3:SetCondition(c61320914.descon)
	e3:SetTarget(c61320914.destg)
	e3:SetOperation(c61320914.desop)
	c:RegisterEffect(e3)
end
-- 检查自己是否因战斗或效果受到伤害
function c61320914.condition(e,tp,eg,ep,ev,re,r,rp)
	return ep==tp and bit.band(r,REASON_BATTLE+REASON_EFFECT)~=0
end
-- 效果①的发动准备与合法性检测
function c61320914.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的魔法与陷阱区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0 end
	-- 设置操作信息为将墓地的这张卡移出墓地
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
end
-- 效果①的效果处理
function c61320914.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将这张卡移动到自己的魔法与陷阱区域表侧表示放置
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
-- 效果②的发动条件
function c61320914.spcon1(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前的阶段
	local ph=Duel.GetCurrentPhase()
	return (ph==PHASE_MAIN1 or ph==PHASE_MAIN2) and e:GetHandler():GetType()==TYPE_TRAP+TYPE_CONTINUOUS
end
-- 过滤自己场上可解放的「英雄」怪兽
function c61320914.cfilter1(c,tp)
	-- 检查卡片是否为「英雄」怪兽，且解放后能腾出可用的怪兽区域，并且该卡在场上表侧表示或由自己控制
	return c:IsSetCard(0x8) and Duel.GetMZoneCount(tp,c)>0 and (c:IsFaceup() or c:IsControler(tp))
end
-- 效果②的发动代价
function c61320914.spcost1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在可解放的「英雄」怪兽
	if chk==0 then return Duel.CheckReleaseGroup(tp,c61320914.cfilter1,1,nil,tp) end
	-- 选择自己场上1只可解放的「英雄」怪兽
	local g=Duel.SelectReleaseGroup(tp,c61320914.cfilter1,1,1,nil,tp)
	-- 将选择的怪兽解放
	Duel.Release(g,REASON_COST)
end
-- 效果②的发动准备与合法性检测
function c61320914.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己是否能将这张卡作为怪兽特殊召唤
	if chk==0 then return Duel.IsPlayerCanSpecialSummonMonster(tp,61320914,0x5008,TYPE_MONSTER+TYPE_EFFECT,900,1100,3,RACE_WARRIOR,ATTRIBUTE_DARK) end
	-- 设置操作信息为特殊召唤这张卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果②的效果处理
function c61320914.spop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将这张卡特殊召唤
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- 效果③的发动条件
function c61320914.descon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_SZONE) and c:GetPreviousSequence()<5
end
-- 过滤对方场上表侧表示且等级4以下的怪兽
function c61320914.desfilter(c)
	return c:IsFaceup() and c:IsLevelBelow(4)
end
-- 效果③的发动准备与合法性检测
function c61320914.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方场上是否存在等级4以下的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c61320914.desfilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 获取对方场上所有等级4以下的怪兽
	local g=Duel.GetMatchingGroup(c61320914.desfilter,tp,0,LOCATION_MZONE,nil)
	-- 设置操作信息为破坏其中1张卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果③的效果处理
function c61320914.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要破坏的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家选择对方场上1只等级4以下的怪兽
	local g=Duel.SelectMatchingCard(tp,c61320914.desfilter,tp,0,LOCATION_MZONE,1,1,nil)
	if g:GetCount()>0 then
		-- 为选中的卡片显示被选为对象的动画效果
		Duel.HintSelection(g)
		-- 因效果破坏选中的怪兽
		Duel.Destroy(g,REASON_EFFECT)
	end
end
