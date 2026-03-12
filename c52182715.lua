--グリーン・ダストン
-- 效果：
-- 这张卡不能解放，也不能作为融合·同调·超量召唤的素材。场上的这张卡被破坏时，这张卡的控制者选择自己场上1张魔法·陷阱卡回到持有者手卡。「绿尘妖」在自己场上只能有1只表侧表示存在。
function c52182715.initial_effect(c)
	c:SetUniqueOnField(1,0,52182715)
	-- 效果原文：这张卡不能解放，也不能作为融合·同调·超量召唤的素材。
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
	-- 效果原文：这张卡不能解放，也不能作为融合·同调·超量召唤的素材。
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
	-- 效果原文：场上的这张卡被破坏时，这张卡的控制者选择自己场上1张魔法·陷阱卡回到持有者手卡。
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
-- 判断是否为融合召唤的素材限制条件
function c52182715.fuslimit(e,c,sumtype)
	return sumtype==SUMMON_TYPE_FUSION
end
-- 判断是否为被破坏且在场上的状态
function c52182715.retcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_DESTROY) and c:IsPreviousLocation(LOCATION_ONFIELD)
end
-- 筛选魔法·陷阱卡返回手牌的过滤函数
function c52182715.filter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- 设置选择目标并设定操作信息
function c52182715.rettg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local prec=e:GetHandler():GetPreviousControler()
	if chkc then return chkc:IsControler(prec) and chkc:IsOnField() and c52182715.filter(chkc) end
	if chk==0 then return true end
	-- 提示选择要返回手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择符合条件的魔法·陷阱卡作为目标
	local g=Duel.SelectTarget(prec,c52182715.filter,prec,LOCATION_ONFIELD,0,1,1,nil)
	-- 设置操作信息为将目标卡送入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,g:GetCount(),0,0)
end
-- 执行将目标卡送回手牌的操作
function c52182715.retop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁处理的目标卡
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 将目标卡以效果原因送入手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
