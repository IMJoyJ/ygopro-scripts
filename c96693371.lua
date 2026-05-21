--V・HERO マルティプリ・ガイ
-- 效果：
-- 这个卡名的①②③的效果1回合各能使用1次。
-- ①：自己因战斗·效果受到伤害的场合才能发动。墓地的这张卡当作永续陷阱卡使用在自己的魔法与陷阱区域表侧表示放置。
-- ②：这张卡是当作永续陷阱卡使用的场合，双方的主要阶段，把自己场上1只「英雄」怪兽解放才能发动。这张卡特殊召唤。
-- ③：这张卡从魔法与陷阱区域的特殊召唤成功的场合才能发动。选场上1只怪兽，那个攻击力上升800。
function c96693371.initial_effect(c)
	-- ①：自己因战斗·效果受到伤害的场合才能发动。墓地的这张卡当作永续陷阱卡使用在自己的魔法与陷阱区域表侧表示放置。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(96693371,0))  --"这张卡当作永续陷阱卡放置"
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL+EFFECT_FLAG_DELAY)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCountLimit(1,96693371)
	e1:SetCondition(c96693371.condition)
	e1:SetTarget(c96693371.target)
	e1:SetOperation(c96693371.operation)
	c:RegisterEffect(e1)
	-- ②：这张卡是当作永续陷阱卡使用的场合，双方的主要阶段，把自己场上1只「英雄」怪兽解放才能发动。这张卡特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(96693371,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCountLimit(1,96693372)
	e2:SetHintTiming(0,TIMING_MAIN_END)
	e2:SetCondition(c96693371.spcon1)
	e2:SetCost(c96693371.spcost1)
	e2:SetTarget(c96693371.sptg1)
	e2:SetOperation(c96693371.spop1)
	c:RegisterEffect(e2)
	-- ③：这张卡从魔法与陷阱区域的特殊召唤成功的场合才能发动。选场上1只怪兽，那个攻击力上升800。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(96693371,2))
	e3:SetCategory(CATEGORY_ATKCHANGE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,96693373)
	e3:SetCondition(c96693371.atkcon)
	e3:SetTarget(c96693371.atktg)
	e3:SetOperation(c96693371.atkop)
	c:RegisterEffect(e3)
end
-- 检查自己是否因战斗或效果受到伤害
function c96693371.condition(e,tp,eg,ep,ev,re,r,rp)
	return ep==tp and bit.band(r,REASON_BATTLE+REASON_EFFECT)~=0
end
-- 效果①的发动准备：检查魔法与陷阱区域是否有空位，并设置将墓地的这张卡移出墓地的操作信息
function c96693371.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的魔法与陷阱区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0 end
	-- 设置当前连锁的操作信息为：将墓地的这张卡移出墓地
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
end
-- 效果①的效果处理：将墓地的这张卡移动到魔法与陷阱区域表侧表示放置，并使其类型变更为永续陷阱卡
function c96693371.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 尝试将这张卡移动到自己的魔法与陷阱区域表侧表示放置
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
-- 效果②的发动条件：当前是双方的主要阶段，且这张卡在魔陷区当作永续陷阱卡使用
function c96693371.spcon1(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前的阶段
	local ph=Duel.GetCurrentPhase()
	return (ph==PHASE_MAIN1 or ph==PHASE_MAIN2) and e:GetHandler():GetType()==TYPE_TRAP+TYPE_CONTINUOUS
end
-- 过滤条件：自己场上可解放的「英雄」怪兽，且解放后能腾出怪兽区域空位
function c96693371.cfilter1(c,tp)
	-- 检查卡片是否为「英雄」怪兽，且解放该卡后自己场上有可用于特殊召唤的怪兽区域空格，并且该卡在场上表侧表示（或在自己控制下）
	return c:IsSetCard(0x8) and Duel.GetMZoneCount(tp,c)>0 and (c:IsFaceup() or c:IsControler(tp))
end
-- 效果②的消耗：解放自己场上1只「英雄」怪兽
function c96693371.spcost1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在至少1只满足过滤条件的可解放怪兽
	if chk==0 then return Duel.CheckReleaseGroup(tp,c96693371.cfilter1,1,nil,tp) end
	-- 玩家选择1只满足过滤条件的可解放怪兽
	local g=Duel.SelectReleaseGroup(tp,c96693371.cfilter1,1,1,nil,tp)
	-- 解放选中的怪兽作为发动的代价
	Duel.Release(g,REASON_COST)
end
-- 效果②的发动准备：检查是否可以特殊召唤这张卡，并设置特殊召唤的操作信息
function c96693371.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否能将这张卡（暗属性、战士族、3星、攻击力900、守备力1100的效果怪兽）特殊召唤
	if chk==0 then return Duel.IsPlayerCanSpecialSummonMonster(tp,96693371,0x5008,TYPE_MONSTER+TYPE_EFFECT,900,1100,3,RACE_WARRIOR,ATTRIBUTE_DARK) end
	-- 设置当前连锁的操作信息为：特殊召唤这张卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果②的效果处理：将这张卡特殊召唤
function c96693371.spop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将这张卡以表侧表示特殊召唤到自己的怪兽区域
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- 效果③的发动条件：这张卡原本在魔法与陷阱区域（且不是场地区域）
function c96693371.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_SZONE) and c:GetPreviousSequence()<5
end
-- 效果③的发动准备：检查场上是否存在表侧表示的怪兽
function c96693371.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查双方场上是否存在至少1只表侧表示的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
end
-- 效果③的效果处理：选择场上1只表侧表示的怪兽，使其攻击力上升800
function c96693371.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 给玩家发送提示信息，要求选择1张表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 玩家选择双方场上1只表侧表示的怪兽
	local tc=Duel.SelectMatchingCard(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil):GetFirst()
	if tc then
		-- 那个攻击力上升800
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(800)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
