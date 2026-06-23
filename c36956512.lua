--怪粉壊獣ガダーラ
-- 效果：
-- ①：这张卡可以把对方场上1只怪兽解放，从手卡往对方场上攻击表示特殊召唤。
-- ②：对方场上有「坏兽」怪兽存在的场合，这张卡可以从手卡攻击表示特殊召唤。
-- ③：「坏兽」怪兽在自己场上只能有1只表侧表示存在。
-- ④：1回合1次，把自己·对方场上3个坏兽指示物取除才能发动。这张卡以外的场上的全部怪兽的攻击力·守备力变成一半。这个效果在对方回合也能发动。
function c36956512.initial_effect(c)
	-- 设置此卡在场上的唯一性，确保同一组「坏兽」怪兽在己方场上只能有1只表侧表示存在
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
-- 定义特殊召唤时可解放的怪兽过滤条件：满足可解放且对方怪兽区有空位
function c36956512.spfilter(c,tp)
	-- 满足可解放且对方怪兽区有空位
	return c:IsReleasable(REASON_SPSUMMON) and Duel.GetMZoneCount(1-tp,c,tp)>0
end
-- 判断是否满足特殊召唤条件：己方场上有可解放的怪兽
function c36956512.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 己方场上有可解放的怪兽
	return Duel.IsExistingMatchingCard(c36956512.spfilter,tp,0,LOCATION_MZONE,1,nil,tp)
end
-- 选择要解放的怪兽并设置为效果目标
function c36956512.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取满足特殊召唤条件的怪兽组
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
	-- 将目标怪兽解放
	Duel.Release(g,REASON_SPSUMMON)
end
-- 定义「坏兽」怪兽的过滤条件：表侧表示且为「坏兽」种族
function c36956512.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xd3)
end
-- 判断是否满足第二种特殊召唤条件：己方场上有「坏兽」怪兽且己方怪兽区有空位
function c36956512.spcon2(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 己方怪兽区有空位
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 己方场上有「坏兽」怪兽
		and Duel.IsExistingMatchingCard(c36956512.cfilter,tp,0,LOCATION_MZONE,1,nil)
end
-- 支付效果代价：移除自己或对方场上的3个坏兽指示物
function c36956512.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否可以移除3个坏兽指示物作为代价
	if chk==0 then return Duel.IsCanRemoveCounter(tp,1,1,0x37,3,REASON_COST) end
	-- 移除3个坏兽指示物
	Duel.RemoveCounter(tp,1,1,0x37,3,REASON_COST)
end
-- 判断效果是否可以发动：己方场上存在表侧表示的怪兽
function c36956512.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 己方场上存在表侧表示的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,e:GetHandler()) end
end
-- 执行效果：将场上所有怪兽的攻击力和守备力减半
function c36956512.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取场上所有表侧表示的怪兽（除自身外）
	local tg=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,aux.ExceptThisCard(e))
	local tc=tg:GetFirst()
	while tc do
		local atk=tc:GetAttack()
		local def=tc:GetDefense()
		-- 将目标怪兽的攻击力设为原来的一半
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(math.ceil(atk/2))
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 将目标怪兽的守备力设为原来的一半
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_SET_DEFENSE_FINAL)
		e2:SetValue(math.ceil(def/2))
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
		tc=tg:GetNext()
	end
end
