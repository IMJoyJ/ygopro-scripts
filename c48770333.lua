--雷撃壊獣サンダー・ザ・キング
-- 效果：
-- ①：这张卡可以把对方场上1只怪兽解放，从手卡往对方场上攻击表示特殊召唤。
-- ②：对方场上有「坏兽」怪兽存在的场合，这张卡可以从手卡攻击表示特殊召唤。
-- ③：「坏兽」怪兽在自己场上只能有1只表侧表示存在。
-- ④：1回合1次，把自己·对方场上3个坏兽指示物取除才能发动。这个回合，对方不能把魔法·陷阱·怪兽的效果发动，这张卡在同1次的战斗阶段中最多3次可以向怪兽攻击。
function c48770333.initial_effect(c)
	-- 设置「坏兽」系列的场地上唯一规则：自己怪兽区域只能有1只表侧表示的「坏兽」怪兽存在
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
-- 解放用过滤函数：检查对象怪兽能否为特殊召唤而解放，且其被解放后对方场上仍有空余怪兽区域
function c48770333.spfilter(c,tp)
	-- 该怪兽可以为特殊召唤而解放，且解放它之后对方场上可用的怪兽区数量大于0
	return c:IsReleasable(REASON_SPSUMMON) and Duel.GetMZoneCount(1-tp,c,tp)>0
end
-- 特殊召唤条件①：检查对方场上是否存在可以为特殊召唤而解放的怪兽
function c48770333.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 对方场上存在至少1只满足解放过滤条件的怪兽时，才允许进行这个特殊召唤
	return Duel.IsExistingMatchingCard(c48770333.spfilter,tp,0,LOCATION_MZONE,1,nil,tp)
end
-- 特殊召唤目标处理：检索对方场上可解放的怪兽，让玩家选择其中1只作为要解放的怪兽
function c48770333.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 检索对方场上所有满足解放过滤条件的怪兽，组成候选卡组
	local g=Duel.GetMatchingGroup(c48770333.spfilter,tp,0,LOCATION_MZONE,nil,tp)
	-- 向玩家提示「请选择要解放的卡」
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 特殊召唤操作：取出之前选择的怪兽，将其以特殊召唤为由解放
function c48770333.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将选中的对方场上怪兽以特殊召唤为由解放，作为往对方场上特殊召唤的手续
	Duel.Release(g,REASON_SPSUMMON)
end
-- 过滤函数：筛选表侧表示的「坏兽」系列怪兽
function c48770333.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xd3)
end
-- 特殊召唤条件②：自己场上有空余怪兽区域，且对方场上存在表侧表示的「坏兽」怪兽
function c48770333.spcon2(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 自己场上必须有至少1个可用的怪兽区域
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 对方场上存在至少1只表侧表示的「坏兽」怪兽
		and Duel.IsExistingMatchingCard(c48770333.cfilter,tp,0,LOCATION_MZONE,1,nil)
end
-- 起动效果的发动条件：回合玩家能够进入战斗阶段
function c48770333.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查回合玩家当前能否进入战斗阶段
	return Duel.IsAbleToEnterBP()
end
-- 发动代价：把自己·对方场上合计3个坏兽指示物取除
function c48770333.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检查：确认能以代价为由从自己·对方场上取除3个坏兽指示物
	if chk==0 then return Duel.IsCanRemoveCounter(tp,1,1,0x37,3,REASON_COST) end
	-- 以代价为由从自己·对方场上取除3个坏兽指示物
	Duel.RemoveCounter(tp,1,1,0x37,3,REASON_COST)
end
-- 效果处理：注册本回合对方不能发动效果的全局效果，并在这张卡仍与效果关联时赋予其对怪兽最多3次攻击的能力
function c48770333.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 这个回合，对方不能把魔法·陷阱·怪兽的效果发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetTargetRange(0,1)
	e1:SetValue(1)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 把「对方不能发动效果」的限制作为回合玩家发动的全局效果注册，直到回合结束阶段
	Duel.RegisterEffect(e1,tp)
	if c:IsRelateToEffect(e) then
		-- 这张卡在同1次的战斗阶段中最多3次可以向怪兽攻击。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetCode(EFFECT_EXTRA_ATTACK_MONSTER)
		e2:SetValue(2)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e2)
	end
end
