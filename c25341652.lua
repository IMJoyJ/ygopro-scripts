--交響魔人マエストローク
-- 效果：
-- 4星怪兽×2
-- 1回合1次，把这张卡1个超量素材取除，选择对方场上表侧攻击表示存在的1只怪兽才能发动。选择的怪兽变成里侧守备表示。此外，只要这张卡在场上表侧表示存在，自己场上的名字带有「魔人」的超量怪兽被破坏的场合，可以作为代替把那怪兽1个超量素材取除。
function c25341652.initial_effect(c)
	-- 添加XYZ召唤手续，使用等级为4的怪兽2只进行叠放
	aux.AddXyzProcedure(c,nil,4,2)
	c:EnableReviveLimit()
	-- 1回合1次，把这张卡1个超量素材取除，选择对方场上表侧攻击表示存在的1只怪兽才能发动。选择的怪兽变成里侧守备表示。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(25341652,0))  --"变成里侧守备"
	e1:SetCategory(CATEGORY_POSITION+CATEGORY_MSET)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(c25341652.poscost)
	e1:SetTarget(c25341652.postg)
	e1:SetOperation(c25341652.posop)
	c:RegisterEffect(e1)
	-- 此外，只要这张卡在场上表侧表示存在，自己场上的名字带有「魔人」的超量怪兽被破坏的场合，可以作为代替把那怪兽1个超量素材取除。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTarget(c25341652.reptg)
	e2:SetValue(c25341652.repval)
	e2:SetOperation(c25341652.repop)
	c:RegisterEffect(e2)
end
-- 支付1个超量素材作为cost
function c25341652.poscost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 筛选表侧攻击表示且可以变为里侧守备表示的怪兽
function c25341652.posfilter(c)
	return c:IsPosition(POS_FACEUP_ATTACK) and c:IsCanTurnSet()
end
-- 选择对方场上表侧攻击表示存在的1只怪兽作为效果对象
function c25341652.postg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and c25341652.posfilter(chkc) end
	-- 确认对方场上是否存在表侧攻击表示的怪兽
	if chk==0 then return Duel.IsExistingTarget(c25341652.posfilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择表侧攻击表示的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUPATTACK)  --"请选择表侧攻击表示的怪兽"
	-- 选择对方场上表侧攻击表示存在的1只怪兽
	local g=Duel.SelectTarget(tp,c25341652.posfilter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置效果处理信息，将选择的怪兽变为里侧守备表示
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
end
-- 将选择的怪兽变为里侧守备表示
function c25341652.posop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的效果对象
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 将对象怪兽变为里侧守备表示
		Duel.ChangePosition(tc,POS_FACEDOWN_DEFENSE)
	end
end
-- 筛选自己场上表侧表示、名字带有「魔人」且拥有超量素材可被取除的怪兽
function c25341652.repfilter(c,tp)
	return c:IsFaceup() and c:IsControler(tp) and c:IsLocation(LOCATION_MZONE) and c:IsSetCard(0x6d) and c:CheckRemoveOverlayCard(tp,1,REASON_EFFECT)
end
-- 判断是否满足代替破坏的条件
function c25341652.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(c25341652.repfilter,1,nil,tp) end
	-- 询问玩家是否发动效果
	if Duel.SelectEffectYesNo(tp,e:GetHandler(),96) then
		local g=eg:Filter(c25341652.repfilter,nil,tp)
		-- 设置效果处理的目标卡片
		Duel.SetTargetCard(g)
		return true
	else return false end
end
-- 返回符合条件的怪兽作为代替破坏的对象
function c25341652.repval(e,c)
	return c25341652.repfilter(c,e:GetHandlerPlayer())
end
-- 将符合条件的怪兽的1个超量素材取除
function c25341652.repop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中设置的目标卡片组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local tc=g:GetFirst()
	while tc do
		tc:RemoveOverlayCard(tp,1,1,REASON_EFFECT)
		tc=g:GetNext()
	end
end
