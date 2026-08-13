--ZS－幻影賢者
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：自己场上有「希望皇 霍普」怪兽存在的场合才能发动。自己从卡组抽1张。
-- ②：自己场上的怪兽在战斗阶段中被除外的场合，以那之内的1只为对象，把这张卡从场上除外才能发动。作为对象的怪兽在自己场上特殊召唤，对方场上有攻击力3000以下的怪兽存在的场合，选那之内的1只除外。
function c51865604.initial_effect(c)
	-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。①：自己场上有「希望皇 霍普」怪兽存在的场合才能发动。自己从卡组抽1张。
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
-- 过滤函数：判断怪兽是否表侧表示且属于「希望皇 霍普」字段（0x107f），用于检测自己场上是否存在满足条件的「希望皇 霍普」怪兽。
function c51865604.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x107f)
end
-- ①效果的发动条件：检查自己场上是否存在至少1只表侧表示且属于「希望皇 霍普」字段的怪兽。
function c51865604.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在至少1张满足cfilter（表侧表示且「希望皇 霍普」字段）的怪兽，作为①效果的发动前提。
	return Duel.IsExistingMatchingCard(c51865604.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- ①效果的发动时处理：设定抽卡的玩家和数量（自己抽1张），并登记操作信息，以便处理时获取。
function c51865604.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查：确认玩家tp可以进行1次抽卡，若不能则不能发动。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 将当前连锁的对象玩家设置为tp，表示本次抽卡由tp执行。
	Duel.SetTargetPlayer(tp)
	-- 将当前连锁的对象参数设置为1，表示本次抽卡的数量为1张。
	Duel.SetTargetParam(1)
	-- 设置操作信息：声明本连锁包含从卡组抽1张卡的效果，目标玩家为tp，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- ①效果实际处理：从连锁信息中读取目标玩家和抽卡数量，让该玩家抽卡。
function c51865604.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁中取出之前保存的对象玩家p（抽卡玩家）和对象参数d（抽卡数量）。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让玩家p抽取d张卡，原因记为效果处理（REASON_EFFECT）。
	Duel.Draw(p,d,REASON_EFFECT)
end
-- 过滤函数：判断被除外的怪兽是否满足②效果的特殊召唤条件：表侧表示、之前在自己主要怪兽区、之前控制者是tp、可以特殊召唤且能成为效果对象。
function c51865604.spfilter(c,e,tp)
	return c:IsFaceup() and c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousControler(tp)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and c:IsCanBeEffectTarget(e)
end
-- ②效果的触发条件：当前处于战斗阶段（从战斗阶段开始到结束）且被除外的怪兽中存在满足spfilter的怪兽。
function c51865604.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 满足战斗阶段且除外组中存在至少1只满足特殊召唤条件的自己怪兽。
	return (Duel.GetCurrentPhase()>=PHASE_BATTLE_START and Duel.GetCurrentPhase()<=PHASE_BATTLE) and eg:IsExists(c51865604.spfilter,1,nil,e,tp)
end
-- ②效果的发动代价：检查这张卡能否从场上除外作为cost，若能则选择除外自己作为发动代价。
function c51865604.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost() end
	-- 实际支付代价：将这张卡自身以表侧表示除外，原因记为COST。
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_COST)
end
-- 过滤函数：用于选择对方场上要被除外的怪兽，条件为攻击力3000以下且可以除外。
function c51865604.rmfilter(c)
	return c:IsAttackBelow(3000) and c:IsAbleToRemove()
end
-- ②效果的发动时处理：从被除外的自己怪兽中选择1只作为特殊召唤对象，并确认自己场上有空位且对方场上有可除外的攻击力3000以下怪兽。
function c51865604.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return eg:IsContains(chkc) and c51865604.spfilter(chkc,e,tp) end
	-- 检查自己场上主要怪兽区是否有空位，用于特殊召唤对象怪兽。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查对方场上是否存在攻击力3000以下且可以被除外的怪兽，用于后续的除外处理。
		and Duel.IsExistingMatchingCard(c51865604.rmfilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 弹出选择提示，让tp选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	local g=eg:FilterSelect(tp,c51865604.spfilter,1,1,nil,e,tp)
	-- 将选择的怪兽设置为当前连锁的对象（即取对象）。
	Duel.SetTargetCard(g)
	-- 设置操作信息：本连锁会对选择的怪兽进行特殊召唤，对象为g，数量1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- ②效果处理：将对象怪兽特殊召唤到自己场上；若特殊召唤成功，则选择对方场上1只攻击力3000以下的怪兽除外。
function c51865604.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的对象卡（之前选择要特殊召唤的怪兽）。
	local tc=Duel.GetFirstTarget()
	-- 检查对象卡仍与效果相关且特殊召唤成功（以表侧表示特殊召唤到tp场上），成功则继续处理后续除外。
	if tc:IsRelateToEffect(e) and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 弹出选择提示，让tp选择要除外的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		-- 选择对方场上的1只攻击力3000以下且可以除外的怪兽。
		local g=Duel.SelectMatchingCard(tp,c51865604.rmfilter,tp,0,LOCATION_MZONE,1,1,nil)
		-- 将选择的对方怪兽以表侧表示除外，原因记为效果处理（REASON_EFFECT）。
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
	end
end
