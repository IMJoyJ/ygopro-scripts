--ZS－幻影賢者
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：自己场上有「希望皇 霍普」怪兽存在的场合才能发动。自己从卡组抽1张。
-- ②：自己场上的怪兽在战斗阶段中被除外的场合，以那之内的1只为对象，把这张卡从场上除外才能发动。作为对象的怪兽在自己场上特殊召唤，对方场上有攻击力3000以下的怪兽存在的场合，选那之内的1只除外。
function c51865604.initial_effect(c)
	-- ①：自己场上有「希望皇 霍普」怪兽存在的场合才能发动。自己从卡组抽1张。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(51865604,0))  --"抽卡"
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,51865604)
	e1:SetCondition(c51865604.condition)
	e1:SetTarget(c51865604.target)
	e1:SetOperation(c51865604.operation)
	c:RegisterEffect(e1)
	-- ②：自己场上的怪兽在战斗阶段中被除外的场合，以那之内的1只为对象，把这张卡从场上除外才能发动。作为对象的怪兽在自己场上特殊召唤，对方场上有攻击力3000以下的怪兽存在的场合，选那之内的1只除外。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(51865604,1))  --"特殊召唤并除外"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_REMOVE)
	e2:SetCountLimit(1,51865604)
	e2:SetCondition(c51865604.spcon)
	e2:SetCost(c51865604.spcost)
	e2:SetTarget(c51865604.sptg)
	e2:SetOperation(c51865604.spop)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于判断场上是否存在「希望皇 霍普」怪兽
function c51865604.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x107f)
end
-- 效果条件函数，检查是否满足①效果发动条件
function c51865604.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上有「希望皇 霍普」怪兽存在
	return Duel.IsExistingMatchingCard(c51865604.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 设置效果目标为抽卡
function c51865604.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否可以抽1张卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 设置效果的目标玩家为自己
	Duel.SetTargetPlayer(tp)
	-- 设置效果的目标参数为抽1张卡
	Duel.SetTargetParam(1)
	-- 设置效果操作信息为抽卡效果
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 效果处理函数，执行抽卡操作
function c51865604.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中的目标玩家和目标参数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让目标玩家从卡组抽指定数量的卡
	Duel.Draw(p,d,REASON_EFFECT)
end
-- 过滤函数，用于筛选被除外且满足特殊召唤条件的怪兽
function c51865604.spfilter(c,e,tp)
	return c:IsFaceup() and c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousControler(tp)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and c:IsCanBeEffectTarget(e)
end
-- 触发效果条件函数，检查是否满足②效果发动条件
function c51865604.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前阶段为战斗阶段，并且有符合条件的怪兽被除外
	return (Duel.GetCurrentPhase()>=PHASE_BATTLE_START and Duel.GetCurrentPhase()<=PHASE_BATTLE) and eg:IsExists(c51865604.spfilter,1,nil,e,tp)
end
-- 设置效果成本，将自身从场上除外作为cost
function c51865604.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost() end
	-- 将自身从场上除外作为效果成本
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_COST)
end
-- 过滤函数，用于筛选攻击力3000以下且可以被除外的怪兽
function c51865604.rmfilter(c)
	return c:IsAttackBelow(3000) and c:IsAbleToRemove()
end
-- 设置效果目标，选择要特殊召唤的怪兽并检查是否有可除外的怪兽
function c51865604.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return eg:IsContains(chkc) and c51865604.spfilter(chkc,e,tp) end
	-- 检查自己场上是否有足够的特殊召唤区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查对方场上有攻击力3000以下的怪兽存在
		and Duel.IsExistingMatchingCard(c51865604.rmfilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	local g=eg:FilterSelect(tp,c51865604.spfilter,1,1,nil,e,tp)
	-- 设置当前效果的目标卡为所选怪兽
	Duel.SetTargetCard(g)
	-- 设置效果操作信息为特殊召唤效果
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理函数，执行特殊召唤和除外操作
function c51865604.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 检查目标怪兽是否仍然有效，并将其特殊召唤到场上
	if tc:IsRelateToEffect(e) and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 提示玩家选择要除外的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		-- 选择攻击力3000以下且可以被除外的怪兽
		local g=Duel.SelectMatchingCard(tp,c51865604.rmfilter,tp,0,LOCATION_MZONE,1,1,nil)
		-- 将选中的怪兽从场上除外
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
	end
end
