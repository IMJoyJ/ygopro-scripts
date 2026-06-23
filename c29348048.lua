--ヴェンデット・スカヴェンジャー
-- 效果：
-- 「复仇死者」仪式魔法卡降临。这个卡名的①②的效果1回合各能使用1次。
-- ①：双方的主要阶段，把自己场上1只不死族怪兽解放才能发动。这张卡的攻击力直到回合结束时上升解放的怪兽的原本攻击力数值。
-- ②：这张卡在墓地存在，自己场上有「归魂复仇死者·屠魔侠」存在的场合才能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
function c29348048.initial_effect(c)
	c:EnableReviveLimit()
	-- ①：双方的主要阶段，把自己场上1只不死族怪兽解放才能发动。这张卡的攻击力直到回合结束时上升解放的怪兽的原本攻击力数值。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e1:SetCountLimit(1,29348048)
	e1:SetCondition(c29348048.atkcon)
	e1:SetCost(c29348048.atkcost)
	e1:SetOperation(c29348048.atkop)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在，自己场上有「归魂复仇死者·屠魔侠」存在的场合才能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,29348049)
	e2:SetCondition(c29348048.spcon)
	e2:SetTarget(c29348048.sptg)
	e2:SetOperation(c29348048.spop)
	c:RegisterEffect(e2)
end
-- 判断是否处于主要阶段1或主要阶段2
function c29348048.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否处于主要阶段1或主要阶段2
	return Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2
end
-- 检查是否满足解放不死族怪兽的条件并选择解放对象
function c29348048.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查是否满足解放不死族怪兽的条件
	if chk==0 then return Duel.CheckReleaseGroup(tp,Card.IsRace,1,c,RACE_ZOMBIE) end
	-- 提示玩家选择要解放的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	-- 选择1张场上存在的不死族怪兽进行解放
	local g=Duel.SelectReleaseGroup(tp,Card.IsRace,1,1,c,RACE_ZOMBIE)
	local tc=g:GetFirst()
	e:SetLabelObject(tc)
	-- 将选中的怪兽从场上解放
	Duel.Release(g,REASON_COST)
end
-- 将解放的怪兽原本攻击力数值加到自身攻击力上
function c29348048.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 将自身攻击力提升解放的怪兽的原本攻击力数值
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(e:GetLabelObject():GetBaseAttack())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
-- 判断场上的「归魂复仇死者·屠魔侠」是否表侧表示存在
function c29348048.filter(c)
	return c:IsCode(4388680) and c:IsFaceup()
end
-- 判断场上的「归魂复仇死者·屠魔侠」是否表侧表示存在
function c29348048.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断场上的「归魂复仇死者·屠魔侠」是否表侧表示存在
	return Duel.IsExistingMatchingCard(c29348048.filter,tp,LOCATION_ONFIELD,0,1,nil)
end
-- 判断是否满足特殊召唤条件
function c29348048.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断场上是否有足够的召唤区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 执行特殊召唤并设置效果
function c29348048.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断卡片是否可以特殊召唤并执行特殊召唤
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 特殊召唤后，使该卡从场上离开时被除外
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e1,true)
	end
end
