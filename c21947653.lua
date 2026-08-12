--E-HERO ライトニング・ゴーレム
-- 效果：
-- 「元素英雄 电光侠」＋「元素英雄 黏土侠」
-- 这张卡用「暗黑融合」的效果才能特殊召唤。
-- ①：1回合1次，以场上1只怪兽为对象才能发动。那只怪兽破坏。
function c21947653.initial_effect(c)
	-- 记录此卡可以通过「暗黑融合」特殊召唤
	aux.AddCodeList(c,94820406)
	c:EnableReviveLimit()
	-- 设置融合召唤所需的2只融合素材卡号为「元素英雄 电光侠」和「元素英雄 黏土侠」
	aux.AddFusionProcCode2(c,20721928,84327329,true,true)
	-- 这张卡用「暗黑融合」的效果才能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置特殊召唤条件为必须通过「暗黑融合」或「暗黑神召」
	e1:SetValue(aux.DarkFusionLimit)
	c:RegisterEffect(e1)
	-- ①：1回合1次，以场上1只怪兽为对象才能发动。那只怪兽破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(21947653,0))  --"破坏"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetCountLimit(1)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetTarget(c21947653.target)
	e2:SetOperation(c21947653.operation)
	c:RegisterEffect(e2)
end
c21947653.material_setcode=0x8
c21947653.dark_calling=true
-- 设置效果目标为场上任意1只怪兽
function c21947653.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) end
	-- 检查是否满足选择目标的条件
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上1只怪兽作为破坏对象
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置连锁操作信息为破坏效果
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 执行破坏效果
function c21947653.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁选择的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 将目标怪兽破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
