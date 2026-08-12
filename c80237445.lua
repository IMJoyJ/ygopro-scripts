--アーティファクト－ミョルニル
-- 效果：
-- 这个卡名的③的效果1回合只能使用1次。
-- ①：这张卡可以当作魔法卡使用从手卡到魔法与陷阱区域盖放。
-- ②：魔法与陷阱区域盖放的这张卡在对方回合被破坏送去墓地的场合发动。这张卡特殊召唤。
-- ③：对方回合，这张卡特殊召唤成功的场合，以自己墓地1只「古遗物」怪兽为对象发动。那只怪兽守备表示特殊召唤。这个效果的发动后，直到下个回合的结束时自己不是「古遗物」怪兽不能特殊召唤。
function c80237445.initial_effect(c)
	-- ①：这张卡可以当作魔法卡使用从手卡到魔法与陷阱区域盖放。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_MONSTER_SSET)
	e1:SetValue(TYPE_SPELL)
	c:RegisterEffect(e1)
	-- ②：魔法与陷阱区域盖放的这张卡在对方回合被破坏送去墓地的场合发动。这张卡特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(80237445,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCondition(c80237445.spcon1)
	e2:SetTarget(c80237445.sptg1)
	e2:SetOperation(c80237445.spop1)
	c:RegisterEffect(e2)
	-- ③：对方回合，这张卡特殊召唤成功的场合，以自己墓地1只「古遗物」怪兽为对象发动。那只怪兽守备表示特殊召唤。这个效果的发动后，直到下个回合的结束时自己不是「古遗物」怪兽不能特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(80237445,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetCountLimit(1,80237445)
	e3:SetCondition(c80237445.spcon2)
	e3:SetTarget(c80237445.sptg2)
	e3:SetOperation(c80237445.spop2)
	c:RegisterEffect(e3)
end
-- 定义效果②的触发条件函数，检查此卡是否在对方回合从己方魔陷区盖放状态被破坏并送去墓地
function c80237445.spcon1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_SZONE) and c:IsPreviousPosition(POS_FACEDOWN)
		and c:IsPreviousControler(tp)
		-- 判断此卡是否因破坏送去墓地，且当前回合玩家不是自己（即对方回合）
		and c:IsReason(REASON_DESTROY) and Duel.GetTurnPlayer()~=tp
end
-- 定义效果②的靶向与发动准备函数，设置特殊召唤自身的操作信息
function c80237445.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置特殊召唤的操作信息，表明此效果将特殊召唤自身（1张卡）
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 定义效果②的效果处理函数，在自身仍存在于墓地时执行特殊召唤
function c80237445.spop1(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		-- 将自身以表侧表示特殊召唤到己方场上
		Duel.SpecialSummon(e:GetHandler(),0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 定义效果③的触发条件函数，检查特殊召唤成功的时点是否在对方回合
function c80237445.spcon2(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否不是自己（即对方回合）
	return Duel.GetTurnPlayer()~=tp
end
-- 定义过滤函数，筛选出自己墓地中可以守备表示特殊召唤的「古遗物」怪兽
function c80237445.spfilter(c,e,tp)
	return c:IsSetCard(0x97) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 定义效果③的靶向与发动准备函数，选择自己墓地1只「古遗物」怪兽作为对象，并设置特殊召唤的操作信息
function c80237445.sptg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c80237445.spfilter(chkc,e,tp) end
	if chk==0 then return true end
	-- 向玩家发送提示信息，提示选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家选择自己墓地1只满足条件的「古遗物」怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,c80237445.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	if #g>0 then
		-- 设置特殊召唤的操作信息，表明此效果将特殊召唤选择的对象怪兽（1张卡）
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
	end
end
-- 定义效果③的效果处理函数，将对象怪兽守备表示特殊召唤，并对玩家施加后续的特殊召唤限制
function c80237445.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取此效果在发动时选择的第一个（也是唯一一个）对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 将对象怪兽以表侧守备表示特殊召唤到己方场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
	-- 这个效果的发动后，直到下个回合的结束时自己不是「古遗物」怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c80237445.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END,2)
	-- 将限制特殊召唤的效果注册给发动效果的玩家
	Duel.RegisterEffect(e1,tp)
end
-- 定义特殊召唤限制的过滤函数，限制不能特殊召唤非「古遗物」怪兽
function c80237445.splimit(e,c)
	return not c:IsSetCard(0x97)
end
