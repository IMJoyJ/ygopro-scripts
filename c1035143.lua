--ダークリボー
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己场上的恶魔族怪兽或融合怪兽成为攻击·效果的对象时，把这张卡从手卡丢弃，以那之内的1只为对象才能发动。这个回合，那只怪兽不会被战斗·效果破坏，那只怪兽在场上发动的效果不会被无效化。
-- ②：这张卡被效果从手卡送去墓地的场合才能发动。从自己的卡组·墓地把1张「融合」加入手卡。
local s,id,o=GetID()
-- 初始化卡片效果，注册三个效果：①抗性效果（成为对象时）②抗性效果（被选为攻击对象时）③检索效果
function s.initial_effect(c)
	-- 为卡片注册关联卡片代码24094653（融合）
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
-- 过滤函数：判断目标怪兽是否为表侧表示、属于玩家、在主要怪兽区、且为恶魔族或融合怪兽
function s.cfilter(c,tp)
	return c:IsFaceupEx() and c:IsControler(tp) and c:IsLocation(LOCATION_MZONE)
		and (c:IsRace(RACE_FIEND) or c:IsAllTypes(TYPE_FUSION+TYPE_MONSTER))
end
-- 效果①的发动条件：确认是否有满足条件的怪兽成为效果对象
function s.indcon1(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp)
end
-- 效果②的发动条件：确认攻击目标是否满足条件
function s.indcon2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前攻击目标
	local d=Duel.GetAttackTarget()
	return d and s.cfilter(d,tp)
end
-- 效果①的发动费用：将此卡从手卡丢弃
function s.indcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsDiscardable() end
	-- 将此卡从手卡丢弃至墓地
	Duel.SendtoGrave(c,REASON_COST+REASON_DISCARD)
end
-- 过滤函数：判断目标是否在指定组中且满足cfilter条件
function s.indfilter(c,g,tp)
	return g:IsContains(c) and s.cfilter(c,tp)
end
-- 效果①的发动目标选择：选择满足条件的1只怪兽
function s.indtg1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return s.indfilter(chkc,eg,tp) end
	-- 检查是否有满足条件的怪兽可作为目标
	if chk==0 then return Duel.IsExistingTarget(s.indfilter,tp,LOCATION_MZONE,0,1,nil,eg,tp) end
	-- 提示玩家选择表侧表示的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择满足条件的1只怪兽作为目标
	Duel.SelectTarget(tp,s.indfilter,tp,LOCATION_MZONE,0,1,1,nil,eg,tp)
end
-- 效果②的发动目标选择：设置当前攻击目标为效果对象
function s.indtg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 获取当前攻击目标
	local tg=Duel.GetAttackTarget()
	if chkc then return chkc==tg end
	if chk==0 then return tg:IsOnField() and tg:IsCanBeEffectTarget(e) end
	-- 将攻击目标设置为效果对象
	Duel.SetTargetCard(tg)
end
-- 效果①的发动处理：为指定怪兽添加抗性效果
function s.indop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsType(TYPE_MONSTER) then
		tc:RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,2))  --"「暗黑栗子球」的效果适用中"
		tc:RegisterFlagEffect(id,RESET_EVENT+RESET_TOFIELD+RESET_PHASE+PHASE_END,0,1)
		-- 为指定怪兽添加不会被战斗破坏的效果
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
		-- 为指定怪兽添加不会被无效化的效果
		local e3=Effect.CreateEffect(e:GetHandler())
		e3:SetType(EFFECT_TYPE_FIELD)
		e3:SetCode(EFFECT_CANNOT_DISEFFECT)
		e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CAN_FORBIDDEN)
		e3:SetValue(s.effectfilter)
		e3:SetLabelObject(tc)
		e3:SetReset(RESET_PHASE+PHASE_END)
		-- 将效果注册到场上
		Duel.RegisterEffect(e3,tp)
	end
end
-- 无效化效果过滤函数：判断是否为指定怪兽在场上发动的效果
function s.effectfilter(e,ct)
	-- 获取当前连锁的效果和位置信息
	local te,loc=Duel.GetChainInfo(ct,CHAININFO_TRIGGERING_EFFECT,CHAININFO_TRIGGERING_LOCATION)
	local tc=e:GetLabelObject()
	return tc and tc==te:GetHandler() and bit.band(loc,LOCATION_MZONE)~=0
		and tc:GetFlagEffect(id)~=0
end
-- 效果②的发动条件：确认此卡是从手卡因效果送去墓地
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_HAND) and bit.band(r,REASON_EFFECT)~=0
end
-- 检索过滤函数：判断是否为融合卡
function s.thfilter(c)
	return c:IsCode(24094653) and c:IsAbleToHand()
end
-- 效果②的发动目标选择：确认卡组或墓地有融合卡
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组或墓地是否有融合卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	-- 设置效果②的处理信息：将1张融合卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
-- 效果②的发动处理：选择并加入手牌
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的1张融合卡
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
