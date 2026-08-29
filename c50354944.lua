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
	-- 设置③效果的发动代价为“把墓地的这张卡除外”，使用aux.bfgcost简化实现。
	e3:SetCost(aux.bfgcost)
	e3:SetTarget(c50354944.atktg)
	e3:SetOperation(c50354944.atkop)
	c:RegisterEffect(e3)
end
-- 过滤条件：手卡中存在5星以上且可以作为代价送去墓地的怪兽。
function c50354944.cfilter(c)
	return c:IsLevelAbove(5) and c:IsAbleToGraveAsCost()
end
-- ①效果的代价处理：从手卡选择1只5星以上怪兽（不能选择发动效果的这张卡自身）送去墓地作为代价。
function c50354944.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检查：确认手卡中是否存在满足条件的怪兽可以作为代价。
	if chk==0 then return Duel.IsExistingMatchingCard(c50354944.cfilter,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 弹出提示，让玩家选择要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从手卡选择1只满足条件的5星以上怪兽，且排除发动效果的这张卡自身。
	local g=Duel.SelectMatchingCard(tp,c50354944.cfilter,tp,LOCATION_HAND,0,1,1,e:GetHandler())
	-- 将选择的卡送去墓地，作为效果的发动代价。
	Duel.SendtoGrave(g,REASON_COST)
end
-- ①效果的目标处理：确认自己场上主要怪兽区有空位且自身可以被特殊召唤，并设置特殊召唤的操作信息。
function c50354944.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己主要怪兽区是否有空余区域，用于判断能否特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置本次连锁的操作信息：登记为特殊召唤自身。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①效果的处理：将这张卡从手卡特殊召唤到场上的主要怪兽区。
function c50354944.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将这张卡以表侧攻击表示特殊召唤到自己场上。
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- ②效果的判定条件：被解放的怪兽种族必须为战士族。
function c50354944.condition(e,c)
	local ec=e:GetHandler()
	return c:IsRace(RACE_WARRIOR) and (ec:IsFaceup() or c:GetControler()==ec:GetControler())
end
-- ③效果的发动条件：仅限自己或对方的战斗阶段，且满足伤害步骤前发动的限制。
function c50354944.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前游戏阶段。
	local ph=Duel.GetCurrentPhase()
	-- 判断当前阶段是否处于战斗阶段开始到战斗阶段结束之间，并满足伤害步骤中伤害计算前才能发动的限制。
	return ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE and aux.dscon(e,tp,eg,ep,ev,re,r,rp)
end
-- 对象选择条件：场上表侧表示且当前攻击力与原本攻击力不同的怪兽。
function c50354944.atkfilter(c)
	return c:IsFaceup() and not c:IsAttack(c:GetBaseAttack())
end
-- ③效果的目标选择：选择场上1只表侧表示且攻击力与原本攻击力不同的怪兽作为对象。
function c50354944.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c50354944.atkfilter(chkc) end
	-- 检查场上是否存在满足条件的怪兽可以作为效果对象。
	if chk==0 then return Duel.IsExistingTarget(c50354944.atkfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 弹出提示，让玩家选择效果对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择场上1只符合条件的怪兽作为效果对象。
	Duel.SelectTarget(tp,c50354944.atkfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
-- ③效果的处理：将对象怪兽的攻击力变成原本攻击力。
function c50354944.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得这个效果选择的对象怪兽。
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
