--アポクリフォート・カーネル
-- 效果：
-- 这张卡不能特殊召唤，把自己场上3只「机壳」怪兽解放的场合才能通常召唤。
-- ①：通常召唤的这张卡不受魔法·陷阱卡的效果影响，也不受原本的等级或者阶级比这张卡的等级低的怪兽发动的效果影响。
-- ②：1回合1次，以对方场上1只怪兽为对象才能发动。那只怪兽的控制权直到结束阶段得到。
function c40061558.initial_effect(c)
	-- 效果原文：这张卡不能特殊召唤
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- 效果原文：把自己场上3只「机壳」怪兽解放的场合才能通常召唤
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_TRIBUTE_LIMIT)
	e2:SetValue(c40061558.tlimit)
	c:RegisterEffect(e2)
	-- 效果原文：①：通常召唤的这张卡不受魔法·陷阱卡的效果影响，也不受原本的等级或者阶级比这张卡的等级低的怪兽发动的效果影响
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(40061558,0))  --"把3只「机壳」怪兽解放"
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e3:SetCode(EFFECT_LIMIT_SUMMON_PROC)
	e3:SetCondition(c40061558.ttcon)
	e3:SetOperation(c40061558.ttop)
	e3:SetValue(SUMMON_TYPE_ADVANCE)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_LIMIT_SET_PROC)
	c:RegisterEffect(e4)
	-- 效果原文：②：1回合1次，以对方场上1只怪兽为对象才能发动。那只怪兽的控制权直到结束阶段得到
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_UNCOPYABLE)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCode(EFFECT_IMMUNE_EFFECT)
	e5:SetCondition(c40061558.immcon)
	e5:SetValue(c40061558.efilter)
	c:RegisterEffect(e5)
	-- 检索满足条件的卡片组
	local e6=Effect.CreateEffect(c)
	e6:SetCategory(CATEGORY_CONTROL)
	e6:SetType(EFFECT_TYPE_IGNITION)
	e6:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e6:SetRange(LOCATION_MZONE)
	e6:SetCountLimit(1)
	e6:SetTarget(c40061558.cttg)
	e6:SetOperation(c40061558.ctop)
	c:RegisterEffect(e6)
end
-- 判断祭品是否为机壳怪兽
function c40061558.tlimit(e,c)
	return not c:IsSetCard(0xaa)
end
-- 判断是否满足通常召唤的祭品条件
function c40061558.ttcon(e,c,minc)
	if c==nil then return true end
	-- 判断场上是否存在3个祭品
	return minc<=3 and Duel.CheckTribute(c,3)
end
-- 选择并解放3个祭品
function c40061558.ttop(e,tp,eg,ep,ev,re,r,rp,c)
	-- 选择3个祭品
	local g=Duel.SelectTribute(tp,c,3,3)
	c:SetMaterial(g)
	-- 解放祭品
	Duel.Release(g,REASON_SUMMON+REASON_MATERIAL)
end
-- 判断是否为通常召唤
function c40061558.immcon(e)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_NORMAL)
end
-- 判断效果是否为魔法或陷阱卡
function c40061558.efilter(e,te)
	if te:IsActiveType(TYPE_SPELL+TYPE_TRAP) then return true
	-- 调用机壳怪兽通用抗性过滤函数
	else return aux.qlifilter(e,te) end
end
-- 选择目标怪兽
function c40061558.cttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsControlerCanBeChanged() end
	-- 检查是否存在可选择的目标怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsControlerCanBeChanged,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示选择目标怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
	-- 选择目标怪兽
	local g=Duel.SelectTarget(tp,Card.IsControlerCanBeChanged,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,0,0)
end
-- 执行控制权转移
function c40061558.ctop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 获得目标怪兽的控制权
		Duel.GetControl(tc,tp,PHASE_END,1)
	end
end
