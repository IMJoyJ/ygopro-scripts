--コアキメイル・テストベッド
-- 效果：
-- 场上表侧表示存在的名字带有「核成」的怪兽在结束阶段时被破坏的场合，可以作为代替把这张卡破坏。此外，场上表侧表示存在的名字带有「核成」的怪兽在结束阶段时被破坏时，可以在自己场上把1只「核成衍生物」（岩石族·地·4星·攻/守1800）特殊召唤。
function c176392.initial_effect(c)
	-- 效果原文：场上表侧表示存在的名字带有「核成」的怪兽在结束阶段时被破坏的场合，可以作为代替把这张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_DESTROY_REPLACE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c176392.descon)
	e1:SetTarget(c176392.destg)
	e1:SetValue(c176392.repval)
	c:RegisterEffect(e1)
	-- 效果原文：此外，场上表侧表示存在的名字带有「核成」的怪兽在结束阶段时被破坏时，可以在自己场上把1只「核成衍生物」（岩石族·地·4星·攻/守1800）特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(176392,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetCondition(c176392.spcon)
	e2:SetTarget(c176392.sptg)
	e2:SetOperation(c176392.spop)
	c:RegisterEffect(e2)
end
-- 判断是否处于结束阶段
function c176392.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否处于结束阶段
	return Duel.GetCurrentPhase()==PHASE_END
end
-- 筛选场上表侧表示、在怪兽区、名字带有「核成」且不是代替破坏的怪兽
function c176392.rfilter(c)
	return c:IsFaceup() and c:IsLocation(LOCATION_MZONE) and c:IsSetCard(0x1d) and not c:IsReason(REASON_REPLACE)
end
-- 判断是否满足代替破坏的条件
function c176392.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return eg:IsExists(c176392.rfilter,1,c)
		and c:IsDestructable(e) and not c:IsStatus(STATUS_DESTROY_CONFIRMED) end
	-- 询问玩家是否发动代替破坏效果
	if Duel.SelectEffectYesNo(tp,c,96) then
		-- 执行将自身破坏的操作
		Duel.Destroy(c,REASON_EFFECT+REASON_REPLACE)
		return true
	else return false end
end
-- 判断被破坏的怪兽是否满足代替条件
function c176392.repval(e,c)
	return c:IsFaceup() and c:IsSetCard(0x1d) and c~=e:GetHandler()
end
-- 筛选被破坏前在怪兽区、正面表示、名字带有「核成」的怪兽
function c176392.spfilter(c)
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousSetCard(0x1d)
end
-- 判断是否处于结束阶段且有符合条件的怪兽被破坏
function c176392.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否处于结束阶段且有符合条件的怪兽被破坏
	return Duel.GetCurrentPhase()==PHASE_END and eg:IsExists(c176392.spfilter,1,nil)
end
-- 设置特殊召唤衍生物的条件
function c176392.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断是否可以特殊召唤衍生物
		and Duel.IsPlayerCanSpecialSummonMonster(tp,176393,0x1d,TYPES_TOKEN_MONSTER,1800,1800,4,RACE_ROCK,ATTRIBUTE_EARTH) end
	-- 设置操作信息为召唤衍生物
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	-- 设置操作信息为特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
-- 执行特殊召唤衍生物的操作
function c176392.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断场上是否还有空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 判断是否可以特殊召唤衍生物
	if not Duel.IsPlayerCanSpecialSummonMonster(tp,176393,0x1d,TYPES_TOKEN_MONSTER,1800,1800,4,RACE_ROCK,ATTRIBUTE_EARTH) then return end
	-- 创建「核成衍生物」
	local token=Duel.CreateToken(tp,176393)
	-- 将「核成衍生物」特殊召唤到场上
	Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)
end
