--U.A.ペナルティ
-- 效果：
-- 「超级运动员受罚」的①的效果1回合只能使用1次。
-- ①：自己的「超级运动员」怪兽和对方怪兽进行战斗的伤害步骤开始时才能把这个效果发动。那只对方怪兽直到发动后第2次的对方结束阶段除外。
-- ②：把墓地的这张卡除外才能发动。从卡组把1张「超级运动员」魔法卡加入手卡。
function c70043345.initial_effect(c)
	-- ①：自己的「超级运动员」怪兽和对方怪兽进行战斗的伤害步骤开始时才能把这个效果发动。那只对方怪兽直到发动后第2次的对方结束阶段除外。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	e1:SetTarget(c70043345.target)
	c:RegisterEffect(e1)
	-- ①：自己的「超级运动员」怪兽和对方怪兽进行战斗的伤害步骤开始时才能把这个效果发动。那只对方怪兽直到发动后第2次的对方结束阶段除外。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_BATTLE_START)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,70043345)
	e2:SetCondition(c70043345.rmcon)
	e2:SetTarget(c70043345.rmtg)
	e2:SetOperation(c70043345.rmop)
	c:RegisterEffect(e2)
	-- ②：把墓地的这张卡除外才能发动。从卡组把1张「超级运动员」魔法卡加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_GRAVE)
	-- 把墓地的这张卡除外作为发动成本
	e3:SetCost(aux.bfgcost)
	e3:SetTarget(c70043345.thtg)
	e3:SetOperation(c70043345.thop)
	c:RegisterEffect(e3)
end
-- 卡片发动时的效果处理与分支判定（处理单纯的卡片发动或在伤害步骤开始时同时发动①的效果）
function c70043345.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判定当前阶段是否不为伤害步骤（即是否可以进行通常的卡片发动）
	local b1=Duel.GetCurrentPhase()~=PHASE_DAMAGE
	-- 判定当前是否处于伤害步骤开始时，且满足①的效果的发动条件和除外目标的存在
	local b2=Duel.CheckEvent(EVENT_BATTLE_START) and c70043345.rmcon(e,tp,eg,ep,ev,re,r,rp) and c70043345.rmtg(e,tp,eg,ep,ev,re,r,rp,0)
	if chk==0 then return b1 or b2 end
	if b2 then
		e:SetCategory(CATEGORY_REMOVE)
		e:SetOperation(c70043345.rmop)
		c70043345.rmtg(e,tp,eg,ep,ev,re,r,rp,1)
	else
		e:SetCategory(0)
		e:SetOperation(nil)
	end
end
-- 判定是否满足①的效果的发动条件（自己的「超级运动员」怪兽和对方怪兽进行战斗）
function c70043345.rmcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本次战斗的攻击怪兽
	local tc=Duel.GetAttacker()
	-- 获取本次战斗的被攻击怪兽
	local bc=Duel.GetAttackTarget()
	if not bc then return false end
	if tc:IsControler(1-tp) then tc,bc=bc,tc end
	if tc:IsFaceup() and tc:IsSetCard(0xb2) then
		e:SetLabelObject(bc)
		return true
	else return false end
end
-- ①的效果的目标选择与发动合法性检测（检测对方怪兽是否可以除外，并确保每回合只能使用1次）
function c70043345.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local bc=e:GetLabelObject()
	-- 检查对方怪兽是否可以被除外，且本回合该玩家尚未发动过该效果
	if chk==0 then return bc:IsAbleToRemove() and Duel.GetFlagEffect(tp,70043345)==0 end
	-- 设置连锁信息，表示该效果的操作分类为除外，操作对象为该对方怪兽
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,bc,1,0,0)
	-- 给玩家注册一个回合内有效的标识，用于限制该效果一回合只能使用一次
	Duel.RegisterFlagEffect(tp,70043345,RESET_PHASE+PHASE_END,0,1)
end
-- ①的效果的运行空间（将对方怪兽暂时除外，并注册一个在第2次对方结束阶段将其返回场上的效果）
function c70043345.rmop(e,tp,eg,ep,ev,re,r,rp)
	local bc=e:GetLabelObject()
	-- 确认该怪兽仍处于战斗关系中且仍由对方控制，将其以效果原因暂时除外
	if bc:IsRelateToBattle() and bc:IsControler(1-tp) and Duel.Remove(bc,0,REASON_EFFECT+REASON_TEMPORARY)~=0 then
		bc:SetTurnCounter(0)
		-- 那只对方怪兽直到发动后第2次的对方结束阶段除外。②：把墓地的这张卡除外才能发动。从卡组把1张「超级运动员」魔法卡加入手卡。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(aux.Stringid(70043345,0))  --"除外的怪兽回到场上"
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetReset(RESET_PHASE+PHASE_END+RESET_OPPO_TURN,2)
		e1:SetLabelObject(bc)
		e1:SetCountLimit(1)
		e1:SetCondition(c70043345.retcon)
		e1:SetOperation(c70043345.retop)
		-- 注册全局环境下的延迟效果，用于后续将除外的怪兽返回场上
		Duel.RegisterEffect(e1,tp)
	end
end
-- 判定是否为对方回合的结束阶段（用于计算第2次对方结束阶段）
function c70043345.retcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前回合玩家是否不是自己（即当前是对方的回合）
	return Duel.GetTurnPlayer()~=tp
end
-- 累加对方回合结束阶段的计数器，并在达到第2次时将怪兽返回场上
function c70043345.retop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	local ct=tc:GetTurnCounter()
	ct=ct+1
	tc:SetTurnCounter(ct)
	if ct==2 then
		-- 将暂时除外的怪兽返回到场上
		Duel.ReturnToField(tc)
	end
end
-- 过滤卡组中满足条件的「超级运动员」魔法卡
function c70043345.thfilter(c)
	return c:IsSetCard(0xb2) and c:IsType(TYPE_SPELL) and c:IsAbleToHand()
end
-- ②的效果的发动检测与目标确认
function c70043345.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在可以加入手牌的「超级运动员」魔法卡
	if chk==0 then return Duel.IsExistingMatchingCard(c70043345.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁信息，表示该效果的操作分类为检索卡组并加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ②的效果的运行空间（从卡组将1张「超级运动员」魔法卡加入手牌）
function c70043345.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组中选择1张满足条件的「超级运动员」魔法卡
	local g=Duel.SelectMatchingCard(tp,c70043345.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡片加入玩家手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示加入手牌的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
