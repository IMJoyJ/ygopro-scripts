--不知火の師範
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡在墓地存在，自己场上有「不知火」怪兽2种类以上存在的场合才能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
-- ②：这张卡被除外的场合，以自己场上1只不死族怪兽为对象才能发动。那只怪兽的攻击力直到回合结束时上升600。
function c5177985.initial_effect(c)
	-- ①：这张卡在墓地存在，自己场上有「不知火」怪兽2种类以上存在的场合才能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(5177985,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCountLimit(1,5177985)
	e1:SetCondition(c5177985.condition)
	e1:SetTarget(c5177985.target)
	e1:SetOperation(c5177985.operation)
	c:RegisterEffect(e1)
	-- ②：这张卡被除外的场合，以自己场上1只不死族怪兽为对象才能发动。那只怪兽的攻击力直到回合结束时上升600。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(5177985,1))
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_REMOVE)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,5177986)
	e2:SetTarget(c5177985.atktg)
	e2:SetOperation(c5177985.atkop)
	c:RegisterEffect(e2)
end
-- 检查场上是否存在至少2种类以上的「不知火」怪兽，用于判断效果①是否可以发动。
function c5177985.cfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0xd9)
		-- 检查场上是否存在至少1只其他种类的「不知火」怪兽，用于判断效果①是否可以发动。
		and Duel.IsExistingMatchingCard(c5177985.cfilter2,tp,LOCATION_MZONE,0,1,nil,c:GetCode())
end
-- 用于筛选场上其他种类的「不知火」怪兽，配合cfilter函数实现2种类以上的效果检测。
function c5177985.cfilter2(c,code)
	return c:IsFaceup() and c:IsSetCard(0xd9) and not c:IsCode(code)
end
-- 判断效果①是否可以发动：自己场上有「不知火」怪兽2种类以上存在。
function c5177985.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否存在至少2种类以上的「不知火」怪兽，用于判断效果①是否可以发动。
	return Duel.IsExistingMatchingCard(c5177985.cfilter,tp,LOCATION_MZONE,0,1,nil,tp)
end
-- 设置效果①的发动条件：确认是否有足够的召唤区域并能特殊召唤此卡。
function c5177985.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否有足够的召唤区域来特殊召唤此卡。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁信息，表示将要进行特殊召唤操作。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 执行效果①的处理：若满足条件则将此卡特殊召唤，并设置其离场时除外的效果。
function c5177985.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断此卡是否能被特殊召唤并成功特殊召唤。
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- 创建一个永续效果，使该卡从场上离开时被除外。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e1,true)
	end
end
-- 筛选场上正面表示的不死族怪兽，用于效果②的目标选择。
function c5177985.atkfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_ZOMBIE)
end
-- 设置效果②的目标选择：选择自己场上的1只不死族怪兽作为对象。
function c5177985.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c5177985.atkfilter(chkc) end
	-- 检查是否场上存在符合条件的不死族怪兽作为目标。
	if chk==0 then return Duel.IsExistingTarget(c5177985.atkfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择效果的对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择场上正面表示的1只不死族怪兽作为效果②的目标。
	Duel.SelectTarget(tp,c5177985.atkfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 执行效果②的处理：使目标怪兽攻击力上升600点直到回合结束。
function c5177985.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的目标怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 创建一个临时效果，使目标怪兽的攻击力增加600点，并在回合结束时消失。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(600)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
