--レアル・ジェネクス・ウンディーネ
-- 效果：
-- ①：1回合1次，从自己墓地把1只「次世代」怪兽除外才能发动。这张卡的属性也当作和那只怪兽相同属性使用。把调整除外发动的场合，可以再把这张卡直到回合结束时当作调整使用。
-- ②：自己场上有「次世代」同调怪兽存在的场合，以包含这张卡的自己墓地2只「次世代」怪兽为对象才能发动。那些怪兽加入手卡。这个回合，被送去自己墓地的卡不去墓地而除外。
local s,id,o=GetID()
-- 定义本卡的初始效果注册函数，为这张卡创建并注册两个起动效果：①用于除外墓地“次世代”怪兽后变更属性（可选追加调整），②用于回收包含自身的墓地“次世代”怪兽并附加本回合送墓改为除外的效果。
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
-- 定义筛选函数：用于选择可以作为①发动代价除外的“次世代”怪兽，要求是怪兽、属于「次世代」字段、能够除外，且其属性与这张卡当前属性不同（否则属性变更无意义）。
function s.cgfilter(c,mc)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x2) and c:IsAbleToRemove() and not c:IsAttribute(mc:GetAttribute())
end
-- ①效果的发动代价处理：检查墓地是否存在合格对象；若存在则提示玩家选择1只“次世代”怪兽表侧除外，并将该怪兽的属性与“是否为调整”存入效果标签，供处理阶段使用。
function s.cgcost(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 发动代价的合法性检查：在代价检查阶段（chk==0）时，确认自己墓地存在至少1张符合s.cgfilter条件的“次世代”怪兽，才允许发动。
	if chk==0 then return Duel.IsExistingMatchingCard(s.cgfilter,tp,LOCATION_GRAVE,0,1,nil,e:GetHandler()) end
	-- 发出选择提示，提示玩家从墓地选择要除外的“次世代”怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从自己墓地选择1张符合s.cgfilter条件且不是这张卡自身的“次世代”怪兽，作为发动代价的对象。
	local g=Duel.SelectMatchingCard(tp,s.cgfilter,tp,LOCATION_GRAVE,0,1,1,nil,e:GetHandler())
	-- 将选择的卡以表侧表示除外，作为发动①效果的代价。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
	local rc=g:GetFirst()
	local tuner=rc:IsType(TYPE_TUNER) and 1 or 0
	e:SetLabel(rc:GetAttribute(),tuner)
end
-- ①效果发动成功后的处理：若这张卡仍表侧且在场上且与效果相关，则把它的属性变为除外怪兽的属性；若除外的是调整且玩家同意，再把它也当作调整使用直到结束阶段。
function s.cgop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not (c:IsFaceup() and c:IsRelateToEffect(e)) then return end
	local att,tuner=e:GetLabel()
	if c:IsAttribute(att) then return end
	-- 这张卡的属性也当作和那只怪兽相同属性使用。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_ADD_ATTRIBUTE)
	e1:SetValue(att)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
	c:RegisterEffect(e1)
	if tuner==1 and not c:IsType(TYPE_TUNER)
		-- 询问玩家是否把这张卡也当作调整使用（仅在除外的是调整怪兽且这张卡尚不是调整时出现），提示文本为“是否把这张卡当作调整使用？”。
		and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否把这张卡当作调整使用？"
		-- 中断当前效果处理，使后续“当作调整使用”的部分与前面的属性变更效果分开处理，避免造成错误的时点关系。
		Duel.BreakEffect()
		-- 把调整除外发动的场合，可以再把这张卡直到回合结束时当作调整使用。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetCode(EFFECT_ADD_TYPE)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e2:SetValue(TYPE_TUNER)
		c:RegisterEffect(e2)
	end
end
-- 定义“次世代”同调怪兽的过滤器，用于②效果的发动条件：要求是表侧表示、属于「次世代」字段、且为同调怪兽。
function s.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x2) and c:IsType(TYPE_SYNCHRO)
end
-- ②效果的发动条件判断：检查自己场上是否存在至少1只表侧表示的「次世代」同调怪兽，若存在则可以发动。
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 返回判定结果：自己场上是否存在表侧表示且属于「次世代」字段的同调怪兽。
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 定义②效果的对象过滤器：选择自己墓地中属于「次世代」字段且能被加入手卡的怪兽。
function s.tgfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x2) and c:IsAbleToHand()
end
-- ②效果的发动目标设定：处理取对象。需要选择自己墓地1只“次世代”怪兽作为对象，并且让本卡自身也作为对象，构成“包含这张卡的自己墓地2只「次世代」怪兽”。同时检查本卡能否加入手卡、能否成为效果对象。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.tgfilter(chkc) and chkc~=c end
	-- 目标选择合法性检查：确认自己墓地存在至少1只符合条件的“次世代”怪兽，且这张卡自身能够加入手卡并能成为效果对象，才可发动。
	if chk==0 then return Duel.IsExistingTarget(s.tgfilter,tp,LOCATION_GRAVE,0,1,c)
		and c:IsAbleToHand() and c:IsCanBeEffectTarget(e) end
	-- 发出选择提示，提示玩家选择要返回手牌的“次世代”怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 让玩家从自己墓地选择1只符合条件的“次世代”怪兽作为效果对象（不包含这张卡自身），并自动登记为连锁对象。
	local g=Duel.SelectTarget(tp,s.tgfilter,tp,LOCATION_GRAVE,0,1,1,c)
	-- 将发动效果的这张卡自身也设置为该连锁的对象，从而满足“以包含这张卡的自己墓地2只「次世代」怪兽为对象”的要求。
	Duel.SetTargetCard(c)
	g:AddCard(c)
	-- 设置操作信息：本效果处理时会将2张对象卡加入手卡（g中已包含选中卡和这张卡），用于外部效果（如星尘龙）的发动检测。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,2,0,0)
end
-- ②效果的处理：取出所有仍与效果相关的对象卡并加入持有者手卡；随后在本回合内给自己场上附加“被送去墓地的卡改为除外”的领域效果。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中获取本效果的目标卡组（即之前选择并登记的2张“次世代”怪兽）。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local sg=g:Filter(Card.IsRelateToEffect,nil,e)
	if sg:GetCount()>0 then
		-- 将仍与效果相关的对象卡加入其持有者的手卡（回手牌）。
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
	end
	-- 这个回合，被送去自己墓地的卡不去墓地而除外。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_RANGE+EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetCode(EFFECT_TO_GRAVE_REDIRECT)
	e1:SetTargetRange(0xff,0xfe)
	e1:SetTarget(s.rmtg)
	e1:SetValue(LOCATION_REMOVED)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将“这个回合，被送去自己墓地的卡不去墓地而除外”的持续效果注册给当前玩家，直到结束阶段。
	Duel.RegisterEffect(e1,tp)
end
-- 定义上述送墓除外效果的适用对象过滤器：仅当卡的持有者为发动效果的这个玩家时，该卡被送去墓地时才被改为除外。
function s.rmtg(e,c)
	local tp=e:GetHandlerPlayer()
	return c:GetOwner()==tp
end
