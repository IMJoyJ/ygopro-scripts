--魔海城アイガイオン
-- 效果：
-- 8星怪兽×2
-- 「魔海城 埃该翁」的①②的效果1回合各能使用1次，对方回合也能发动。
-- ①：从对方的额外卡组把里侧表示的怪兽随机1只除外。这张卡的攻击力变成和除外的怪兽的攻击力相同。
-- ②：把这张卡1个超量素材取除，以除外的1只对方的融合·同调·超量怪兽为对象才能发动。那只怪兽回到额外卡组，选和那只怪兽相同种类（融合·同调·超量）的对方场上1只怪兽破坏。
function c10678778.initial_effect(c)
	-- 为怪兽添加8星、需要2只怪兽进行XYZ召唤的手续
	aux.AddXyzProcedure(c,nil,8,2)
	c:EnableReviveLimit()
	-- ①：从对方的额外卡组把里侧表示的怪兽随机1只除外。这张卡的攻击力变成和除外的怪兽的攻击力相同。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(10678778,0))  --"除外"
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,10678778)
	e1:SetTarget(c10678778.rmtg)
	e1:SetOperation(c10678778.rmop)
	c:RegisterEffect(e1)
	-- ②：把这张卡1个超量素材取除，以除外的1只对方的融合·同调·超量怪兽为对象才能发动。那只怪兽回到额外卡组，选和那只怪兽相同种类（融合·同调·超量）的对方场上1只怪兽破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(10678778,1))  --"怪兽破坏"
	e2:SetCategory(CATEGORY_TOEXTRA+CATEGORY_DESTROY)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,10678779)
	e2:SetCost(c10678778.descost)
	e2:SetTarget(c10678778.destg)
	e2:SetOperation(c10678778.desop)
	c:RegisterEffect(e2)
end
-- 定义用于筛选对方额外卡组中里侧表示且可除外的怪兽的过滤函数
function c10678778.rmfilter(c)
	return c:IsFacedown() and c:IsAbleToRemove()
end
-- 定义①效果的发动时处理函数，用于判断是否满足发动条件并设置操作信息
function c10678778.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方额外卡组是否存在至少1张里侧表示且可除外的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c10678778.rmfilter,tp,0,LOCATION_EXTRA,1,nil) end
	-- 设置连锁操作信息，表示将要除外对方额外卡组的1张怪兽
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,1-tp,LOCATION_EXTRA)
end
-- 定义①效果的处理函数，用于执行除外怪兽并改变自身攻击力
function c10678778.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方额外卡组中所有里侧表示且可除外的怪兽组成的集合
	local g=Duel.GetMatchingGroup(c10678778.rmfilter,tp,0,LOCATION_EXTRA,nil)
	if g:GetCount()==0 then return end
	-- 将对方额外卡组进行洗切
	Duel.ShuffleExtra(1-tp)
	local tc=g:RandomSelect(tp,1):GetFirst()
	-- 将随机选择的1只怪兽从对方额外卡组除外
	Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	local atk=tc:GetAttack()
	if atk<0 then atk=0 end
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	-- 将自身攻击力设置为除外怪兽的攻击力
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SET_ATTACK_FINAL)
	e1:SetValue(atk)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
	c:RegisterEffect(e1)
end
-- 定义②效果的发动时消耗处理函数，用于扣除自身1个超量素材
function c10678778.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 定义用于筛选对方除外区中可送回额外卡组的融合·同调·超量怪兽的过滤函数
function c10678778.filter(c,tp)
	local ctype=bit.band(c:GetType(),TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ)
	return c:IsFaceup() and ctype~=0 and c:IsAbleToExtra()
		-- 检查对方场上是否存在与所选怪兽类型相同的怪兽
		and Duel.IsExistingMatchingCard(c10678778.filter2,tp,0,LOCATION_MZONE,1,nil,ctype)
end
-- 定义用于筛选对方场上指定类型的怪兽的过滤函数
function c10678778.filter2(c,ctype)
	return c:IsFaceup() and c:IsType(ctype)
end
-- 定义②效果的发动时处理函数，用于判断是否满足发动条件并设置操作信息
function c10678778.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(1-tp) and c10678778.filter(chkc,tp) end
	-- 检查对方除外区是否存在至少1张可送回额外卡组的融合·同调·超量怪兽
	if chk==0 then return Duel.IsExistingTarget(c10678778.filter,tp,0,LOCATION_REMOVED,1,nil,tp) end
	-- 提示玩家选择要送回额外卡组的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	-- 选择对方除外区中1张符合条件的怪兽作为对象
	local g=Duel.SelectTarget(tp,c10678778.filter,tp,0,LOCATION_REMOVED,1,1,nil,tp)
	-- 设置连锁操作信息，表示将要将所选怪兽送回额外卡组
	Duel.SetOperationInfo(0,CATEGORY_TOEXTRA,g,1,0,0)
	local ctype=bit.band(g:GetFirst():GetType(),TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ)
	-- 获取对方场上与所选怪兽类型相同的怪兽组成的集合
	local dg=Duel.GetMatchingGroup(c10678778.filter2,tp,0,LOCATION_MZONE,nil,ctype)
	-- 设置连锁操作信息，表示将要破坏对方场上的1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,dg,1,0,0)
end
-- 定义②效果的处理函数，用于执行怪兽送回额外卡组并破坏对方场上怪兽
function c10678778.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁处理的目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 判断目标怪兽是否有效且成功送回额外卡组
	if tc:IsRelateToEffect(e) and Duel.SendtoDeck(tc,nil,SEQ_DECKTOP,REASON_EFFECT)~=0 then
		local ctype=bit.band(tc:GetType(),TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ)
		-- 提示玩家选择要破坏的对方场上怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		-- 选择对方场上1只与目标怪兽类型相同的怪兽作为破坏对象
		local g=Duel.SelectMatchingCard(tp,c10678778.filter2,tp,0,LOCATION_MZONE,1,1,nil,ctype)
		-- 将所选怪兽破坏
		Duel.Destroy(g,REASON_EFFECT)
	end
end
