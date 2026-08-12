--怪粉壊獣ガダーラ
-- 效果：
-- ①：这张卡可以把对方场上1只怪兽解放，从手卡往对方场上攻击表示特殊召唤。
-- ②：对方场上有「坏兽」怪兽存在的场合，这张卡可以从手卡攻击表示特殊召唤。
-- ③：「坏兽」怪兽在自己场上只能有1只表侧表示存在。
-- ④：1回合1次，把自己·对方场上3个坏兽指示物取除才能发动。这张卡以外的场上的全部怪兽的攻击力·守备力变成一半。这个效果在对方回合也能发动。
function c36956512.initial_effect(c)
	-- 设置「坏兽」系列怪兽在自己场上只能有1只表侧表示存在的唯一性限制
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
	-- 设置发动条件：不能在伤害步骤的伤害计算后发动（伤害步骤中仅限伤害计算前）
	e3:SetCondition(aux.dscon)
	e3:SetCost(c36956512.atkcost)
	e3:SetTarget(c36956512.atktg)
	e3:SetOperation(c36956512.atkop)
	c:RegisterEffect(e3)
end
c36956512.mentioned_counter={
	[0x37]=true,
}
-- 过滤函数：检查对方场上的怪兽是否可以为了特殊召唤而解放，且对方场上在那只怪兽离开后仍有可用的怪兽区
function c36956512.spfilter(c,tp)
	-- 检查该怪兽可被以特殊召唤为原因解放，且该怪兽离开后对方场上还有空余怪兽区
	return c:IsReleasable(REASON_SPSUMMON) and Duel.GetMZoneCount(1-tp,c,tp)>0
end
-- ①效果的特殊召唤条件：对方场上存在满足解放条件的怪兽
function c36956512.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查对方场上是否存在至少1只可被解放且解放后仍有空余怪兽区的怪兽
	return Duel.IsExistingMatchingCard(c36956512.spfilter,tp,0,LOCATION_MZONE,1,nil,tp)
end
-- ①效果的目标选择：从对方场上选择1只要解放的怪兽并记录
function c36956512.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 取得对方场上所有满足解放过滤条件的怪兽组
	local g=Duel.GetMatchingGroup(c36956512.spfilter,tp,0,LOCATION_MZONE,nil,tp)
	-- 提示玩家「请选择要解放的卡」
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- ①效果的处理：将之前记录的怪兽解放以进行特殊召唤
function c36956512.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 以特殊召唤为原因解放选中的怪兽
	Duel.Release(g,REASON_SPSUMMON)
end
-- 过滤函数：检查怪兽是否表侧表示且属于「坏兽」系列
function c36956512.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xd3)
end
-- ②效果的特殊召唤条件：自己场上有空余怪兽区，且对方场上有表侧表示的「坏兽」怪兽存在
function c36956512.spcon2(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查自己场上是否有可用的怪兽区
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查对方场上是否存在至少1只表侧表示的「坏兽」怪兽
		and Duel.IsExistingMatchingCard(c36956512.cfilter,tp,0,LOCATION_MZONE,1,nil)
end
-- ④效果的代价：把自己·对方场上3个坏兽指示物取除才能发动
function c36956512.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检查：确认能以效果为代价从双方场上移除3个坏兽指示物
	if chk==0 then return Duel.IsCanRemoveCounter(tp,1,1,0x37,3,REASON_COST) end
	-- 以效果代价从双方场上移除3个坏兽指示物
	Duel.RemoveCounter(tp,1,1,0x37,3,REASON_COST)
end
-- ④效果的目标检查：确认这张卡以外的场上存在表侧表示的怪兽
function c36956512.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查这张卡以外的双方场上是否存在至少1只表侧表示的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,e:GetHandler()) end
end
-- ④效果的处理：将这张卡以外的场上全部表侧表示怪兽的攻击力·守备力各自变成一半
function c36956512.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得这张卡以外的双方场上全部表侧表示的怪兽
	local tg=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,aux.ExceptThisCard(e))
	local tc=tg:GetFirst()
	while tc do
		local atk=tc:GetAttack()
		local def=tc:GetDefense()
		-- 攻击力变成一半
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(math.ceil(atk/2))
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 守备力变成一半
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_SET_DEFENSE_FINAL)
		e2:SetValue(math.ceil(def/2))
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
		tc=tg:GetNext()
	end
end
