--怪粉壊獣ガダーラ
-- 效果：
-- ①：这张卡可以把对方场上1只怪兽解放，从手卡往对方场上攻击表示特殊召唤。
-- ②：对方场上有「坏兽」怪兽存在的场合，这张卡可以从手卡攻击表示特殊召唤。
-- ③：「坏兽」怪兽在自己场上只能有1只表侧表示存在。
-- ④：1回合1次，把自己·对方场上3个坏兽指示物取除才能发动。这张卡以外的场上的全部怪兽的攻击力·守备力变成一半。这个效果在对方回合也能发动。
function c36956512.initial_effect(c)
	-- 设置此卡在场上的唯一性，确保同一时间场上只能存在一只表侧表示的「坏兽」怪兽
	c:SetUniqueOnField(1,0,aux.FilterBoolFunction(Card.IsSetCard,0xd3),LOCATION_MZONE)
	-- ①：这张卡可以把对方场上1只怪兽解放，从手卡往对方场上攻击表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_HAND)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SPSUM_PARAM)
	e1:SetTargetRange(POS_FACEUP_ATTACK,1)
	e1:SetCondition(c36956512.spcon)
	e1:SetTarget(c36956512.sptg)
	e1:SetOperation(c36956512.spop)
	c:RegisterEffect(e1)
	-- ②：对方场上有「坏兽」怪兽存在的场合，这张卡可以从手卡攻击表示特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetRange(LOCATION_HAND)
	e2:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SPSUM_PARAM)
	e2:SetTargetRange(POS_FACEUP_ATTACK,0)
	e2:SetCondition(c36956512.spcon2)
	c:RegisterEffect(e2)
	-- ④：1回合1次，把自己·对方场上3个坏兽指示物取除才能发动。这张卡以外的场上的全部怪兽的攻击力·守备力变成一半。这个效果在对方回合也能发动。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(36956512,0))
	e3:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e3:SetHintTiming(TIMING_DAMAGE_STEP,TIMING_DAMAGE_STEP+TIMINGS_CHECK_MONSTER)
	e3:SetCountLimit(1)
	-- 限制此效果只能在伤害步骤前发动
	e3:SetCondition(aux.dscon)
	e3:SetCost(c36956512.atkcost)
	e3:SetTarget(c36956512.atktg)
	e3:SetOperation(c36956512.atkop)
	c:RegisterEffect(e3)
end
c36956512.mentioned_counter={
	[0x37]=true,
}
-- 定义特殊召唤时用于筛选可解放的怪兽的过滤函数
function c36956512.spfilter(c,tp)
	-- 返回值为真表示该怪兽可以被解放用于特殊召唤且对方场上存在可用怪兽区
	return c:IsReleasable(REASON_SPSUMMON) and Duel.GetMZoneCount(1-tp,c,tp)>0
end
-- 判断是否满足特殊召唤条件：场上存在可解放的怪兽
function c36956512.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查场上是否存在满足条件的怪兽以供解放
	return Duel.IsExistingMatchingCard(c36956512.spfilter,tp,0,LOCATION_MZONE,1,nil,tp)
end
-- 定义特殊召唤时选择要解放的怪兽的操作函数
function c36956512.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取所有满足条件的可解放怪兽组
	local g=Duel.GetMatchingGroup(c36956512.spfilter,tp,0,LOCATION_MZONE,nil,tp)
	-- 提示玩家选择要解放的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 执行特殊召唤时的解放操作
function c36956512.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将指定怪兽从场上解放用于特殊召唤
	Duel.Release(g,REASON_SPSUMMON)
end
-- 定义用于判断对方场上有无「坏兽」怪兽的过滤函数
function c36956512.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xd3)
end
-- 判断是否满足第二种特殊召唤条件：对方场上有「坏兽」怪兽存在且己方有空怪兽区
function c36956512.spcon2(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查己方是否有可用怪兽区
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查对方场上是否存在「坏兽」怪兽
		and Duel.IsExistingMatchingCard(c36956512.cfilter,tp,0,LOCATION_MZONE,1,nil)
end
-- 定义效果发动时消耗3个坏兽指示物的处理函数
function c36956512.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否可以移除3个坏兽指示物作为发动代价
	if chk==0 then return Duel.IsCanRemoveCounter(tp,1,1,0x37,3,REASON_COST) end
	-- 从己方和对方场上移除3个坏兽指示物
	Duel.RemoveCounter(tp,1,1,0x37,3,REASON_COST)
end
-- 定义效果发动时的目标选择函数
function c36956512.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在至少一只表侧表示的怪兽作为目标
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,e:GetHandler()) end
end
-- 定义效果发动时对所有场上怪兽攻击力与守备力进行减半的操作函数
function c36956512.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取场上所有表侧表示的怪兽（除自身外）
	local tg=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,aux.ExceptThisCard(e))
	local tc=tg:GetFirst()
	while tc do
		local atk=tc:GetAttack()
		local def=tc:GetDefense()
		-- 将目标怪兽的攻击力设置为原来的一半
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(math.ceil(atk/2))
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 将目标怪兽的守备力设置为原来的一半
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_SET_DEFENSE_FINAL)
		e2:SetValue(math.ceil(def/2))
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
		tc=tg:GetNext()
	end
end
