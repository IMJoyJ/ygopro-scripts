--マシンナーズ・カーネル
-- 效果：
-- 这张卡不能通常召唤，用卡的效果才能特殊召唤。这个卡名的①②的效果1回合各能使用1次。
-- ①：自己·对方回合，以自己场上1只机械族怪兽为对象才能发动。那只机械族怪兽和持有那个攻击力以下的攻击力的对方场上的怪兽全部破坏。
-- ②：这张卡在墓地存在的状态，「机甲上校」以外的自己场上的表侧表示的机械族·地属性怪兽被战斗·效果破坏的场合才能发动。这张卡特殊召唤。
function c87074380.initial_effect(c)
	-- 这张卡不能通常召唤，用卡的效果才能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetValue(c87074380.splimit)
	c:RegisterEffect(e1)
	-- ①：自己·对方回合，以自己场上1只机械族怪兽为对象才能发动。那只机械族怪兽和持有那个攻击力以下的攻击力的对方场上的怪兽全部破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(87074380,0))  --"怪兽破坏"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e2:SetCountLimit(1,87074380)
	e2:SetTarget(c87074380.destg)
	e2:SetOperation(c87074380.desop)
	c:RegisterEffect(e2)
	-- ②：这张卡在墓地存在的状态，「机甲上校」以外的自己场上的表侧表示的机械族·地属性怪兽被战斗·效果破坏的场合才能发动。这张卡特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(87074380,1))  --"这张卡特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,87074381)
	e3:SetCondition(c87074380.spcon)
	e3:SetTarget(c87074380.sptg)
	e3:SetOperation(c87074380.spop)
	c:RegisterEffect(e3)
end
-- 特殊召唤限制的判定函数，限制只能通过卡的效果特殊召唤
function c87074380.splimit(e,se,sp,st)
	return se:IsHasType(EFFECT_TYPE_ACTIONS)
end
-- 过滤自己场上表侧表示的机械族怪兽，且对方场上存在持有该怪兽攻击力以下攻击力的怪兽
function c87074380.cfilter(c,tp)
	return c:IsFaceup() and c:IsRace(RACE_MACHINE)
		-- 检查对方场上是否存在至少1只攻击力在当前怪兽攻击力以下的表侧表示怪兽
		and Duel.IsExistingMatchingCard(c87074380.desfilter,tp,0,LOCATION_MZONE,1,nil,c:GetAttack())
end
-- 过滤对方场上攻击力在指定数值以下的表侧表示怪兽
function c87074380.desfilter(c,atk)
	return c:IsFaceup() and c:IsAttackBelow(atk)
end
-- 破坏效果的发动准备与目标选择函数
function c87074380.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c87074380.cfilter(chkc,tp) end
	-- 检查自己场上是否存在可以作为此效果对象的机械族怪兽
	if chk==0 then return Duel.IsExistingTarget(c87074380.cfilter,tp,LOCATION_MZONE,0,1,nil,tp) end
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 让玩家选择自己场上1只表侧表示的机械族怪兽作为对象
	local tc=Duel.SelectTarget(tp,c87074380.cfilter,tp,LOCATION_MZONE,0,1,1,nil,tp):GetFirst()
	-- 获取对方场上所有攻击力在对象怪兽攻击力以下的表侧表示怪兽
	local g=Duel.GetMatchingGroup(c87074380.desfilter,tp,0,LOCATION_MZONE,nil,tc:GetAttack())
	g:AddCard(tc)
	-- 设置效果处理时的操作信息，包含破坏分类以及预估被破坏的卡片组和数量
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 破坏效果的效果处理函数
function c87074380.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsRace(RACE_MACHINE) then
		-- 重新获取对方场上所有攻击力在对象怪兽攻击力以下的表侧表示怪兽
		local g=Duel.GetMatchingGroup(c87074380.desfilter,tp,0,LOCATION_MZONE,nil,tc:GetAttack())
		if g:GetCount()>0 then
			g:AddCard(tc)
			-- 用卡的效果将对象怪兽和满足条件的对方怪兽全部破坏
			Duel.Destroy(g,REASON_EFFECT)
		end
	end
end
-- 过滤「机甲上校」以外的、在自己场上表侧表示存在并被战斗或效果破坏的机械族·地属性怪兽
function c87074380.sfilter(c,tp)
	return not c:IsCode(87074380) and c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousControler(tp)
		and bit.band(c:GetPreviousAttributeOnField(),ATTRIBUTE_EARTH)~=0
		and bit.band(c:GetPreviousRaceOnField(),RACE_MACHINE)~=0
		and c:IsReason(REASON_BATTLE+REASON_EFFECT) and c:IsPreviousLocation(LOCATION_MZONE)
end
-- 特殊召唤效果的发动条件判定函数，检查是否有符合条件的怪兽被破坏，且自身不在被破坏的卡中
function c87074380.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c87074380.sfilter,1,nil,tp) and not eg:IsContains(e:GetHandler())
end
-- 特殊召唤效果的发动准备函数
function c87074380.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有空余的怪兽区域，以及墓地的这张卡是否能特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置效果处理时的操作信息，包含特殊召唤分类以及自身
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 特殊召唤效果的效果处理函数
function c87074380.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将墓地的这张卡以表侧表示特殊召唤
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
