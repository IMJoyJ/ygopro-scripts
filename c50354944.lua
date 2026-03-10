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
	-- 将此卡从手卡除外作为效果发动的代价
	e3:SetCost(aux.bfgcost)
	e3:SetTarget(c50354944.atktg)
	e3:SetOperation(c50354944.atkop)
	c:RegisterEffect(e3)
end
-- 过滤函数：检查手牌中是否存在等级5以上的可送入墓地的怪兽
function c50354944.cfilter(c)
	return c:IsLevelAbove(5) and c:IsAbleToGraveAsCost()
end
-- 效果发动时的处理：选择并送入墓地1只满足条件的怪兽
function c50354944.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足发动条件：确认场上存在至少1只等级5以上的怪兽可以送入墓地
	if chk==0 then return Duel.IsExistingMatchingCard(c50354944.cfilter,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 提示玩家选择要送入墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择满足条件的怪兽并将其加入到送入墓地的组中
	local g=Duel.SelectMatchingCard(tp,c50354944.cfilter,tp,LOCATION_HAND,0,1,1,e:GetHandler())
	-- 将选中的怪兽送入墓地作为发动效果的代价
	Duel.SendtoGrave(g,REASON_COST)
end
-- 判断是否满足特殊召唤的条件：确认场上存在空位且此卡可以被特殊召唤
function c50354944.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足特殊召唤的条件：确认场上存在空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁操作信息，表示将要进行特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 执行特殊召唤的操作：将此卡特殊召唤到场上
function c50354944.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将此卡以特殊召唤方式送入场上
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- 过滤函数：检查目标怪兽是否为表侧表示且攻击力与原本不同
function c50354944.condition(e,c)
	return c:IsRace(RACE_WARRIOR)
end
-- 判断效果发动时机：确认当前阶段为战斗阶段且未进入伤害计算阶段
function c50354944.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前游戏阶段
	local ph=Duel.GetCurrentPhase()
	-- 返回当前阶段是否在战斗开始到战斗阶段之间，并且尚未完成伤害计算
	return ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE and aux.dscon(e,tp,eg,ep,ev,re,r,rp)
end
-- 过滤函数：检查目标怪兽是否为表侧表示且攻击力与原本不同
function c50354944.atkfilter(c)
	return c:IsFaceup() and not c:IsAttack(c:GetBaseAttack())
end
-- 效果发动时的处理：选择并指定一个满足条件的场上怪兽作为对象
function c50354944.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c50354944.atkfilter(chkc) end
	-- 判断是否满足发动条件：确认场上存在至少1只满足条件的怪兽可以被指定为对象
	if chk==0 then return Duel.IsExistingTarget(c50354944.atkfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要指定的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择满足条件的怪兽作为效果的目标
	Duel.SelectTarget(tp,c50354944.atkfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
-- 执行效果处理：将目标怪兽的攻击力修改为原本数值
function c50354944.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中指定的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		local atk=tc:GetBaseAttack()
		-- 设置一个永久改变目标怪兽攻击力的效果，使其变为原本攻击力
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(atk)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
