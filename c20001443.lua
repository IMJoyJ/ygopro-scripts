--相剣師－莫邪
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤的场合，把手卡1张「相剑」卡或者1只幻龙族怪兽给对方观看才能发动。在自己场上把1只「相剑衍生物」（幻龙族·调整·水·4星·攻/守0）特殊召唤。只要这个效果特殊召唤的衍生物存在，自己不是同调怪兽不能从额外卡组特殊召唤。
-- ②：这张卡作为同调素材送去墓地的场合才能发动。自己抽1张。
function c20001443.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤的场合，把手卡1张「相剑」卡或者1只幻龙族怪兽给对方观看才能发动。在自己场上把1只「相剑衍生物」（幻龙族·调整·水·4星·攻/守0）特殊召唤。只要这个效果特殊召唤的衍生物存在，自己不是同调怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(20001443,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,20001443)
	e1:SetCost(c20001443.spcost)
	e1:SetTarget(c20001443.sptg)
	e1:SetOperation(c20001443.spop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：这张卡作为同调素材送去墓地的场合才能发动。自己抽1张。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_DRAW)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCode(EVENT_BE_MATERIAL)
	e3:SetCountLimit(1,20001444)
	e3:SetCondition(c20001443.drcon)
	e3:SetTarget(c20001443.drtg)
	e3:SetOperation(c20001443.drop)
	c:RegisterEffect(e3)
end
-- 检索满足条件的「相剑」卡或幻龙族怪兽
function c20001443.costfilter(c)
	return (c:IsSetCard(0x16b) or (c:IsRace(RACE_WYRM) and c:IsType(TYPE_MONSTER))) and not c:IsPublic()
end
-- 选择并确认手牌中满足条件的卡
function c20001443.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手牌中是否存在满足条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c20001443.costfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 提示玩家选择要确认的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 选择满足条件的卡
	local g=Duel.SelectMatchingCard(tp,c20001443.costfilter,tp,LOCATION_HAND,0,1,1,nil)
	-- 向对方确认所选的卡
	Duel.ConfirmCards(1-tp,g)
	-- 将手牌洗切
	Duel.ShuffleHand(tp)
end
-- 准备特殊召唤衍生物
function c20001443.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查是否可以特殊召唤衍生物
		and Duel.IsPlayerCanSpecialSummonMonster(tp,20001444,0x16b,TYPES_TOKEN_MONSTER+TYPE_TUNER,0,0,4,RACE_WYRM,ATTRIBUTE_WATER) end
	-- 设置操作信息为特殊召唤衍生物
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	-- 设置操作信息为特殊召唤衍生物
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
-- 执行特殊召唤衍生物并设置限制效果
function c20001443.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否有空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查是否可以特殊召唤衍生物
		and Duel.IsPlayerCanSpecialSummonMonster(tp,20001444,0x16b,TYPES_TOKEN_MONSTER+TYPE_TUNER,0,0,4,RACE_WYRM,ATTRIBUTE_WATER) then
		-- 创建衍生物
		local token=Duel.CreateToken(tp,20001444)
		-- 特殊召唤衍生物
		Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
		-- 设置衍生物的限制效果
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetRange(LOCATION_MZONE)
		e1:SetAbsoluteRange(tp,1,0)
		e1:SetTarget(c20001443.splimit)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		token:RegisterEffect(e1,true)
		-- 完成特殊召唤流程
		Duel.SpecialSummonComplete()
	end
end
-- 限制非同调怪兽从额外卡组特殊召唤
function c20001443.splimit(e,c)
	return not c:IsType(TYPE_SYNCHRO) and c:IsLocation(LOCATION_EXTRA)
end
-- 判断是否作为同调素材进入墓地
function c20001443.drcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and r==REASON_SYNCHRO
end
-- 准备抽卡效果
function c20001443.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否可以抽卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 设置抽卡对象为当前玩家
	Duel.SetTargetPlayer(tp)
	-- 设置抽卡数量为1
	Duel.SetTargetParam(1)
	-- 设置操作信息为抽卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 执行抽卡效果
function c20001443.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中的抽卡对象和数量
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 执行抽卡
	Duel.Draw(p,d,REASON_EFFECT)
end
