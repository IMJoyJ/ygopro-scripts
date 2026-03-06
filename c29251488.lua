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
-- 初始化卡片效果，设置灵摆属性并注册5个效果
function s.initial_effect(c)
	-- 为卡片添加灵摆怪兽属性，不注册灵摆卡发动效果
	aux.EnablePendulumAttribute(c,false)
	-- ①：这张卡发动的回合的自己主要阶段才能发动。从卡组把灵摆怪兽以外的1张「新式魔厨」卡加入手卡。
	local e0=Effect.CreateEffect(c)
	e0:SetDescription(1160)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	e0:SetRange(LOCATION_HAND)
	e0:SetCost(s.reg)
	c:RegisterEffect(e0)
	-- ②：对方场上有怪兽特殊召唤的场合才能发动。这张卡特殊召唤。
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
	-- ①：自己·对方回合1次，以场上1只效果怪兽为对象才能发动。那只怪兽的等级上升最多3星。
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
	-- ②：1回合1次，对方把怪兽特殊召唤的场合，从自己的手卡·卡组·墓地把1张「食谱」仪式魔法卡除外才能发动。那张仪式魔法卡发动时的仪式召唤效果适用。
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
	-- ③：场上的这张卡被解放以表侧加入额外卡组的场合才能发动。这张卡在自己的灵摆区域放置。
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
	-- 注册灵摆区域的发动效果
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
-- 设置灵摆区域发动的费用，记录标识效果
function s.reg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,EFFECT_FLAG_OATH,1)
end
-- 判断是否满足灵摆区域发动条件
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(id)~=0
end
-- 检索过滤函数，筛选非灵摆怪兽的「新式魔厨」卡
function s.thfilter(c)
	return not c:IsAllTypes(TYPE_PENDULUM+TYPE_MONSTER) and c:IsSetCard(0x196) and c:IsAbleToHand()
end
-- 设置检索效果的目标和操作信息
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足检索条件
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置检索效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 执行检索效果，选择并加入手牌
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的卡
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 确认对方查看加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 判断是否满足特殊召唤条件
function s.spcon1(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsControler,1,nil,1-tp)
end
-- 设置特殊召唤效果的目标和操作信息
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足特殊召唤条件
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 执行特殊召唤效果
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() then
		-- 将卡片特殊召唤到场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 等级上升效果的过滤函数
function s.cfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_EFFECT) and c:GetLevel()>0
end
-- 设置等级上升效果的目标和操作信息
function s.lvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.cfilter(chkc) end
	-- 判断是否满足等级上升条件
	if chk==0 then return Duel.GetFlagEffect(tp,id+o)==0
		-- 判断是否满足等级上升条件
		and Duel.IsExistingTarget(s.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 注册等级上升效果的标识
	Duel.RegisterFlagEffect(tp,id,RESET_CHAIN,0,1)
	-- 提示玩家选择等级上升对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择等级上升对象
	Duel.SelectTarget(tp,s.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
-- 执行等级上升效果
function s.lvop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取等级上升对象
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() and tc:IsFaceup() and tc:IsType(TYPE_MONSTER) then
		local ct={1,2,3}
		-- 提示玩家选择等级上升数量
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,5))  --"请选择要上升的等级"
		-- 选择等级上升数量
		local ac=Duel.AnnounceNumber(tp,table.unpack(ct))
		-- 设置等级上升效果
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(ac)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
-- 判断是否满足仪式魔法效果条件
function s.rspcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsSummonPlayer,1,nil,1-tp)
end
-- 仪式魔法卡的过滤函数
function s.rfilter(c)
	return c:IsSetCard(0x197) and c:IsAllTypes(TYPE_RITUAL+TYPE_SPELL) and c:CheckActivateEffect(false,true,false)~=nil and c:IsAbleToRemoveAsCost()
end
-- 设置仪式魔法效果的目标和操作信息
function s.rsptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	-- 判断是否满足仪式魔法效果条件
	if chk==0 then return e:IsCostChecked() and Duel.GetFlagEffect(tp,id)==0
		-- 判断是否满足仪式魔法效果条件
		and Duel.IsExistingMatchingCard(s.rfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	-- 注册仪式魔法效果的标识
	Duel.RegisterFlagEffect(tp,id+o,RESET_CHAIN,0,1)
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择满足条件的仪式魔法卡
	local g=Duel.SelectMatchingCard(tp,s.rfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	local te,ceg,cep,cev,cre,cr,crp=g:GetFirst():CheckActivateEffect(false,true,true)
	-- 将卡除外作为仪式魔法效果的费用
	Duel.Remove(g,POS_FACEUP,REASON_COST)
	e:SetProperty(te:GetProperty())
	local tg=te:GetTarget()
	if tg then tg(e,tp,ceg,cep,cev,cre,cr,crp,1) end
	te:SetLabelObject(e:GetLabelObject())
	e:SetLabelObject(te)
	-- 清除当前连锁的操作信息
	Duel.ClearOperationInfo(0)
end
-- 执行仪式魔法效果
function s.rspop(e,tp,eg,ep,ev,re,r,rp)
	local te=e:GetLabelObject()
	if not te then return end
	e:SetLabelObject(te:GetLabelObject())
	local op=te:GetOperation()
	if op then op(e,tp,eg,ep,ev,re,r,rp) end
end
-- 判断是否满足灵摆区域放置条件
function s.pzcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsReason(REASON_RELEASE) and c:IsLocation(LOCATION_EXTRA)
		and c:IsFaceup()
end
-- 设置灵摆区域放置效果的目标和操作信息
function s.pztg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足灵摆区域放置条件
	if chk==0 then return Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1) end
end
-- 执行灵摆区域放置效果
function s.pzop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() then
		-- 将卡片移动到灵摆区域
		Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end
