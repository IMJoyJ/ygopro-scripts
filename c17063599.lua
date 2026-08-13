--風の天翼ミラドーラ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次，那些发动和效果不会被无效化。
-- ①：对方从额外卡组把攻击力2000以上的怪兽特殊召唤的场合才能发动。这张卡从手卡特殊召唤。
-- ②：这张卡从手卡的特殊召唤成功的场合，以从额外卡组特殊召唤的对方场上1只表侧表示怪兽为对象才能发动。这只怪兽表侧表示存在期间，作为对象的怪兽不能把效果发动。
function c17063599.initial_effect(c)
	-- 这个卡名的①②的效果1回合各能使用1次，那些发动和效果不会被无效化。①：对方从额外卡组把攻击力2000以上的怪兽特殊召唤的场合才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(17063599,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CANNOT_INACTIVATE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CAN_FORBIDDEN)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,17063599)
	e1:SetCondition(c17063599.spcon)
	e1:SetTarget(c17063599.sptg)
	e1:SetOperation(c17063599.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡从手卡的特殊召唤成功的场合，以从额外卡组特殊召唤的对方场上1只表侧表示怪兽为对象才能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(17063599,1))
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CANNOT_INACTIVATE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CAN_FORBIDDEN)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCountLimit(1,17063600)
	e2:SetCondition(c17063599.actcon)
	e2:SetTarget(c17063599.acttg)
	e2:SetOperation(c17063599.actop)
	c:RegisterEffect(e2)
end
-- 筛选条件：判断怪兽是否满足“对方从额外卡组把攻击力2000以上的怪兽特殊召唤”——该怪兽由对方从额外卡组特殊召唤、攻击力在2000以上且表侧表示。
function c17063599.cfilter(c,tp)
	return c:IsSummonLocation(LOCATION_EXTRA) and c:IsSummonPlayer(1-tp) and c:IsAttackAbove(2000) and c:IsFaceup()
end
-- ①效果的发动条件：本次特殊召唤成功的怪兽集合中存在至少1只满足cfilter条件的卡，即对方从额外卡组把攻击力2000以上的怪兽特殊召唤。
function c17063599.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c17063599.cfilter,1,nil,tp)
end
-- ①效果的发动合法性检查：我方主要怪兽区域存在空位，且这张卡自身能够被特殊召唤。
function c17063599.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查我方主要怪兽区域是否有可用的空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息，声明本次效果处理将包含特殊召唤（这张卡从手卡特殊召唤），用于连锁判定和时点处理。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理：若这张卡仍与该效果关联，则将这张卡从手卡以表侧表示特殊召唤到我方场上。
function c17063599.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 执行特殊召唤：将这张卡以表侧表示特殊召唤到我方场上（sumtype=0，不检查召唤条件与苏生限制）。
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- ②效果的发动条件：这张卡在此次特殊召唤成功之前位于手牌，即这张卡是从手卡发动的特殊召唤。
function c17063599.actcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_HAND)
end
-- 对象筛选条件：对方场上的表侧表示怪兽，且是从额外卡组特殊召唤的效果怪兽。
function c17063599.filter(c)
	return c:IsFaceup() and c:IsSummonLocation(LOCATION_EXTRA) and c:GetType()&TYPE_EFFECT~=0
end
-- ②效果的目标处理：确认对象合法性并选择对象——若为连锁确认，检查所选卡是否满足条件；若为发动时，检查是否存在合法对象，存在则提示选择表侧表示的怪兽并选择对象。
function c17063599.acttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c17063599.filter(chkc) end
	-- 检查对方场上是否存在至少1只满足filter条件且可以作为效果对象的表侧表示怪兽。
	if chk==0 then return Duel.IsExistingTarget(c17063599.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 游戏提示：要求玩家选择表侧表示的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让玩家从对方主要怪兽区选择1只满足filter条件的表侧表示怪兽作为效果对象，并将其登记为连锁对象。
	Duel.SelectTarget(tp,c17063599.filter,tp,0,LOCATION_MZONE,1,1,nil)
end
-- ②效果处理：若这张卡与对象怪兽都仍与效果关联，则将对象怪兽设为这张卡的永续对象，并给对象怪兽附加“不能发动效果”的效果，只要这张卡仍表侧存在并保持着该对象，该禁止效果就持续适用。
function c17063599.actop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取本效果发动时选择的对象怪兽（取对象效果的目标）。
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and c:IsFaceup() and tc and tc:IsRelateToEffect(e) then
		c:SetCardTarget(tc)
		-- 这只怪兽表侧表示存在期间，作为对象的怪兽不能把效果发动。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_TRIGGER)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetCondition(c17063599.ctcon)
		tc:RegisterEffect(e1,true)
	end
end
-- 禁止效果的适用条件：这张卡（米拉多羽蛇）仍表侧表示存在，并且仍以对象怪兽作为永续对象（即二者联系尚未中断）时，对象怪兽不能发动效果。
function c17063599.ctcon(e)
	local c=e:GetOwner()
	local h=e:GetHandler()
	return c:IsHasCardTarget(h)
end
