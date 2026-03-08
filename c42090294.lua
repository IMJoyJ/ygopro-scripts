--レプティレス・ニャミニ
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：自己墓地有爬虫类族怪兽存在的场合，自己·对方的主要阶段，把这张卡从手卡送去墓地，以对方场上1只表侧表示怪兽为对象才能发动。那只怪兽的攻击力变成0。
-- ②：对方场上有攻击力0的怪兽存在的场合才能发动。这张卡从墓地特殊召唤。
function c42090294.initial_effect(c)
	-- ①：自己墓地有爬虫类族怪兽存在的场合，自己·对方的主要阶段，把这张卡从手卡送去墓地，以对方场上1只表侧表示怪兽为对象才能发动。那只怪兽的攻击力变成0。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(42090294,0))
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_HAND)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e1:SetCountLimit(1,42090294)
	e1:SetCondition(c42090294.atkcon)
	e1:SetCost(c42090294.atkcost)
	e1:SetTarget(c42090294.atktg)
	e1:SetOperation(c42090294.atkop)
	c:RegisterEffect(e1)
	-- ②：对方场上有攻击力0的怪兽存在的场合才能发动。这张卡从墓地特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(42090294,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,42090294)
	e2:SetCondition(c42090294.spcon)
	e2:SetTarget(c42090294.sptg)
	e2:SetOperation(c42090294.spop)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于判断是否为爬虫类族怪兽
function c42090294.cfilter1(c)
	return c:IsRace(RACE_REPTILE)
end
-- 效果条件：自己墓地有爬虫类族怪兽存在且当前阶段为自己的主要阶段1或主要阶段2
function c42090294.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己墓地是否存在至少1张爬虫类族怪兽
	return Duel.IsExistingMatchingCard(c42090294.cfilter1,tp,LOCATION_GRAVE,0,1,nil)
		-- 检查当前阶段是否为自己的主要阶段1或主要阶段2
		and (Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2)
end
-- 效果代价：将此卡送入墓地作为代价
function c42090294.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToGraveAsCost() end
	-- 将此卡从手牌送入墓地
	Duel.SendtoGrave(c,REASON_COST)
end
-- 效果目标选择：选择对方场上1只表侧表示的攻击力不为0的怪兽
function c42090294.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 目标选择过滤条件：选择对方场上1只表侧表示的攻击力不为0的怪兽
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and aux.nzatk(chkc) end
	-- 检查是否存在满足条件的目标怪兽
	if chk==0 then return Duel.IsExistingTarget(aux.nzatk,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择表侧表示的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择对方场上1只表侧表示的攻击力不为0的怪兽
	Duel.SelectTarget(tp,aux.nzatk,tp,0,LOCATION_MZONE,1,1,nil)
end
-- 效果处理：将选定怪兽的攻击力变为0
function c42090294.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 将攻击力设置为0的效果
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(0)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
-- 过滤函数，用于判断是否为表侧表示且攻击力为0的怪兽
function c42090294.cfilter2(c)
	return c:IsFaceup() and c:IsAttack(0)
end
-- 效果条件：对方场上有攻击力为0的怪兽存在
function c42090294.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查对方场上是否存在至少1只攻击力为0的怪兽
	return Duel.IsExistingMatchingCard(c42090294.cfilter2,tp,0,LOCATION_MZONE,1,nil)
end
-- 特殊召唤效果的目标设定：确认可以将此卡特殊召唤
function c42090294.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查己方场上是否有足够的召唤位置
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：此效果将特殊召唤此卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 特殊召唤效果处理：将此卡特殊召唤到场上
function c42090294.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将此卡以表侧表示形式特殊召唤到己方场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
