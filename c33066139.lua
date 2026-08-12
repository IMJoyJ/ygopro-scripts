--カードを狩る死神
-- 效果：
-- 反转：选择场上存在的1张陷阱卡破坏。选择的卡是盖放的场合，把那张卡翻开确认，是陷阱卡则破坏。魔法卡的场合回到原状。
function c33066139.initial_effect(c)
	-- 反转效果：选择场上存在的1张陷阱卡破坏。选择的卡是盖放的场合，把那张卡翻开确认，是陷阱卡则破坏。魔法卡的场合回到原状。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(33066139,0))  --"陷阱破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP)
	e1:SetTarget(c33066139.target)
	e1:SetOperation(c33066139.operation)
	c:RegisterEffect(e1)
end
-- 过滤函数：判断目标卡是否为里侧表示或陷阱卡类型
function c33066139.filter(c)
	return c:IsFacedown() or c:IsType(TYPE_TRAP)
end
-- 效果目标选择函数：选择场上1张魔法陷阱区的卡作为目标
function c33066139.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_SZONE) and c33066139.filter(chkc) end
	if chk==0 then return true end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择目标卡，限定在魔法陷阱区，数量为1张
	local g=Duel.SelectTarget(tp,c33066139.filter,tp,LOCATION_SZONE,LOCATION_SZONE,1,1,e:GetHandler())
	if g:GetCount()>0 and g:GetFirst():IsFaceup() then
		-- 设置操作信息，表示将要破坏目标卡
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	end
end
-- 效果处理函数：处理选择的卡，若为里侧则翻开确认，若为陷阱卡则破坏
function c33066139.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标卡
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 若目标卡为里侧表示，则翻开确认其卡面
		if tc:IsFacedown() then Duel.ConfirmCards(tp,tc) end
		-- 若目标卡为陷阱卡类型，则以效果原因破坏该卡
		if tc:IsType(TYPE_TRAP) then Duel.Destroy(tc,REASON_EFFECT) end
	end
end
