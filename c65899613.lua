--B・F－必中のピン
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己场上有昆虫族怪兽存在的场合才能发动。这张卡从手卡特殊召唤。
-- ②：自己主要阶段才能发动。给与对方为自己场上的「蜂军-必中之大头针蜂」数量×200伤害。
function c65899613.initial_effect(c)
	-- ①：自己场上有昆虫族怪兽存在的场合才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,65899613)
	e1:SetCondition(c65899613.spcon)
	e1:SetTarget(c65899613.sptg)
	e1:SetOperation(c65899613.spop)
	c:RegisterEffect(e1)
	-- ②：自己主要阶段才能发动。给与对方为自己场上的「蜂军-必中之大头针蜂」数量×200伤害。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_DAMAGE)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,65899614)
	e3:SetTarget(c65899613.damtg)
	e3:SetOperation(c65899613.damop)
	c:RegisterEffect(e3)
end
-- 过滤条件：是否为表侧表示的昆虫族怪兽
function c65899613.cfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_INSECT)
end
-- 效果①的发动条件函数
function c65899613.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在表侧表示的昆虫族怪兽
	return Duel.IsExistingMatchingCard(c65899613.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 效果①的发动准备函数：检查怪兽区域空格并确认自身能否特殊召唤
function c65899613.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁的操作信息为特殊召唤自身
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果①的效果处理函数
function c65899613.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将这张卡以表侧表示特殊召唤
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- 过滤条件：是否为表侧表示的「蜂军-必中之大头针蜂」
function c65899613.damfilter(c)
	return c:IsFaceup() and c:IsCode(65899613)
end
-- 效果②的发动准备函数：确认场上有符合条件的卡并计算伤害、设置效果参数
function c65899613.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在至少1张表侧表示的「蜂军-必中之大头针蜂」
	if chk==0 then return Duel.IsExistingMatchingCard(c65899613.damfilter,tp,LOCATION_ONFIELD,0,1,nil) end
	-- 计算伤害值：场上表侧表示的「蜂军-必中之大头针蜂」数量乘以200
	local val=Duel.GetMatchingGroupCount(c65899613.damfilter,tp,LOCATION_ONFIELD,0,nil)*200
	-- 设置当前连锁的对象玩家为对方玩家
	Duel.SetTargetPlayer(1-tp)
	-- 设置当前连锁的对象参数为计算出的伤害值
	Duel.SetTargetParam(val)
	-- 设置连锁的操作信息为给与对方伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,val)
end
-- 效果②的效果处理函数
function c65899613.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的对象玩家
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 重新计算当前场上表侧表示的「蜂军-必中之大头针蜂」数量对应的伤害值
	local val=Duel.GetMatchingGroupCount(c65899613.damfilter,tp,LOCATION_ONFIELD,0,nil)*200
	-- 给与目标玩家效果伤害
	Duel.Damage(p,val,REASON_EFFECT)
end
