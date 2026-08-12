--ゴーストリック・スペクター
-- 效果：
-- 自己场上有名字带有「鬼计」的怪兽存在的场合才能让这张卡表侧表示召唤。这张卡1回合只有1次可以变成里侧守备表示。此外，名字带有「鬼计」的怪兽被对方的卡的效果或者对方怪兽的攻击破坏送去自己墓地时才能发动。这张卡从手卡里侧守备表示特殊召唤，从卡组抽1张卡。
function c81907872.initial_effect(c)
	-- 自己场上有名字带有「鬼计」的怪兽存在的场合才能让这张卡表侧表示召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_SUMMON)
	e1:SetCondition(c81907872.sumcon)
	c:RegisterEffect(e1)
	-- 这张卡1回合只有1次可以变成里侧守备表示。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(81907872,0))  --"变成里侧守备"
	e2:SetCategory(CATEGORY_POSITION+CATEGORY_MSET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTarget(c81907872.postg)
	e2:SetOperation(c81907872.posop)
	c:RegisterEffect(e2)
	-- 名字带有「鬼计」的怪兽被对方的卡的效果或者对方怪兽的攻击破坏送去自己墓地时才能发动。这张卡从手卡里侧守备表示特殊召唤，从卡组抽1张卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(81907872,1))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DRAW+CATEGORY_MSET)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetRange(LOCATION_HAND)
	e3:SetCondition(c81907872.spcon)
	e3:SetTarget(c81907872.sptg)
	e3:SetOperation(c81907872.spop)
	c:RegisterEffect(e3)
end
-- 过滤条件：自己场上表侧表示的「鬼计」怪兽
function c81907872.sfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x8d)
end
-- 召唤限制效果的启用条件：自己场上不存在表侧表示的「鬼计」怪兽
function c81907872.sumcon(e)
	-- 检查自己场上是否不存在表侧表示的「鬼计」怪兽
	return not Duel.IsExistingMatchingCard(c81907872.sfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
-- 变成里侧守备表示效果的发动检测与操作信息设置函数
function c81907872.postg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsCanTurnSet() and c:GetFlagEffect(81907872)==0 end
	c:RegisterFlagEffect(81907872,RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET+RESET_PHASE+PHASE_END,0,1)
	-- 设置操作信息：包含改变表示形式分类，操作对象为自身
	Duel.SetOperationInfo(0,CATEGORY_POSITION,c,1,0,0)
end
-- 变成里侧守备表示效果的执行函数
function c81907872.posop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 将自身变为里侧守备表示
		Duel.ChangePosition(c,POS_FACEDOWN_DEFENSE)
	end
end
-- 过滤条件：被对方卡片效果或对方怪兽攻击破坏并送去自己墓地的自己场上的「鬼计」怪兽
function c81907872.cfilter(c,tp)
	return c:IsControler(tp) and c:IsPreviousControler(tp) and c:IsReason(REASON_DESTROY) and c:GetReasonPlayer()==1-tp
		-- 检查卡片是否为「鬼计」怪兽，且因效果破坏或作为攻击对象被战斗破坏
		and c:IsSetCard(0x8d) and c:IsType(TYPE_MONSTER) and (c:IsReason(REASON_EFFECT) or (c:IsReason(REASON_BATTLE) and c==Duel.GetAttackTarget()))
end
-- 特殊召唤并抽卡效果的发动条件：送去墓地的卡中存在满足上述破坏条件的「鬼计」怪兽
function c81907872.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c81907872.cfilter,1,nil,tp)
end
-- 特殊召唤并抽卡效果的发动检测与操作信息设置函数
function c81907872.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动检测：检查自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE)
		-- 发动检测：检查玩家是否可以抽1张卡
		and Duel.IsPlayerCanDraw(tp,1) end
	-- 设置操作信息：包含特殊召唤分类，操作对象为自身
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
	-- 设置操作信息：包含抽卡分类，数量为1张
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 特殊召唤并抽卡效果的执行函数
function c81907872.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将自身以里侧守备表示特殊召唤，若特殊召唤成功则继续执行
	if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)~=0 then
		-- 给对方玩家确认特殊召唤的里侧表示怪兽
		Duel.ConfirmCards(1-tp,c)
		-- 玩家因效果抽1张卡
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
