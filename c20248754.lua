--海造賊－静寂のメルケ号
-- 效果：
-- 4星怪兽×2
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：从手卡丢弃1张「海造贼」卡，以对方场上1只效果怪兽为对象才能发动。那只怪兽除外。那之后，可以从卡组把1张「海造贼」魔法·陷阱卡加入手卡。这张卡有「海造贼」卡装备的场合，这个效果在对方回合也能发动。
-- ②：自己场上的「海造贼」卡被战斗·效果破坏的场合，可以作为代替把这张卡1个超量素材取除。
function c20248754.initial_effect(c)
	-- 为卡片添加等级为4、需要2只怪兽进行XYZ召唤的手续
	aux.AddXyzProcedure(c,nil,4,2)
	c:EnableReviveLimit()
	-- ①：从手卡丢弃1张「海造贼」卡，以对方场上1只效果怪兽为对象才能发动。那只怪兽除外。那之后，可以从卡组把1张「海造贼」魔法·陷阱卡加入手卡。这张卡有「海造贼」卡装备的场合，这个效果在对方回合也能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(20248754,0))
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,20248754)
	e1:SetCondition(c20248754.rmcon1)
	e1:SetCost(c20248754.rmcost)
	e1:SetTarget(c20248754.rmtg)
	e1:SetOperation(c20248754.rmop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e2:SetCondition(c20248754.rmcon2)
	c:RegisterEffect(e2)
	-- ②：自己场上的「海造贼」卡被战斗·效果破坏的场合，可以作为代替把这张卡1个超量素材取除。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_DESTROY_REPLACE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTarget(c20248754.reptg)
	e3:SetValue(c20248754.repval)
	c:RegisterEffect(e3)
end
-- 判断装备的卡是否为「海造贼」卡且正面表示
function c20248754.confilter(c)
	return c:IsFaceup() and c:IsSetCard(0x13f)
end
-- 判断当前卡片是否没有装备「海造贼」卡，用于①效果的发动条件
function c20248754.rmcon1(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetHandler():GetEquipGroup()
	return not g or not g:IsExists(c20248754.confilter,1,nil)
end
-- 判断当前卡片是否装备有「海造贼」卡，用于①效果在对方回合发动的条件
function c20248754.rmcon2(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetHandler():GetEquipGroup()
	return g and g:IsExists(c20248754.confilter,1,nil)
end
-- 判断手卡中是否存在可丢弃的「海造贼」卡
function c20248754.costfilter(c)
	return c:IsSetCard(0x13f) and c:IsDiscardable()
end
-- 执行丢弃1张「海造贼」卡的费用
function c20248754.rmcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否手卡中存在至少1张「海造贼」卡
	if chk==0 then return Duel.IsExistingMatchingCard(c20248754.costfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 从手卡丢弃1张「海造贼」卡作为费用
	Duel.DiscardHand(tp,c20248754.costfilter,1,1,REASON_COST+REASON_DISCARD)
end
-- 判断目标怪兽是否为正面表示、效果怪兽且可除外
function c20248754.rmfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_EFFECT) and c:IsAbleToRemove()
end
-- 设置①效果的目标选择和操作信息
function c20248754.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c20248754.rmfilter(chkc) end
	-- 检查对方场上是否存在至少1只正面表示的效果怪兽
	if chk==0 then return Duel.IsExistingTarget(c20248754.rmfilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要除外的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择对方场上1只正面表示的效果怪兽作为除外对象
	local g=Duel.SelectTarget(tp,c20248754.rmfilter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息，表示将要除外1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- 判断卡组中是否存在「海造贼」魔法·陷阱卡
function c20248754.thfilter(c)
	return c:IsSetCard(0x13f) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- 执行①效果的处理，将目标怪兽除外并检索1张「海造贼」魔法·陷阱卡加入手牌
function c20248754.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 判断目标怪兽是否仍然在场且满足除外条件，并确认卡组中存在「海造贼」魔法·陷阱卡
	if tc:IsRelateToEffect(e) and Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)~=0 and Duel.IsExistingMatchingCard(c20248754.thfilter,tp,LOCATION_DECK,0,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(20248754,1)) then  --"是否从卡组把「海造贼」魔法·陷阱卡加入手卡？"
		-- 中断当前效果处理，使后续处理不与当前效果同时进行
		Duel.BreakEffect()
		-- 提示玩家选择要加入手牌的「海造贼」魔法·陷阱卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 从卡组中选择1张「海造贼」魔法·陷阱卡
		local g=Duel.SelectMatchingCard(tp,c20248754.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		-- 将选中的魔法·陷阱卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 判断场上的「海造贼」卡是否为正面表示、属于玩家、在场上、为「海造贼」卡、因战斗或效果破坏且未被代替破坏
function c20248754.repfilter(c,tp)
	return c:IsFaceup() and c:IsControler(tp) and c:IsOnField() and c:IsSetCard(0x13f) and c:IsReason(REASON_EFFECT+REASON_BATTLE) and not c:IsReason(REASON_REPLACE)
end
-- 判断是否满足代替破坏的条件，即场上有「海造贼」卡被破坏且当前卡片可取除1个超量素材
function c20248754.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(c20248754.repfilter,1,nil,tp)
		and e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_EFFECT) end
	-- 询问玩家是否发动代替破坏效果
	if Duel.SelectEffectYesNo(tp,e:GetHandler(),96) then
		e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_EFFECT)
		return true
	end
	return false
end
-- 返回代替破坏的目标卡是否满足条件
function c20248754.repval(e,c)
	return c20248754.repfilter(c,e:GetHandlerPlayer())
end
