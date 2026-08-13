--パイル・アームド・ドラゴン
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：把风属性或者7星以上的1只这张卡以外的龙族怪兽从手卡送去墓地才能发动。这张卡从手卡特殊召唤。
-- ②：从手卡·卡组把「打桩武装龙」以外的1只「武装龙」怪兽送去墓地，以自己场上1只表侧表示怪兽为对象才能发动。这个回合，自己只能用1只怪兽攻击，作为对象的怪兽的攻击力上升送去墓地的怪兽的等级×300。
function c19153590.initial_effect(c)
	-- ①：把风属性或者7星以上的1只这张卡以外的龙族怪兽从手卡送去墓地才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(19153590,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,19153590)
	e1:SetCost(c19153590.spcost)
	e1:SetTarget(c19153590.sptg)
	e1:SetOperation(c19153590.spop)
	c:RegisterEffect(e1)
	-- ②：从手卡·卡组把「打桩武装龙」以外的1只「武装龙」怪兽送去墓地，以自己场上1只表侧表示怪兽为对象才能发动。这个回合，自己只能用1只怪兽攻击，作为对象的怪兽的攻击力上升送去墓地的怪兽的等级×300。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(19153590,1))
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,19153591)
	e2:SetCost(c19153590.cost)
	e2:SetTarget(c19153590.target)
	e2:SetOperation(c19153590.operation)
	c:RegisterEffect(e2)
end
-- 定义①代价的过滤条件：需为龙族怪兽、可作为代价送去墓地，且为风属性或7星以上。
function c19153590.cfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsRace(RACE_DRAGON) and c:IsAbleToGraveAsCost()
		and (c:IsAttribute(ATTRIBUTE_WIND) or c:IsLevelAbove(7))
end
-- ①的代价处理：检查手卡是否存在满足条件的龙族怪兽（排除自身），再丢弃1张作为发动代价。
function c19153590.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价合法性检查：确认手卡中存在至少1张满足cfilter且不是本卡的龙族怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c19153590.cfilter,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 执行丢弃代价：玩家从手卡选择1张满足条件的龙族怪兽送去墓地。
	Duel.DiscardHand(tp,c19153590.cfilter,1,1,REASON_COST,e:GetHandler())
end
-- ①的发动目标：确认自己主要怪兽区有空位且这张卡可以被特殊召唤。
function c19153590.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的主要怪兽区域空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：本次效果处理时将特殊召唤这张卡。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①的效果处理：确认这张卡仍与效果关联后，将其从手卡特殊召唤到自己场上。
function c19153590.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将这张卡以表侧表示特殊召唤到自己场上。
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- 定义②代价的过滤条件：怪兽、属于「武装龙」字段、不是「打桩武装龙」本身、可作为代价送去墓地。
function c19153590.tgfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x111) and not c:IsCode(19153590) and c:IsAbleToGraveAsCost()
end
-- ②的代价处理：从手卡·卡组选择1张「打桩武装龙」以外的「武装龙」怪兽送去墓地，并将其记录为标签对象。
function c19153590.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价合法性检查：确认手卡或卡组中存在至少1张满足tgfilter的「武装龙」怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c19153590.tgfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil) end
	-- 显示选择提示，要求玩家选择1张要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 玩家从自己的手卡·卡组中选择1张满足条件的「武装龙」怪兽。
	local tg=Duel.SelectMatchingCard(tp,c19153590.tgfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,1,nil)
	-- 将所选卡送去墓地，作为发动代价。
	Duel.SendtoGrave(tg,REASON_COST)
	e:SetLabelObject(tg:GetFirst())
end
-- ②的发动目标：选择自己场上1张表侧表示怪兽作为对象，并设置攻击力变化操作信息。
function c19153590.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and chkc:IsFaceup() end
	-- 检查自己场上是否存在至少1张可以成为对象的表侧表示怪兽。
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,0,1,nil) end
	-- 显示选择提示，要求玩家选择表侧表示的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择自己场上1张表侧表示怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置操作信息：本次连锁将改变对象怪兽的攻击力。
	Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,g,1,0,0)
end
-- ②的效果处理：给对象怪兽附加攻击力上升效果，上升值为代价怪兽等级×300；并设置本回合只能有1只怪兽攻击的限制。
function c19153590.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得效果发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	local tgc=e:GetLabelObject()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 作为对象的怪兽的攻击力上升送去墓地的怪兽的等级×300。
		local e0=Effect.CreateEffect(c)
		e0:SetType(EFFECT_TYPE_SINGLE)
		e0:SetCode(EFFECT_UPDATE_ATTACK)
		e0:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e0:SetValue(tgc:GetLevel()*300)
		tc:RegisterEffect(e0)
	end
	-- 这个回合，自己只能用1只怪兽攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetOperation(c19153590.checkop)
	-- 将攻击宣言的监听效果注册到环境中，用于记录本回合首次攻击宣言的怪兽。
	Duel.RegisterEffect(e1,tp)
	-- 这个回合，自己只能用1只怪兽攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetReset(RESET_PHASE+PHASE_END)
	e2:SetCondition(c19153590.atkcon)
	e2:SetTarget(c19153590.atktg)
	e1:SetLabelObject(e2)
	-- 将限制攻击宣言的效果注册到环境中，使非首次攻击宣言的怪兽不能攻击。
	Duel.RegisterEffect(e2,tp)
end
-- 攻击宣言时点的记录函数：若本回合尚未记录，则记录首次攻击宣言怪兽的FieldID并设置标识。
function c19153590.checkop(e,tp,eg,ep,ev,re,r,rp)
	-- 如果本回合已经记录过标识，则不再重复处理。
	if Duel.GetFlagEffect(tp,19153590)~=0 then return end
	local fid=eg:GetFirst():GetFieldID()
	-- 为玩家注册一个回合标识，表示本回合已限制过攻击次数。
	Duel.RegisterFlagEffect(tp,19153590,RESET_PHASE+PHASE_END,0,1)
	e:GetLabelObject():SetLabel(fid)
end
-- 限制攻击宣言效果的发动条件：仅在本回合已设置攻击限制标识时生效。
function c19153590.atkcon(e)
	-- 判断玩家本回合是否已存在攻击限制标识。
	return Duel.GetFlagEffect(e:GetHandlerPlayer(),19153590)>0
end
-- 若尝试攻击的怪兽不是本回合首次攻击宣言的怪兽，则禁止其攻击宣言。
function c19153590.atktg(e,c)
	return c:GetFieldID()~=e:GetLabel()
end
