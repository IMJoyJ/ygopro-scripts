--毒の魔妖－束脛
-- 效果：
-- ①：「毒之魔妖-束胫」在自己场上只能有1只表侧表示存在。
-- ②：这张卡在墓地存在，「毒之魔妖-束胫」以外的自己的「魔妖」怪兽被战斗或者对方的效果破坏的场合才能发动。这张卡特殊召唤。这个效果发动的回合，自己不是「魔妖」怪兽不能从额外卡组特殊召唤。
function c5325155.initial_effect(c)
	c:SetUniqueOnField(1,0,5325155)
	-- ②：这张卡在墓地存在，「毒之魔妖-束胫」以外的自己的「魔妖」怪兽被战斗或者对方的效果破坏的场合才能发动。这张卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(5325155,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_DESTROYED)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCondition(c5325155.spcon)
	e1:SetCost(c5325155.spcost)
	e1:SetTarget(c5325155.sptg)
	e1:SetOperation(c5325155.spop)
	c:RegisterEffect(e1)
	-- 注册自定义活动计数器，用于检测该回合是否进行了非「魔妖」怪兽从额外卡组的特殊召唤
	Duel.AddCustomActivityCounter(5325155,ACTIVITY_SPSUMMON,c5325155.counterfilter)
end
-- 计数器过滤条件：被特殊召唤的怪兽不是从额外卡组特殊召唤，或者是表侧表示的「魔妖」怪兽
function c5325155.counterfilter(c)
	return not c:IsSummonLocation(LOCATION_EXTRA) or c:IsSetCard(0x121) and c:IsFaceup()
end
-- 过滤条件：自己场上「毒之魔妖-束胫」以外的「魔妖」怪兽被战斗或者对方的效果破坏
function c5325155.cfilter(c,tp,rp)
	return c:IsReason(REASON_BATTLE+REASON_EFFECT) and c:IsSetCard(0x121) and not c:IsCode(5325155)
		and c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousControler(tp)
		and (c:IsReason(REASON_BATTLE) or (rp==1-tp and c:IsReason(REASON_EFFECT)))
end
-- 特殊召唤效果的发动条件：存在符合被破坏条件的怪兽
function c5325155.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c5325155.cfilter,1,nil,tp,rp)
end
-- 限制从额外卡组特殊召唤非「魔妖」怪兽的誓约效果
function c5325155.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- chk为0时，检查玩家本回合是否从额外卡组特殊召唤过非「魔妖」怪兽
	if chk==0 then return Duel.GetCustomActivityCount(5325155,tp,ACTIVITY_SPSUMMON)==0 end
	-- 这个效果发动的回合，自己不是「魔妖」怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c5325155.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将不能从额外卡组特殊召唤非「魔妖」怪兽的限制效果注册给发动效果的玩家
	Duel.RegisterEffect(e1,tp)
end
-- 特殊召唤效果的发动判定与准备
function c5325155.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- chk为0时，检查自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP) end
	-- 设置包含自身特殊召唤的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 特殊召唤效果的具体处理
function c5325155.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡特殊召唤到场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 特殊召唤限制过滤条件：限制不能从额外卡组特殊召唤非「魔妖」怪兽
function c5325155.splimit(e,c,sump,sumtype,sumpos,targetp)
	return c:IsLocation(LOCATION_EXTRA) and not c:IsSetCard(0x121)
end
