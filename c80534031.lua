--ヴァーチュ・ストリーム
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：以自己场上1只鱼族·海龙族·水族怪兽和对方场上2张卡为对象才能发动。那些卡破坏。
-- ②：把墓地的这张卡除外，以场上1只表侧表示怪兽为对象才能发动。那只怪兽是水属性的场合，这个回合，作为对象的怪兽只有1次不会被效果破坏。那以外的场合，作为对象的怪兽变成水属性。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含①效果（场上卡片破坏）和②效果（墓地除外改变属性或赋予抗性）。
function s.initial_effect(c)
	-- ①：以自己场上1只鱼族·海龙族·水族怪兽和对方场上2张卡为对象才能发动。那些卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外，以场上1只表侧表示怪兽为对象才能发动。那只怪兽是水属性的场合，这个回合，作为对象的怪兽只有1次不会被效果破坏。那以外的场合，作为对象的怪兽变成水属性。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"改变属性或者赋予抗性"
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o)
	-- 设置发动效果的Cost为将墓地的这张卡除外。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.atttg)
	e2:SetOperation(s.attop)
	c:RegisterEffect(e2)
end
-- 过滤自己场上表侧表示的鱼族、水族或海龙族怪兽。
function s.desfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_FISH+RACE_AQUA+RACE_SEASERPENT)
end
-- ①效果的发动准备与对象选择，确认场上是否存在符合条件的自己怪兽和对方卡片。
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 检查自己场上是否存在至少1只表侧表示的鱼族·海龙族·水族怪兽。
	if chk==0 then return Duel.IsExistingTarget(s.desfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 检查对方场上是否存在至少2张卡。
		and Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_ONFIELD,2,nil) end
	-- 提示玩家选择要破坏的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择自己场上1只表侧表示的鱼族·海龙族·水族怪兽作为对象。
	local g1=Duel.SelectTarget(tp,s.desfilter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 提示玩家选择要破坏的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上2张卡作为对象。
	local g2=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,2,2,nil)
	g1:Merge(g2)
	-- 设置效果处理信息，包含破坏选定卡片的操作。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g1,g1:GetCount(),0,0)
end
-- ①效果的处理，将作为对象的卡片破坏。
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中作为对象的所有卡片。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local sg=g:Filter(Card.IsRelateToEffect,nil,e)
	-- 因效果将仍存在于场上且与效果相关的对象卡片破坏。
	Duel.Destroy(sg,REASON_EFFECT)
end
-- ②效果的发动准备与对象选择，确认场上是否存在表侧表示怪兽并将其选为对象。
function s.atttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	-- 检查场上是否存在至少1只表侧表示怪兽。
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择效果的对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择场上1只表侧表示怪兽作为对象。
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
-- ②效果的处理，根据对象怪兽的属性赋予1次效果破坏抗性或将其属性变更为水属性。
function s.attop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的怪兽。
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) or tc:IsFacedown() or not tc:IsType(TYPE_MONSTER) then return end
	if tc:IsAttribute(ATTRIBUTE_WATER) then
		-- 这个回合，作为对象的怪兽只有1次不会被效果破坏。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCountLimit(1)
		e1:SetValue(s.valcon)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	else
		-- 那以外的场合，作为对象的怪兽变成水属性。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_ATTRIBUTE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(ATTRIBUTE_WATER)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
-- 设定抗性判定条件，仅在因效果尝试破坏时适用。
function s.valcon(e,re,r,rp)
	return bit.band(r,REASON_EFFECT)~=0
end
