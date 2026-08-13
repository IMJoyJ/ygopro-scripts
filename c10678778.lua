--魔海城アイガイオン
-- 效果：
-- 8星怪兽×2
-- 「魔海城 埃该翁」的①②的效果1回合各能使用1次，对方回合也能发动。
-- ①：从对方的额外卡组把里侧表示的怪兽随机1只除外。这张卡的攻击力变成和除外的怪兽的攻击力相同。
-- ②：把这张卡1个超量素材取除，以除外的1只对方的融合·同调·超量怪兽为对象才能发动。那只怪兽回到额外卡组，选和那只怪兽相同种类（融合·同调·超量）的对方场上1只怪兽破坏。
function c10678778.initial_effect(c)
	-- 为这张卡添加超量召唤手续：用2只等级8的怪兽作为超量素材来超量召唤（对应“8星怪兽×2”）。
	aux.AddXyzProcedure(c,nil,8,2)
	c:EnableReviveLimit()
	-- 「魔海城 埃该翁」的①②的效果1回合各能使用1次，对方回合也能发动。①：从对方的额外卡组把里侧表示的怪兽随机1只除外。这张卡的攻击力变成和除外的怪兽的攻击力相同。
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
-- ①效果的筛选函数：从对方额外卡组中筛选出里侧表示且能够被除外的怪兽。
function c10678778.rmfilter(c)
	return c:IsFacedown() and c:IsAbleToRemove()
end
-- ①效果的发动时点处理：检查对方额外卡组是否存在符合 rmfilter 的里侧表示可除外怪兽；若存在，则设置除外操作信息（不取对象，效果处理时随机选择1张）。
function c10678778.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件：确认对方额外卡组中至少存在1张里侧表示且可除外的卡，才能发动①效果。
	if chk==0 then return Duel.IsExistingMatchingCard(c10678778.rmfilter,tp,0,LOCATION_EXTRA,1,nil) end
	-- 写入操作信息：该连锁将进行除外处理，预计从对方额外卡组除外1张卡（具体哪张在效果处理时随机确定，因此 targets 填 nil）。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,1-tp,LOCATION_EXTRA)
end
-- ①效果处理：取得对方额外卡组中符合条件的卡；若无则直接结束。洗切对方额外卡组后随机选1张里侧表示怪兽，以表侧表示除外；若此卡仍与效果关联且表侧表示，则将攻击力变为除外怪兽的攻击力（攻击力为负按0处理），并给此卡注册攻击力变化效果。
function c10678778.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得对方额外卡组中所有满足 rmfilter（里侧表示且可除外）的卡作为候选集合。
	local g=Duel.GetMatchingGroup(c10678778.rmfilter,tp,0,LOCATION_EXTRA,nil)
	if g:GetCount()==0 then return end
	-- 洗切对方的额外卡组，为随机选择1张里侧表示怪兽做准备。
	Duel.ShuffleExtra(1-tp)
	local tc=g:RandomSelect(tp,1):GetFirst()
	-- 将被随机选中的对方额外卡组怪兽以表侧表示除外，除外原因为效果。
	Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	local atk=tc:GetAttack()
	if atk<0 then atk=0 end
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	-- “这张卡的攻击力变成和除外的怪兽的攻击力相同。”
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SET_ATTACK_FINAL)
	e1:SetValue(atk)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
	c:RegisterEffect(e1)
end
-- ②效果的发动代价：检查这张卡是否有1个超量素材能够作为代价取除；有则取除这张卡的1个超量素材，原因为代价。
function c10678778.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- ②效果的对象选择条件：被选卡必须是对方除外区表侧表示的融合·同调·超量怪兽，能够回到额外卡组，且对方场上有与它相同种类的表侧表示怪兽可以作为破坏对象。
function c10678778.filter(c,tp)
	local ctype=bit.band(c:GetType(),TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ)
	return c:IsFaceup() and ctype~=0 and c:IsAbleToExtra()
		-- 进一步要求场上存在至少1只表侧表示且与对象相同种类（融合/同调/超量）的对方怪兽，以确保后续破坏操作能够进行。
		and Duel.IsExistingMatchingCard(c10678778.filter2,tp,0,LOCATION_MZONE,1,nil,ctype)
end
-- 破坏对象候选的筛选：对方场上表侧表示，且属于指定的融合·同调·超量种类之一的怪兽。
function c10678778.filter2(c,ctype)
	return c:IsFaceup() and c:IsType(ctype)
end
-- ②效果的发动条件与选对象处理：先检查除外区是否存在满足条件的对方融合·同调·超量怪兽；存在则让玩家选择1张作为对象，设置其回额外卡组的操作信息；再根据该对象的种类，获取对方场上同种类的怪兽集合，设置破坏1张的操作信息。
function c10678778.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(1-tp) and c10678778.filter(chkc,tp) end
	-- 发动条件：确认除外区存在至少1只对方持有的、可作为②效果对象的融合·同调·超量怪兽（对象本身还要满足后续可破坏同种类怪兽存在的条件）。
	if chk==0 then return Duel.IsExistingTarget(c10678778.filter,tp,0,LOCATION_REMOVED,1,nil,tp) end
	-- 显示选择提示：『请选择要返回卡组的卡』，引导玩家选择除外区的对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 让当前玩家从对方除外区的符合条件的融合·同调·超量怪兽中选择1张，并自动登记为当前连锁的处理对象。
	local g=Duel.SelectTarget(tp,c10678778.filter,tp,0,LOCATION_REMOVED,1,1,nil,tp)
	-- 写入操作信息：选中的对象将作为回额外卡组的效果处理对象。
	Duel.SetOperationInfo(0,CATEGORY_TOEXTRA,g,1,0,0)
	local ctype=bit.band(g:GetFirst():GetType(),TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ)
	-- 取得对方场上所有与已选对象相同种类（融合/同调/超量）的表侧表示怪兽，作为后续可破坏的候选集合。
	local dg=Duel.GetMatchingGroup(c10678778.filter2,tp,0,LOCATION_MZONE,nil,ctype)
	-- 写入操作信息：从这些同种类怪兽中破坏1张；传入候选集合 dg 用于连锁判定。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,dg,1,0,0)
end
-- ②效果处理：取回对象；若对象仍与效果关联且成功回到额外卡组，则根据该对象的种类，从对方场上表侧表示的同种类怪兽中选择1张并破坏。
function c10678778.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得②效果发动时选择的对象（被除外的对方融合·同调·超量怪兽）。
	local tc=Duel.GetFirstTarget()
	-- 确认对象仍与此次效果关联，并使其回到额外卡组顶端；只有成功送回（返回数量不为0）时才继续后续破坏处理。
	if tc:IsRelateToEffect(e) and Duel.SendtoDeck(tc,nil,SEQ_DECKTOP,REASON_EFFECT)~=0 then
		local ctype=bit.band(tc:GetType(),TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ)
		-- 显示选择提示：『请选择要破坏的卡』，引导玩家选择破坏对象。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		-- 从对方场上表侧表示且与已回额外卡组的对象相同种类的怪兽中选择1张作为破坏对象。
		local g=Duel.SelectMatchingCard(tp,c10678778.filter2,tp,0,LOCATION_MZONE,1,1,nil,ctype)
		-- 以效果原因破坏选中的对方场上怪兽。
		Duel.Destroy(g,REASON_EFFECT)
	end
end
