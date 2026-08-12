--電脳堺甲－甲々
-- 效果：
-- 3星怪兽×2只以上
-- ①：1回合1次，把这张卡1个超量素材取除，以自己场上1只表侧表示怪兽为对象才能发动。那只怪兽直到对方回合结束时不会被战斗破坏。
-- ②：1回合1次，原本的种族·属性相同的怪兽在自己墓地有2只以上存在，这张卡和对方怪兽进行战斗的伤害计算后才能发动。那只对方怪兽除外。
function c90664857.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加超量召唤手续：需要2只以上的3星怪兽。
	aux.AddXyzProcedure(c,nil,3,2,nil,nil,99)
	-- ①：1回合1次，把这张卡1个超量素材取除，以自己场上1只表侧表示怪兽为对象才能发动。那只怪兽直到对方回合结束时不会被战斗破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(90664857,0))  --"不会被战斗破坏"
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c90664857.cost)
	e1:SetTarget(c90664857.target)
	e1:SetOperation(c90664857.operation)
	c:RegisterEffect(e1)
	-- ②：1回合1次，原本的种族·属性相同的怪兽在自己墓地有2只以上存在，这张卡和对方怪兽进行战斗的伤害计算后才能发动。那只对方怪兽除外。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(90664857,1))  --"除外"
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLED)
	e2:SetCountLimit(1)
	e2:SetCondition(c90664857.rmcon)
	e2:SetTarget(c90664857.rmtg)
	e2:SetOperation(c90664857.rmop)
	c:RegisterEffect(e2)
end
-- 效果①的代价：检查并取除这张卡的1个超量素材。
function c90664857.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 效果①的发动准备（目标选择）：选择自己场上1只表侧表示怪兽为对象。
function c90664857.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and chkc:IsFaceup() end
	-- 检查自己场上是否存在可以作为对象的表侧表示怪兽。
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择表侧表示的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 玩家选择1只表侧表示怪兽作为效果对象。
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果①的处理：使作为对象的怪兽直到对方回合结束时不会被战斗破坏。
function c90664857.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果①的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 那只怪兽直到对方回合结束时不会被战斗破坏。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,2)
		tc:RegisterEffect(e1)
	end
end
-- 过滤函数：检查墓地中是否存在与怪兽c原本种族和属性相同的其他怪兽。
function c90664857.rmfilter(c,g)
	return g:IsExists(c90664857.rmfilter2,1,c,c)
end
-- 过滤函数：判断两只怪兽的原本种族和原本属性是否相同。
function c90664857.rmfilter2(c,tc)
	return c:GetOriginalRace()&tc:GetOriginalRace()~=0
		and c:GetOriginalAttribute()&tc:GetOriginalAttribute()~=0
end
-- 效果②的发动条件：伤害计算后，这张卡和对方怪兽进行过战斗，且自己墓地存在2只以上原本种族·属性相同的怪兽。
function c90664857.rmcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	e:SetLabelObject(bc)
	-- 获取自己墓地的所有怪兽卡。
	local g=Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_GRAVE,0,nil,TYPE_MONSTER)
	return bc and bc:IsStatus(STATUS_OPPO_BATTLE) and bc:IsRelateToBattle() and g:IsExists(c90664857.rmfilter,1,nil,g)
end
-- 效果②的发动准备：检查对方怪兽是否可以除外，并设置除外操作信息。
function c90664857.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local bc=e:GetLabelObject()
	if chk==0 then return bc:IsAbleToRemove() end
	-- 设置效果处理信息：将1张对方怪兽卡除外。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,bc,1,0,0)
end
-- 效果②的处理：将进行战斗的对方怪兽除外。
function c90664857.rmop(e,tp,eg,ep,ev,re,r,rp)
	local bc=e:GetLabelObject()
	if bc:IsRelateToBattle() and bc:IsControler(1-tp) then
		-- 以效果将对方怪兽表侧表示除外。
		Duel.Remove(bc,POS_FACEUP,REASON_EFFECT)
	end
end
