--黄金の邪教神
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：自己·对方回合1次，可以发动。对方手卡全部确认。这张卡的卡名直到结束阶段当作「千眼邪教神」使用。
-- ②：这张卡被除外的场合或者被效果送去墓地的场合，以对方场上1只效果怪兽为对象才能发动。那只效果怪兽给自己场上1只不能通常召唤的「纳祭」怪兽装备。只要这个效果把怪兽装备中，装备怪兽的攻击力上升那个攻击力数值。
function c78642798.initial_effect(c)
	-- ①：自己·对方回合1次，可以发动。对方手卡全部确认。这张卡的卡名直到结束阶段当作「千眼邪教神」使用。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(78642798,0))
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(c78642798.rntg)
	e1:SetOperation(c78642798.rnop)
	c:RegisterEffect(e1)
	-- ②：这张卡被除外的场合或者被效果送去墓地的场合，以对方场上1只效果怪兽为对象才能发动。那只效果怪兽给自己场上1只不能通常召唤的「纳祭」怪兽装备。只要这个效果把怪兽装备中，装备怪兽的攻击力上升那个攻击力数值。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(78642798,1))
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_REMOVE)
	e2:SetCountLimit(1,78642798)
	e2:SetTarget(c78642798.eqtg)
	e2:SetOperation(c78642798.eqop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCondition(c78642798.eqcon)
	c:RegisterEffect(e3)
end
-- ①号效果的靶函数（Target），用于检查发动条件
function c78642798.rntg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方手卡中是否存在未公开的卡
	if chk==0 then return Duel.GetMatchingGroupCount(aux.NOT(Card.IsPublic),tp,0,LOCATION_HAND,nil)>0 end
end
-- ①号效果的操作函数（Operation），执行确认手卡和改变卡名的处理
function c78642798.rnop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取对方手卡中所有未公开的卡
	local g=Duel.GetMatchingGroup(aux.NOT(Card.IsPublic),tp,0,LOCATION_HAND,nil)
	if g:GetCount()>0 then
		-- 给自身玩家确认获取到的对方手卡
		Duel.ConfirmCards(tp,g)
		-- 洗切对方的手卡
		Duel.ShuffleHand(1-tp)
		if c:IsFaceup() and c:IsRelateToEffect(e) then
			-- 这张卡的卡名直到结束阶段当作「千眼邪教神」使用。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetCode(EFFECT_CHANGE_CODE)
			e1:SetValue(27125110)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			c:RegisterEffect(e1)
		end
	end
end
-- ②号效果送去墓地时的发动条件，判断是否是被效果送去墓地
function c78642798.eqcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_EFFECT)
end
-- 过滤对方场上表侧表示、可以转移控制权的效果怪兽
function c78642798.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_EFFECT) and c:IsAbleToChangeControler()
end
-- 过滤自己场上表侧表示、属于「纳祭」字段且不能通常召唤的怪兽
function c78642798.eqfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x110) and not c:IsSummonableCard()
end
-- ②号效果的靶函数（Target），进行对象选择和可行性检查
function c78642798.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c78642798.filter(chkc) end
	-- 检查对方场上是否存在可以作为装备对象的效果怪兽
	if chk==0 then return Duel.IsExistingTarget(c78642798.filter,tp,0,LOCATION_MZONE,1,nil)
		-- 并且自己场上存在可以装备该怪兽的「纳祭」怪兽
		and Duel.IsExistingMatchingCard(c78642798.eqfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择要装备的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择对方场上1只表侧表示的效果怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,c78642798.filter,tp,0,LOCATION_MZONE,1,1,nil)
end
-- ②号效果的操作函数（Operation），执行装备和攻击力上升的处理
function c78642798.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查自己场上是否有可用的魔法与陷阱区域空格，若无则直接返回
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	-- 获取作为效果对象的对方怪兽
	local tc1=Duel.GetFirstTarget()
	if tc1:IsRelateToEffect(e) and tc1:IsAbleToChangeControler() then
		local atk=tc1:GetTextAttack()
		if atk<0 then atk=0 end
		-- 提示玩家选择要装备的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
		-- 选择自己场上1只符合条件的「纳祭」怪兽
		local sg=Duel.SelectMatchingCard(tp,c78642798.eqfilter,tp,LOCATION_MZONE,0,1,1,nil)
		if sg:GetCount()>0 then
			local tc2=sg:GetFirst()
			if tc1:IsFaceup() and tc1:IsRelateToEffect(e) and tc2 then
				-- 将对方怪兽作为装备卡装备给选定的己方「纳祭」怪兽
				Duel.Equip(tp,tc1,tc2,false)
				-- 只要这个效果把怪兽装备中，装备怪兽的攻击力上升那个攻击力数值。
				local e1=Effect.CreateEffect(tc1)
				e1:SetType(EFFECT_TYPE_EQUIP)
				e1:SetCode(EFFECT_UPDATE_ATTACK)
				e1:SetValue(atk)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD)
				tc1:RegisterEffect(e1)
				-- 那只效果怪兽给自己场上1只不能通常召唤的「纳祭」怪兽装备。
				local e2=Effect.CreateEffect(c)
				e2:SetType(EFFECT_TYPE_SINGLE)
				e2:SetCode(EFFECT_EQUIP_LIMIT)
				e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
				e2:SetValue(c78642798.eqlimit)
				e2:SetReset(RESET_EVENT+RESETS_STANDARD)
				e2:SetLabelObject(tc2)
				tc1:RegisterEffect(e2)
			end
		end
	end
end
-- 装备限制函数，限制该装备卡只能装备给指定的「纳祭」怪兽
function c78642798.eqlimit(e,c)
	return c==e:GetLabelObject()
end
