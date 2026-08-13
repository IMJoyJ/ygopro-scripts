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
-- ①效果的发动条件：当前处于双方的主要阶段1或主要阶段2才可发动。
function c29348048.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前阶段为主要阶段1（M1）或主要阶段2（M2），满足①效果在主要阶段的发动时机。
	return Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2
end
-- ①效果的发动代价：解放自己场上1只不死族怪兽；先检查可解放对象，再选择并解放。
function c29348048.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 代价检查：确认自己场上存在1只不死族怪兽可以解放（且不能选择效果持有者自身）。
	if chk==0 then return Duel.CheckReleaseGroup(tp,Card.IsRace,1,c,RACE_ZOMBIE) end
	-- 弹出“请选择要解放的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	-- 选择自己场上1只不死族怪兽作为解放代价。
	local g=Duel.SelectReleaseGroup(tp,Card.IsRace,1,1,c,RACE_ZOMBIE)
	local tc=g:GetFirst()
	e:SetLabelObject(tc)
	-- 将选择的不死族怪兽解放，作为效果的发动代价（REASON_COST）。
	Duel.Release(g,REASON_COST)
end
-- ①效果处理：这张卡仍表侧表示且与效果关联时，将解放怪兽的原本攻击力数值作为攻击力上升值赋予这张卡，持续到回合结束。
function c29348048.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 对应①效果的后半句：这张卡的攻击力直到回合结束时上升解放的怪兽的原本攻击力数值。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(e:GetLabelObject():GetBaseAttack())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
-- ②效果的条件筛选：用于判断自己场上是否存在表侧表示的「归魂复仇死者·屠魔侠」（卡号4388680）。
function c29348048.filter(c)
	return c:IsCode(4388680) and c:IsFaceup()
end
-- ②效果的发动条件：自己场上有「归魂复仇死者·屠魔侠」表侧表示存在。
function c29348048.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在至少1张表侧表示的「归魂复仇死者·屠魔侠」。
	return Duel.IsExistingMatchingCard(c29348048.filter,tp,LOCATION_ONFIELD,0,1,nil)
end
-- ②效果发动时确认：自己的主要怪兽区有空位，且这张卡可以被特殊召唤。
function c29348048.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己的主要怪兽区是否有可用空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置本次连锁将进行特殊召唤的操作信息（CATEGORY_SPECIAL_SUMMON），供规则检测时点。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ②效果处理：将这张卡特殊召唤；若成功，则给这张卡附加“从场上离开的场合除外”的效果。
function c29348048.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 确认这张卡仍与效果关联且特殊召唤成功，成功则继续附加离场除外效果。
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 对应②效果的后半部分：这个效果特殊召唤的这张卡从场上离开的场合除外。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e1,true)
	end
end
