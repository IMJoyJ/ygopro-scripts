--雷撃壊獣サンダー・ザ・キング
-- 效果：
-- ①：这张卡可以把对方场上1只怪兽解放，从手卡往对方场上攻击表示特殊召唤。
-- ②：对方场上有「坏兽」怪兽存在的场合，这张卡可以从手卡攻击表示特殊召唤。
-- ③：「坏兽」怪兽在自己场上只能有1只表侧表示存在。
-- ④：1回合1次，把自己·对方场上3个坏兽指示物取除才能发动。这个回合，对方不能把魔法·陷阱·怪兽的效果发动，这张卡在同1次的战斗阶段中最多3次可以向怪兽攻击。
function c48770333.initial_effect(c)
	-- 设置此卡在场上唯一存在，且必须是坏兽卡组的怪兽
	c:SetUniqueOnField(1,0,aux.FilterBoolFunction(Card.IsSetCard,0xd3),LOCATION_MZONE)
	-- ①：这张卡可以把对方场上1只怪兽解放，从手卡往对方场上攻击表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_HAND)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SPSUM_PARAM)
	e1:SetTargetRange(POS_FACEUP_ATTACK,1)
	e1:SetCondition(c48770333.spcon)
	e1:SetTarget(c48770333.sptg)
	e1:SetOperation(c48770333.spop)
	c:RegisterEffect(e1)
	-- ②：对方场上有「坏兽」怪兽存在的场合，这张卡可以从手卡攻击表示特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetRange(LOCATION_HAND)
	e2:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SPSUM_PARAM)
	e2:SetTargetRange(POS_FACEUP_ATTACK,0)
	e2:SetCondition(c48770333.spcon2)
	c:RegisterEffect(e2)
	-- ④：1回合1次，把自己·对方场上3个坏兽指示物取除才能发动。这个回合，对方不能把魔法·陷阱·怪兽的效果发动，这张卡在同1次的战斗阶段中最多3次可以向怪兽攻击。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(48770333,0))
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(c48770333.atkcon)
	e3:SetCost(c48770333.atkcost)
	e3:SetOperation(c48770333.atkop)
	c:RegisterEffect(e3)
end
c48770333.mentioned_counter={
	[0x37]=true,
}
-- 过滤满足条件的可解放怪兽，包括其能被特殊召唤且对方场上存在可用怪兽区
function c48770333.spfilter(c,tp)
	-- 返回该怪兽是否可被解放用于特殊召唤，并且对方场上存在可用怪兽区
	return c:IsReleasable(REASON_SPSUMMON) and Duel.GetMZoneCount(1-tp,c,tp)>0
end
-- 判断是否有满足条件的怪兽可以作为解放对象以进行特殊召唤
function c48770333.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查是否存在至少1只满足条件的怪兽（即可以解放的怪兽）
	return Duel.IsExistingMatchingCard(c48770333.spfilter,tp,0,LOCATION_MZONE,1,nil,tp)
end
-- 选择并标记要解放的怪兽，用于后续特殊召唤操作
function c48770333.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取所有满足特殊召唤条件的怪兽组
	local g=Duel.GetMatchingGroup(c48770333.spfilter,tp,0,LOCATION_MZONE,nil,tp)
	-- 提示玩家选择要解放的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 执行特殊召唤时的解放操作
function c48770333.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将指定怪兽从场上解放以完成特殊召唤
	Duel.Release(g,REASON_SPSUMMON)
end
-- 过滤满足条件的己方坏兽怪兽（必须表侧表示）
function c48770333.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xd3)
end
-- 判断是否满足特殊召唤条件：己方场上有空位且存在坏兽怪兽
function c48770333.spcon2(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查己方场上是否存在可用怪兽区
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查己方场上是否存在至少1只坏兽怪兽
		and Duel.IsExistingMatchingCard(c48770333.cfilter,tp,0,LOCATION_MZONE,1,nil)
end
-- 判断是否可以进入战斗阶段
function c48770333.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查是否能进入战斗阶段
	return Duel.IsAbleToEnterBP()
end
-- 支付发动效果的代价：移除3个坏兽指示物
function c48770333.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否可以移除3个坏兽指示物作为代价
	if chk==0 then return Duel.IsCanRemoveCounter(tp,1,1,0x37,3,REASON_COST) end
	-- 从己方和对方场上移除3个坏兽指示物
	Duel.RemoveCounter(tp,1,1,0x37,3,REASON_COST)
end
-- 发动效果：禁止对方在本回合发动魔法/陷阱/怪兽效果，并使此卡可额外攻击2次
function c48770333.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 创建并注册一个禁止对方发动效果的永续效果
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetTargetRange(0,1)
	e1:SetValue(1)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将效果注册到玩家环境中
	Duel.RegisterEffect(e1,tp)
	if c:IsRelateToEffect(e) then
		-- 创建并注册一个使此卡可额外攻击2次的效果
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetCode(EFFECT_EXTRA_ATTACK_MONSTER)
		e2:SetValue(2)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e2)
	end
end
