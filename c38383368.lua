--エキストラケアトップス
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡在墓地存在，额外怪兽区域的怪兽被和主要怪兽区域的怪兽的战斗破坏送去墓地时才能发动。这张卡在那只破坏的额外怪兽区域的怪兽的持有者场上守备表示特殊召唤。
-- ②：这张卡的①的效果特殊召唤的这张卡被破坏送去墓地的场合发动。自己从卡组抽1张。
function c38383368.initial_effect(c)
	-- ①：这张卡在墓地存在，额外怪兽区域的怪兽被和主要怪兽区域的怪兽的战斗破坏送去墓地时才能发动。这张卡在那只破坏的额外怪兽区域的怪兽的持有者场上守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(38383368,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCountLimit(1,38383368)
	e1:SetTarget(c38383368.sptg)
	e1:SetOperation(c38383368.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡的①的效果特殊召唤的这张卡被破坏送去墓地的场合发动。自己从卡组抽1张。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCondition(c38383368.drcon)
	e2:SetTarget(c38383368.drtg)
	e2:SetOperation(c38383368.drop)
	c:RegisterEffect(e2)
end
-- 判断被破坏的怪兽是否为额外怪兽区域的怪兽且是由主要怪兽区域的怪兽战斗破坏的
function c38383368.cfilter(c)
	if not (c:IsReason(REASON_BATTLE) and c:GetPreviousSequence()>=5) then return false end
	local d=c:GetBattleTarget()
	return d:IsRelateToBattle() and d:GetSequence()<5 or not d:IsRelateToBattle() and d:GetPreviousSequence()<5
end
-- 检索满足条件的被战斗破坏的额外怪兽区域怪兽，用于确定特殊召唤的目标玩家
function c38383368.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local tc=eg:Filter(c38383368.cfilter,nil):GetFirst()
	-- 判断目标玩家场上是否有足够的怪兽区域用于特殊召唤
	if chk==0 then return not eg:IsContains(c) and tc and Duel.GetLocationCount(tc:GetControler(),LOCATION_MZONE,tp)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE,tc:GetControler()) end
	e:SetLabel(tc:GetControler())
	-- 设置连锁处理信息，表示将要进行特殊召唤操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 处理特殊召唤效果，将卡片以守备表示特殊召唤到目标玩家场上
function c38383368.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 执行特殊召唤操作，将卡片以守备表示特殊召唤到目标玩家场上
		Duel.SpecialSummon(c,SUMMON_VALUE_SELF,tp,e:GetLabel(),false,false,POS_FACEUP_DEFENSE)
	end
end
-- 判断该卡是否因破坏而进入墓地，且之前在主要怪兽区域，且为特殊召唤
function c38383368.drcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_DESTROY) and c:IsPreviousLocation(LOCATION_MZONE)
		and c:GetSummonType()==SUMMON_TYPE_SPECIAL+SUMMON_VALUE_SELF
end
-- 设置抽卡效果的目标玩家和抽卡数量
function c38383368.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁处理信息中的目标玩家为当前玩家
	Duel.SetTargetPlayer(tp)
	-- 设置连锁处理信息中的目标参数为1（表示抽1张卡）
	Duel.SetTargetParam(1)
	-- 设置连锁处理信息，表示将要进行抽卡操作
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 处理抽卡效果，从卡组抽取1张卡
function c38383368.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁处理信息中的目标玩家和抽卡数量
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 执行抽卡操作，从卡组抽取指定数量的卡
	Duel.Draw(p,d,REASON_EFFECT)
end
