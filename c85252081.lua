--超量機獣グランパルス
-- 效果：
-- 3星怪兽×2
-- ①：没有超量素材的这张卡不能攻击。
-- ②：1回合1次，把这张卡1个超量素材取除，以场上1张魔法·陷阱卡为对象才能发动。那张卡破坏。这张卡有「超级量子战士 蓝光层」在作为超量素材的场合，这个效果在对方回合也能发动。
-- ③：1回合1次，自己主要阶段才能发动。选自己的手卡·场上1只「超级量子战士」怪兽在这张卡下面重叠作为超量素材。
function c85252081.initial_effect(c)
	-- 注册卡片记有「超级量子战士 蓝光层」的卡名。
	aux.AddCodeList(c,12369277)
	-- 添加超量召唤手续：3星怪兽×2。
	aux.AddXyzProcedure(c,nil,3,2)
	c:EnableReviveLimit()
	-- ①：没有超量素材的这张卡不能攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetCondition(c85252081.atcon)
	c:RegisterEffect(e1)
	-- ②：1回合1次，把这张卡1个超量素材取除，以场上1张魔法·陷阱卡为对象才能发动。那张卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetDescription(aux.Stringid(85252081,0))  --"魔陷破坏"
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,EFFECT_COUNT_CODE_SINGLE)
	e2:SetCondition(c85252081.descon1)
	e2:SetCost(c85252081.descost)
	e2:SetTarget(c85252081.destg)
	e2:SetOperation(c85252081.desop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetHintTiming(0,TIMING_END_PHASE+TIMING_EQUIP)
	e3:SetCondition(c85252081.descon2)
	c:RegisterEffect(e3)
	-- ③：1回合1次，自己主要阶段才能发动。选自己的手卡·场上1只「超级量子战士」怪兽在这张卡下面重叠作为超量素材。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(85252081,1))  --"增加素材"
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1)
	e4:SetTarget(c85252081.mttg)
	e4:SetOperation(c85252081.mtop)
	c:RegisterEffect(e4)
end
-- 攻击限制效果的判定条件：这张卡的超量素材数量为0。
function c85252081.atcon(e)
	return e:GetHandler():GetOverlayCount()==0
end
-- 破坏效果作为起动效果发动时的条件：超量素材中不存在「超级量子战士 蓝光层」。
function c85252081.descon1(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():GetOverlayGroup():IsExists(Card.IsCode,1,nil,12369277)
end
-- 破坏效果作为即时诱发效果（对方回合也能发动）时的条件：超量素材中存在「超级量子战士 蓝光层」。
function c85252081.descon2(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetOverlayGroup():IsExists(Card.IsCode,1,nil,12369277)
end
-- 破坏效果的代价：取除这张卡的1个超量素材。
function c85252081.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 过滤条件：魔法卡或陷阱卡。
function c85252081.desfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 破坏效果的靶向目标选择：选择场上1张魔法·陷阱卡作为对象。
function c85252081.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c85252081.desfilter(chkc) end
	-- 检查场上是否存在可以作为对象的魔法·陷阱卡。
	if chk==0 then return Duel.IsExistingTarget(c85252081.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要破坏的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 玩家选择1张魔法·陷阱卡并将其设为效果对象。
	local g=Duel.SelectTarget(tp,c85252081.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置效果处理信息：破坏选中的1张卡。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 破坏效果的处理：若对象卡在效果处理时仍符合条件，则将其破坏。
function c85252081.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果的对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 因效果将对象卡破坏。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- 叠放素材的对象过滤条件：自己手卡·场上表侧表示的「超级量子战士」怪兽。
function c85252081.mtfilter(c,e)
	return c:IsFaceupEx() and c:IsType(TYPE_MONSTER) and c:IsSetCard(0x10dc) and c:IsCanOverlay() and not (e and c:IsImmuneToEffect(e))
end
-- 叠放素材效果的靶向目标选择：检查自身是否为超量怪兽，且手卡或场上是否存在可叠放的「超级量子战士」怪兽。
function c85252081.mttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsType(TYPE_XYZ)
		-- 检查自己手卡或场上是否存在符合条件的「超级量子战士」怪兽。
		and Duel.IsExistingMatchingCard(c85252081.mtfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil) end
end
-- 叠放素材效果的处理：选择1只符合条件的怪兽，将其及其原本的超量素材（若有）处理后，重叠作为这张卡的超量素材。
function c85252081.mtop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 提示玩家选择要作为超量素材的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)  --"请选择要作为超量素材的卡"
	-- 玩家选择1只手卡或场上的「超级量子战士」怪兽。
	local g=Duel.SelectMatchingCard(tp,c85252081.mtfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil,e)
	if g:GetCount()>0 then
		local mg=g:GetFirst():GetOverlayGroup()
		if mg:GetCount()>0 then
			-- 若被选择的怪兽本身拥有超量素材，则根据规则将那些素材送去墓地。
			Duel.SendtoGrave(mg,REASON_RULE)
		end
		-- 将选择的怪兽重叠在这张卡下面作为超量素材。
		Duel.Overlay(c,g)
	end
end
