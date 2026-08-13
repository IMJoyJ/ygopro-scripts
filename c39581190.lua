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
-- 过滤函数：判断怪兽是否为表侧表示的「地中族」怪兽。
function c39581190.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xed)
end
-- ①效果的发动条件：这张卡为攻击怪兽、攻击对象为里侧守备表示怪兽，且自己场上有这张卡以外的表侧「地中族」怪兽存在。
function c39581190.tdcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取这张卡攻击的对方怪兽作为攻击目标。
	local d=Duel.GetAttackTarget()
	-- 确认攻击方为这张卡本身，且攻击目标存在并处于里侧守备表示。
	return c==Duel.GetAttacker() and d and d:IsPosition(POS_FACEDOWN_DEFENSE)
		-- 确认自己场上的主要怪兽区存在这张卡以外的表侧「地中族」怪兽（ex参数c除外）。
		and Duel.IsExistingMatchingCard(c39581190.cfilter,tp,LOCATION_MZONE,0,1,c)
end
-- ①效果发动时的目标判定：攻击目标必须能被送回持有者卡组，并设置将那只怪兽送回卡组的操作信息。
function c39581190.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取成为效果对象的攻击目标（对方里侧守备表示怪兽）。
	local d=Duel.GetAttackTarget()
	if chk==0 then return d:IsAbleToDeck() end
	-- 设置操作信息：将攻击目标怪兽（1张）弹回持有者卡组（回卡组分类）。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,d,1,0,0)
end
-- ①效果处理：若攻击目标仍与本次战斗关联且处于里侧守备表示，则将其弹回持有者卡组并洗牌。
function c39581190.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前攻击目标，用于效果处理时确认对象。
	local d=Duel.GetAttackTarget()
	if d:IsRelateToBattle() and d:IsPosition(POS_FACEDOWN_DEFENSE) then
		-- 将攻击目标怪兽以效果原因弹回持有者卡组并洗切（先置于卡组底再洗牌）。
		Duel.SendtoDeck(d,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
-- ②效果的发动条件：这张卡从场上被战斗或效果破坏并送去墓地。
function c39581190.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsReason(REASON_DESTROY) and c:IsReason(REASON_BATTLE+REASON_EFFECT)
end
-- 过滤函数：选择卡组中满足「地中族」字段且能以守备表示特殊召唤的怪兽。
function c39581190.spfilter(c,e,tp)
	return c:IsSetCard(0xed) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_DEFENSE)
end
-- ②效果发动时的目标判定：自己主要怪兽区有空位，且卡组存在符合条件的「地中族」怪兽。
function c39581190.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 若为发动确认阶段，检查自己场上是否有可用的主要怪兽区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 且卡组中存在至少1只满足特殊召唤条件的「地中族」怪兽。
		and Duel.IsExistingMatchingCard(c39581190.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置操作信息：从卡组特殊召唤1只怪兽（特殊召唤分类，对象在效果处理时选择）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- ②效果处理：从卡组选择1只「地中族」怪兽以守备表示特殊召唤；若特殊召唤后为里侧表示，则向对方确认。
function c39581190.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时若自己场上没有可用的主要怪兽区域，则效果不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 弹出提示，让玩家从卡组选择要特殊召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组选择1只符合条件的「地中族」怪兽（不取对象，效果处理时选择）。
	local g=Duel.SelectMatchingCard(tp,c39581190.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if not tc then return end
	-- 将选择的怪兽以守备表示特殊召唤到己方场上；若特殊召唤成功且为里侧守备表示，则继续给对方确认。
	if Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_DEFENSE)~=0 and tc:IsFacedown() then
		-- 将里侧守备表示特殊召唤的怪兽向对方玩家展示确认。
		Duel.ConfirmCards(1-tp,tc)
	end
end
