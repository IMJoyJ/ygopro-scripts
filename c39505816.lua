--炎天禍サンバーン
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：自己场上的表侧表示的炎属性怪兽被战斗或者对方的效果破坏的场合才能发动。这张卡从手卡特殊召唤。那之后，可以选那1只破坏的自己墓地的炎属性怪兽，给与对方那个攻击力一半数值的伤害。
function c39505816.initial_effect(c)
	-- 这个卡名的效果1回合只能使用1次。①：自己场上的表侧表示的炎属性怪兽被战斗或者对方的效果破坏的场合才能发动。这张卡从手卡特殊召唤。那之后，可以选那1只破坏的自己墓地的炎属性怪兽，给与对方那个攻击力一半数值的伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(39505816,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_DESTROYED)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,39505816)
	e1:SetCondition(c39505816.spcon)
	e1:SetTarget(c39505816.sptg)
	e1:SetOperation(c39505816.spop)
	c:RegisterEffect(e1)
end
-- 定义筛选函数：判定某张被破坏的怪兽是否满足“自己场上的表侧表示的炎属性怪兽被战斗或者对方的效果破坏”。具体为：该怪兽破坏前由发动者控制、位于其主要怪兽区、表侧表示，且其在场上的属性为炎；同时其破坏原因必须是战斗破坏，或者是由对方玩家发动的效果造成的破坏。
function c39505816.cfilter(c,tp)
	return c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE)
		and c:IsPreviousPosition(POS_FACEUP) and bit.band(c:GetPreviousAttributeOnField(),ATTRIBUTE_FIRE)~=0
		and (c:IsReason(REASON_BATTLE) or c:IsReason(REASON_EFFECT) and c:GetReasonPlayer()==1-tp)
end
-- 效果发动条件：本次破坏事件中存在至少1只被破坏的怪兽满足cfilter的条件，即存在“自己场上的表侧表示的炎属性怪兽被战斗或对方的效果破坏”的情况。
function c39505816.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c39505816.cfilter,1,nil,tp)
end
-- 效果发动时的合法性检查（chk==0）：确认自己主要怪兽区域有空位，且这张手牌中的“炎天祸 桑伯恩”能够被特殊召唤。满足这些条件才能发动效果。
function c39505816.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 确认自己场上存在可用的主要怪兽区域，用于后续将此卡特殊召唤到自己的主要怪兽区。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 向规则引擎注册操作信息：声明本效果当前连锁涉及特殊召唤，对象为这张手牌中的“炎天祸 桑伯恩”，数量为1张。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 定义伤害候选筛选函数：从被破坏的怪兽中，筛选出位于发动者墓地、归发动者控制、当前攻击力大于0，并且满足cfilter条件的怪兽，作为后续可能造成伤害的候选对象。
function c39505816.damfilter(c,tp)
	return c:IsLocation(LOCATION_GRAVE) and c:IsControler(tp) and c:GetAttack()>0 and c39505816.cfilter(c,tp)
end
-- 效果处理：先将此卡从手牌特殊召唤；若特殊召唤成功且存在符合条件的破坏怪兽，则询问发动者是否给对方伤害；若选择是，则从候选怪兽中选择1只，给对方造成其攻击力一半数值的伤害。
function c39505816.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local g=eg:Filter(c39505816.damfilter,nil,tp)
	-- 判断此卡是否成功特殊召唤到场上（成功时返回值大于0）。只有特殊召唤成功后才继续处理后续的选卡与伤害效果。
	if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0
		-- 在特殊召唤成功的基础上，判断是否存在可选的破坏怪兽，且发动者通过“是/否”询问同意造成伤害。若都满足才执行后续的选卡与伤害步骤。
		and g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(39505816,1)) then  --"是否给与对方伤害？"
		-- 弹出选择提示，要求发动者从符合条件的墓地炎属性怪兽中选择1张（这里提示文案为“请选择自己的卡”）。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SELF)  --"请选择自己的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 给对方造成所选怪兽当前攻击力一半数值的伤害（向上取整），伤害类型为效果伤害，reason使用REASON_EFFECT。
		Duel.Damage(1-tp,math.ceil(sg:GetFirst():GetAttack()/2),REASON_EFFECT)
	end
end
