--ヴァイロン・ソルジャー
-- 效果：
-- 这张卡的攻击宣言时，可以选择最多有这张卡装备的装备卡数量的对方场上存在的怪兽，把表示形式变更。
function c40619741.initial_effect(c)
	-- 这张卡的攻击宣言时，可以选择最多有这张卡装备的装备卡数量的对方场上存在的怪兽，把表示形式变更。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(40619741,0))  --"改变表示形式"
	e1:SetCategory(CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetTarget(c40619741.postg)
	e1:SetOperation(c40619741.posop)
	c:RegisterEffect(e1)
end
-- 过滤函数：判断怪兽是否可以通过效果改变表示形式，即可作为本次效果对象的条件。
function c40619741.filter(c)
	return c:IsCanChangePosition()
end
-- 目标选择处理：确认对象必须是对方场上可变更表示形式的怪兽；本卡有装备卡且存在可选对象时才可发动；提示后选择最多为装备卡数量的对象，并登记操作信息。
function c40619741.postg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c40619741.filter(chkc) end
	-- 发动条件检查：本卡装备卡数量大于0，且对方场上有满足条件的怪兽存在，效果才能发动。
	if chk==0 then return e:GetHandler():GetEquipCount()>0 and Duel.IsExistingTarget(c40619741.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 向玩家显示“请选择要改变表示形式的怪兽”的选择提示消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
	-- 从对方场上选择1到本卡装备卡数量（最多）的满足条件的怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,c40619741.filter,tp,0,LOCATION_MZONE,1,e:GetHandler():GetEquipCount(),nil)
	-- 登记操作信息：本次连锁将处理改变表示形式的效果，操作对象为已选择的目标，数量为目标数量。
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,g:GetCount(),0,0)
end
-- 效果处理：获取本次连锁的对象卡组，筛选其中仍与效果相关（仍受该效果影响）的卡，然后将这些卡变更表示形式。
function c40619741.posop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁处理中记录的对象卡组，即发动时选择的目标怪兽。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local sg=g:Filter(Card.IsRelateToEffect,nil,e)
	-- 将目标怪兽的表示形式变更：表侧攻击表示变为表侧守备表示，里侧攻击表示变为里侧守备表示，表侧守备表示或里侧守备表示变为表侧攻击表示。
	Duel.ChangePosition(sg,POS_FACEUP_DEFENSE,POS_FACEDOWN_DEFENSE,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK)
end
