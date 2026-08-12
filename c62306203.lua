--サルベージェント・ドライバー
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡在手卡·墓地存在，自己场上的电子界族连接怪兽被对方的效果破坏的场合才能发动。这张卡特殊召唤。
-- ②：从手卡丢弃1张魔法卡，以自己墓地1只电子界族怪兽为对象才能发动。那只怪兽特殊召唤。这个效果特殊召唤的怪兽在这个回合不能直接攻击。
function c62306203.initial_effect(c)
	-- ①：这张卡在手卡·墓地存在，自己场上的电子界族连接怪兽被对方的效果破坏的场合才能发动。这张卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(62306203,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_DESTROYED)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetCountLimit(1,62306203)
	e1:SetCondition(c62306203.spcon1)
	e1:SetTarget(c62306203.sptg1)
	e1:SetOperation(c62306203.spop1)
	c:RegisterEffect(e1)
	-- ②：从手卡丢弃1张魔法卡，以自己墓地1只电子界族怪兽为对象才能发动。那只怪兽特殊召唤。这个效果特殊召唤的怪兽在这个回合不能直接攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(62306203,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,62306204)
	e2:SetCost(c62306203.spcost2)
	e2:SetTarget(c62306203.sptg2)
	e2:SetOperation(c62306203.spop2)
	c:RegisterEffect(e2)
end
-- 过滤条件：检查被破坏的卡是否为自己场上表侧表示的电子界族连接怪兽
function c62306203.cfilter(c,tp)
	return c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousPosition(POS_FACEUP)
		and bit.band(c:GetPreviousTypeOnField(),TYPE_LINK)~=0 and bit.band(c:GetPreviousRaceOnField(),RACE_CYBERSE)~=0
end
-- 效果①的发动条件：对方的效果破坏了自己场上的电子界族连接怪兽
function c62306203.spcon1(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and eg:IsExists(c62306203.cfilter,1,e:GetHandler(),tp)
end
-- 效果①的发动准备：检查怪兽区域空位、自身是否能特殊召唤，并设置特殊召唤的操作信息
function c62306203.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤的操作信息（将自身特殊召唤）
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果①的处理：将自身特殊召唤
function c62306203.spop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡在自己场上表侧表示特殊召唤
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤条件：手卡中可以丢弃的魔法卡
function c62306203.costfilter(c)
	return c:IsType(TYPE_SPELL) and c:IsDiscardable()
end
-- 效果②的代价：从手卡丢弃1张魔法卡
function c62306203.spcost2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡中是否存在可以丢弃的魔法卡
	if chk==0 then return Duel.IsExistingMatchingCard(c62306203.costfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 玩家选择并丢弃1张手卡中的魔法卡作为发动代价
	Duel.DiscardHand(tp,c62306203.costfilter,1,1,REASON_COST+REASON_DISCARD)
end
-- 过滤条件：自己墓地可以特殊召唤的电子界族怪兽
function c62306203.spfilter(c,e,tp)
	return c:IsRace(RACE_CYBERSE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②的发动准备：检查怪兽区域空位、墓地是否存在可特殊召唤的电子界族怪兽，并选择对象
function c62306203.sptg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c62306203.spfilter(chkc,e,tp) end
	-- 检查自己场上是否有可用的怪兽区域空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在可以特殊召唤的电子界族怪兽
		and Duel.IsExistingTarget(c62306203.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只满足条件的电子界族怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c62306203.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置特殊召唤的操作信息（特殊召唤选中的对象怪兽）
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果②的处理：将作为对象的怪兽特殊召唤，并赋予其本回合不能直接攻击的效果
function c62306203.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	-- 检查对象怪兽是否仍符合效果，并尝试将其表侧表示特殊召唤
	if tc:IsRelateToEffect(e) and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		-- 这个效果特殊召唤的怪兽在这个回合不能直接攻击。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
	-- 完成特殊召唤的处理
	Duel.SpecialSummonComplete()
end
