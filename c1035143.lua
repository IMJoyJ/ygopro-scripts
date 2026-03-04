--ダークリボー
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己场上的恶魔族怪兽或融合怪兽成为攻击·效果的对象时，把这张卡从手卡丢弃，以那之内的1只为对象才能发动。这个回合，那只怪兽不会被战斗·效果破坏，那只怪兽在场上发动的效果不会被无效化。
-- ②：这张卡被效果从手卡送去墓地的场合才能发动。从自己的卡组·墓地把1张「融合」加入手卡。
local s,id,o=GetID()
-- 定义卡片初始化效果的函数。
function s.initial_effect(c)
	-- 为卡片注册“有卡片记述”的卡片代码列表，这里添加了“融合”魔法卡的卡号。
	aux.AddCodeList(c,24094653)
	-- ①：自己场上的恶魔族怪兽或融合怪兽成为攻击·效果的对象时，把这张卡从手卡丢弃，以那之内的1只为对象才能发动。这个回合，那只怪兽不会被战斗·效果破坏，那只怪兽在场上发动的效果不会被无效化。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_BECOME_TARGET)
	e1:SetRange(LOCATION_HAND)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.indcon1)
	e1:SetCost(s.indcost)
	e1:SetTarget(s.indtg1)
	e1:SetOperation(s.indop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_BE_BATTLE_TARGET)
	e2:SetCondition(s.indcon2)
	e2:SetTarget(s.indtg2)
	c:RegisterEffect(e2)
	-- ②：这张卡被效果从手卡送去墓地的场合才能发动。从自己的卡组·墓地把1张「融合」加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,id+o)
	e3:SetCondition(s.thcon)
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)
end
-- 定义过滤函数，检查卡片是否在己方场上表侧表示，且是恶魔族怪兽或融合怪兽。
function s.cfilter(c,tp)
	return c:IsFaceupEx() and c:IsControler(tp) and c:IsLocation(LOCATION_MZONE)
		and (c:IsRace(RACE_FIEND) or c:IsAllTypes(TYPE_FUSION+TYPE_MONSTER))
end
-- 检查事件中是否有己方场上的恶魔族或融合怪兽成为效果对象。
function s.indcon1(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp)
end
-- 检查攻击目标是否是己方场上的恶魔族或融合怪兽。
function s.indcon2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前攻击的目标怪兽。
	local d=Duel.GetAttackTarget()
	return d and s.cfilter(d,tp)
end
-- 定义效果发动的成本函数，检查并执行丢弃手牌中的这张卡。
function s.indcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsDiscardable() end
	-- 将这张卡从手牌丢弃送去墓地作为发动成本。
	Duel.SendtoGrave(c,REASON_COST+REASON_DISCARD)
end
-- 定义过滤函数，从事件组中选择己方场上满足条件的怪兽作为效果对象。
function s.indfilter(c,g,tp)
	return g:IsContains(c) and s.cfilter(c,tp)
end
-- 定义效果的目标选择处理，让玩家选择己方场上成为效果对象的恶魔族或融合怪兽。
function s.indtg1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return s.indfilter(chkc,eg,tp) end
	-- 检查己方场上是否存在至少一只成为效果对象的恶魔族或融合怪兽。
	if chk==0 then return Duel.IsExistingTarget(s.indfilter,tp,LOCATION_MZONE,0,1,nil,eg,tp) end
	-- 提示玩家选择表侧表示的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	-- 让玩家从己方场上选择一只成为效果对象的恶魔族或融合怪兽作为效果对象。
	Duel.SelectTarget(tp,s.indfilter,tp,LOCATION_MZONE,0,1,1,nil,eg,tp)
end
-- 定义效果的目标选择处理，直接以攻击目标为对象。
function s.indtg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 获取当前攻击的目标怪兽。
	local tg=Duel.GetAttackTarget()
	if chkc then return chkc==tg end
	if chk==0 then return tg:IsOnField() and tg:IsCanBeEffectTarget(e) end
	-- 将攻击目标设置为效果的对象。
	Duel.SetTargetCard(tg)
end
-- 定义效果处理的操作，为目标怪兽赋予不被战斗·效果破坏和效果不被无效化的效果。
function s.indop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果处理的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsType(TYPE_MONSTER) then
		tc:RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,2))
		tc:RegisterFlagEffect(id,RESET_EVENT+RESET_TOFIELD+RESET_PHASE+PHASE_END,0,1)
		-- 不会被战斗破坏。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_SET_AVAILABLE)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
		tc:RegisterEffect(e2)
		-- 那只怪兽在场上发动的效果不会被无效化。
		local e3=Effect.CreateEffect(e:GetHandler())
		e3:SetType(EFFECT_TYPE_FIELD)
		e3:SetCode(EFFECT_CANNOT_DISEFFECT)
		e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CAN_FORBIDDEN)
		e3:SetValue(s.effectfilter)
		e3:SetLabelObject(tc)
		e3:SetReset(RESET_PHASE+PHASE_END)
		-- 将赋予效果不被无效化的效果注册到玩家。
		Duel.RegisterEffect(e3,tp)
	end
end
-- 定义过滤函数，检查连锁中的效果是否由目标怪兽在场上发动。
function s.effectfilter(e,ct)
	-- 获取指定连锁的触发效果和触发位置。
	local te,loc=Duel.GetChainInfo(ct,CHAININFO_TRIGGERING_EFFECT,CHAININFO_TRIGGERING_LOCATION)
	local tc=e:GetLabelObject()
	return tc and tc==te:GetHandler() and bit.band(loc,LOCATION_MZONE)~=0
		and tc:GetFlagEffect(id)~=0
end
-- 检查卡片是否从手牌被效果送去墓地。
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_HAND) and bit.band(r,REASON_EFFECT)~=0
end
-- 定义过滤函数，检查卡片是否是“融合”魔法卡且可以加入手牌。
function s.thfilter(c)
	return c:IsCode(24094653) and c:IsAbleToHand()
end
-- 定义效果的目标选择处理，检查并设置操作信息。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组或墓地中是否存在可以加入手牌的“融合”魔法卡。
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	-- 设置效果操作信息，表示将从卡组或墓地加入手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
-- 定义效果处理的操作，从卡组或墓地检索“融合”魔法卡加入手牌。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	-- 让玩家从卡组或墓地选择一张“融合”魔法卡加入手牌，考虑王家长眠之谷的影响。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的“融合”魔法卡加入手牌。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示加入手牌的卡片。
		Duel.ConfirmCards(1-tp,g)
	end
end
