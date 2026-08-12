--天使の手鏡
-- 效果：
-- 把以场上1只怪兽为对象发动的对方的魔法，转移给其他正确的对象。
function c17653779.initial_effect(c)
	-- 效果发动时，将该魔法卡设为可以对对象进行选择的效果
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(c17653779.tgcon)
	e1:SetTarget(c17653779.tgtg)
	e1:SetOperation(c17653779.tgop)
	c:RegisterEffect(e1)
end
-- 判断是否为对方发动的魔法卡且有对象
function c17653779.tgcon(e,tp,eg,ep,ev,re,r,rp)
	if rp==tp or not re:IsHasType(EFFECT_TYPE_ACTIVATE) or not re:IsActiveType(TYPE_SPELL)
		or not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	-- 获取当前连锁的效果对象卡片组
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	if not g or g:GetCount()~=1 then return false end
	local tc=g:GetFirst()
	e:SetLabelObject(tc)
	return tc:IsLocation(LOCATION_MZONE)
end
-- 用于判断目标怪兽是否可以成为连锁效果的对象
function c17653779.filter(c,ct)
	-- 检查目标怪兽是否可以成为连锁效果的对象
	return Duel.CheckChainTarget(ct,c)
end
-- 设置选择目标怪兽的条件并执行选择
function c17653779.tgtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc~=e:GetLabelObject() and chkc:IsLocation(LOCATION_MZONE) and c17653779.filter(chkc,ev) end
	-- 判断是否存在符合条件的目标怪兽
	if chk==0 then return Duel.IsExistingTarget(c17653779.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,e:GetLabelObject(),ev) end
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择符合条件的目标怪兽
	Duel.SelectTarget(tp,c17653779.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,e:GetLabelObject(),ev)
end
-- 效果处理时，将原连锁对象更换为新选择的对象
function c17653779.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前正在处理的连锁的对象卡片组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	if g:GetFirst():IsRelateToEffect(e) then
		-- 将连锁的原对象更换为新的对象卡片组
		Duel.ChangeTargetCard(ev,g)
	end
end
