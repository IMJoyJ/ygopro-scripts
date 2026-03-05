--呪われた棺
-- 效果：
-- 盖放的这张卡被破坏送去墓地时，对方从以下的效果选择1个适用。
-- ●随机丢弃自己的1张手卡。
-- ●自己场上的1只怪兽破坏。
function c1804528.initial_effect(c)
	-- 创建一个诱发必发效果，用于处理盖放的这张卡被破坏送去墓地时的连锁反应
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(1804528,0))  --"选择一个效果"
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_HANDES)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCondition(c1804528.descon)
	e1:SetOperation(c1804528.desop)
	c:RegisterEffect(e1)
end
-- 效果发动的条件：该卡因破坏而送去墓地，且之前在场上背面表示
function c1804528.descon(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(r,REASON_DESTROY)~=0
		and e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
		and e:GetHandler():IsPreviousPosition(POS_FACEDOWN)
end
-- 效果处理函数：根据对方选择的效果执行丢弃手牌或破坏场上怪兽的操作
function c1804528.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方手牌区的所有卡片组成一个组
	local g1=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
	-- 获取对方场上所有怪兽区的卡片组成一个组
	local g2=Duel.GetFieldGroup(tp,0,LOCATION_MZONE)
	local opt=0
	if g1:GetCount()>0 and g2:GetCount()>0 then
		-- 让对方从两个效果中选择一个，选项1为丢弃手牌，选项2为破坏场上怪兽
		opt=Duel.SelectOption(1-tp,aux.Stringid(1804528,1),aux.Stringid(1804528,2))  --"随机丢弃自己的1张手卡/自己场上的1只怪兽破坏"
	elseif g1:GetCount()>0 then
		-- 让对方只能选择丢弃手牌的效果
		opt=Duel.SelectOption(1-tp,aux.Stringid(1804528,1))  --"随机丢弃自己的1张手卡"
	elseif g2:GetCount()>0 then
		-- 让对方只能选择破坏场上怪兽的效果
		opt=Duel.SelectOption(1-tp,aux.Stringid(1804528,2))+1  --"自己场上的1只怪兽破坏"
	else return end
	if opt==0 then
		local dg=g1:RandomSelect(1-tp,1)
		-- 将对方随机选择的一张手牌送去墓地，原因包括效果和丢弃
		Duel.SendtoGrave(dg,REASON_EFFECT+REASON_DISCARD)
	else
		-- 向对方提示“请选择要破坏的卡”
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		local dg=g2:Select(1-tp,1,1,nil)
		-- 破坏对方场上选择的一只怪兽，原因包括效果
		Duel.Destroy(dg,REASON_EFFECT)
	end
end
