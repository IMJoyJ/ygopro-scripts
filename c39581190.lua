--サブテラーの射手
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己场上有这张卡以外的「地中族」怪兽存在，这张卡向对方的里侧守备表示怪兽攻击的伤害步骤开始时才能发动。那只对方怪兽回到持有者卡组。
-- ②：场上的这张卡被战斗·效果破坏送去墓地的场合才能发动。从卡组把1只「地中族」怪兽表侧守备表示或者里侧守备表示特殊召唤。
function c39581190.initial_effect(c)
	-- ①：自己场上有这张卡以外的「地中族」怪兽存在，这张卡向对方的里侧守备表示怪兽攻击的伤害步骤开始时才能发动。那只对方怪兽回到持有者卡组。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(39581190,0))
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_START)
	e1:SetCountLimit(1,39581190)
	e1:SetCondition(c39581190.tdcon)
	e1:SetTarget(c39581190.tdtg)
	e1:SetOperation(c39581190.tdop)
	c:RegisterEffect(e1)
	-- ②：场上的这张卡被战斗·效果破坏送去墓地的场合才能发动。从卡组把1只「地中族」怪兽表侧守备表示或者里侧守备表示特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(39581190,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_MSET)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,39581191)
	e2:SetCondition(c39581190.spcon)
	e2:SetTarget(c39581190.sptg)
	e2:SetOperation(c39581190.spop)
	c:RegisterEffect(e2)
end
-- 过滤函数，检查场上是否存在满足条件的「地中族」怪兽（表侧表示）
function c39581190.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xed)
end
-- 效果条件函数，判断是否满足①效果的发动条件
function c39581190.tdcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取此次战斗的攻击目标怪兽
	local d=Duel.GetAttackTarget()
	-- 判断是否为攻击怪兽且攻击目标为里侧守备表示
	return c==Duel.GetAttacker() and d and d:IsPosition(POS_FACEDOWN_DEFENSE)
		-- 判断自己场上是否存在其他「地中族」怪兽
		and Duel.IsExistingMatchingCard(c39581190.cfilter,tp,LOCATION_MZONE,0,1,c)
end
-- ①效果的发动时的处理函数
function c39581190.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取此次战斗的攻击目标怪兽
	local d=Duel.GetAttackTarget()
	if chk==0 then return d:IsAbleToDeck() end
	-- 设置操作信息，指定将目标怪兽送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,d,1,0,0)
end
-- ①效果的处理函数，将目标怪兽送回卡组
function c39581190.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取此次战斗的攻击目标怪兽
	local d=Duel.GetAttackTarget()
	if d:IsRelateToBattle() and d:IsPosition(POS_FACEDOWN_DEFENSE) then
		-- 将目标怪兽送回卡组并洗牌
		Duel.SendtoDeck(d,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
-- ②效果的发动条件函数，判断是否满足墓地触发条件
function c39581190.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsReason(REASON_DESTROY) and c:IsReason(REASON_BATTLE+REASON_EFFECT)
end
-- 过滤函数，检查卡组中是否存在可特殊召唤的「地中族」怪兽
function c39581190.spfilter(c,e,tp)
	return c:IsSetCard(0xed) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_DEFENSE)
end
-- ②效果的发动时处理函数
function c39581190.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断场上是否有足够的特殊召唤区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断卡组中是否存在满足条件的「地中族」怪兽
		and Duel.IsExistingMatchingCard(c39581190.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置操作信息，指定将1只「地中族」怪兽特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- ②效果的处理函数，从卡组特殊召唤1只「地中族」怪兽
function c39581190.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断场上是否有足够的特殊召唤区域
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组中选择1只满足条件的「地中族」怪兽
	local g=Duel.SelectMatchingCard(tp,c39581190.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if not tc then return end
	-- 将选中的怪兽特殊召唤到场上
	if Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_DEFENSE)~=0 and tc:IsFacedown() then
		-- 确认对方能看到被特殊召唤的怪兽
		Duel.ConfirmCards(1-tp,tc)
	end
end
