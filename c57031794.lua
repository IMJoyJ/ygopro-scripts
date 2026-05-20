--超量機獣マグナライガー
-- 效果：
-- 5星怪兽×2
-- ①：没有超量素材的这张卡不能攻击。
-- ②：1回合1次，把这张卡1个超量素材取除，以场上1只怪兽为对象才能发动。那只怪兽破坏。这张卡有「超级量子战士 红光层」在作为超量素材的场合，这个效果在对方回合也能发动。
-- ③：1回合1次，自己主要阶段才能发动。选自己的手卡·场上1只「超级量子战士」怪兽在这张卡下面重叠作为超量素材。
function c57031794.initial_effect(c)
	-- 注册该卡关联的卡片密码（超级量子战士 红光层），用于卡片检索或效果关联判定
	aux.AddCodeList(c,59975920)
	-- 为这张卡添加超量召唤手续：5星怪兽×2
	aux.AddXyzProcedure(c,nil,5,2)
	c:EnableReviveLimit()
	-- ①：没有超量素材的这张卡不能攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetCondition(c57031794.atcon)
	c:RegisterEffect(e1)
	-- ②：1回合1次，把这张卡1个超量素材取除，以场上1只怪兽为对象才能发动。那只怪兽破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetDescription(aux.Stringid(57031794,0))  --"怪兽破坏"
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,EFFECT_COUNT_CODE_SINGLE)
	e2:SetCondition(c57031794.descon1)
	e2:SetCost(c57031794.descost)
	e2:SetTarget(c57031794.destg)
	e2:SetOperation(c57031794.desop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e3:SetCondition(c57031794.descon2)
	c:RegisterEffect(e3)
	-- ③：1回合1次，自己主要阶段才能发动。选自己的手卡·场上1只「超级量子战士」怪兽在这张卡下面重叠作为超量素材。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(57031794,1))  --"超量素材"
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1)
	e4:SetTarget(c57031794.mttg)
	e4:SetOperation(c57031794.mtop)
	c:RegisterEffect(e4)
end
-- 判断这张卡的超量素材数量是否为0，作为不能攻击效果的生效条件
function c57031794.atcon(e)
	return e:GetHandler():GetOverlayCount()==0
end
-- 判断这张卡的超量素材中不存在「超级量子战士 红光层」，作为起动效果（只能在自己回合发动）的条件
function c57031794.descon1(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():GetOverlayGroup():IsExists(Card.IsCode,1,nil,59975920)
end
-- 判断这张卡的超量素材中存在「超级量子战士 红光层」，作为诱发即时效果（在对方回合也能发动）的条件
function c57031794.descon2(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetOverlayGroup():IsExists(Card.IsCode,1,nil,59975920)
end
-- 效果发动的代价：取除这张卡的1个超量素材
function c57031794.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 破坏效果的发动准备，包括判断合法对象、选择场上的1只怪兽作为效果对象并设置破坏的操作信息
function c57031794.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) end
	-- 在发动时点，检查场上是否存在至少1只可以作为效果对象的怪兽
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向发动效果的玩家提示选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家选择场上1只怪兽作为效果对象
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置当前连锁的操作信息为“破坏选中的1张卡”
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 破坏效果的处理：将作为效果对象的怪兽破坏
function c57031794.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 因效果将目标怪兽破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- 过滤满足“手卡或场上表侧表示的「超级量子战士」怪兽，且可以作为超量素材”条件的卡片
function c57031794.mtfilter(c,e)
	return c:IsFaceupEx() and c:IsType(TYPE_MONSTER) and c:IsSetCard(0x10dc) and c:IsCanOverlay() and not (e and c:IsImmuneToEffect(e))
end
-- 重叠素材效果的发动准备，检查自身是否为超量怪兽，以及手卡或场上是否存在满足条件的「超级量子战士」怪兽
function c57031794.mttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsType(TYPE_XYZ)
		-- 检查自己的手卡或场上是否存在至少1只满足条件的「超级量子战士」怪兽
		and Duel.IsExistingMatchingCard(c57031794.mtfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil) end
end
-- 重叠素材效果的处理：选择自己手卡或场上1只「超级量子战士」怪兽，将其重叠在这张卡下面作为超量素材
function c57031794.mtop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 向发动效果的玩家提示选择要作为超量素材的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)  --"请选择要作为超量素材的卡"
	-- 让玩家选择自己手卡或场上1只满足条件的「超级量子战士」怪兽
	local g=Duel.SelectMatchingCard(tp,c57031794.mtfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil,e)
	if g:GetCount()>0 then
		local mg=g:GetFirst():GetOverlayGroup()
		if mg:GetCount()>0 then
			-- 根据规则，将要作为超量素材的怪兽原本拥有的超量素材送去墓地
			Duel.SendtoGrave(mg,REASON_RULE)
		end
		-- 将选择的怪兽重叠在这张卡下面作为超量素材
		Duel.Overlay(c,g)
	end
end
