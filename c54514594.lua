--ヴォルカニック・ハンマー
-- 效果：
-- 可以给与对方基本分自己墓地存在的名字带有「火山」的怪兽卡数量×200的数值的伤害。这个效果1回合只能使用1次。这个效果发动的场合，这个回合这张卡不能攻击。
function c54514594.initial_effect(c)
	-- 可以给与对方基本分自己墓地存在的名字带有「火山」的怪兽卡数量×200的数值的伤害。这个效果1回合只能使用1次。这个效果发动的场合，这个回合这张卡不能攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(54514594,0))  --"给予对方伤害"
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c54514594.cost)
	e1:SetTarget(c54514594.target)
	e1:SetOperation(c54514594.operation)
	c:RegisterEffect(e1)
end
-- 效果发动成本：检查自身本回合是否未宣言攻击，并给自身施加本回合不能攻击的誓约限制。
function c54514594.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetAttackAnnouncedCount()==0 end
	-- 这个效果发动的场合，这个回合这张卡不能攻击。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e:GetHandler():RegisterEffect(e1)
end
-- 效果发动目标：确认自己墓地有「火山」怪兽存在，并指定对方为伤害对象。
function c54514594.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段，确认自己墓地是否存在至少1张名字带有「火山」的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsSetCard,tp,LOCATION_GRAVE,0,1,nil,0x32) end
	-- 将对方玩家设定为效果的目标玩家。
	Duel.SetTargetPlayer(1-tp)
	-- 向系统注册操作信息：此效果会造成伤害分类的操作，目标是对方玩家。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,0)
end
-- 效果处理：获取目标玩家，并根据自己墓地「火山」怪兽的数量给予其对应的伤害。
function c54514594.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在发动时设定的目标玩家（即对方玩家）。
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 计算自己墓地中名字带有「火山」的卡片数量，并乘以200作为伤害值。
	local d=Duel.GetMatchingGroupCount(Card.IsSetCard,tp,LOCATION_GRAVE,0,nil,0x32)*200
	-- 对目标玩家造成计算出的效果伤害。
	Duel.Damage(p,d,REASON_EFFECT)
end
