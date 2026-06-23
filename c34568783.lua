--レアル・ジェネクス・ウンディーネ
-- 效果：
-- ①：1回合1次，从自己墓地把1只「次世代」怪兽除外才能发动。这张卡的属性也当作和那只怪兽相同属性使用。把调整除外发动的场合，可以再把这张卡直到回合结束时当作调整使用。
-- ②：自己场上有「次世代」同调怪兽存在的场合，以包含这张卡的自己墓地2只「次世代」怪兽为对象才能发动。那些怪兽加入手卡。这个回合，被送去自己墓地的卡不去墓地而除外。
local s,id,o=GetID()
-- 注册两个效果：①变更属性效果和②墓地回收效果
function s.initial_effect(c)
	-- ①：1回合1次，从自己墓地把1只「次世代」怪兽除外才能发动。这张卡的属性也当作和那只怪兽相同属性使用。把调整除外发动的场合，可以再把这张卡直到回合结束时当作调整使用。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"变更属性"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(s.cgcost)
	e1:SetOperation(s.cgop)
	c:RegisterEffect(e1)
	-- ②：自己场上有「次世代」同调怪兽存在的场合，以包含这张卡的自己墓地2只「次世代」怪兽为对象才能发动。那些怪兽加入手卡。这个回合，被送去自己墓地的卡不去墓地而除外。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"墓地回收"
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCondition(s.thcon)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于检测墓地中的「次世代」怪兽是否可以被除外并用于变更属性
function s.cgfilter(c,mc)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x2) and c:IsAbleToRemove() and not c:IsAttribute(mc:GetAttribute())
end
-- cost函数，检查是否有满足条件的「次世代」怪兽可以除外，并选择一张进行除外操作
function s.cgcost(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 检查是否有满足条件的「次世代」怪兽可以除外
	if chk==0 then return Duel.IsExistingMatchingCard(s.cgfilter,tp,LOCATION_GRAVE,0,1,nil,e:GetHandler()) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择一张满足条件的「次世代」怪兽进行除外
	local g=Duel.SelectMatchingCard(tp,s.cgfilter,tp,LOCATION_GRAVE,0,1,1,nil,e:GetHandler())
	-- 将选中的卡除外
	Duel.Remove(g,POS_FACEUP,REASON_COST)
	local rc=g:GetFirst()
	local tuner=rc:IsType(TYPE_TUNER) and 1 or 0
	e:SetLabel(rc:GetAttribute(),tuner)
end
-- op函数，根据除外的卡的属性变更自身属性，若为调整则可选择是否当作调整使用
function s.cgop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not (c:IsFaceup() and c:IsRelateToEffect(e)) then return end
	local att,tuner=e:GetLabel()
	if c:IsAttribute(att) then return end
	-- 增加自身属性
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_ADD_ATTRIBUTE)
	e1:SetValue(att)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
	c:RegisterEffect(e1)
	if tuner==1 and not c:IsType(TYPE_TUNER)
		-- 询问玩家是否将自身当作调整使用
		and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否把这张卡当作调整使用？"
		-- 中断当前效果处理，使后续效果视为不同时处理
		Duel.BreakEffect()
		-- 将自身添加为调整类型
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetCode(EFFECT_ADD_TYPE)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e2:SetValue(TYPE_TUNER)
		c:RegisterEffect(e2)
	end
end
-- 过滤函数，用于检测场上是否有「次世代」同调怪兽
function s.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x2) and c:IsType(TYPE_SYNCHRO)
end
-- 条件函数，检查场上是否存在「次世代」同调怪兽
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否存在「次世代」同调怪兽
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 过滤函数，用于检测墓地中的「次世代」怪兽是否可以加入手牌
function s.tgfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x2) and c:IsAbleToHand()
end
-- target函数，设置目标卡为墓地中的「次世代」怪兽
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.tgfilter(chkc) and chkc~=c end
	-- 检查是否有满足条件的墓地中的「次世代」怪兽可以作为目标
	if chk==0 then return Duel.IsExistingTarget(s.tgfilter,tp,LOCATION_GRAVE,0,1,c)
		and c:IsAbleToHand() and c:IsCanBeEffectTarget(e) end
	-- 提示玩家选择要返回手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择一张满足条件的墓地中的「次世代」怪兽作为目标
	local g=Duel.SelectTarget(tp,s.tgfilter,tp,LOCATION_GRAVE,0,1,1,c)
	-- 设置当前效果的目标卡为自身
	Duel.SetTargetCard(c)
	g:AddCard(c)
	-- 设置操作信息，表示将目标卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,2,0,0)
end
-- op函数，将目标卡加入手牌，并设置效果使本回合被送去墓地的卡除外
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标卡组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local sg=g:Filter(Card.IsRelateToEffect,nil,e)
	if sg:GetCount()>0 then
		-- 将目标卡加入手牌
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
	end
	-- 设置效果使本回合被送去墓地的卡除外
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_RANGE+EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetCode(EFFECT_TO_GRAVE_REDIRECT)
	e1:SetTargetRange(0xff,0xfe)
	e1:SetTarget(s.rmtg)
	e1:SetValue(LOCATION_REMOVED)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册效果，使本回合被送去墓地的卡除外
	Duel.RegisterEffect(e1,tp)
end
-- target函数，判断卡是否为当前玩家所有
function s.rmtg(e,c)
	local tp=e:GetHandlerPlayer()
	return c:GetOwner()==tp
end
