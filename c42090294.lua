--レプティレス・ニャミニ
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：自己墓地有爬虫类族怪兽存在的场合，自己·对方的主要阶段，把这张卡从手卡送去墓地，以对方场上1只表侧表示怪兽为对象才能发动。那只怪兽的攻击力变成0。
-- ②：对方场上有攻击力0的怪兽存在的场合才能发动。这张卡从墓地特殊召唤。
function c42090294.initial_effect(c)
	-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。①：自己墓地有爬虫类族怪兽存在的场合，自己·对方的主要阶段，把这张卡从手卡送去墓地，以对方场上1只表侧表示怪兽为对象才能发动。那只怪兽的攻击力变成0。
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
	-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。②：对方场上有攻击力0的怪兽存在的场合才能发动。这张卡从墓地特殊召唤。
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
-- 定义过滤条件：卡片属于爬虫类族，用于判断墓地是否存在爬虫类族怪兽。
function c42090294.cfilter1(c)
	return c:IsRace(RACE_REPTILE)
end
-- 效果①的发动条件：自己墓地存在爬虫类族怪兽，且当前阶段是主要阶段1或主要阶段2（即自己·对方的主要阶段）。
function c42090294.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己墓地是否存在至少1张爬虫类族怪兽。
	return Duel.IsExistingMatchingCard(c42090294.cfilter1,tp,LOCATION_GRAVE,0,1,nil)
		-- 并且当前阶段必须是主要阶段1或主要阶段2。
		and (Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2)
end
-- 效果①的发动代价：将这张卡从手卡送去墓地。chk==0时检查是否可作为代价送去墓地，随后实际执行送墓。
function c42090294.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToGraveAsCost() end
	-- 将这张卡作为发动代价送去墓地。
	Duel.SendtoGrave(c,REASON_COST)
end
-- 效果①的取对象处理：选择对方场上1只表侧表示且攻击力不为0的怪兽作为对象。包括对象合法性检查和发动时的可选取目标检查。
function c42090294.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 若是对已选对象的合法性校验，则要求该对象在对方怪兽区域、由对方控制且为表侧表示、攻击力不为0。
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and aux.nzatk(chkc) end
	-- 发动时检查是否存在至少1只符合条件的对方场上的表侧表示且攻击力不为0的怪兽。
	if chk==0 then return Duel.IsExistingTarget(aux.nzatk,tp,0,LOCATION_MZONE,1,nil) end
	-- 向玩家显示选择提示，提示需要选择表侧表示的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让玩家从对方场上选择1只表侧表示且攻击力不为0的怪兽，并将其设为效果对象。
	Duel.SelectTarget(tp,aux.nzatk,tp,0,LOCATION_MZONE,1,1,nil)
end
-- 效果①处理：将对象怪兽的攻击力变成0。通过给对象怪兽注册一个最终攻击力设定为0的效果来实现。
function c42090294.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果①选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 那只怪兽的攻击力变成0。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(0)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
-- 定义过滤条件：怪兽为表侧表示且攻击力为0，用于检查对方场上是否存在攻击力0的怪兽。
function c42090294.cfilter2(c)
	return c:IsFaceup() and c:IsAttack(0)
end
-- 效果②的发动条件：对方场上有表侧表示且攻击力为0的怪兽存在。
function c42090294.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查对方场上是否存在至少1只表侧表示且攻击力为0的怪兽。
	return Duel.IsExistingMatchingCard(c42090294.cfilter2,tp,0,LOCATION_MZONE,1,nil)
end
-- 效果②的发动目标检查：这张卡在墓地时，自己场上存在可用的主要怪兽区空格，且这张卡可以被特殊召唤。
function c42090294.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查自己场上是否有可用的主要怪兽区空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置本连锁的特殊召唤操作信息：将这张卡特殊召唤，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 效果②处理：这张卡从墓地特殊召唤到自己场上。
function c42090294.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡以表侧攻击表示特殊召唤到自己场上。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
