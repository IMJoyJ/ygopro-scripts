--E・HERO ダーク・ブライトマン
-- 效果：
-- 「元素英雄 电光侠」＋「元素英雄 死灵暗侠」
-- 这只怪兽不能作融合召唤以外的特殊召唤。这张卡攻击守备表示怪兽时，若这张卡的攻击力超过守备表示怪兽的守备力，给与对方基本分那个数值的战斗伤害。这张卡攻击的场合，伤害步骤结束时变成守备表示。这张卡被破坏时，把对方场上1只怪兽破坏。
function c41517968.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加融合召唤手续，使用卡号为20721928和89252153的2只怪兽为融合素材
	aux.AddFusionProcCode2(c,20721928,89252153,true,true)
	-- 这只怪兽不能作融合召唤以外的特殊召唤
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置该效果为融合召唤的特殊召唤条件
	e1:SetValue(aux.fuslimit)
	c:RegisterEffect(e1)
	-- 这张卡攻击守备表示怪兽时，若这张卡的攻击力超过守备表示怪兽的守备力，给与对方基本分那个数值的战斗伤害
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_PIERCE)
	c:RegisterEffect(e2)
	-- 这张卡攻击的场合，伤害步骤结束时变成守备表示
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_DAMAGE_STEP_END)
	e3:SetCondition(c41517968.poscon)
	e3:SetOperation(c41517968.posop)
	c:RegisterEffect(e3)
	-- 这张卡被破坏时，把对方场上1只怪兽破坏
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(41517968,0))  --"破坏"
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e4:SetCategory(CATEGORY_DESTROY)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetCode(EVENT_DESTROYED)
	e4:SetTarget(c41517968.destg)
	e4:SetOperation(c41517968.desop)
	c:RegisterEffect(e4)
end
c41517968.material_setcode=0x8
-- 判断是否为攻击怪兽且参与了战斗
function c41517968.poscon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前处理的卡是否为攻击怪兽且参与了战斗
	return e:GetHandler()==Duel.GetAttacker() and e:GetHandler():IsRelateToBattle()
end
-- 若攻击表示则变为守备表示
function c41517968.posop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsAttackPos() then
		-- 将目标怪兽变为守备表示
		Duel.ChangePosition(c,POS_FACEUP_DEFENSE)
	end
end
-- 设置破坏效果的目标选择逻辑
function c41517968.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) end
	if chk==0 then return true end
	-- 提示选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上的1只怪兽作为破坏对象
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置连锁操作信息，指定将要破坏的卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 执行破坏效果
function c41517968.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中选择的目标卡
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 将目标卡以效果原因破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
