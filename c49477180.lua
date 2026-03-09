--ヴェンデット・ストリゲス
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡被送去墓地的场合，把手卡1张「复仇死者」卡给对方观看才能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
-- ②：使用场上的这张卡仪式召唤的「复仇死者」怪兽得到以下效果。
-- ●这张卡和对方怪兽进行战斗的伤害计算后才能发动。自己从卡组抽1张，那之后选1张手卡丢弃。
function c49477180.initial_effect(c)
	-- ①：这张卡被送去墓地的场合，把手卡1张「复仇死者」卡给对方观看才能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(49477180,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,49477180)
	e1:SetCost(c49477180.spcost)
	e1:SetTarget(c49477180.sptg)
	e1:SetOperation(c49477180.spop)
	c:RegisterEffect(e1)
	-- ②：使用场上的这张卡仪式召唤的「复仇死者」怪兽得到以下效果。●这张卡和对方怪兽进行战斗的伤害计算后才能发动。自己从卡组抽1张，那之后选1张手卡丢弃。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_EVENT_PLAYER)
	e2:SetCode(EVENT_BE_MATERIAL)
	e2:SetCountLimit(1,49477181)
	e2:SetCondition(c49477180.mtcon)
	e2:SetOperation(c49477180.mtop)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于检索满足条件的「复仇死者」手牌（未公开）
function c49477180.spcfilter(c)
	return c:IsSetCard(0x106) and not c:IsPublic()
end
-- 效果处理：选择并确认一张手牌中的「复仇死者」卡，然后洗切手牌
function c49477180.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足发动条件：手牌中存在至少1张「复仇死者」且未公开的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c49477180.spcfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 提示玩家选择要给对方确认的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 选择一张手牌中的「复仇死者」卡并确认给对方观看
	local cg=Duel.SelectMatchingCard(tp,c49477180.spcfilter,tp,LOCATION_HAND,0,1,1,nil)
	-- 将所选卡牌展示给对方玩家
	Duel.ConfirmCards(1-tp,cg)
	-- 将玩家的手牌进行洗切
	Duel.ShuffleHand(tp)
end
-- 效果处理：判断是否可以特殊召唤此卡
function c49477180.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否有足够的怪兽区域用于特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：准备特殊召唤此卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理：将此卡特殊召唤到场上，并设置其离场时的去向为除外
function c49477180.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查是否满足特殊召唤条件：场上存在空位且此卡与效果相关
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<1 or not c:IsRelateToEffect(e) then return end
	-- 执行特殊召唤操作，若成功则继续设置效果
	if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- 创建并注册一个效果，使该卡从场上离开时被除外
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e1,true)
	end
end
-- 判断是否满足触发条件：此卡作为仪式召唤的素材被使用且其前位置为怪兽区
function c49477180.mtcon(e,tp,eg,ep,ev,re,r,rp)
	return r==REASON_RITUAL and e:GetHandler():IsPreviousLocation(LOCATION_MZONE)
		and eg:IsExists(Card.IsSetCard,1,nil,0x106)
end
-- 效果处理：为使用此卡仪式召唤的「复仇死者」怪兽添加战斗后抽卡丢卡的效果
function c49477180.mtop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=eg:Filter(Card.IsSetCard,nil,0x106)
	local rc=g:GetFirst()
	if not rc then return end
	-- 为该怪兽添加一个诱发效果，使其在战斗伤害计算后发动抽卡丢卡效果
	local e1=Effect.CreateEffect(rc)
	e1:SetDescription(aux.Stringid(49477180,1))
	e1:SetCategory(CATEGORY_HANDES+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLED)
	e1:SetTarget(c49477180.drtg)
	e1:SetOperation(c49477180.drop)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	rc:RegisterEffect(e1,true)
	if not rc:IsType(TYPE_EFFECT) then
		-- 若该怪兽不具有效果类型，则为其添加TYPE_EFFECT类型
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_ADD_TYPE)
		e3:SetValue(TYPE_EFFECT)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD)
		rc:RegisterEffect(e3,true)
	end
	rc:RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(49477180,2))  --"「复仇死者·斯特里克斯」效果适用中"
end
-- 效果处理：设置抽卡与丢卡的操作信息
function c49477180.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足发动条件：攻击怪兽存在且玩家可以抽卡
	if chk==0 then return Duel.GetAttackTarget()~=nil and Duel.IsPlayerCanDraw(tp,1) end
	-- 设置操作信息：准备丢弃一张手牌
	Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,tp,1)
	-- 设置操作信息：准备让玩家抽一张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 效果处理：执行抽卡并丢弃手牌的操作
function c49477180.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查是否成功抽到卡
	if Duel.Draw(tp,1,REASON_EFFECT)~=0 then
		-- 中断当前连锁，使后续处理视为错时点
		Duel.BreakEffect()
		-- 从玩家手牌中选择并丢弃一张卡
		Duel.DiscardHand(tp,nil,1,1,REASON_EFFECT+REASON_DISCARD)
	end
end
