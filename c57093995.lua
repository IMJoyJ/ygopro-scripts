--コンドーレンス・パペット
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：把最多有从额外卡组特殊召唤的对方场上的怪兽数量＋1张的「机关傀儡」怪兽从卡组送去墓地（同名卡最多1张）。
-- ②：把墓地的这张卡除外，以自己场上1只机械族超量怪兽为对象才能发动。那只怪兽只要在场上表侧表示存在，不会被对方的效果破坏。
function c57093995.initial_effect(c)
	-- ①：把最多有从额外卡组特殊召唤的对方场上的怪兽数量＋1张的「机关傀儡」怪兽从卡组送去墓地（同名卡最多1张）。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(57093995,0))
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,57093995)
	e1:SetTarget(c57093995.target)
	e1:SetOperation(c57093995.activate)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外，以自己场上1只机械族超量怪兽为对象才能发动。那只怪兽只要在场上表侧表示存在，不会被对方的效果破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(57093995,1))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,57093996)
	-- 将墓地的这张卡除外作为发动的代价（Cost）。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c57093995.indtg)
	e2:SetOperation(c57093995.indop)
	c:RegisterEffect(e2)
end
-- 过滤卡组中可以送去墓地的「机关傀儡」怪兽卡。
function c57093995.tgfilter(c)
	return c:IsSetCard(0x1083) and c:IsType(TYPE_MONSTER) and c:IsAbleToGrave()
end
-- 效果①的发动准备与合法性检测，确认卡组中存在可送去墓地的卡，并设置送去墓地的操作信息。
function c57093995.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己卡组中是否存在至少1张满足条件的「机关傀儡」怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c57093995.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁处理的操作信息，表示该效果会将卡组的卡送去墓地。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 效果①的效果处理，计算对方场上从额外卡组特殊召唤的怪兽数量，并从卡组选择对应数量且卡名不同的「机关傀儡」怪兽送去墓地。
function c57093995.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己卡组中所有满足条件的「机关傀儡」怪兽。
	local g=Duel.GetMatchingGroup(c57093995.tgfilter,tp,LOCATION_DECK,0,nil)
	-- 获取对方场上从额外卡组特殊召唤的怪兽数量。
	local ct=Duel.GetMatchingGroupCount(Card.IsSummonLocation,tp,0,LOCATION_MZONE,nil,LOCATION_EXTRA)
	-- 提示玩家选择要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从符合条件的卡中选择1到ct+1张卡名各不相同的卡。
	local sg=g:SelectSubGroup(tp,aux.dncheck,false,1,ct+1)
	if sg and sg:GetCount()>0 then
		-- 将选中的卡因效果送去墓地。
		Duel.SendtoGrave(sg,REASON_EFFECT)
	end
end
-- 过滤自己场上表侧表示的机械族超量怪兽。
function c57093995.indfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:IsRace(RACE_MACHINE)
end
-- 效果②的发动准备，确认自己场上存在符合条件的机械族超量怪兽，并选择该怪兽作为效果的对象。
function c57093995.indtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c57093995.indfilter(chkc) end
	-- 检查自己场上是否存在可以作为对象的表侧表示机械族超量怪兽。
	if chk==0 then return Duel.IsExistingTarget(c57093995.indfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择表侧表示的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择自己场上1只表侧表示的机械族超量怪兽作为效果对象。
	Duel.SelectTarget(tp,c57093995.indfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果②的效果处理，给作为对象的怪兽赋予“不会被对方的效果破坏”的抗性。
function c57093995.indop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的效果对象。
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 那只怪兽只要在场上表侧表示存在，不会被对方的效果破坏。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
		-- 设置不会被破坏的来源为对方卡片的效果。
		e1:SetValue(aux.indoval)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
