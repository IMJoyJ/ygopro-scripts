--怨念の魂 業火
-- 效果：
-- ①：自己场上有炎属性怪兽存在的场合，这张卡可以从手卡特殊召唤。
-- ②：这张卡的①的方法特殊召唤成功的场合，以自己场上1只炎属性怪兽为对象发动。那只自己的炎属性怪兽破坏。
-- ③：把这张卡以外的自己场上1只炎属性怪兽解放才能发动。这张卡的攻击力直到回合结束时上升500。
-- ④：自己准备阶段发动。在自己场上把1只「火之玉衍生物」（炎族·炎·1星·攻/守100）守备表示特殊召唤。
function c23116808.initial_effect(c)
	-- ①：自己场上有炎属性怪兽存在的场合，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c23116808.spcon)
	e1:SetValue(SUMMON_VALUE_SELF)
	c:RegisterEffect(e1)
	-- ②：这张卡的①的方法特殊召唤成功的场合，以自己场上1只炎属性怪兽为对象发动。那只自己的炎属性怪兽破坏。
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
	-- ④：自己准备阶段发动。在自己场上把1只「火之玉衍生物」（炎族·炎·1星·攻/守100）守备表示特殊召唤。
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
	-- ③：把这张卡以外的自己场上1只炎属性怪兽解放才能发动。这张卡的攻击力直到回合结束时上升500。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(23116808,2))  --"攻击上升"
	e4:SetCategory(CATEGORY_ATKCHANGE)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCost(c23116808.atkcost)
	e4:SetOperation(c23116808.atkop)
	c:RegisterEffect(e4)
end
-- 过滤函数：判断怪兽是否为表侧表示的炎属性怪兽，用于确认场上存在符合条件的炎属性怪兽。
function c23116808.spfilter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_FIRE)
end
-- 规则特殊召唤条件：当c为nil表示询问是否能从手牌规则特召；否则需满足自己场上存在空位、且场上有表侧炎属性怪兽，才能以①的效果从手牌特殊召唤。
function c23116808.spcon(e,c)
	if c==nil then return true end
	-- 检查该怪兽控制者场上是否存在可用的主要怪兽区空格。
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
		-- 检查该怪兽控制者场上是否存在至少1只表侧表示的炎属性怪兽（用于满足①的手牌特殊召唤条件）。
		and Duel.IsExistingMatchingCard(c23116808.spfilter,c:GetControler(),LOCATION_MZONE,0,1,nil)
end
-- ②效果的诱发条件：判定这张卡是否是以①的方法（SUMMON_TYPE_SPECIAL+SUMMON_VALUE_SELF）特殊召唤成功的场合。
function c23116808.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetSummonType()==SUMMON_TYPE_SPECIAL+SUMMON_VALUE_SELF
end
-- 过滤函数：选择对象时的筛选条件，要求是自己场上的表侧炎属性怪兽。
function c23116808.desfilter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_FIRE)
end
-- ②效果的发动目标处理：取对象效果，选择自己场上1只表侧炎属性怪兽作为破坏对象，并设置破坏的操作信息。
function c23116808.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c23116808.desfilter(chkc) end
	if chk==0 then return true end
	-- 向玩家显示“请选择要破坏的卡”的提示信息，用于选择对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让当前玩家从自己场上选择1只表侧炎属性怪兽作为效果对象，并登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,c23116808.desfilter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置本次连锁将产生“破坏”操作信息，目标为已选对象，数量为对象数，供其他效果连锁时判断。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- ②效果处理：取得对象怪兽，若其仍与该效果关联，则将其破坏（效果破坏）。
function c23116808.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 取回发动时选择的对象卡（目标怪兽）。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 以‘效果’为破坏原因将该对象怪兽破坏。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- ④效果的发动条件：仅在己方准备阶段且当前回合玩家为自己时满足。
function c23116808.tkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为自己，即处于自己的准备阶段。
	return Duel.GetTurnPlayer()==tp
end
-- ④效果的发动目标设定：无取对象，效果处理时只需设置特殊召唤衍生物及特殊召唤的操作信息。
function c23116808.tktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置本次连锁将产生衍生物的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	-- 设置本次连锁将进行特殊召唤的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
-- ④效果处理：若自己场上空位足够且可特殊召唤火之玉衍生物，则生成该衍生物并守备表示特殊召唤到自己场上。
function c23116808.tkop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否有空余的主要怪兽区，若没有则无法特殊召唤衍生物，效果处理终止。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<1 then return end
	-- 检查自己是否能够将“火之玉衍生物”（炎族·炎·1星·攻/守100）以守备表示特殊召唤到场上。
	if not Duel.IsPlayerCanSpecialSummonMonster(tp,23116809,0,TYPES_TOKEN_MONSTER,100,100,1,RACE_PYRO,ATTRIBUTE_FIRE,POS_FACEUP_DEFENSE) then return end
	-- 生成1只「火之玉衍生物」Token，持有者为自己。
	local token=Duel.CreateToken(tp,23116809)
	-- 将生成的衍生物以守备表示特殊召唤到自己场上（不视为效果特殊召唤，sumtype为0）。
	Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
end
-- ③效果的发动代价：必须将这张卡以外的自己场上1只炎属性怪兽解放作为cost，才能发动。
function c23116808.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动前确认自己场上是否存在除这张卡以外可解放的炎属性怪兽。
	if chk==0 then return Duel.CheckReleaseGroup(tp,Card.IsAttribute,1,e:GetHandler(),ATTRIBUTE_FIRE) end
	-- 让玩家从自己场上选择除这张卡以外的1只炎属性怪兽，作为解放的代价。
	local g=Duel.SelectReleaseGroup(tp,Card.IsAttribute,1,1,e:GetHandler(),ATTRIBUTE_FIRE)
	-- 将所选怪兽以代价原因（REASON_COST）解放，完成发动cost。
	Duel.Release(g,REASON_COST)
end
-- ③效果处理：为这张卡附加一个直到回合结束时攻击力上升500的增益效果（仅表侧表示且与效果关联时适用）。
function c23116808.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 这张卡的攻击力直到回合结束时上升500。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(500)
		c:RegisterEffect(e1)
	end
end
