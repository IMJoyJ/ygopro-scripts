--怨念の魂 業火
-- 效果：
-- ①：自己场上有炎属性怪兽存在的场合，这张卡可以从手卡特殊召唤。
-- ②：这张卡的①的方法特殊召唤成功的场合，以自己场上1只炎属性怪兽为对象发动。那只自己的炎属性怪兽破坏。
-- ③：把这张卡以外的自己场上1只炎属性怪兽解放才能发动。这张卡的攻击力直到回合结束时上升500。
-- ④：自己准备阶段发动。在自己场上把1只「火之玉衍生物」（炎族·炎·1星·攻/守100）守备表示特殊召唤。
function c23116808.initial_effect(c)
	-- 效果原文内容：①：自己场上有炎属性怪兽存在的场合，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c23116808.spcon)
	e1:SetValue(SUMMON_VALUE_SELF)
	c:RegisterEffect(e1)
	-- 效果原文内容：②：这张卡的①的方法特殊召唤成功的场合，以自己场上1只炎属性怪兽为对象发动。那只自己的炎属性怪兽破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(23116808,0))  --"破坏"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(c23116808.descon)
	e2:SetTarget(c23116808.destg)
	e2:SetOperation(c23116808.desop)
	c:RegisterEffect(e2)
	-- 效果原文内容：④：自己准备阶段发动。在自己场上把1只「火之玉衍生物」（炎族·炎·1星·攻/守100）守备表示特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(23116808,1))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(c23116808.tkcon)
	e3:SetTarget(c23116808.tktg)
	e3:SetOperation(c23116808.tkop)
	c:RegisterEffect(e3)
	-- 效果原文内容：③：把这张卡以外的自己场上1只炎属性怪兽解放才能发动。这张卡的攻击力直到回合结束时上升500。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(23116808,2))  --"攻击上升"
	e4:SetCategory(CATEGORY_ATKCHANGE)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCost(c23116808.atkcost)
	e4:SetOperation(c23116808.atkop)
	c:RegisterEffect(e4)
end
-- 规则层面操作：定义过滤函数，用于检测场上是否存在炎属性的表侧表示怪兽。
function c23116808.spfilter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_FIRE)
end
-- 规则层面操作：判断是否满足特殊召唤条件，即己方场上存在炎属性怪兽且有空场。
function c23116808.spcon(e,c)
	if c==nil then return true end
	-- 规则层面操作：检查己方场上是否有空位可以放置怪兽。
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
		-- 规则层面操作：检查己方场上是否存在至少1只炎属性的表侧表示怪兽。
		and Duel.IsExistingMatchingCard(c23116808.spfilter,c:GetControler(),LOCATION_MZONE,0,1,nil)
end
-- 规则层面操作：判断该卡是否通过特殊召唤方式（①）成功召唤。
function c23116808.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetSummonType()==SUMMON_TYPE_SPECIAL+SUMMON_VALUE_SELF
end
-- 规则层面操作：定义过滤函数，用于检测场上是否存在炎属性的表侧表示怪兽。
function c23116808.desfilter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_FIRE)
end
-- 规则层面操作：设置破坏效果的目标选择逻辑，选择己方场上的炎属性怪兽。
function c23116808.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c23116808.desfilter(chkc) end
	if chk==0 then return true end
	-- 规则层面操作：提示玩家选择要破坏的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 规则层面操作：选择目标怪兽并将其加入操作信息。
	local g=Duel.SelectTarget(tp,c23116808.desfilter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 规则层面操作：设置操作信息，表明将要破坏目标怪兽。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 规则层面操作：执行破坏操作，将目标怪兽破坏。
function c23116808.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面操作：获取当前连锁中被选择的目标怪兽。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 规则层面操作：将目标怪兽以效果原因破坏。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- 规则层面操作：判断是否为己方准备阶段。
function c23116808.tkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面操作：判断当前回合玩家是否为效果发动者。
	return Duel.GetTurnPlayer()==tp
end
-- 规则层面操作：设置衍生物特殊召唤的效果信息。
function c23116808.tktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 规则层面操作：设置操作信息，表明将要特殊召唤衍生物。
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	-- 规则层面操作：设置操作信息，表明将要特殊召唤衍生物。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
-- 规则层面操作：执行衍生物的特殊召唤。
function c23116808.tkop(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面操作：检查己方场上是否有空位可以放置怪兽。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<1 then return end
	-- 规则层面操作：检查是否可以特殊召唤衍生物。
	if not Duel.IsPlayerCanSpecialSummonMonster(tp,23116809,0,TYPES_TOKEN_MONSTER,100,100,1,RACE_PYRO,ATTRIBUTE_FIRE,POS_FACEUP_DEFENSE) then return end
	-- 规则层面操作：创建火之玉衍生物。
	local token=Duel.CreateToken(tp,23116809)
	-- 规则层面操作：将火之玉衍生物以守备表示特殊召唤到己方场上。
	Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 规则层面操作：设置攻击上升效果的费用支付逻辑。
function c23116808.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 规则层面操作：检查是否可以解放1只炎属性怪兽作为费用。
	if chk==0 then return Duel.CheckReleaseGroup(tp,Card.IsAttribute,1,e:GetHandler(),ATTRIBUTE_FIRE) end
	-- 规则层面操作：选择并解放1只炎属性怪兽作为费用。
	local g=Duel.SelectReleaseGroup(tp,Card.IsAttribute,1,1,e:GetHandler(),ATTRIBUTE_FIRE)
	-- 规则层面操作：将选中的怪兽解放。
	Duel.Release(g,REASON_COST)
end
-- 规则层面操作：设置攻击力上升效果。
function c23116808.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 规则层面操作：设置攻击力上升效果的数值和持续时间。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(500)
		c:RegisterEffect(e1)
	end
end
