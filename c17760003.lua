--A・ジェネクス・トライアーム
-- 效果：
-- 「次世代控制员」＋调整以外的怪兽1只以上
-- ①：1回合1次，可以丢弃1张手卡，从作为这张卡的同调素材的除调整以外的怪兽属性的以下效果选择1个发动。
-- ●风：对方手卡随机1张送去墓地。
-- ●水：以场上1张魔法·陷阱卡为对象才能发动。那张卡破坏。
-- ●暗：以场上1只光属性怪兽为对象才能发动。那只光属性怪兽破坏，自己抽1张。
function c17760003.initial_effect(c)
	-- 将卡号68505803（次世代控制员）加入本卡的同调素材卡名列表，用于同调召唤素材限制和关联判定。
	aux.AddMaterialCodeList(c,68505803)
	-- 为这张卡添加同调召唤手续：调整素材必须为卡名「次世代控制员」，调整以外的素材至少1只。
	aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsCode,68505803),aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- 从作为这张卡的同调素材的除调整以外的怪兽属性的以下效果选择1个发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_MATERIAL_CHECK)
	e1:SetValue(c17760003.valcheck)
	c:RegisterEffect(e1)
	-- ①：1回合1次，可以丢弃1张手卡，从作为这张卡的同调素材的除调整以外的怪兽属性的以下效果选择1个发动。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(c17760003.regcon)
	e2:SetOperation(c17760003.regop)
	c:RegisterEffect(e2)
	e2:SetLabelObject(e1)
end
-- 遍历同调素材，将其中除「次世代控制员」（调整）以外的怪兽属性按位合并，并只保留风、水、暗属性，存入效果Label，用于后续判断可发动的属性选项。
function c17760003.valcheck(e,c)
	local g=c:GetMaterial()
	local att=0
	local tc=g:GetFirst()
	while tc do
		if not tc:IsCode(68505803) or not tc:IsType(TYPE_TUNER) then
			att=bit.bor(att,tc:GetAttribute())
		end
		tc=g:GetNext()
	end
	att=bit.band(att,0x2a)
	e:SetLabel(att)
end
-- 此效果的触发条件：这张卡同调召唤成功，且素材检查中记录的风/水/暗属性不全为0（即至少存在一种符合条件的属性）。
function c17760003.regcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
		and e:GetLabelObject():GetLabel()~=0
end
-- 同调召唤成功时，根据素材检查记录的风、水、暗属性，为这张卡分别注册对应的①效果选项，并附上客户端提示标记。
function c17760003.regop(e,tp,eg,ep,ev,re,r,rp)
	local att=e:GetLabelObject():GetLabel()
	local c=e:GetHandler()
	if bit.band(att,ATTRIBUTE_WIND)~=0 then
		-- ①：1回合1次，可以丢弃1张手卡，从作为这张卡的同调素材的除调整以外的怪兽属性的以下效果选择1个发动。●风：对方手卡随机1张送去墓地。
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(17760003,0))  --"对方手牌随机1张送去墓地"
		e1:SetType(EFFECT_TYPE_IGNITION)
		e1:SetRange(LOCATION_MZONE)
		e1:SetCountLimit(1,EFFECT_COUNT_CODE_SINGLE)
		e1:SetCost(c17760003.cost)
		e1:SetTarget(c17760003.target1)
		e1:SetOperation(c17760003.operation1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
		c:RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(17760003,3))  --"风属性怪兽作为同调素材"
	end
	if bit.band(att,ATTRIBUTE_WATER)~=0 then
		-- ①：1回合1次，可以丢弃1张手卡，从作为这张卡的同调素材的除调整以外的怪兽属性的以下效果选择1个发动。●水：以场上1张魔法·陷阱卡为对象才能发动。那张卡破坏。
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(17760003,1))  --"场上存在的1张魔法或者陷阱卡破坏"
		e1:SetCategory(CATEGORY_DESTROY)
		e1:SetType(EFFECT_TYPE_IGNITION)
		e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
		e1:SetRange(LOCATION_MZONE)
		e1:SetCountLimit(1,EFFECT_COUNT_CODE_SINGLE)
		e1:SetCost(c17760003.cost)
		e1:SetTarget(c17760003.target2)
		e1:SetOperation(c17760003.operation2)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
		c:RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(17760003,4))  --"水属性怪兽作为同调素材"
	end
	if bit.band(att,ATTRIBUTE_DARK)~=0 then
		-- ①：1回合1次，可以丢弃1张手卡，从作为这张卡的同调素材的除调整以外的怪兽属性的以下效果选择1个发动。●暗：以场上1只光属性怪兽为对象才能发动。那只光属性怪兽破坏，自己抽1张。
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(17760003,2))  --"场上表侧表示存在的1只光属性怪兽破坏"
		e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DRAW)
		e1:SetType(EFFECT_TYPE_IGNITION)
		e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
		e1:SetRange(LOCATION_MZONE)
		e1:SetCountLimit(1,EFFECT_COUNT_CODE_SINGLE)
		e1:SetCost(c17760003.cost)
		e1:SetTarget(c17760003.target3)
		e1:SetOperation(c17760003.operation3)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
		c:RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(17760003,5))  --"暗属性怪兽作为同调素材"
	end
end
-- 效果发动代价：从手卡丢弃1张卡，用于支付①效果发动时的丢弃手卡COST。
function c17760003.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己手卡是否有至少1张可丢弃的卡（且不能丢弃此卡自身）。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 从手卡选择1张可丢弃的卡以COST+丢弃原因送去墓地，完成代价支付。
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 风效果的发动条件与处理信息：对方手卡存在至少1张卡；设置本次连锁将对方手卡1张卡送去墓地的操作信息。
function c17760003.target1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 风效果发动条件：对方手卡至少有1张卡。
	if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)>0 end
	-- 设置操作信息：效果处理时将对方手卡中的1张送去墓地；因为随机选择，目标不固定，targets为nil。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,1-tp,LOCATION_HAND)
end
-- 风效果处理：从对方手卡中随机选择1张卡，将其送去墓地。
function c17760003.operation1(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方手卡中的所有卡组成的组。
	local g=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
	if g:GetCount()==0 then return end
	local sg=g:RandomSelect(tp,1)
	-- 将随机选出的那张对方手卡以效果原因送去墓地。
	Duel.SendtoGrave(sg,REASON_EFFECT)
end
-- 过滤条件：场上的魔法·陷阱卡，作为水效果的对象候选。
function c17760003.filter2(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 水效果的发动条件与取对象：场上存在至少1张魔法·陷阱卡可作为对象；选定1张并设置破坏操作信息。
function c17760003.target2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and c17760003.filter2(chkc) end
	-- 水效果发动条件：场上存在至少1张魔法·陷阱卡可以作为效果对象。
	if chk==0 then return Duel.IsExistingTarget(c17760003.filter2,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 向自己发送选择提示：请选择要破坏的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 从双方场上选择1张魔法·陷阱卡作为此效果的对象。
	local g=Duel.SelectTarget(tp,c17760003.filter2,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置操作信息：将选择的对象卡破坏，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 水效果处理：若对象卡仍与此效果关联，则将其破坏。
function c17760003.operation2(e,tp,eg,ep,ev,re,r,rp)
	-- 取得此连锁中记录的第一张对象卡（水效果选择的魔法·陷阱卡）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将该对象卡以效果原因破坏。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- 过滤条件：场上表侧表示的光属性怪兽，作为暗效果的对象候选。
function c17760003.filter3(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_LIGHT)
end
-- 暗效果的发动条件与取对象：自己可抽1张卡且场上存在至少1只表侧表示光属性怪兽；选定1只并设置破坏和抽卡操作信息。
function c17760003.target3(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c17760003.filter3(chkc) end
	-- 暗效果发动条件之一：自己可以进行1张卡的效果抽卡。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1)
		-- 暗效果发动条件之二：场上存在至少1只表侧表示的光属性怪兽可以作为效果对象。
		and Duel.IsExistingTarget(c17760003.filter3,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向自己发送选择提示：请选择要破坏的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 从双方怪兽区选择1只表侧表示的光属性怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,c17760003.filter3,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息：将选择的光属性怪兽破坏。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 设置操作信息：效果处理时自己可能抽1张卡（目标为nil，数量1）。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 暗效果处理：若对象光属性怪兽仍与此效果关联且仍为表侧光属性，则将其破坏；破坏成功时自己抽1张卡。
function c17760003.operation3(e,tp,eg,ep,ev,re,r,rp)
	-- 取得暗效果选择的对象光属性怪兽。
	local tc=Duel.GetFirstTarget()
	-- 检查对象仍与此效果关联、仍是表侧光属性，并尝试以效果原因破坏；只有破坏成功才继续抽卡。
	if tc:IsRelateToEffect(e) and c17760003.filter3(tc) and Duel.Destroy(tc,REASON_EFFECT)~=0 then
		-- 自己以效果原因抽1张卡。
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
