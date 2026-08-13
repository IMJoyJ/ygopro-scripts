--覇蛇大公ゴルゴンダ
-- 效果：
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：这张卡在手卡·墓地存在，自己的场地区域有表侧表示卡存在的场合才能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
-- ②：只要场上有「大沙海 黄金戈尔工达」存在，这张卡的原本攻击力变成3000。
-- ③：场上的「大沙海 黄金戈尔工达」被效果破坏的场合，可以作为代替把自己墓地1只怪兽除外。
function c31042659.initial_effect(c)
	-- 将卡号60884672（大沙海 黄金戈尔工达）登记为这张卡效果文本中记载的卡名，用于相关卡名的检索与判定。
	aux.AddCodeList(c,60884672)
	-- ①：这张卡在手卡·墓地存在，自己的场地区域有表侧表示卡存在的场合才能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(31042659,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetCountLimit(1,31042659)
	e1:SetCondition(c31042659.spcon)
	e1:SetTarget(c31042659.sptg)
	e1:SetOperation(c31042659.spop)
	c:RegisterEffect(e1)
	-- ③：场上的「大沙海 黄金戈尔工达」被效果破坏的场合，可以作为代替把自己墓地1只怪兽除外。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,31042660)
	e2:SetTarget(c31042659.reptg)
	e2:SetValue(c31042659.repval)
	c:RegisterEffect(e2)
	-- ②：只要场上有「大沙海 黄金戈尔工达」存在，这张卡的原本攻击力变成3000。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_SET_BASE_ATTACK)
	e3:SetCondition(c31042659.atkcon)
	e3:SetValue(3000)
	c:RegisterEffect(e3)
end
-- ①效果的发动条件判定函数：确认自己场地区域存在表侧表示的卡。
function c31042659.spcon(e)
	-- 检查以效果控制者视角，自己的场地区域是否存在至少1张表侧表示卡。
	return Duel.IsExistingMatchingCard(Card.IsFaceup,e:GetHandlerPlayer(),LOCATION_FZONE,0,1,nil)
end
-- ①效果发动时点的合法性判定：保证自己主要怪兽区有空位，且这张卡能够被特殊召唤。
function c31042659.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 确认自己的主要怪兽区域存在可用空位，否则无法发动特殊召唤效果。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置效果处理信息，声明此效果涉及将这张卡特殊召唤，供后续效果（如星尘龙等）进行发动判定。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①效果处理：将这张卡特殊召唤；若成功，再赋予其“从场上离开时除外”的永续效果。
function c31042659.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 确认这张卡仍与效果关联且特殊召唤成功时，才继续赋予离场除外效果。
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 这个效果特殊召唤的这张卡从场上离开的场合除外。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e1,true)
	end
end
-- ③效果的代替破坏过滤器：判断“大沙海 黄金戈尔工达”是否表侧表示在场、将因效果被破坏且不是被代替破坏。
function c31042659.repfilter(c)
	return c:IsFaceup() and c:IsCode(60884672) and c:IsReason(REASON_EFFECT) and not c:IsReason(REASON_REPLACE)
end
-- ③效果的除外过滤器：选择自己墓地中可作为代替除外的怪兽。
function c31042659.rmfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToRemove()
end
-- ③效果的发动条件判定：存在将被效果破坏的“大沙海 黄金戈尔工达”，且自己墓地有可除外的怪兽。
function c31042659.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(c31042659.repfilter,1,nil)
		-- 确认自己的墓地存在至少1只满足除外条件的怪兽，以保证可以代替破坏。
		and Duel.IsExistingMatchingCard(c31042659.rmfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 询问玩家是否发动代替破坏效果，将墓地怪兽除外来代替“大沙海 黄金戈尔工达”的破坏。
	if Duel.SelectEffectYesNo(tp,e:GetHandler(),96) then
		-- 提示玩家选择要除外的卡（墓地怪兽）。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		-- 从自己墓地选择1只满足 rmfilter 的怪兽作为代替除外的对象。
		local g=Duel.SelectMatchingCard(tp,c31042659.rmfilter,tp,LOCATION_GRAVE,0,1,1,nil)
		-- 将选择的墓地怪兽除外，作为代替破坏的处理（原因包含效果和代替）。
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT+REASON_REPLACE)
		return true
	end
	return false
end
-- ③效果的代替破坏判定函数：判断被破坏的卡是否为符合条件的“大沙海 黄金戈尔工达”。
function c31042659.repval(e,c)
	return c31042659.repfilter(c)
end
-- ②效果的适用条件判定：场上存在“大沙海 黄金戈尔工达”（通过环境判定）。
function c31042659.atkcon(e)
	-- 检查当前场上是否适用“大沙海 黄金戈尔工达”的场地/视为存在，用于决定原本攻击力是否变为3000。
	return Duel.IsEnvironment(60884672)
end
