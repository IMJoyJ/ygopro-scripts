--スロワースワロー
-- 效果：
-- 这个卡名的①的方法的特殊召唤1回合只能有1次。
-- ①：场上有相同等级的怪兽2只以上存在的场合，这张卡可以从手卡特殊召唤。
-- ②：把这张卡解放才能发动。下次的自己抽卡阶段的通常抽卡变成2张。
function c10505300.initial_effect(c)
	-- ①：场上有相同等级的怪兽2只以上存在的场合，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_HAND)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetCountLimit(1,10505300+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c10505300.spcon)
	c:RegisterEffect(e1)
	-- ②：把这张卡解放才能发动。下次的自己抽卡阶段的通常抽卡变成2张。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(10505300,0))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCost(c10505300.cost)
	e2:SetOperation(c10505300.operation)
	c:RegisterEffect(e2)
end
-- 检索满足条件的怪兽组，用于判断场上有无相同等级的怪兽
function c10505300.spfilter1(c)
	return c:IsFaceup() and c:IsLevelAbove(0)
		-- 检查场上是否存在至少1只与当前怪兽等级相同的表侧表示怪兽
		and Duel.IsExistingMatchingCard(c10505300.spfilter2,0,LOCATION_MZONE,LOCATION_MZONE,1,c,c:GetLevel())
end
-- 用于判断指定等级的怪兽是否存在
function c10505300.spfilter2(c,lv)
	return c:IsFaceup() and c:IsLevel(lv)
end
-- 判断特殊召唤条件是否满足
function c10505300.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查玩家场上是否有可用空间
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查场上是否存在至少1只满足条件的表侧表示怪兽
		and Duel.IsExistingMatchingCard(c10505300.spfilter1,0,LOCATION_MZONE,LOCATION_MZONE,1,nil)
end
-- 设置效果的发动费用
function c10505300.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 将自身解放作为发动费用
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 设置效果的发动后操作
function c10505300.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 下次自己抽卡阶段的通常抽卡变成2张
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_DRAW_COUNT)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE+PHASE_DRAW+RESET_SELF_TURN)
	e1:SetValue(2)
	-- 将效果注册到游戏环境，使效果生效
	Duel.RegisterEffect(e1,tp)
end
