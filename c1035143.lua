--ダークリボー
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己场上的恶魔族怪兽或融合怪兽成为攻击·效果的对象时，把这张卡从手卡丢弃，以那之内的1只为对象才能发动。这个回合，那只怪兽不会被战斗·效果破坏，那只怪兽在场上发动的效果不会被无效化。
-- ②：这张卡被效果从手卡送去墓地的场合才能发动。从自己的卡组·墓地把1张「融合」加入手卡。
local s,id,o=GetID()
-- 初始化卡片效果
function s.initial_effect(c)
	-- 将「融合」加入此卡的关联卡片列表中
	aux.AddCodeList(c,24094653)
	-- ①：自己场上的恶魔族怪兽或融合怪兽成为攻击·效果的对象时，把这张卡从手卡丢弃，以那之内的1只为对象才能发动。这个回合，那只怪兽不会被战斗·效果破坏，那只怪兽在场上发动的效果不会被无效化。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"抗性"
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
	e3:SetDescription(aux.Stringid(id,1))  --"检索"
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
-- 过滤自己场上表侧表示的恶魔族怪兽或融合怪兽
function s.cfilter(c,tp)
	return c:IsFaceupEx() and c:IsControler(tp) and c:IsLocation(LOCATION_MZONE)
		and (c:IsRace(RACE_FIEND) or c:IsAllTypes(TYPE_FUSION+TYPE_MONSTER))
end
-- 效果发动条件：自己场上的恶魔族怪兽或融合怪兽成为效果对象
function s.indcon1(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp)
end
-- 效果发动条件：自己场上的恶魔族怪兽或融合怪兽被选择为攻击对象
function s.indcon2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取被攻击的怪兽
	local d=Duel.GetAttackTarget()
	return d and s.cfilter(d,tp)
end
-- 效果发动的代价
function s.indcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsDiscardable() end
	-- 将此卡从手卡丢弃送去墓地
	Duel.SendtoGrave(c,REASON_COST+REASON_DISCARD)
end
-- 过滤成为对象且满足条件的恶魔族怪兽或融合怪兽
function s.indfilter(c,g,tp)
	return g:IsContains(c) and s.cfilter(c,tp)
end
-- 效果发动的目标
function s.indtg1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return s.indfilter(chkc,eg,tp) end
	-- 检查自己场上是否存在符合条件的成为效果对象的怪兽
	if chk==0 then return Duel.IsExistingTarget(s.indfilter,tp,LOCATION_MZONE,0,1,nil,eg,tp) end
	-- 提示玩家选择表侧表示的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择自己场上1只符合条件的成为效果对象的怪兽作为对象
	Duel.SelectTarget(tp,s.indfilter,tp,LOCATION_MZONE,0,1,1,nil,eg,tp)
end
-- 效果发动的目标
function s.indtg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 获取被攻击的对象
	local tg=Duel.GetAttackTarget()
	if chkc then return chkc==tg end
	if chk==0 then return tg:IsOnField() and tg:IsCanBeEffectTarget(e) end
	-- 将该被攻击的怪兽设定为效果的对象
	Duel.SetTargetCard(tg)
end
-- 效果发动的具体操作
function s.indop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsType(TYPE_MONSTER) then
		tc:RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,2))  --"「暗黑栗子球」效果适用中"
		tc:RegisterFlagEffect(id,RESET_EVENT+RESET_TOFIELD+RESET_PHASE+PHASE_END,0,1)
		-- 这个回合，那只怪兽不会被战斗·效果破坏
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
		-- 那只怪兽在场上发动的效果不会被无效化。/ ②：这张卡被效果从手卡送去墓地的场合才能发动。从自己的卡组·墓地把1张「融合」加入手卡。
		local e3=Effect.CreateEffect(e:GetHandler())
		e3:SetType(EFFECT_TYPE_FIELD)
		e3:SetCode(EFFECT_CANNOT_DISEFFECT)
		e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CAN_FORBIDDEN)
		e3:SetValue(s.effectfilter)
		e3:SetLabelObject(tc)
		e3:SetReset(RESET_PHASE+PHASE_END)
		-- 注册全局效果：无法无效化该怪兽发动的效果
		Duel.RegisterEffect(e3,tp)
	end
end
-- 过滤判断该怪兽发动的效果且其处于怪兽区域
function s.effectfilter(e,ct)
	-- 获取触发的效果及触发的位置
	local te,loc=Duel.GetChainInfo(ct,CHAININFO_TRIGGERING_EFFECT,CHAININFO_TRIGGERING_LOCATION)
	local tc=e:GetLabelObject()
	return tc and tc==te:GetHandler() and bit.band(loc,LOCATION_MZONE)~=0
		and tc:GetFlagEffect(id)~=0
end
-- 效果发动条件：此卡因效果从手卡送去墓地
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_HAND) and bit.band(r,REASON_EFFECT)~=0
end
-- 过滤卡组或墓地中的「融合」
function s.thfilter(c)
	return c:IsCode(24094653) and c:IsAbleToHand()
end
-- 效果发动的目标
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己卡组或墓地是否存在「融合」
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	-- 设置操作信息：将卡组或墓地的1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
-- 效果发动的具体操作
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手卡的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组或墓地选择1张「融合」
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的「融合」加入手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家确认加入手卡的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
