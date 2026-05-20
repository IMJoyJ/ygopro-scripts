--ペンギン僧侶
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：「企鹅」怪兽被对方从自己的怪兽区域送去自己墓地的场合，以那之内的1只为对象才能发动（伤害步骤也能发动）。这张卡从手卡丢弃，作为对象的怪兽里侧守备表示特殊召唤。
-- ②：1回合1次，以自己场上1只「企鹅」怪兽为对象才能发动。那只怪兽的攻击力直到回合结束时上升600，自己回复600基本分。
function c73640163.initial_effect(c)
	-- 这个卡名的①的效果1回合只能使用1次。①：「企鹅」怪兽被对方从自己的怪兽区域送去自己墓地的场合，以那之内的1只为对象才能发动（伤害步骤也能发动）。这张卡从手卡丢弃，作为对象的怪兽里侧守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(73640163,0))  --"丢弃并特殊召唤"
	e1:SetCategory(CATEGORY_HANDES+CATEGORY_SPECIAL_SUMMON+CATEGORY_MSET)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,73640163)
	e1:SetCondition(c73640163.spcon)
	e1:SetTarget(c73640163.sptg)
	e1:SetOperation(c73640163.spop)
	c:RegisterEffect(e1)
	-- ②：1回合1次，以自己场上1只「企鹅」怪兽为对象才能发动。那只怪兽的攻击力直到回合结束时上升600，自己回复600基本分。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(73640163,1))
	e2:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_RECOVER)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1)
	e2:SetTarget(c73640163.atktg)
	e2:SetOperation(c73640163.atkop)
	c:RegisterEffect(e2)
end
-- 过滤送去墓地的卡：自己场上的「企鹅」怪兽因对方而被送去自己墓地
function c73640163.cfilter(c,tp)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x5a)
		and c:IsControler(tp) and c:GetReasonPlayer()==1-tp
		and c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE)
end
-- 效果①的发动条件：存在满足条件的被送去墓地的「企鹅」怪兽
function c73640163.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c73640163.cfilter,1,nil,tp)
end
-- 过滤可以里侧守备表示特殊召唤且属于本次送去墓地的「企鹅」怪兽
function c73640163.spfilter(c,e,tp,g)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE) and g:IsContains(c)
end
-- 效果①的发动准备（检查怪兽区域空位、是否存在可特殊召唤的对象、选择对象并设置操作信息）
function c73640163.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local g=eg:Filter(c73640163.cfilter,nil,tp)
	if chkc then return c73640163.spfilter(chkc,e,tp,g) end
	-- 检查自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在可以里侧守备表示特殊召唤的、本次被送去墓地的「企鹅」怪兽
		and Duel.IsExistingTarget(c73640163.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp,g) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择墓地中1只满足条件的「企鹅」怪兽作为效果对象
	local sg=Duel.SelectTarget(tp,c73640163.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp,g)
	-- 设置特殊召唤的操作信息（特殊召唤对象怪兽）
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,sg,1,0,0)
	-- 设置丢弃手牌的操作信息（丢弃这张卡）
	Duel.SetOperationInfo(0,CATEGORY_HANDES,e:GetHandler(),1,0,0)
end
-- 效果①的效果处理（将自身从手卡丢弃，并将对象怪兽里侧守备表示特殊召唤）
function c73640163.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果的对象怪兽
	local tc=Duel.GetFirstTarget()
	-- 检查这张卡是否仍存在于手卡，并将其作为效果丢弃送去墓地
	if c:IsRelateToEffect(e) and Duel.SendtoGrave(c,REASON_EFFECT+REASON_DISCARD)~=0
		-- 检查对象怪兽是否仍符合条件，并将其在自己场上里侧守备表示特殊召唤
		and tc:IsRelateToEffect(e) and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)>0 then
		-- 让对方玩家确认里侧表示特殊召唤的怪兽
		Duel.ConfirmCards(1-tp,tc)
	end
end
-- 过滤自己场上表侧表示的「企鹅」怪兽
function c73640163.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x5a)
end
-- 效果②的发动准备（选择自己场上1只表侧表示的「企鹅」怪兽作为对象，并设置回复基本分的操作信息）
function c73640163.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c73640163.filter(chkc) end
	-- 检查自己场上是否存在表侧表示的「企鹅」怪兽
	if chk==0 then return Duel.IsExistingTarget(c73640163.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择自己场上1只表侧表示的「企鹅」怪兽作为效果对象
	Duel.SelectTarget(tp,c73640163.filter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置回复基本分的对象玩家为自己
	Duel.SetTargetPlayer(tp)
	-- 设置回复基本分的数值为600
	Duel.SetTargetParam(600)
	-- 设置回复基本分的操作信息
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,600)
end
-- 效果②的效果处理（使对象怪兽攻击力上升600，并回复自己600基本分）
function c73640163.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) and not tc:IsImmuneToEffect(e) then
		-- 那只怪兽的攻击力直到回合结束时上升600
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(600)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 获取当前连锁设定的回复对象玩家和回复数值
		local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
		-- 执行回复基本分的效果
		Duel.Recover(p,d,REASON_EFFECT)
	end
end
