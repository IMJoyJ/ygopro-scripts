--ファイヤー・ソウル
-- 效果：
-- 对方玩家抽1张卡。从自己卡组选择1只炎族怪兽从游戏中除外。给与对方基本分除外怪兽的攻击力一半数值的伤害。这张卡发动的场合，这个回合自己不能攻击宣言。
function c95026693.initial_effect(c)
	-- 对方玩家抽1张卡。从自己卡组选择1只炎族怪兽从游戏中除外。给与对方基本分除外怪兽的攻击力一半数值的伤害。这张卡发动的场合，这个回合自己不能攻击宣言。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW+CATEGORY_REMOVE+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c95026693.cost)
	e1:SetTarget(c95026693.target)
	e1:SetOperation(c95026693.activate)
	c:RegisterEffect(e1)
end
-- 定义发动代价，检查并注册本回合不能攻击宣言的限制
function c95026693.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查本回合自己是否未进行过攻击宣言
	if chk==0 then return Duel.GetActivityCount(tp,ACTIVITY_ATTACK)==0 end
	-- 对方玩家抽1张卡。从自己卡组选择1只炎族怪兽从游戏中除外。给与对方基本分除外怪兽的攻击力一半数值的伤害。这张卡发动的场合，这个回合自己不能攻击宣言。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将不能攻击宣言的效果注册给发动玩家
	Duel.RegisterEffect(e1,tp)
end
-- 过滤卡组中可以除外的炎族怪兽
function c95026693.filter(c)
	return c:IsRace(RACE_PYRO) and c:IsAbleToRemove()
end
-- 定义效果发动的目标，检查对方是否能抽卡以及自己卡组是否有可除外的炎族怪兽，并设置操作信息
function c95026693.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方玩家是否可以抽1张卡
	if chk==0 then return Duel.IsPlayerCanDraw(1-tp,1)
		-- 检查自己卡组是否存在至少1只可以除外的炎族怪兽
		and Duel.IsExistingMatchingCard(c95026693.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息，表示此效果包含对方抽1张卡的处理
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,1-tp,1)
	-- 设置操作信息，表示此效果包含从自己卡组除外1张卡的处理
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_DECK)
end
-- 定义效果处理，依次执行对方抽卡、自己除外炎族怪兽、给与对方伤害的处理
function c95026693.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 对方玩家抽1张卡
	Duel.Draw(1-tp,1,REASON_EFFECT)
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从自己卡组选择1只满足条件的炎族怪兽
	local g=Duel.SelectMatchingCard(tp,c95026693.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的怪兽表侧表示除外
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
		local dam=math.floor(g:GetFirst():GetAttack()/2)
		-- 给与对方玩家除外怪兽攻击力一半数值的伤害
		Duel.Damage(1-tp,dam,REASON_EFFECT)
	end
end
