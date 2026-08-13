--グリーン・ダストン
-- 效果：
-- 这张卡不能解放，也不能作为融合·同调·超量召唤的素材。场上的这张卡被破坏时，这张卡的控制者选择自己场上1张魔法·陷阱卡回到持有者手卡。「绿尘妖」在自己场上只能有1只表侧表示存在。
function c52182715.initial_effect(c)
	c:SetUniqueOnField(1,0,52182715)
	-- “这张卡不能解放”（作为上级召唤的祭品限制部分）
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_UNRELEASABLE_SUM)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UNRELEASABLE_NONSUM)
	c:RegisterEffect(e2)
	-- “不能作为融合·同调·超量召唤的素材”中的“不能作为融合素材”部分
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e3:SetCode(EFFECT_CANNOT_BE_FUSION_MATERIAL)
	e3:SetValue(c52182715.fuslimit)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
	e4:SetValue(1)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EFFECT_CANNOT_BE_XYZ_MATERIAL)
	c:RegisterEffect(e5)
	-- “场上的这张卡被破坏时，这张卡的控制者选择自己场上1张魔法·陷阱卡回到持有者手卡。”
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(52182715,0))  --"返回手牌"
	e6:SetCategory(CATEGORY_TOHAND)
	e6:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e6:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e6:SetCode(EVENT_DESTROYED)
	e6:SetCondition(c52182715.retcon)
	e6:SetTarget(c52182715.rettg)
	e6:SetOperation(c52182715.retop)
	c:RegisterEffect(e6)
end
-- e3的Value函数：当召唤类型为融合召唤（SUMMON_TYPE_FUSION）时返回true，用于限制该卡不能作为融合素材。
function c52182715.fuslimit(e,c,sumtype)
	return sumtype==SUMMON_TYPE_FUSION
end
-- e6的发动条件：这张卡因被破坏而离场，且破坏前位于场上。
function c52182715.retcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_DESTROY) and c:IsPreviousLocation(LOCATION_ONFIELD)
end
-- 选择对象的过滤器：必须是魔法·陷阱卡且能够加入手卡（IsAbleToHand）。
function c52182715.filter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- e6的取对象处理：以这张卡破坏前的控制者（prec）为选择方，从该玩家场上选择1张满足filter的魔法·陷阱卡作为效果对象，并设置回手牌的操作信息。
function c52182715.rettg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local prec=e:GetHandler():GetPreviousControler()
	if chkc then return chkc:IsControler(prec) and chkc:IsOnField() and c52182715.filter(chkc) end
	if chk==0 then return true end
	-- 向玩家提示选择要返回手牌的卡，提示内容为HINTMSG_RTOHAND对应的文本。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 让破坏前的控制者prec从自己场上选择1张满足filter的魔法·陷阱卡，并将所选卡设为当前连锁的效果对象。
	local g=Duel.SelectTarget(prec,c52182715.filter,prec,LOCATION_ONFIELD,0,1,1,nil)
	-- 设置操作信息，声明本效果将把对象卡返回手牌（CATEGORY_TOHAND），数量为选取的卡数。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,g:GetCount(),0,0)
end
-- e6的效果处理：取得对象卡，若对象卡仍与效果关联，则将其送回持有者手卡。
function c52182715.retop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果处理时当前连锁的第一个对象卡（这里即被选择的那张魔法·陷阱卡）。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 将对象卡以REASON_EFFECT为原因送回持有者手卡。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
