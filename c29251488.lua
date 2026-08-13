--シェフ・ド・ヌーベルズ
-- 效果：
-- ←0 【灵摆】 0→
-- 这个卡名的①②的灵摆效果1回合各能使用1次。
-- ①：这张卡发动的回合的自己主要阶段才能发动。从卡组把灵摆怪兽以外的1张「新式魔厨」卡加入手卡。
-- ②：对方场上有怪兽特殊召唤的场合才能发动。这张卡特殊召唤。
-- 【怪兽效果】
-- 这个卡名的①②的怪兽效果在同一连锁上不能发动。
-- ①：自己·对方回合1次，以场上1只效果怪兽为对象才能发动。那只怪兽的等级上升最多3星。
-- ②：1回合1次，对方把怪兽特殊召唤的场合，从自己的手卡·卡组·墓地把1张「食谱」仪式魔法卡除外才能发动。那张仪式魔法卡发动时的仪式召唤效果适用。
-- ③：场上的这张卡被解放以表侧加入额外卡组的场合才能发动。这张卡在自己的灵摆区域放置。
local s,id,o=GetID()
-- 初始化该卡的所有效果：附加灵摆怪兽属性，并依次注册手牌发动、灵摆区检索、灵摆区自跳、怪兽区等级上升、怪兽区仪式效果适用、表侧加入额外卡组后放置灵摆区等效果。
function s.initial_effect(c)
	-- 为这张卡附加灵摆怪兽属性（灵摆召唤、可作为灵摆卡放置在灵摆区），但不自动注册灵摆卡“从手卡发动”的效果，该效果由e0另行实现。
	aux.EnablePendulumAttribute(c,false)
	-- 对应“这张卡发动的回合的自己主要阶段才能发动。”：注册灵摆卡从手卡发动的效果，发动时通过cost登记本回合已发动的标记。
	local e0=Effect.CreateEffect(c)
	e0:SetDescription(1160)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	e0:SetRange(LOCATION_HAND)
	e0:SetCost(s.reg)
	c:RegisterEffect(e0)
	-- ①：这张卡发动的回合的自己主要阶段才能发动。从卡组把灵摆怪兽以外的1张「新式魔厨」卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"检索"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.thcon)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	-- ②：对方场上有怪兽特殊召唤的场合才能发动。这张卡特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"这张卡特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_PZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.spcon1)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	-- ①：自己·对方回合1次，以场上1只效果怪兽为对象才能发动。那只怪兽的等级上升最多3星。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))  --"等级上升"
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END+TIMING_END_PHASE)
	e3:SetCountLimit(1)
	e3:SetTarget(s.lvtg)
	e3:SetOperation(s.lvop)
	c:RegisterEffect(e3)
	-- ②：1回合1次，对方把怪兽特殊召唤的场合，从自己的手卡·卡组·墓地把1张「食谱」仪式魔法卡除外才能发动。那张仪式魔法卡发动时的仪式召唤效果适用。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,3))  --"适用效果"
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1)
	e4:SetCondition(s.rspcon)
	e4:SetTarget(s.rsptg)
	e4:SetOperation(s.rspop)
	c:RegisterEffect(e4)
	-- ③：场上的这张卡被解放以表侧加入额外卡组的场合才能发动。这张卡在自己的灵摆区域放置。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,4))  --"在灵摆区域放置"
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e5:SetCode(EVENT_TO_DECK)
	e5:SetProperty(EFFECT_FLAG_DELAY)
	e5:SetCondition(s.pzcon)
	e5:SetTarget(s.pztg)
	e5:SetOperation(s.pzop)
	c:RegisterEffect(e5)
end
-- 作为灵摆卡发动时的cost：给这张卡注册一个本回合已发动过的标记（OATH），持续到回合结束，用于判断“这张卡发动的回合”。
function s.reg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,EFFECT_FLAG_OATH,1)
end
-- 检索效果发动条件：检查这张卡是否拥有“本回合已发动”的标记，即满足“这张卡发动的回合”这一条件。
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(id)~=0
end
-- 定义检索目标的条件：不是灵摆怪兽、属于「新式魔厨」系列、且能够加入手牌。
function s.thfilter(c)
	return not c:IsAllTypes(TYPE_PENDULUM+TYPE_MONSTER) and c:IsSetCard(0x196) and c:IsAbleToHand()
end
-- 检索效果的目标处理：确认卡组中存在符合条件的检索对象，并设置操作信息为“从卡组加入手牌”。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 合法性检查：卡组中是否存在至少1张满足s.thfilter的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：本效果将把卡组中的1张卡加入手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 执行检索：提示玩家选择1张符合条件的「新式魔厨」卡加入手牌，并让对方确认检索到的卡。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 弹出选择提示，让玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选出1张满足s.thfilter的卡。
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入其持有者的手牌。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方展示本次检索加入手牌的卡。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 灵摆②的触发条件：特殊召唤成功的怪兽中有控制者为对方的怪兽，即“对方场上有怪兽特殊召唤”。
function s.spcon1(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsControler,1,nil,1-tp)
end
-- 特殊召唤效果的发动条件：自己主要怪兽区有空位，且这张卡自身能够被特殊召唤。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己主要怪兽区是否存在可用区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：本效果将会把这张卡特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 执行特殊召唤：若此卡仍与当前连锁有联系，则特殊召唤自身。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() then
		-- 以表侧表示将这张卡特殊召唤到自己场上。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 定义可作为等级上升对象的条件：表侧表示的效果怪兽且等级大于0。
function s.cfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_EFFECT) and c:GetLevel()>0
end
-- 等级上升效果的目标处理：确认一回合一次限制、场上存在合法对象，并选择对象。
function s.lvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.cfilter(chkc) end
	-- 检查本回合是否尚未使用过此效果（1回合1次限制）。
	if chk==0 then return Duel.GetFlagEffect(tp,id+o)==0
		-- 检查场上是否存在满足条件的对象。
		and Duel.IsExistingTarget(s.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 注册本连锁上已使用过怪兽①效果的标记，用于实现“①②的怪兽效果在同一连锁上不能发动”。
	Duel.RegisterFlagEffect(tp,id,RESET_CHAIN,0,1)
	-- 提示玩家选择效果对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择场上1只表侧表示的效果怪兽作为效果对象。
	Duel.SelectTarget(tp,s.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
-- 处理等级上升：获取对象，若仍合法，宣言上升1~3星，并给对象赋予等级上升效果。
function s.lvop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁处理中的效果对象。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() and tc:IsFaceup() and tc:IsType(TYPE_MONSTER) then
		local ct={1,2,3}
		-- 提示玩家宣言要上升的等级数。
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,5))  --"请选择要上升的等级"
		-- 玩家宣言1、2或3，决定上升的星数。
		local ac=Duel.AnnounceNumber(tp,table.unpack(ct))
		-- 那只怪兽的等级上升最多3星。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(ac)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
-- 怪兽②的触发条件：特殊召唤成功的怪兽中存在由对方玩家特殊召唤的怪兽，即“对方把怪兽特殊召唤”。
function s.rspcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsSummonPlayer,1,nil,1-tp)
end
-- 定义可除外的cost条件：手卡·卡组·墓地中的「食谱」仪式魔法卡，且该卡能够发动仪式召唤效果并可作为cost除外。
function s.rfilter(c)
	return c:IsSetCard(0x197) and c:IsAllTypes(TYPE_RITUAL+TYPE_SPELL) and c:CheckActivateEffect(false,true,false)~=nil and c:IsAbleToRemoveAsCost()
end
-- 怪兽②的发动条件：未在本连锁上使用过互相限制的另一效果，且存在符合条件的「食谱」仪式魔法卡可作为cost。
function s.rsptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	-- 检查本连锁上是否未使用过互相限制的另一个怪兽效果（flag id为0）。
	if chk==0 then return e:IsCostChecked() and Duel.GetFlagEffect(tp,id)==0
		-- 检查手卡·卡组·墓地中是否存在至少1张符合条件的「食谱」仪式魔法卡。
		and Duel.IsExistingMatchingCard(s.rfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	-- 注册本连锁上已使用过怪兽②效果的标记，用于实现“①②的怪兽效果在同一连锁上不能发动”。
	Duel.RegisterFlagEffect(tp,id+o,RESET_CHAIN,0,1)
	-- 提示玩家选择要除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从手卡·卡组·墓地选择1张符合条件的「食谱」仪式魔法卡。
	local g=Duel.SelectMatchingCard(tp,s.rfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	local te,ceg,cep,cev,cre,cr,crp=g:GetFirst():CheckActivateEffect(false,true,true)
	-- 将选中的卡表侧除外，作为发动cost。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
	e:SetProperty(te:GetProperty())
	local tg=te:GetTarget()
	if tg then tg(e,tp,ceg,cep,cev,cre,cr,crp,1) end
	te:SetLabelObject(e:GetLabelObject())
	e:SetLabelObject(te)
	-- 清除当前连锁的操作信息，使接下来适用的仪式魔法卡的效果不会被无关卡的效果响应。
	Duel.ClearOperationInfo(0)
end
-- 执行“那张仪式魔法卡发动时的仪式召唤效果适用”：取出保存的仪式效果并执行其效果处理。
function s.rspop(e,tp,eg,ep,ev,re,r,rp)
	local te=e:GetLabelObject()
	if not te then return end
	e:SetLabelObject(te:GetLabelObject())
	local op=te:GetOperation()
	if op then op(e,tp,eg,ep,ev,re,r,rp) end
end
-- 怪兽③的触发条件：此卡从场上被解放后表侧表示进入额外卡组。
function s.pzcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsReason(REASON_RELEASE) and c:IsLocation(LOCATION_EXTRA)
		and c:IsFaceup()
end
-- 放置灵摆区的发动条件：自己的灵摆区域存在空位。
function s.pztg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己的灵摆区左/右任一格是否为空。
	if chk==0 then return Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1) end
end
-- 执行放置灵摆区：若此卡仍与连锁相关，则将其移动到自己的灵摆区。
function s.pzop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() then
		-- 以表侧表示将这张卡移动到自己的灵摆区。
		Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end
