--デーモンの根源
local s,id,o=GetID()
-- 初始化效果函数，注册三个效果：手牌起动效果、召唤成功时的诱发效果、以及场上的连锁发动时的反击效果
function s.initial_effect(c)
	-- 记录该卡与70781052（恶魔之根源）的关联关系
	aux.AddCodeList(c,70781052)
	-- 效果1：手牌起动效果，可以解放满足条件的怪兽将自身特殊召唤到场上
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- 效果2：召唤成功时发动的效果，可以特殊召唤手牌、卡组或墓地中的恶魔族6星怪兽
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.sptg2)
	e2:SetOperation(s.spop2)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	-- 效果3：场上的连锁发动时发动的效果，可以无效对方的怪兽效果并破坏其怪兽
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))
	e4:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_CHAINING)
	e4:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,id+o*2)
	e4:SetCondition(s.negcon)
	e4:SetTarget(s.negtg)
	e4:SetOperation(s.negop)
	c:RegisterEffect(e4)
end
-- 过滤函数：判断是否为恶魔族怪兽且场上存在空位
function s.cfilter(c,tp)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x45)
		-- 判断目标怪兽所在玩家的场上是否存在空位
		and Duel.GetMZoneCount(tp,c)>0
end
-- 特殊召唤的费用处理函数，检查是否有满足条件的卡可解放并进行选择和解放操作
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查是否有满足条件的卡可作为解放对象
	if chk==0 then return Duel.CheckReleaseGroupEx(tp,s.cfilter,1,REASON_COST,true,c,tp) end
	-- 提示玩家选择要解放的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	-- 选择满足条件的卡进行解放
	local g=Duel.SelectReleaseGroupEx(tp,s.cfilter,1,1,REASON_COST,true,c,tp)
	-- 执行解放操作
	Duel.Release(g,REASON_COST)
end
-- 特殊召唤的目标确认函数，判断自身是否可以被特殊召唤
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息为特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 特殊召唤的操作函数，将自身特殊召唤到场上
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() then
		-- 执行特殊召唤操作
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤函数：判断是否为攻击力2500、恶魔族、等级6的怪兽且可特殊召唤
function s.spfilter2(c,e,tp)
	return c:IsAttack(2500) and c:IsRace(RACE_FIEND) and c:IsLevel(6) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 特殊召唤的目标确认函数，判断是否有满足条件的卡可特殊召唤
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断目标玩家场上是否存在空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断手牌、卡组或墓地是否存在满足条件的卡
		and Duel.IsExistingMatchingCard(s.spfilter2,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置操作信息为特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE)
end
-- 特殊召唤的操作函数，选择并特殊召唤满足条件的卡
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 判断目标玩家场上是否存在空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的卡进行特殊召唤
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter2),tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 执行特殊召唤操作
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤函数：判断是否为表侧表示且卡号为70781052的卡
function s.cfilter1(c)
	return c:IsFaceup() and c:IsCode(70781052)
end
-- 反击效果的发动条件函数，判断对方怪兽效果发动时且场上有该卡存在
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断对方发动了怪兽效果且该连锁可被无效
	return rp~=tp and re:IsActiveType(TYPE_MONSTER) and Duel.IsChainNegatable(ev)
		-- 判断场上是否存在该卡
		and Duel.IsExistingMatchingCard(s.cfilter1,tp,LOCATION_ONFIELD,0,1,nil)
end
-- 反击效果的目标确认函数，设置操作信息为无效和破坏
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息为无效
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置操作信息为破坏
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 反击效果的操作函数，无效对方效果并破坏其怪兽
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否成功无效对方效果且对方怪兽存在
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToChain(ev) then
		-- 执行破坏操作
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
