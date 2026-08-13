--ライトニングパニッシャー
-- 效果：
-- 连锁积累有3个的场合，把对方场上1张卡破坏。同1组连锁上有复数次同名卡的效果发动的场合，这个效果不能发动。
function c45023678.initial_effect(c)
	-- 对应效果原文：“连锁积累有3个的场合”与“同1组连锁上有复数次同名卡的效果发动的场合，这个效果不能发动。”（该部分用于记录连锁状态）
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_MZONE)
	e1:SetOperation(c45023678.chop)
	c:RegisterEffect(e1)
	-- 对应效果原文：“连锁积累有3个的场合，把对方场上1张卡破坏。”中的“把对方场上1张卡破坏”。
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
-- 连锁发动时的事件处理：记录当前连锁中是否满足发动条件。若为连锁1则重置标记为0；若存在同名卡发动则标记为2（不可发动）；否则连锁数≥3且未被标记为2时标记为1（可发动）。
function c45023678.chop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前正在处理的连锁序号（第几链）。
	local ct=Duel.GetCurrentChain()
	if ct==1 then
		e:SetLabel(0)
	-- 检查当前连锁中是否存在同名卡效果发动，若存在（CheckChainUniqueness返回false）则将标记置为2，使破坏效果不能发动。
	elseif not Duel.CheckChainUniqueness() then
		e:SetLabel(2)
	elseif ct>=3 and e:GetLabel()~=2 then
		e:SetLabel(1)
	end
end
-- 破坏效果的发动条件：读取辅助效果记录的标记，若为1（即连锁积累至3且无同名卡发动）则允许发动，并立即将标记重置为0。
function c45023678.descon(e,tp,eg,ep,ev,re,r,rp)
	local res=e:GetLabelObject():GetLabel()
	e:GetLabelObject():SetLabel(0)
	return res==1
end
-- 破坏效果的发动时处理：取对象并设置操作信息。若检查指定对象则必须为对方场上卡；发动时提示选择要破坏的卡，选择对方场上1张卡作为对象，然后设置破坏操作信息。
function c45023678.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsOnField() end
	if chk==0 then return true end
	-- 发送选择卡片的提示消息，提示文字为“请选择要破坏的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让操作玩家从对方场上选择1张卡（任意卡）作为效果对象，并将该卡登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置破坏效果的操作信息：目标为已选择的卡，数量为1，效果分类为破坏。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果处理阶段：从当前连锁取得对象卡，若该卡仍与效果相关，则将其破坏。
function c45023678.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁中登记的第一个（唯一一个）对象卡。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 以效果原因破坏该对象卡。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
