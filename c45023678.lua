--ライトニングパニッシャー
-- 效果：
-- 连锁积累有3个的场合，把对方场上1张卡破坏。同1组连锁上有复数次同名卡的效果发动的场合，这个效果不能发动。
function c45023678.initial_effect(c)
	-- 连锁积累有3个的场合，把对方场上1张卡破坏。同1组连锁上有复数次同名卡的效果发动的场合，这个效果不能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_MZONE)
	e1:SetOperation(c45023678.chop)
	c:RegisterEffect(e1)
	-- 连锁积累有3个的场合，把对方场上1张卡破坏。同1组连锁上有复数次同名卡的效果发动的场合，这个效果不能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(45023678,0))  --"破坏"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_CHAIN_END)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c45023678.descon)
	e2:SetTarget(c45023678.destg)
	e2:SetOperation(c45023678.desop)
	e2:SetLabelObject(e1)
	c:RegisterEffect(e2)
end
-- 记录当前连锁数，若为1则标记为0，若存在同名卡则标记为2，若连锁数大于等于3且未标记为2则标记为1。
function c45023678.chop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前正在处理的连锁序号。
	local ct=Duel.GetCurrentChain()
	if ct==1 then
		e:SetLabel(0)
	-- 检查当前连锁中是否存在同名卡的发动，若存在则标记为2。
	elseif not Duel.CheckChainUniqueness() then
		e:SetLabel(2)
	elseif ct>=3 and e:GetLabel()~=2 then
		e:SetLabel(1)
	end
end
-- 判断是否满足发动条件，即上一个效果标记为1。
function c45023678.descon(e,tp,eg,ep,ev,re,r,rp)
	local res=e:GetLabelObject():GetLabel()
	e:GetLabelObject():SetLabel(0)
	return res==1
end
-- 选择对方场上的1张卡作为破坏对象。
function c45023678.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsOnField() end
	if chk==0 then return true end
	-- 提示玩家选择要破坏的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上的1张卡作为目标。
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置操作信息，指定将要破坏的卡。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 执行破坏效果，将选中的卡破坏。
function c45023678.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标卡。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 将目标卡以效果原因破坏。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
