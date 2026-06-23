--雷撃壊獣サンダー・ザ・キング
-- 效果：
-- ①：这张卡可以把对方场上1只怪兽解放，从手卡往对方场上攻击表示特殊召唤。
-- ②：对方场上有「坏兽」怪兽存在的场合，这张卡可以从手卡攻击表示特殊召唤。
-- ③：「坏兽」怪兽在自己场上只能有1只表侧表示存在。
-- ④：1回合1次，把自己·对方场上3个坏兽指示物取除才能发动。这个回合，对方不能把魔法·陷阱·怪兽的效果发动，这张卡在同1次的战斗阶段中最多3次可以向怪兽攻击。
function c48770333.initial_effect(c)
	-- 设置此卡在场上的唯一性，确保同一组「坏兽」怪兽只能有1只表侧表示存在
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
-- 定义特殊召唤时可解放的目标怪兽过滤条件：目标怪兽需满足可解放且对方场上存在可用怪兽区
function c48770333.spfilter(c,tp)
	-- 目标怪兽需满足可解放且对方场上存在可用怪兽区
	return c:IsReleasable(REASON_SPSUMMON) and Duel.GetMZoneCount(1-tp,c,tp)>0
end
-- 设置特殊召唤的条件函数，检查是否存在满足条件的怪兽作为解放对象
function c48770333.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查是否存在满足条件的怪兽作为解放对象
	return Duel.IsExistingMatchingCard(c48770333.spfilter,tp,0,LOCATION_MZONE,1,nil,tp)
end
-- 定义特殊召唤的目标选择函数，从符合条件的怪兽中选择1只进行解放
function c48770333.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取所有满足特殊召唤条件的怪兽组
	local g=Duel.GetMatchingGroup(c48770333.spfilter,tp,0,LOCATION_MZONE,nil,tp)
	-- 提示玩家选择要解放的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 定义特殊召唤的操作函数，执行对所选怪兽的解放操作
function c48770333.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将目标怪兽以特殊召唤为代价进行解放
	Duel.Release(g,REASON_SPSUMMON)
end
-- 定义「坏兽」怪兽的过滤条件：必须是表侧表示且属于「坏兽」系列
function c48770333.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xd3)
end
-- 设置第二套特殊召唤的条件函数，检查己方场上是否存在「坏兽」怪兽且有可用怪兽区
function c48770333.spcon2(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查己方场上是否有可用怪兽区
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查己方场上是否存在「坏兽」怪兽
		and Duel.IsExistingMatchingCard(c48770333.cfilter,tp,0,LOCATION_MZONE,1,nil)
end
-- 定义攻击效果的发动条件：检查回合玩家是否能进入战斗阶段
function c48770333.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查回合玩家是否能进入战斗阶段
	return Duel.IsAbleToEnterBP()
end
-- 定义攻击效果的费用函数，检查是否可以移除3个坏兽指示物作为代价
function c48770333.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否可以移除3个坏兽指示物作为代价
	if chk==0 then return Duel.IsCanRemoveCounter(tp,1,1,0x37,3,REASON_COST) end
	-- 执行移除3个坏兽指示物的操作
	Duel.RemoveCounter(tp,1,1,0x37,3,REASON_COST)
end
-- 定义攻击效果的发动操作，设置对方不能发动效果并使此卡获得额外攻击次数
function c48770333.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 创建一个影响对方玩家的效果，禁止其在本回合发动魔法·陷阱·怪兽效果
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetTargetRange(0,1)
	e1:SetValue(1)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将该效果注册给对方玩家
	Duel.RegisterEffect(e1,tp)
	if c:IsRelateToEffect(e) then
		-- 创建一个使此卡在本回合可额外攻击2次的效果
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetCode(EFFECT_EXTRA_ATTACK_MONSTER)
		e2:SetValue(2)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e2)
	end
end
