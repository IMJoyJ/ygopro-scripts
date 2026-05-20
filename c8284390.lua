--SR56プレーン
-- 效果：
-- 「疾行机人 56飞机」的①的效果1回合只能使用1次。
-- ①：自己场上有怪兽特殊召唤的场合才能发动。这张卡从手卡特殊召唤。这个效果的发动后，直到回合结束时自己不是风属性怪兽不能特殊召唤。
-- ②：这张卡召唤·特殊召唤成功的场合，以场上1只表侧表示怪兽为对象才能发动。那只怪兽的攻击力直到回合结束时下降600。
function c8284390.initial_effect(c)
	-- 「疾行机人 56飞机」的①的效果1回合只能使用1次。①：自己场上有怪兽特殊召唤的场合才能发动。这张卡从手卡特殊召唤。这个效果的发动后，直到回合结束时自己不是风属性怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(8284390,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,8284390)
	e1:SetCondition(c8284390.spcon)
	e1:SetTarget(c8284390.sptg)
	e1:SetOperation(c8284390.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡召唤·特殊召唤成功的场合，以场上1只表侧表示怪兽为对象才能发动。那只怪兽的攻击力直到回合结束时下降600。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(8284390,1))
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetTarget(c8284390.atktg)
	e2:SetOperation(c8284390.atkop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
end
-- 检查特殊召唤成功的怪兽中是否存在自己场上的怪兽（即控制者为自己）。
function c8284390.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsControler,1,nil,tp)
end
-- 效果①的发动准备与合法性检测，检查怪兽区域是否有空位以及自身是否能特殊召唤。
function c8284390.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查当前玩家场上是否有可用的怪兽区域空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤的操作信息，表明此效果将特殊召唤自身。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果①的效果处理：将自身特殊召唤，并注册“直到回合结束时自己不是风属性怪兽不能特殊召唤”的限制。
function c8284390.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡以表侧表示特殊召唤到发动效果的玩家场上。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
	-- 这个效果的发动后，直到回合结束时自己不是风属性怪兽不能特殊召唤。②：这张卡召唤·特殊召唤成功的场合，以场上1只表侧表示怪兽为对象才能发动。那只怪兽的攻击力直到回合结束时下降600。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c8284390.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将不能特殊召唤风属性以外怪兽的限制效果注册给发动效果的玩家。
	Duel.RegisterEffect(e1,tp)
end
-- 限制不能特殊召唤风属性以外的怪兽。
function c8284390.splimit(e,c,tp,sumtp,sumpos)
	return not c:IsAttribute(ATTRIBUTE_WIND)
end
-- 效果②的靶向与合法性检测，选择场上1只表侧表示怪兽作为对象，并设置改变攻击力的操作信息。
function c8284390.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	-- 检查场上是否存在至少1只表侧表示的怪兽可以作为效果对象。
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择表侧表示的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让玩家选择场上1只表侧表示的怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置改变攻击力的操作信息，表明此效果将改变所选怪兽的攻击力。
	Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,g,1,0,0)
end
-- 效果②的效果处理：使作为对象的怪兽的攻击力直到回合结束时下降600。
function c8284390.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择为效果对象的怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 那只怪兽的攻击力直到回合结束时下降600。
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_UPDATE_ATTACK)
		e2:SetValue(-600)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
	end
end
