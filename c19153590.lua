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
-- 过滤函数，用于判断手卡中是否满足条件的龙族怪兽（风属性或7星以上）
function c19153590.cfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsRace(RACE_DRAGON) and c:IsAbleToGraveAsCost()
		and (c:IsAttribute(ATTRIBUTE_WIND) or c:IsLevelAbove(7))
end
-- 检查手卡中是否存在满足条件的龙族怪兽并将其丢弃作为费用
function c19153590.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡中是否存在满足条件的龙族怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c19153590.cfilter,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 将满足条件的龙族怪兽从手卡丢弃作为费用
	Duel.DiscardHand(tp,c19153590.cfilter,1,1,REASON_COST,e:GetHandler())
end
-- 判断是否可以将此卡特殊召唤
function c19153590.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断场上是否有足够的空间进行特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤的连锁操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 执行特殊召唤操作
function c19153590.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将此卡特殊召唤到场上
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- 过滤函数，用于判断手卡或卡组中是否满足条件的「武装龙」怪兽（非打桩武装龙）
function c19153590.tgfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x111) and not c:IsCode(19153590) and c:IsAbleToGraveAsCost()
end
-- 检查手卡或卡组中是否存在满足条件的「武装龙」怪兽并将其丢弃作为费用
function c19153590.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡或卡组中是否存在满足条件的「武装龙」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c19153590.tgfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择满足条件的「武装龙」怪兽并将其丢弃到墓地
	local tg=Duel.SelectMatchingCard(tp,c19153590.tgfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,1,nil)
	-- 将选择的「武装龙」怪兽送去墓地
	Duel.SendtoGrave(tg,REASON_COST)
	e:SetLabelObject(tg:GetFirst())
end
-- 判断是否可以选取场上表侧表示的怪兽作为对象
function c19153590.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and chkc:IsFaceup() end
	-- 检查场上是否存在表侧表示的怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择表侧表示的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择场上表侧表示的怪兽作为对象
	local g=Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置攻击力变化的连锁操作信息
	Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,g,1,0,0)
end
-- 执行效果操作，使对象怪兽攻击力上升并限制攻击次数
function c19153590.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	local tgc=e:GetLabelObject()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 使目标怪兽的攻击力上升其等级×300
		local e0=Effect.CreateEffect(c)
		e0:SetType(EFFECT_TYPE_SINGLE)
		e0:SetCode(EFFECT_UPDATE_ATTACK)
		e0:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e0:SetValue(tgc:GetLevel()*300)
		tc:RegisterEffect(e0)
	end
	-- 注册攻击宣言时的连锁效果，用于记录攻击方的场ID
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetOperation(c19153590.checkop)
	-- 注册攻击宣言时的连锁效果
	Duel.RegisterEffect(e1,tp)
	-- 注册限制攻击的连锁效果
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetReset(RESET_PHASE+PHASE_END)
	e2:SetCondition(c19153590.atkcon)
	e2:SetTarget(c19153590.atktg)
	e1:SetLabelObject(e2)
	-- 注册限制攻击的连锁效果
	Duel.RegisterEffect(e2,tp)
end
-- 记录攻击方的场ID并设置标记
function c19153590.checkop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否已经注册过标记
	if Duel.GetFlagEffect(tp,19153590)~=0 then return end
	local fid=eg:GetFirst():GetFieldID()
	-- 注册标记效果
	Duel.RegisterFlagEffect(tp,19153590,RESET_PHASE+PHASE_END,0,1)
	e:GetLabelObject():SetLabel(fid)
end
-- 判断是否已注册标记
function c19153590.atkcon(e)
	-- 判断是否已注册标记
	return Duel.GetFlagEffect(e:GetHandlerPlayer(),19153590)>0
end
-- 判断目标怪兽是否为攻击方的怪兽
function c19153590.atktg(e,c)
	return c:GetFieldID()~=e:GetLabel()
end
