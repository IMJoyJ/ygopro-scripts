--EMバリアバルーンバク
-- 效果：
-- 「娱乐伙伴 障碍气球貘」的②的效果1回合只能使用1次。
-- ①：自己怪兽和对方怪兽进行战斗的伤害计算时，把这张卡从手卡丢弃才能发动。那次战斗发生的双方的战斗伤害变成0。
-- ②：这张卡在墓地存在的场合，对方怪兽的直接攻击宣言时从手卡丢弃1只「娱乐伙伴」怪兽才能发动。这张卡从墓地守备表示特殊召唤。
function c71985676.initial_effect(c)
	-- ①：自己怪兽和对方怪兽进行战斗的伤害计算时，把这张卡从手卡丢弃才能发动。那次战斗发生的双方的战斗伤害变成0。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(71985676,0))  --"战斗伤害变成0"
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c71985676.dmcon)
	e1:SetCost(c71985676.dmcost)
	e1:SetOperation(c71985676.dmop)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在的场合，对方怪兽的直接攻击宣言时从手卡丢弃1只「娱乐伙伴」怪兽才能发动。这张卡从墓地守备表示特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(71985676,1))  --"这张卡特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,71985676)
	e2:SetCondition(c71985676.spcon)
	e2:SetCost(c71985676.spcost)
	e2:SetTarget(c71985676.sptg)
	e2:SetOperation(c71985676.spop)
	c:RegisterEffect(e2)
end
-- 判断是否为自己怪兽与对方怪兽进行战斗的伤害计算时
function c71985676.dmcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前进行攻击的怪兽
	local a=Duel.GetAttacker()
	-- 获取当前被攻击的怪兽
	local d=Duel.GetAttackTarget()
	return d and a:GetControler()~=d:GetControler()
end
-- 检查并执行将手牌中的这张卡丢弃的发动代价
function c71985676.dmcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDiscardable() end
	-- 将这张卡作为发动代价从手牌丢弃送去墓地
	Duel.SendtoGrave(e:GetHandler(),REASON_COST+REASON_DISCARD)
end
-- 执行使该次战斗发生的双方战斗伤害变成0的效果处理
function c71985676.dmop(e,tp,eg,ep,ev,re,r,rp)
	-- ②：这张卡在墓地存在的场合，对方怪兽的直接攻击宣言时从手卡丢弃1只「娱乐伙伴」怪兽才能发动。这张卡从墓地守备表示特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,1)
	e1:SetReset(RESET_PHASE+PHASE_DAMAGE)
	-- 在全局注册使双方玩家免受战斗伤害的效果
	Duel.RegisterEffect(e1,tp)
end
-- 判断是否满足对方怪兽直接攻击宣言时的发动条件
function c71985676.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 返回攻击怪兽由对方控制且没有攻击对象（即直接攻击）的判断结果
	return Duel.GetAttacker():IsControler(1-tp) and Duel.GetAttackTarget()==nil
end
-- 过滤手牌中可丢弃的「娱乐伙伴」怪兽
function c71985676.spcfilter(c)
	return c:IsSetCard(0x9f) and c:IsType(TYPE_MONSTER) and c:IsDiscardable()
end
-- 检查并执行从手牌丢弃1只「娱乐伙伴」怪兽的发动代价
function c71985676.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在chk为0时，检查手牌中是否存在可丢弃的「娱乐伙伴」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c71985676.spcfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 从手牌中选择1只「娱乐伙伴」怪兽作为代价丢弃送去墓地
	Duel.DiscardHand(tp,c71985676.spcfilter,1,1,REASON_COST+REASON_DISCARD)
end
-- 检查并设置将自身特殊召唤的效果目标
function c71985676.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在chk为0时，检查自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE) end
	-- 设置当前连锁的操作信息为特殊召唤自身
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 执行将自身从墓地守备表示特殊召唤的效果处理
function c71985676.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将自身以表侧守备表示特殊召唤到自己场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
