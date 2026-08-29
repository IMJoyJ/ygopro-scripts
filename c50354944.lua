--暗黒騎士ガイアオリジン
-- 效果：
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：从手卡把1只5星以上的怪兽送去墓地才能发动。这张卡从手卡特殊召唤。
-- ②：战士族怪兽上级召唤的场合，这张卡可以作为2只的数量解放。
-- ③：自己·对方的战斗阶段，把墓地的这张卡除外，以持有和原本攻击力不同攻击力的场上1只怪兽为对象才能发动。那只怪兽的攻击力变成原本数值。
function c50354944.initial_effect(c)
	-- ①：从手卡把1只5星以上的怪兽送去墓地才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(50354944,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,50354944)
	e1:SetCost(c50354944.spcost)
	e1:SetTarget(c50354944.sptg)
	e1:SetOperation(c50354944.spop)
	c:RegisterEffect(e1)
	-- ②：战士族怪兽上级召唤的场合，这张卡可以作为2只的数量解放。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_DOUBLE_TRIBUTE)
	e2:SetValue(c50354944.condition)
	c:RegisterEffect(e2)
	-- ③：自己·对方的战斗阶段，把墓地的这张卡除外，以持有和原本攻击力不同攻击力的场上1只怪兽为对象才能发动。那只怪兽的攻击力变成原本数值。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(50354944,1))
	e3:SetCategory(CATEGORY_ATKCHANGE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetHintTiming(TIMING_DAMAGE_STEP)
	e3:SetCountLimit(1,50354945)
	e3:SetCondition(c50354944.atkcon)
	-- 把墓地的这张卡除外作为代价
	e3:SetCost(aux.bfgcost)
	e3:SetTarget(c50354944.atktg)
	e3:SetOperation(c50354944.atkop)
	c:RegisterEffect(e3)
end
-- 过滤手卡中可作为代价送去墓地的5星以上怪兽
function c50354944.cfilter(c)
	return c:IsLevelAbove(5) and c:IsAbleToGraveAsCost()
end
-- 特殊召唤效果的发动代价（从手卡把1只5星以上怪兽送去墓地）
function c50354944.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡是否存在除自身外可作为代价送去墓地的5星以上怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c50354944.cfilter,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 提示选择要送去墓地的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从手卡选择1只5星以上的怪兽
	local g=Duel.SelectMatchingCard(tp,c50354944.cfilter,tp,LOCATION_HAND,0,1,1,e:GetHandler())
	-- 将选中的怪兽作为代价送去墓地
	Duel.SendtoGrave(g,REASON_COST)
end
-- 特殊召唤效果的目标确认与操作信息设置
function c50354944.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查主要怪兽区空位及自身特殊召唤条件
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤自身的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 执行特殊召唤自身的操作
function c50354944.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将自身以表侧表示特殊召唤
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- 判断被上级召唤的怪兽是否为战士族
function c50354944.condition(e,c)
	local ec=e:GetHandler()
	return c:IsRace(RACE_WARRIOR) and (ec:IsFaceup() or c:GetControler()==ec:GetControler())
end
-- 重置攻击力效果的发动条件（战斗阶段且在伤害计算前）
function c50354944.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前阶段
	local ph=Duel.GetCurrentPhase()
	-- 判断当前是否处于战斗阶段且满足伤害步骤限制条件
	return ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE and aux.dscon(e,tp,eg,ep,ev,re,r,rp)
end
-- 过滤场上表侧表示且攻击力与原本攻击力不同的怪兽
function c50354944.atkfilter(c)
	return c:IsFaceup() and not c:IsAttack(c:GetBaseAttack())
end
-- 重置攻击力效果的对象选择与操作信息设置
function c50354944.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c50354944.atkfilter(chkc) end
	-- 检查场上是否存在攻击力与原本不同的怪兽
	if chk==0 then return Duel.IsExistingTarget(c50354944.atkfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示选择效果对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择场上1只攻击力与原本攻击力不同的怪兽作为对象
	Duel.SelectTarget(tp,c50354944.atkfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
-- 重置目标怪兽攻击力的效果处理
function c50354944.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		local atk=tc:GetBaseAttack()
		-- 那只怪兽的攻击力变成原本数值。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(atk)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
