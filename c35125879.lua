--真竜皇の復活
-- 效果：
-- 这个卡名的①②③的效果1回合各能使用1次，①②的效果在同一连锁上不能发动。
-- ①：以自己墓地1只「真龙」怪兽为对象才能发动。那只怪兽守备表示特殊召唤。这个效果的发动后，直到回合结束时自己不能把怪兽特殊召唤。
-- ②：对方主要阶段才能发动。表侧表示进行1只「真龙」怪兽的上级召唤。
-- ③：这张卡从魔法与陷阱区域送去墓地的场合，以场上1只怪兽为对象才能发动。那只怪兽破坏。
function c35125879.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	c:RegisterEffect(e1)
	-- ①：以自己墓地1只「真龙」怪兽为对象才能发动。那只怪兽守备表示特殊召唤。这个效果的发动后，直到回合结束时自己不能把怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(35125879,0))  --"墓地苏生"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(0,TIMING_END_PHASE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,35125879)
	e2:SetCost(c35125879.cost)
	e2:SetTarget(c35125879.sptg)
	e2:SetOperation(c35125879.spop)
	c:RegisterEffect(e2)
	-- ②：对方主要阶段才能发动。表侧表示进行1只「真龙」怪兽的上级召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(35125879,1))  --"上级召唤"
	e3:SetCategory(CATEGORY_SUMMON)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetHintTiming(0,TIMING_MAIN_END)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,35125880)
	e3:SetCondition(c35125879.sumcon)
	e3:SetCost(c35125879.cost)
	e3:SetTarget(c35125879.sumtg)
	e3:SetOperation(c35125879.sumop)
	c:RegisterEffect(e3)
	-- ③：这张卡从魔法与陷阱区域送去墓地的场合，以场上1只怪兽为对象才能发动。那只怪兽破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(35125879,2))
	e4:SetCategory(CATEGORY_DESTROY)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetCountLimit(1,35125881)
	e4:SetCondition(c35125879.descon)
	e4:SetTarget(c35125879.destg)
	e4:SetOperation(c35125879.desop)
	c:RegisterEffect(e4)
end
-- 检查是否已使用过①②效果，若未使用则注册标识效果
function c35125879.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否已使用过①②效果
	if chk==0 then return Duel.GetFlagEffect(tp,35125879)==0 end
	-- 注册标识效果，防止在本回合再次发动①②效果
	Duel.RegisterFlagEffect(tp,35125879,RESET_CHAIN,0,1)
end
-- 过滤满足条件的墓地真龙怪兽
function c35125879.spfilter(c,e,tp)
	return c:IsSetCard(0xf9) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 设置①效果的目标选择条件
function c35125879.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c35125879.spfilter(chkc,e,tp) end
	-- 检查是否有满足条件的墓地真龙怪兽
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查场上是否有满足条件的墓地真龙怪兽
		and Duel.IsExistingTarget(c35125879.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的墓地真龙怪兽
	local g=Duel.SelectTarget(tp,c35125879.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置①效果的处理信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 执行①效果的处理
function c35125879.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取①效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽以守备表示特殊召唤
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
	-- 注册效果，使本回合不能特殊召唤怪兽
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	-- 注册使本回合不能特殊召唤怪兽的效果
	Duel.RegisterEffect(e1,tp)
end
-- ②效果的发动条件：对方主要阶段
function c35125879.sumcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前阶段
	local ph=Duel.GetCurrentPhase()
	-- 判断是否为对方主要阶段
	return Duel.GetTurnPlayer()~=tp and (ph==PHASE_MAIN1 or ph==PHASE_MAIN2)
end
-- 过滤满足条件的真龙怪兽
function c35125879.sumfilter(c)
	return c:IsSetCard(0xf9) and c:IsSummonable(true,nil,1)
end
-- 设置②效果的目标选择条件
function c35125879.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否有满足条件的真龙怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c35125879.sumfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 设置②效果的处理信息
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,nil,1,0,0)
end
-- 执行②效果的处理
function c35125879.sumop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)  --"请选择要召唤的卡"
	-- 选择满足条件的真龙怪兽
	local g=Duel.SelectMatchingCard(tp,c35125879.sumfilter,tp,LOCATION_HAND,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		-- 进行上级召唤
		Duel.Summon(tp,tc,true,nil,1)
	end
end
-- ③效果的发动条件：此卡从魔法与陷阱区域送去墓地
function c35125879.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_SZONE)
end
-- 设置③效果的目标选择条件
function c35125879.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) end
	-- 检查场上是否有满足条件的怪兽
	if chk==0 then return Duel.IsExistingTarget(nil,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择满足条件的怪兽
	local g=Duel.SelectTarget(tp,nil,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置③效果的处理信息
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 执行③效果的处理
function c35125879.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取③效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 破坏目标怪兽
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
