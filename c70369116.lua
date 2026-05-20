--捕食植物ヴェルテ・アナコンダ
-- 效果：
-- 效果怪兽2只
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：以场上1只表侧表示怪兽为对象才能发动。那只怪兽直到回合结束时变成暗属性。
-- ②：支付2000基本分，把1张「融合」通常·速攻魔法卡从卡组送去墓地才能发动。这个效果变成和那张魔法卡发动时的效果相同。这个效果的发动后，直到回合结束时自己不能把怪兽特殊召唤。
function c70369116.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡添加连接召唤手续，需要2只效果怪兽作为连接素材。
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkType,TYPE_EFFECT),2,2)
	-- ①：以场上1只表侧表示怪兽为对象才能发动。那只怪兽直到回合结束时变成暗属性。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(70369116,0))  --"改变属性"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,70369116)
	e1:SetTarget(c70369116.atttg)
	e1:SetOperation(c70369116.attop)
	c:RegisterEffect(e1)
	-- ②：支付2000基本分，把1张「融合」通常·速攻魔法卡从卡组送去墓地才能发动。这个效果变成和那张魔法卡发动时的效果相同。这个效果的发动后，直到回合结束时自己不能把怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(70369116,1))  --"融合魔法"
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,70369117)
	e2:SetCost(c70369116.cpcost)
	e2:SetTarget(c70369116.cptg)
	e2:SetOperation(c70369116.cpop)
	c:RegisterEffect(e2)
end
-- 过滤场上表侧表示且非暗属性的怪兽。
function c70369116.attfilter(c)
	return c:IsFaceup() and not c:IsAttribute(ATTRIBUTE_DARK)
end
-- 效果①的靶向（Target）函数，用于检查和选择场上1只表侧表示且非暗属性的怪兽作为对象。
function c70369116.atttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c70369116.attfilter(chkc) end
	-- 检查场上是否存在至少1只可以作为对象的表侧表示非暗属性怪兽。
	if chk==0 then return Duel.IsExistingTarget(c70369116.attfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向玩家发送提示信息，要求选择表侧表示的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让玩家选择1只表侧表示非暗属性怪兽作为效果对象。
	Duel.SelectTarget(tp,c70369116.attfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
-- 效果①的操作（Operation）函数，将选择的对象怪兽属性变更为暗属性。
function c70369116.attop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选为效果对象的怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 那只怪兽直到回合结束时变成暗属性。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_ATTRIBUTE)
		e1:SetValue(ATTRIBUTE_DARK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
-- 过滤卡组中可以送去墓地且可以发动其效果的「融合」通常·速攻魔法卡。
function c70369116.cpfilter(c)
	return (c:GetType()==TYPE_SPELL or c:IsType(TYPE_QUICKPLAY)) and c:IsSetCard(0x46) and c:IsAbleToGraveAsCost()
		and c:CheckActivateEffect(true,true,false)~=nil
end
-- 效果②的Cost处理函数，用于在发动前标记并准备支付代价。
function c70369116.cpcost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	if chk==0 then return true end
end
-- 效果②的靶向（Target）函数，用于检查是否能支付2000基本分并从卡组将「融合」通常·速攻魔法送去墓地，并复制该魔法卡的效果。
function c70369116.cptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if e:GetLabel()==0 then return false end
		e:SetLabel(0)
		-- 检查玩家是否能支付2000基本分，且卡组中是否存在符合条件的「融合」通常·速攻魔法卡。
		return Duel.CheckLPCost(tp,2000) and Duel.IsExistingMatchingCard(c70369116.cpfilter,tp,LOCATION_DECK,0,1,nil)
	end
	e:SetLabel(0)
	-- 扣除发动玩家2000点基本分。
	Duel.PayLPCost(tp,2000)
	-- 向玩家发送提示信息，要求选择要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从卡组选择1张符合条件的「融合」通常·速攻魔法卡。
	local g=Duel.SelectMatchingCard(tp,c70369116.cpfilter,tp,LOCATION_DECK,0,1,1,nil)
	local te,ceg,cep,cev,cre,cr,crp=g:GetFirst():CheckActivateEffect(true,true,true)
	-- 将选择的魔法卡作为发动代价送去墓地。
	Duel.SendtoGrave(g,REASON_COST)
	e:SetProperty(te:GetProperty())
	local tg=te:GetTarget()
	if tg then tg(e,tp,ceg,cep,cev,cre,cr,crp,1) end
	te:SetLabelObject(e:GetLabelObject())
	e:SetLabelObject(te)
	-- 清除当前连锁的操作信息，防止该复制效果被其他卡片直接连锁响应。
	Duel.ClearOperationInfo(0)
end
-- 效果②的操作（Operation）函数，执行被复制的魔法卡的效果，并对自身施加不能特殊召唤的限制。
function c70369116.cpop(e,tp,eg,ep,ev,re,r,rp)
	local te=e:GetLabelObject()
	if te then
		e:SetLabelObject(te:GetLabelObject())
		local op=te:GetOperation()
		if op then op(e,tp,eg,ep,ev,re,r,rp) end
	end
	-- 这个效果的发动后，直到回合结束时自己不能把怪兽特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 给发动效果的玩家注册“直到回合结束时不能特殊召唤怪兽”的限制效果。
	Duel.RegisterEffect(e1,tp)
end
