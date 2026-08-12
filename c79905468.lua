--守護竜プロミネシス
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：把手卡·场上的这张卡送去墓地，以自己场上1只龙族怪兽为对象才能发动。那只怪兽的攻击力·守备力直到对方回合结束时上升500。
-- ②：这张卡在墓地存在，通常怪兽被送去自己墓地的场合才能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
function c79905468.initial_effect(c)
	-- ①：把手卡·场上的这张卡送去墓地，以自己场上1只龙族怪兽为对象才能发动。那只怪兽的攻击力·守备力直到对方回合结束时上升500。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(79905468,0))
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE+LOCATION_HAND)
	e1:SetCost(c79905468.atkcost)
	e1:SetTarget(c79905468.atktg)
	e1:SetOperation(c79905468.atkop)
	c:RegisterEffect(e1)
	-- 这个卡名的②的效果1回合只能使用1次。②：这张卡在墓地存在，通常怪兽被送去自己墓地的场合才能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(79905468,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,79905468)
	e2:SetCondition(c79905468.spcon)
	e2:SetTarget(c79905468.sptg)
	e2:SetOperation(c79905468.spop)
	c:RegisterEffect(e2)
end
-- 效果①的发动代价（Cost）函数：将手卡或场上的这张卡送去墓地。
function c79905468.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 将自身作为发动代价送去墓地。
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 过滤条件：表侧表示的龙族怪兽。
function c79905468.atkfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_DRAGON)
end
-- 效果①的发动准备（Target）函数：确认并选择自己场上1只表侧表示的龙族怪兽作为对象。
function c79905468.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c79905468.atkfilter(chkc) end
	-- 检查自己场上是否存在除自身以外的、可作为对象的表侧表示龙族怪兽。
	if chk==0 then return Duel.IsExistingTarget(c79905468.atkfilter,tp,LOCATION_MZONE,0,1,e:GetHandler()) end
	-- 向玩家发送选择表侧表示卡片的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择自己场上1只表侧表示的龙族怪兽作为效果对象。
	Duel.SelectTarget(tp,c79905468.atkfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果①的效果处理（Operation）函数：使作为对象的怪兽攻击力上升500。
function c79905468.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中作为效果对象的怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 那只怪兽的攻击力·守备力直到对方回合结束时上升500。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(500)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
		tc:RegisterEffect(e1)
	end
end
-- 过滤条件：属于自己且送去墓地的通常怪兽。
function c79905468.cfilter(c,tp)
	return c:IsType(TYPE_NORMAL) and c:IsControler(tp)
end
-- 效果②的发动条件：通常怪兽被送去自己墓地，且不包含这张卡自身。
function c79905468.spcon(e,tp,eg,ep,ev,re,r,rp)
	return not eg:IsContains(e:GetHandler()) and eg:IsExists(c79905468.cfilter,1,nil,tp)
end
-- 效果②的发动准备（Target）函数：检查怪兽区域空位并确认自身能否特殊召唤。
function c79905468.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上的主要怪兽区域是否有空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置当前连锁的操作信息为特殊召唤自身。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果②的效果处理（Operation）函数：将这张卡特殊召唤，并添加离场时除外的限制。
function c79905468.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 若这张卡仍存在于墓地，则将其以表侧表示特殊召唤。
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
