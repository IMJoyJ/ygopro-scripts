--地縛神 Wiraqocha Rasca
-- 效果：
-- ①：「地缚神」怪兽在场上只能有1只表侧表示存在。
-- ②：这张卡召唤成功的场合，以最多有对方手卡数量的这张卡以外的自己场上的卡为对象发动（最多3张）。那些卡回到持有者卡组。那之后，对方手卡随机选回去的数量丢弃，这张卡的攻击力上升丢弃数量×1000。
-- ③：这张卡可以直接攻击。
-- ④：对方不能选择这张卡作为攻击对象。
-- ⑤：没有场地魔法卡表侧表示存在的场合这张卡破坏。
function c41181774.initial_effect(c)
	-- 效果作用：确保场上只能有1只表侧表示的「地缚神」怪兽
	c:SetUniqueOnField(1,1,aux.FilterBoolFunction(Card.IsSetCard,0x1021),LOCATION_MZONE)
	-- ①：「地缚神」怪兽在场上只能有1只表侧表示存在。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCode(EFFECT_SELF_DESTROY)
	e4:SetCondition(c41181774.sdcon)
	c:RegisterEffect(e4)
	-- ④：对方不能选择这张卡作为攻击对象。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetCode(EFFECT_CANNOT_BE_BATTLE_TARGET)
	e5:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e5:SetRange(LOCATION_MZONE)
	-- 效果作用：使该卡不能成为攻击对象
	e5:SetValue(aux.imval1)
	c:RegisterEffect(e5)
	-- ③：这张卡可以直接攻击。
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_SINGLE)
	e6:SetCode(EFFECT_DIRECT_ATTACK)
	c:RegisterEffect(e6)
	-- ②：这张卡召唤成功的场合，以最多有对方手卡数量的这张卡以外的自己场上的卡为对象发动（最多3张）。那些卡回到持有者卡组。那之后，对方手卡随机选回去的数量丢弃，这张卡的攻击力上升丢弃数量×1000。
	local e7=Effect.CreateEffect(c)
	e7:SetDescription(aux.Stringid(41181774,0))  --"返回卡组"
	e7:SetCategory(CATEGORY_TODECK+CATEGORY_HANDES)
	e7:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e7:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e7:SetCode(EVENT_SUMMON_SUCCESS)
	e7:SetTarget(c41181774.hdtg)
	e7:SetOperation(c41181774.hdop)
	c:RegisterEffect(e7)
end
-- ⑤：没有场地魔法卡表侧表示存在的场合这张卡破坏。
function c41181774.sdcon(e)
	-- 效果作用：当没有场地魔法卡表侧表示存在时，该卡破坏
	return not Duel.IsExistingMatchingCard(Card.IsFaceup,0,LOCATION_FZONE,LOCATION_FZONE,1,nil)
end
-- 效果作用：处理召唤成功时的效果，选择最多3张自己场上的卡返回卡组
function c41181774.hdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(tp) and chkc:IsAbleToDeck() end
	if chk==0 then return true end
	-- 获取对方手卡数量
	local ct=Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)
	if ct==0 then return end
	if ct>3 then ct=3 end
	-- 提示玩家选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择满足条件的卡作为返回卡组的对象
	local g=Duel.SelectTarget(tp,Card.IsAbleToDeck,tp,LOCATION_ONFIELD,0,1,ct,e:GetHandler())
	-- 设置连锁操作信息，记录将要返回卡组的卡
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,0)
end
-- 效果作用：执行返回卡组和丢弃手牌并提升攻击力
function c41181774.hdop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中设定的目标卡组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	if not g then return end
	local sg=g:Filter(Card.IsRelateToEffect,nil,e)
	-- 将目标卡送回卡组
	Duel.SendtoDeck(sg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	local ct=sg:FilterCount(Card.IsLocation,nil,LOCATION_DECK+LOCATION_EXTRA)
	if ct==0 then return end
	-- 中断当前效果处理，使后续处理视为错时点
	Duel.BreakEffect()
	-- 从对方手牌中随机选择指定数量的卡
	local dg=Duel.GetFieldGroup(tp,0,LOCATION_HAND):RandomSelect(tp,ct)
	-- 将选中的卡送入墓地（丢弃）
	local dt=Duel.SendtoGrave(dg,REASON_EFFECT+REASON_DISCARD)
	local c=e:GetHandler()
	if dt~=0 and c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 效果作用：提升该卡的攻击力，提升值为丢弃卡数量×1000
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e1:SetRange(LOCATION_MZONE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(dt*1000)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
	end
end
