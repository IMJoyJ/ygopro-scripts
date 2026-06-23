--レイテンシ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡因效果从自己墓地加入手卡的场合才能发动。这张卡从手卡特殊召唤。
-- ②：这张卡的①的效果特殊召唤的这张卡作为连接素材送去墓地的场合才能发动。自己从卡组抽1张。
function c3560069.initial_effect(c)
	-- ①：这张卡因效果从自己墓地加入手卡的场合才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(3560069,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_TO_HAND)
	e1:SetCountLimit(1,3560069)
	e1:SetCondition(c3560069.spcon)
	e1:SetTarget(c3560069.sptg)
	e1:SetOperation(c3560069.spop)
	c:RegisterEffect(e1)
end
-- 检查触发效果的原因为效果（REASON_EFFECT）且该卡从前任控制者墓地离开
function c3560069.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return bit.band(r,REASON_EFFECT)~=0 and c:IsPreviousLocation(LOCATION_GRAVE) and c:IsPreviousControler(tp)
end
-- 判断是否满足特殊召唤条件，包括场上是否有空位以及该卡是否可以被特殊召唤
function c3560069.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 判断场上是否有空位用于特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息，表示将要特殊召唤此卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- ②：这张卡的①的效果特殊召唤的这张卡作为连接素材送去墓地的场合才能发动。自己从卡组抽1张。
function c3560069.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 确认此卡是否仍然存在于场上并成功特殊召唤
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- ②：这张卡的①的效果特殊召唤的这张卡作为连接素材送去墓地的场合才能发动。自己从卡组抽1张。
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(3560069,1))
		e1:SetCategory(CATEGORY_DRAW)
		e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_DELAY)
		e1:SetCode(EVENT_BE_MATERIAL)
		e1:SetCountLimit(1,3560070)
		e1:SetCondition(c3560069.drcon)
		e1:SetTarget(c3560069.drtg)
		e1:SetOperation(c3560069.drop)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_LEAVE-RESET_TOGRAVE)
		c:RegisterEffect(e1)
	end
end
-- 确认此卡作为连接素材被送去墓地且原因为连接（REASON_LINK）
function c3560069.drcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and r==REASON_LINK
end
-- 判断是否可以抽卡并设置抽卡目标玩家和抽卡数量
function c3560069.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断玩家是否可以抽一张卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 设置连锁操作的目标玩家为当前玩家
	Duel.SetTargetPlayer(tp)
	-- 设置连锁操作的目标参数为抽卡数量1
	Duel.SetTargetParam(1)
	-- 设置操作信息，表示将要进行抽卡效果
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 执行抽卡效果
function c3560069.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中设定的目标玩家和抽卡数量
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 执行从卡组抽卡的效果
	Duel.Draw(p,d,REASON_EFFECT)
end
