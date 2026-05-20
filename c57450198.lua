--超量機獣ラスターレックス
-- 效果：
-- 7星怪兽×2
-- ①：没有超量素材的这张卡不能攻击。
-- ②：1回合1次，把这张卡1个超量素材取除，以场上1只效果怪兽为对象才能发动。那只怪兽的效果直到回合结束时无效。这张卡有「超级量子战士 白光层」在作为超量素材的场合，这个效果在对方回合也能发动。
-- ③：1回合1次，自己主要阶段才能发动。从自己的手卡·场上选1只「超级量子战士」怪兽在这张卡下面重叠作为超量素材。
function c57450198.initial_effect(c)
	-- 注册卡片记有「超级量子战士 白光层」的卡片密码，用于相关卡片检索或效果判定。
	aux.AddCodeList(c,73422829)
	-- 为这张卡添加超量召唤手续：7星怪兽×2。
	aux.AddXyzProcedure(c,nil,7,2)
	c:EnableReviveLimit()
	-- ①：没有超量素材的这张卡不能攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetCondition(c57450198.atcon)
	c:RegisterEffect(e1)
	-- ②：1回合1次，把这张卡1个超量素材取除，以场上1只效果怪兽为对象才能发动。那只怪兽的效果直到回合结束时无效。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DISABLE)
	e2:SetDescription(aux.Stringid(57450198,0))  --"效果无效"
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,EFFECT_COUNT_CODE_SINGLE)
	e2:SetCondition(c57450198.discon1)
	e2:SetCost(c57450198.discost)
	e2:SetTarget(c57450198.distg)
	e2:SetOperation(c57450198.disop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e3:SetCondition(c57450198.discon2)
	c:RegisterEffect(e3)
	-- ③：1回合1次，自己主要阶段才能发动。从自己的手卡·场上选1只「超级量子战士」怪兽在这张卡下面重叠作为超量素材。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(57450198,1))  --"补充超量素材"
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1)
	e4:SetTarget(c57450198.mttg)
	e4:SetOperation(c57450198.mtop)
	c:RegisterEffect(e4)
end
-- 判定这张卡没有超量素材的条件函数。
function c57450198.atcon(e)
	return e:GetHandler():GetOverlayCount()==0
end
-- 判定这张卡没有「超级量子战士 白光层」作为超量素材的条件函数（此时只能在自己回合发动效果）。
function c57450198.discon1(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():GetOverlayGroup():IsExists(Card.IsCode,1,nil,73422829)
end
-- 判定这张卡有「超级量子战士 白光层」作为超量素材的条件函数（此时在对方回合也能发动效果）。
function c57450198.discon2(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetOverlayGroup():IsExists(Card.IsCode,1,nil,73422829)
end
-- 效果②的代价去重叠素材处理函数（把这张卡1个超量素材取除）。
function c57450198.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 效果②的对象选择与发动准备函数。
function c57450198.distg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 判定已选择的对象是否仍是场上的表侧表示效果怪兽。
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and aux.NegateEffectMonsterFilter(chkc) end
	-- 检查场上是否存在至少1只可以被选择为无效对象的效果怪兽。
	if chk==0 then return Duel.IsExistingTarget(aux.NegateEffectMonsterFilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要无效的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
	-- 玩家选择场上1只表侧表示的效果怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,aux.NegateEffectMonsterFilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置效果处理信息，表示该效果包含使怪兽效果无效的操作。
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
end
-- 效果②的效果处理函数（使作为对象的怪兽效果无效）。
function c57450198.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在发动时选择的效果对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) and tc:IsCanBeDisabledByEffect(e) then
		-- 使与该对象怪兽相关的连锁中已发动的效果无效化。
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		-- 那只怪兽的效果直到回合结束时无效。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 那只怪兽的效果直到回合结束时无效。
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
	end
end
-- 过滤出可以作为超量素材的「超级量子战士」怪兽的筛选函数。
function c57450198.mtfilter(c,e)
	return c:IsFaceupEx() and c:IsType(TYPE_MONSTER) and c:IsSetCard(0x10dc) and c:IsCanOverlay() and not (e and c:IsImmuneToEffect(e))
end
-- 效果③的发动准备与条件检查函数。
function c57450198.mttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsType(TYPE_XYZ)
		-- 检查自己的手卡或场上是否存在可以作为超量素材的「超级量子战士」怪兽。
		and Duel.IsExistingMatchingCard(c57450198.mtfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil) end
end
-- 效果③的效果处理函数（将选中的怪兽重叠作为超量素材）。
function c57450198.mtop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 提示玩家选择要作为超量素材的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)  --"请选择要作为超量素材的卡"
	-- 玩家从自己的手卡或场上选择1只「超级量子战士」怪兽。
	local g=Duel.SelectMatchingCard(tp,c57450198.mtfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil,e)
	if g:GetCount()>0 then
		local mg=g:GetFirst():GetOverlayGroup()
		if mg:GetCount()>0 then
			-- 将被选为素材的怪兽原本拥有的超量素材送去墓地。
			Duel.SendtoGrave(mg,REASON_RULE)
		end
		-- 将选择的怪兽重叠在这张卡下面作为超量素材。
		Duel.Overlay(c,g)
	end
end
