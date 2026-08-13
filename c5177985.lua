--不知火の師範
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡在墓地存在，自己场上有「不知火」怪兽2种类以上存在的场合才能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
-- ②：这张卡被除外的场合，以自己场上1只不死族怪兽为对象才能发动。那只怪兽的攻击力直到回合结束时上升600。
function c5177985.initial_effect(c)
	-- 这个卡名的①②的效果1回合各能使用1次。①：这张卡在墓地存在，自己场上有「不知火」怪兽2种类以上存在的场合才能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
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
-- 过滤函数：检查c是否为表侧表示的「不知火」怪兽，且己方场上还存在另一只卡名不同的表侧表示「不知火」怪兽（用于满足“2种类以上”）。
function c5177985.cfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0xd9)
		-- 在己方场上检索是否存在至少1只与c卡名不同的表侧表示「不知火」怪兽，从而确认有2种类以上不同的「不知火」怪兽。
		and Duel.IsExistingMatchingCard(c5177985.cfilter2,tp,LOCATION_MZONE,0,1,nil,c:GetCode())
end
-- 过滤函数：判断c是否为表侧表示的「不知火」怪兽，且卡名不等于传入的code（排除同一种类，用于判断种类数）。
function c5177985.cfilter2(c,code)
	return c:IsFaceup() and c:IsSetCard(0xd9) and not c:IsCode(code)
end
-- 发动条件判断：己方场上存在至少1只满足cfilter条件的「不知火」怪兽，即存在至少2种类不同的表侧表示「不知火」怪兽时，条件成立。
function c5177985.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查己方主要怪兽区是否存在至少1只表侧表示且满足“存在另一种类不知火”的「不知火」怪兽，作为发动①效果的前提。
	return Duel.IsExistingMatchingCard(c5177985.cfilter,tp,LOCATION_MZONE,0,1,nil,tp)
end
-- 效果发动时的合法性检查：己方主要怪兽区有空位，且墓地中的这张卡自身可以被特殊召唤。
function c5177985.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查己方主要怪兽区是否有空位，确保特殊召唤有可用区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 将当前连锁的操作信息设置为“特殊召唤这张卡”（数量1），供其他卡/效果进行连锁检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理：若这张卡仍与效果关联，则将其表侧特殊召唤到己方主要怪兽区；成功后给它附加“从场上离开时不去墓地而是除外”的效果。
function c5177985.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断这张卡是否仍与此效果关联，并执行特殊召唤；若特殊召唤成功，则继续附加离场除外效果。
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- 这个效果特殊召唤的这张卡从场上离开的场合除外。②：这张卡被除外的场合，以自己场上1只不死族怪兽为对象才能发动。那只怪兽的攻击力直到回合结束时上升600。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e1,true)
	end
end
-- 过滤函数：判断c是否为表侧表示的不死族怪兽（用于②效果选择对象）。
function c5177985.atkfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_ZOMBIE)
end
-- ②效果的发动目标处理：选择自己场上1只表侧表示的不死族怪兽作为对象；同时处理连锁时的对象合法性判断。
function c5177985.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c5177985.atkfilter(chkc) end
	-- 效果发动时检查己方场上是否存在至少1只表侧表示的不死族怪兽可以作为对象。
	if chk==0 then return Duel.IsExistingTarget(c5177985.atkfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 向玩家显示“请选择效果的对象”的提示信息，然后进入选卡界面。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 由己方玩家选择1只自己场上的表侧表示不死族怪兽，并将其设置为效果对象。
	Duel.SelectTarget(tp,c5177985.atkfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果处理：取得对象怪兽，若其仍与此效果关联且为表侧表示，则给它附加攻击力上升600直到回合结束的效果。
function c5177985.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁处理的效果对象（②效果选中的不死族怪兽）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 那只怪兽的攻击力直到回合结束时上升600。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(600)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
