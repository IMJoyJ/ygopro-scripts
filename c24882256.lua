--ファイアフェニックス＠イグニスター
-- 效果：
-- 电子界族怪兽2只以上
-- 这个卡名的①②③的效果1回合各能使用1次。
-- ①：这张卡攻击的伤害计算时才能发动。给与对方这张卡的攻击力数值的伤害，那次战斗发生的对对方的战斗伤害变成0。
-- ②：这张卡被效果破坏的场合才能发动。选对方场上1只怪兽破坏。
-- ③：连接召唤的这张卡被破坏送去墓地的场合，下次的准备阶段才能发动。这张卡从墓地特殊召唤。
function c24882256.initial_effect(c)
	c:EnableReviveLimit()
	-- 为卡片添加连接召唤手续，要求使用至少2只电子界族的连接素材
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkRace,RACE_CYBERSE),2)
	-- ①：这张卡攻击的伤害计算时才能发动。给与对方这张卡的攻击力数值的伤害，那次战斗发生的对对方的战斗伤害变成0。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(24882256,0))
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e1:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e1:SetCountLimit(1,24882256)
	e1:SetCondition(c24882256.damcon)
	e1:SetTarget(c24882256.damtg)
	e1:SetOperation(c24882256.damop)
	c:RegisterEffect(e1)
	-- ②：这张卡被效果破坏的场合才能发动。选对方场上1只怪兽破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(24882256,1))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetCountLimit(1,24882257)
	e2:SetCondition(c24882256.descon)
	e2:SetTarget(c24882256.destg)
	e2:SetOperation(c24882256.desop)
	c:RegisterEffect(e2)
	-- ③：连接召唤的这张卡被破坏送去墓地的场合，下次的准备阶段才能发动。这张卡从墓地特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetOperation(c24882256.regop)
	c:RegisterEffect(e3)
	-- 当此卡被破坏送去墓地时，若其为连接召唤且从场上被破坏，则在下次准备阶段时记录flag标记
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(24882256,2))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e4:SetRange(LOCATION_GRAVE)
	e4:SetCountLimit(1,24882258)
	e4:SetCondition(c24882256.spcon)
	e4:SetTarget(c24882256.sptg)
	e4:SetOperation(c24882256.spop)
	c:RegisterEffect(e4)
end
-- 判断是否为攻击时的伤害计算阶段
function c24882256.damcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否为攻击时的伤害计算阶段
	return Duel.GetAttacker()==e:GetHandler()
end
-- 设置伤害计算时的效果目标
function c24882256.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置伤害计算时的效果目标
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,e:GetHandler():GetAttack())
end
-- 执行伤害计算时的效果操作
function c24882256.damop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	-- 对对方造成等于自身攻击力的伤害
	Duel.Damage(1-tp,c:GetAttack(),REASON_EFFECT)
	-- 注册一个使对方在本次战斗中避免战斗伤害的效果
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(0,1)
	e1:SetReset(RESET_PHASE+PHASE_DAMAGE)
	-- 注册一个使对方在本次战斗中避免战斗伤害的效果
	Duel.RegisterEffect(e1,tp)
end
-- 判断此卡是否因效果破坏
function c24882256.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_EFFECT)
end
-- 设置破坏效果的目标
function c24882256.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方场上是否存在至少1只怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(nil,tp,0,LOCATION_MZONE,1,nil) end
	-- 获取对方场上的所有怪兽
	local g=Duel.GetMatchingGroup(nil,tp,0,LOCATION_MZONE,nil)
	-- 设置破坏效果的目标
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 执行破坏效果的操作
function c24882256.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要破坏的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上1只怪兽作为破坏对象
	local g=Duel.SelectMatchingCard(tp,nil,tp,0,LOCATION_MZONE,1,1,nil)
	if g:GetCount()>0 then
		-- 显示所选怪兽被破坏的动画效果
		Duel.HintSelection(g)
		-- 将所选怪兽破坏
		Duel.Destroy(g,REASON_EFFECT)
	end
end
-- 记录此卡被破坏时的flag标记
function c24882256.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsReason(REASON_DESTROY) and c:IsPreviousLocation(LOCATION_MZONE) and c:IsSummonType(SUMMON_TYPE_LINK) then
		c:RegisterFlagEffect(24882256,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,2)
	end
end
-- 判断是否为下次准备阶段且已记录flag标记
function c24882256.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断是否为下次准备阶段且已记录flag标记
	return c:GetTurnID()~=Duel.GetTurnCount() and c:GetFlagEffect(24882256)>0
end
-- 设置特殊召唤效果的目标
function c24882256.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否有足够的召唤位置
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤效果的目标
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
	e:GetHandler():ResetFlagEffect(24882256)
end
-- 执行特殊召唤效果的操作
function c24882256.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将此卡从墓地特殊召唤到场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
