--光の継承
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：和已在场上存在的怪兽相同种类（仪式·融合·同调·超量）的怪兽仪式·融合·同调·超量召唤的场合才能发动。自己从卡组抽1张。
function c48784854.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：和已在场上存在的怪兽相同种类（仪式·融合·同调·超量）的怪兽仪式·融合·同调·超量召唤的场合才能发动。自己从卡组抽1张。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(48784854,0))  --"抽1张卡"
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,48784854)
	e2:SetCondition(c48784854.drcon)
	e2:SetTarget(c48784854.drtg)
	e2:SetOperation(c48784854.drop)
	c:RegisterEffect(e2)
end
-- 判断场上是否存在与特殊召唤的怪兽类型相同的怪兽
function c48784854.typfilter(c,sumtype)
	return c:IsFaceup() and c:GetType()&sumtype>0
end
-- 过滤函数，用于检查特殊召唤的怪兽是否为仪式/融合/同调/超量类型，并且场上有相同类型的怪兽
function c48784854.cfilter(c,tp)
	local sumtype=bit.band(c:GetType(),TYPE_RITUAL|TYPE_FUSION|TYPE_SYNCHRO|TYPE_XYZ)
	return c:IsFaceup()
		and (c:IsSummonType(SUMMON_TYPE_RITUAL) or c:IsSummonType(SUMMON_TYPE_FUSION)
			or c:IsSummonType(SUMMON_TYPE_SYNCHRO) or c:IsSummonType(SUMMON_TYPE_XYZ))
		-- 检查场上是否存在与特殊召唤怪兽类型相同的怪兽
		and Duel.IsExistingMatchingCard(c48784854.typfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,c,sumtype)
end
-- 判断是否有满足条件的特殊召唤怪兽（仪式/融合/同调/超量）
function c48784854.drcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c48784854.cfilter,1,nil,tp)
end
-- 设置效果发动时的目标玩家和抽卡数量
function c48784854.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测是否可以抽卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 设置效果的目标玩家为当前玩家
	Duel.SetTargetPlayer(tp)
	-- 设置效果的目标参数为抽卡数量1
	Duel.SetTargetParam(1)
	-- 设置效果操作信息为抽卡效果，目标为当前玩家抽1张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 执行抽卡效果
function c48784854.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中设定的目标玩家和抽卡数量
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 执行从卡组抽卡的效果
	Duel.Draw(p,d,REASON_EFFECT)
end
