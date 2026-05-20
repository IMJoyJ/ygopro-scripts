--悲劇の引き金
-- 效果：
-- 自己场上存在的怪兽成为持有（把场上1只怪兽破坏的效果）的魔法·陷阱·效果怪兽的效果的对象时才能发动。那个效果的对象移向对方场上存在的1只能变成正确对象的怪兽。
function c61656650.initial_effect(c)
	-- 自己场上存在的怪兽成为持有（把场上1只怪兽破坏的效果）的魔法·陷阱·效果怪兽的效果的对象时才能发动。那个效果的对象移向对方场上存在的1只能变成正确对象的怪兽。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(c61656650.efcon)
	e1:SetTarget(c61656650.eftg)
	e1:SetOperation(c61656650.efop)
	c:RegisterEffect(e1)
end
-- 检查发动条件：当前连锁的效果是否为取对象、且对象仅为自己场上的1只怪兽、且该效果是破坏该怪兽的效果
function c61656650.efcon(e,tp,eg,ep,ev,re,r,rp)
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	-- 获取当前连锁效果的对象卡片组
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	if not g or g:GetCount()~=1 then return false end
	local tc=g:GetFirst()
	-- 获取当前连锁效果的破坏操作信息及预定破坏的卡片组
	local ex,dg=Duel.GetOperationInfo(0,CATEGORY_DESTROY)
	return tc:IsControler(tp) and dg and dg:GetCount()==1 and dg:GetFirst()==tc and tc:IsType(TYPE_MONSTER)
end
-- 过滤函数：检查卡片是否能成为当前连锁效果的正确对象
function c61656650.filter(c,ct)
	-- 检查卡片是否是当前连锁效果的合法/正确对象
	return Duel.CheckChainTarget(ct,c)
end
-- 效果发动时的处理：检查是否存在合法的对方场上怪兽作为新对象，并选择该怪兽作为本卡的效果对象
function c61656650.eftg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 检查对方场上是否存在至少1只可以成为当前连锁效果正确对象的怪兽
	if chk==0 then return Duel.IsExistingTarget(c61656650.filter,tp,0,LOCATION_MZONE,1,nil,ev) end
	-- 给发动玩家提示“请选择效果的对象”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择对方场上1只可以成为当前连锁效果正确对象的怪兽作为本卡的对象
	Duel.SelectTarget(tp,c61656650.filter,tp,0,LOCATION_MZONE,1,1,nil,ev)
end
-- 效果处理：将当前连锁效果的对象转移到本卡所选择的对方怪兽上
function c61656650.efop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本卡发动时选择的对象怪兽（即准备转移过去的新对象）
	local tc=Duel.GetFirstTarget()
	-- 检查该新对象是否仍与本卡效果相关，且此时仍能作为当前连锁效果的正确对象
	if tc:IsRelateToEffect(e) and Duel.CheckChainTarget(ev,tc) then
		local g=Group.FromCards(tc)
		-- 将当前连锁效果的对象变更为新选择的怪兽
		Duel.ChangeTargetCard(ev,g)
	end
end
