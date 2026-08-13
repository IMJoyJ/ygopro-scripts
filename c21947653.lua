--E-HERO ライトニング・ゴーレム
-- 效果：
-- 「元素英雄 电光侠」＋「元素英雄 黏土侠」
-- 这张卡用「暗黑融合」的效果才能特殊召唤。
-- ①：1回合1次，以场上1只怪兽为对象才能发动。那只怪兽破坏。
function c21947653.initial_effect(c)
	-- 登记这张卡关联的卡号94820406（暗黑融合），用于识别效果中提到的卡名；这是效果外文本的辅助记录。
	aux.AddCodeList(c,94820406)
	c:EnableReviveLimit()
	-- 为这张卡添加融合召唤手续：融合素材为卡号20721928（元素英雄 电光侠）和卡号84327329（元素英雄 黏土侠），并允许使用融合素材代用品（sub=true）、可作为融合素材手续使用（insf=true），对应效果原文「元素英雄 电光侠」＋「元素英雄 黏土侠」。
	aux.AddFusionProcCode2(c,20721928,84327329,true,true)
	-- 这张卡用「暗黑融合」的效果才能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 将特殊召唤条件设置为aux.DarkFusionLimit，即仅当满足“用「暗黑融合」的效果进行特召”等条件时才允许特殊召唤。
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
-- 发动的目标阶段：检查是否有可选择的怪兽，并让玩家从双方场上选择1只怪兽作为对象，同时设置后续要执行的破坏信息。
function c21947653.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) end
	-- 若在发动合法性检查时，场上不存在任何能被选择为对象的怪兽，则该效果不能发动。
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 显示“请选择要破坏的卡”的选择提示，供玩家选择破坏对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 从双方场上选择1只怪兽作为这张卡效果的对象，并将其登记为该连锁的对象卡。
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 将本次连锁的操作信息登记为破坏效果，目标为已选择的怪兽，数量为其数量，以便其他卡的效果能够正确响应和判定。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果处理阶段：若对象怪兽仍与这张卡的效果相关联，则将那只怪兽破坏。
function c21947653.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 取得发动时选择的那1只对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 以效果原因（REASON_EFFECT）将对象怪兽破坏。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
