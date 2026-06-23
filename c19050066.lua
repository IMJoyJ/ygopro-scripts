--EMバロックリボー
-- 效果：
-- ←1 【灵摆】 1→
-- ①：1回合1次，自己·对方的战斗阶段开始时才能发动。从卡组把1只攻击力300/守备力200的怪兽加入手卡。那之后，这张卡破坏。
-- 【怪兽效果】
-- ①：自己怪兽被战斗破坏时才能发动。这张卡从手卡特殊召唤。
-- ②：只要这张卡在怪兽区域存在，对方不能选择其他怪兽作为攻击对象。
-- ③：这张卡被攻击的场合，伤害步骤结束时变成攻击表示。
function c19050066.initial_effect(c)
	-- 为灵摆怪兽添加灵摆怪兽属性（灵摆召唤，灵摆卡的发动）
	aux.EnablePendulumAttribute(c)
	-- ①：1回合1次，自己·对方的战斗阶段开始时才能发动。从卡组把1只攻击力300/守备力200的怪兽加入手卡。那之后，这张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_PHASE+PHASE_BATTLE_START)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(c19050066.tgtg)
	e1:SetOperation(c19050066.tgop)
	c:RegisterEffect(e1)
	-- ①：自己怪兽被战斗破坏时才能发动。这张卡从手卡特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_DESTROYED)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(c19050066.descon)
	e2:SetTarget(c19050066.destg)
	e2:SetOperation(c19050066.desop)
	c:RegisterEffect(e2)
	-- ②：只要这张卡在怪兽区域存在，对方不能选择其他怪兽作为攻击对象。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(0,LOCATION_MZONE)
	e3:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e3:SetValue(c19050066.atklimit)
	c:RegisterEffect(e3)
	-- ③：这张卡被攻击的场合，伤害步骤结束时变成攻击表示。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_DAMAGE_STEP_END)
	e4:SetOperation(c19050066.posop)
	c:RegisterEffect(e4)
end
-- 过滤函数，检查卡组中是否存在攻击力为300、守备力为200且能加入手牌的怪兽
function c19050066.tgfilter(c)
	return c:IsAttack(300) and c:IsDefense(200) and c:IsAbleToHand()
end
-- 设置连锁处理信息，确定效果发动时要检索的卡和破坏的卡
function c19050066.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查以自己来看的卡组中是否存在至少1张满足条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c19050066.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁处理信息，确定效果发动时要检索的卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	-- 设置连锁处理信息，确定效果发动时要破坏的卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
end
-- 检索满足条件的怪兽加入手牌，确认对方看到该卡，中断当前效果，然后破坏自身
function c19050066.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的1张卡加入手牌
	local g=Duel.SelectMatchingCard(tp,c19050066.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	local tc=g:GetFirst()
	-- 若选择的卡成功加入手牌，则确认对方看到该卡，中断当前效果，然后破坏自身
	if tc and Duel.SendtoHand(tc,nil,REASON_EFFECT)>0 and tc:IsLocation(LOCATION_HAND) then
		-- 给对方确认该卡
		Duel.ConfirmCards(1-tp,tc)
		-- 中断当前效果，使之后的效果处理视为不同时处理
		Duel.BreakEffect()
		-- 以破坏原因将自身破坏
		Duel.Destroy(e:GetHandler(),REASON_EFFECT)
	end
end
-- 过滤函数，检查被破坏的怪兽是否为己方控制的怪兽
function c19050066.cfilter(c,tp)
	return c:IsPreviousControler(tp)
end
-- 判断被战斗破坏的怪兽中是否存在己方控制的怪兽
function c19050066.descon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c19050066.cfilter,1,nil,tp)
end
-- 设置连锁处理信息，确定效果发动时要特殊召唤的卡
function c19050066.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查己方场上是否存在空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁处理信息，确定效果发动时要特殊召唤的卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 将自身从手卡特殊召唤到场上
function c19050066.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将自身以表侧攻击表示特殊召唤到己方场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 设置效果值，使对方不能选择自身作为攻击对象
function c19050066.atklimit(e,c)
	return c~=e:GetHandler()
end
-- 当自身被攻击且处于守备表示时，在伤害步骤结束时变为攻击表示
function c19050066.posop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断自身是否为攻击对象且处于守备表示且参与了战斗
	if c==Duel.GetAttackTarget() and c:IsDefensePos() and c:IsRelateToBattle() then
		-- 将自身变为攻击表示
		Duel.ChangePosition(c,POS_FACEUP_ATTACK)
	end
end
