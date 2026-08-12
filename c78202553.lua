--サブテラーマリス・ジブラタール
-- 效果：
-- 这个卡名的③的效果1回合只能使用1次。
-- ①：自己场上的表侧表示怪兽变成里侧表示时，自己场上没有表侧表示怪兽存在的场合才能发动。这张卡从手卡守备表示特殊召唤。
-- ②：自己主要阶段才能发动。这张卡变成里侧守备表示（1回合只有1次）。
-- ③：这张卡反转的场合才能发动。从手卡丢弃1只「地中族」怪兽，自己从卡组抽2张。
function c78202553.initial_effect(c)
	-- 这个卡名的③的效果1回合只能使用1次。③：这张卡反转的场合才能发动。从手卡丢弃1只「地中族」怪兽，自己从卡组抽2张。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(78202553,0))
	e1:SetCategory(CATEGORY_DRAW+CATEGORY_HANDES_SELF)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,78202553)
	e1:SetTarget(c78202553.target)
	e1:SetOperation(c78202553.operation)
	c:RegisterEffect(e1)
	-- ①：自己场上的表侧表示怪兽变成里侧表示时，自己场上没有表侧表示怪兽存在的场合才能发动。这张卡从手卡守备表示特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(78202553,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetRange(LOCATION_HAND)
	e2:SetCode(EVENT_CHANGE_POS)
	e2:SetCondition(c78202553.spcon)
	e2:SetTarget(c78202553.sptg)
	e2:SetOperation(c78202553.spop)
	c:RegisterEffect(e2)
	-- ②：自己主要阶段才能发动。这张卡变成里侧守备表示（1回合只有1次）。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(78202553,2))
	e3:SetCategory(CATEGORY_POSITION+CATEGORY_MSET)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTarget(c78202553.postg)
	e3:SetOperation(c78202553.posop)
	c:RegisterEffect(e3)
end
-- 过滤条件：手卡中可丢弃的「地中族」怪兽
function c78202553.tgfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0xed) and c:IsDiscardable()
end
-- 效果③（反转效果）的发动准备与合法性检测
function c78202553.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡中是否存在至少1只可丢弃的「地中族」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c78202553.tgfilter,tp,LOCATION_HAND,0,1,nil)
		-- 并且检查玩家是否可以抽2张卡
		and Duel.IsPlayerCanDraw(tp,2) end
	Duel.SetOperationInfo(0,CATEGORY_HANDES_SELF,nil,0,tp,1)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
-- 效果③（反转效果）的效果处理
function c78202553.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 让玩家从手卡丢弃1只「地中族」怪兽，若成功丢弃则执行后续处理
	if Duel.DiscardHand(tp,c78202553.tgfilter,1,1,REASON_EFFECT+REASON_DISCARD)~=0 then
		-- 玩家从卡组抽2张卡
		Duel.Draw(tp,2,REASON_EFFECT)
	end
end
-- 过滤条件：原本是表侧表示现在变成里侧表示的自己场上的怪兽
function c78202553.cfilter(c,tp)
	return c:IsPreviousPosition(POS_FACEUP) and c:IsFacedown() and c:IsControler(tp)
end
-- 效果①（手卡特召）的发动条件：自己场上有怪兽变成里侧表示，且自己场上没有表侧表示怪兽
function c78202553.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c78202553.cfilter,1,nil,tp)
		-- 且自己场上没有表侧表示的怪兽
		and not Duel.IsExistingMatchingCard(Card.IsFaceup,tp,LOCATION_MZONE,0,1,nil)
end
-- 效果①（手卡特召）的发动准备与合法性检测
function c78202553.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 且自己场上没有表侧表示的怪兽
		and not Duel.IsExistingMatchingCard(Card.IsFaceup,tp,LOCATION_MZONE,0,1,nil)
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE) end
	-- 设置操作信息：特殊召唤自身
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果①（手卡特召）的效果处理
function c78202553.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将自身以表侧守备表示特殊召唤
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 效果②（变里侧守备）的发动准备与合法性检测
function c78202553.postg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsCanTurnSet() and c:GetFlagEffect(78202553)==0 end
	c:RegisterFlagEffect(78202553,RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET+RESET_PHASE+PHASE_END,0,1)
	-- 设置操作信息：改变表示形式
	Duel.SetOperationInfo(0,CATEGORY_POSITION,c,1,0,0)
end
-- 效果②（变里侧守备）的效果处理
function c78202553.posop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 将自身变成里侧守备表示
		Duel.ChangePosition(c,POS_FACEDOWN_DEFENSE)
	end
end
