--交響魔人マエストローク
-- 效果：
-- 4星怪兽×2
-- 1回合1次，把这张卡1个超量素材取除，选择对方场上表侧攻击表示存在的1只怪兽才能发动。选择的怪兽变成里侧守备表示。此外，只要这张卡在场上表侧表示存在，自己场上的名字带有「魔人」的超量怪兽被破坏的场合，可以作为代替把那怪兽1个超量素材取除。
function c25341652.initial_effect(c)
	-- 为这张卡添加XYZ召唤手续：用2只4星怪兽叠放召唤。
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
-- 发动代价判定与执行：检查这张卡能否移除1个超量素材作为代价，实际发动时移除1个超量素材。
function c25341652.poscost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 筛选条件：对方场上表侧攻击表示且可以变为里侧守备表示的怪兽。
function c25341652.posfilter(c)
	return c:IsPosition(POS_FACEUP_ATTACK) and c:IsCanTurnSet()
end
-- 发动时的目标选择函数：从对方场上选择1只满足条件的怪兽，并设定改变表示形式的操作信息。
function c25341652.postg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and c25341652.posfilter(chkc) end
	-- 检查对方场上是否存在至少1只满足条件且能够成为效果对象的表侧攻击表示怪兽。
	if chk==0 then return Duel.IsExistingTarget(c25341652.posfilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 显示选择提示，让玩家选择表侧攻击表示的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUPATTACK)  --"请选择表侧攻击表示的怪兽"
	-- 玩家选择对方场上1只符合条件的怪兽作为效果对象，并自动设为连锁对象。
	local g=Duel.SelectTarget(tp,c25341652.posfilter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息，声明本次处理包含改变表示形式（CATEGORY_POSITION）的效果。
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
end
-- 效果处理：将对象怪兽变为里侧守备表示。
function c25341652.posop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的第一个对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 将该怪兽的表示形式变为里侧守备表示。
		Duel.ChangePosition(tc,POS_FACEDOWN_DEFENSE)
	end
end
-- 代替破坏的筛选条件：该怪兽是我方场上的表侧表示「魔人」超量怪兽，且可以去除1个超量素材。
function c25341652.repfilter(c,tp)
	return c:IsFaceup() and c:IsControler(tp) and c:IsLocation(LOCATION_MZONE) and c:IsSetCard(0x6d) and c:CheckRemoveOverlayCard(tp,1,REASON_EFFECT)
end
-- 代替破坏的触发判定：当满足条件的「魔人」超量怪兽将要被破坏时，询问是否发动代替效果，并记录这些怪兽。
function c25341652.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(c25341652.repfilter,1,nil,tp) end
	-- 弹出是否发动代替破坏效果的确认对话框。
	if Duel.SelectEffectYesNo(tp,e:GetHandler(),96) then
		local g=eg:Filter(c25341652.repfilter,nil,tp)
		-- 将满足条件且将要被破坏的怪兽设为当前连锁的对象，供后续处理移除素材。
		Duel.SetTargetCard(g)
		return true
	else return false end
end
-- 代替破坏的值判定函数：返回该怪兽是否满足用去除1个超量素材来代替破坏的条件。
function c25341652.repval(e,c)
	return c25341652.repfilter(c,e:GetHandlerPlayer())
end
-- 代替破坏的处理：对记录下来的每只将被破坏的「魔人」超量怪兽，各移除1个超量素材作为代替。
function c25341652.repop(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中取得之前记录的代替破坏对象（即将被破坏的那些怪兽）。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local tc=g:GetFirst()
	while tc do
		tc:RemoveOverlayCard(tp,1,1,REASON_EFFECT)
		tc=g:GetNext()
	end
end
