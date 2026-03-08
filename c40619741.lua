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
-- 筛选可以改变表示形式的怪兽
function c40619741.filter(c)
	return c:IsCanChangePosition()
end
-- 效果处理时选择目标怪兽，最多为装备卡数量
function c40619741.postg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c40619741.filter(chkc) end
	-- 判断是否满足发动条件：装备卡数量大于0且对方场上存在可改变表示形式的怪兽
	if chk==0 then return e:GetHandler():GetEquipCount()>0 and Duel.IsExistingTarget(c40619741.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要改变表示形式的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
	-- 选择最多装备卡数量的对方怪兽作为目标
	local g=Duel.SelectTarget(tp,c40619741.filter,tp,0,LOCATION_MZONE,1,e:GetHandler():GetEquipCount(),nil)
	-- 设置效果操作信息，确定要改变表示形式的怪兽数量
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,g:GetCount(),0,0)
end
-- 处理效果的发动，改变目标怪兽的表示形式
function c40619741.posop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中设定的目标怪兽组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local sg=g:Filter(Card.IsRelateToEffect,nil,e)
	-- 将目标怪兽全部改变为表侧守备表示或里侧守备表示或表侧攻击表示
	Duel.ChangePosition(sg,POS_FACEUP_DEFENSE,POS_FACEDOWN_DEFENSE,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK)
end
