--不知火流 才華の陣
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：从手卡把1只不死族怪兽特殊召唤。这个效果特殊召唤的怪兽从场上离开的场合除外。
-- ②：把墓地的这张卡除外，以自己场上1只不死族怪兽为对象才能发动。这个回合，那只不死族怪兽不受自身以外的卡的效果影响。
function c74798297.initial_effect(c)
	-- ①：从手卡把1只不死族怪兽特殊召唤。这个效果特殊召唤的怪兽从场上离开的场合除外。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,74798297)
	e1:SetTarget(c74798297.target)
	e1:SetOperation(c74798297.activate)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外，以自己场上1只不死族怪兽为对象才能发动。这个回合，那只不死族怪兽不受自身以外的卡的效果影响。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(74798297,0))
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,74798297)
	e2:SetCode(EVENT_FREE_CHAIN)
	-- 把墓地的这张卡除外作为发动成本
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c74798297.immtg)
	e2:SetOperation(c74798297.immop)
	c:RegisterEffect(e2)
end
-- 过滤手卡中可以特殊召唤的不死族怪兽
function c74798297.spfilter(c,e,tp)
	return c:IsRace(RACE_ZOMBIE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①效果的发动准备与合法性检测
function c74798297.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡中是否存在可以特殊召唤的不死族怪兽
		and Duel.IsExistingMatchingCard(c74798297.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置特殊召唤的操作信息，表示从手卡特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- ①效果的执行：从手卡特殊召唤1只不死族怪兽，并添加离场时除外的效果
function c74798297.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 若此时场上没有可用的怪兽区域，则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<1 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手卡选择1只满足条件的不死族怪兽
	local tc=Duel.SelectMatchingCard(tp,c74798297.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp):GetFirst()
	-- 如果成功选择怪兽，则尝试将其以表侧表示特殊召唤
	if tc and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		-- 这个效果特殊召唤的怪兽从场上离开的场合除外。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		tc:RegisterEffect(e1)
	end
	-- 完成特殊召唤的流程
	Duel.SpecialSummonComplete()
end
-- 过滤自己场上表侧表示的不死族怪兽
function c74798297.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_ZOMBIE)
end
-- ②效果的发动准备与目标选择
function c74798297.immtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c74798297.filter(chkc) end
	-- 检查自己场上是否存在可以作为对象的不死族怪兽
	if chk==0 then return Duel.IsExistingTarget(c74798297.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择自己场上1只表侧表示的不死族怪兽作为效果对象
	Duel.SelectTarget(tp,c74798297.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- ②效果的执行：使目标怪兽在这个回合不受自身以外的卡的效果影响
function c74798297.immop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本次效果发动的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc and c74798297.filter(tc) and tc:IsRelateToEffect(e) then
		-- 这个回合，那只不死族怪兽不受自身以外的卡的效果影响。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_IMMUNE_EFFECT)
		e1:SetValue(c74798297.efilter)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
-- 过滤不受影响的卡的效果（自身以外的卡的效果）
function c74798297.efilter(e,te)
	return te:GetOwner()~=e:GetHandler()
end
