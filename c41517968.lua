--E・HERO ダーク・ブライトマン
-- 效果：
-- 「元素英雄 电光侠」＋「元素英雄 死灵暗侠」
-- 这只怪兽不能作融合召唤以外的特殊召唤。这张卡攻击守备表示怪兽时，若这张卡的攻击力超过守备表示怪兽的守备力，给与对方基本分那个数值的战斗伤害。这张卡攻击的场合，伤害步骤结束时变成守备表示。这张卡被破坏时，把对方场上1只怪兽破坏。
function c41517968.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡添加融合召唤手续，指定融合素材为「元素英雄 电光侠」（20721928）与「元素英雄 死灵暗侠」（89252153），使这张卡能通过上述素材进行融合召唤。
	aux.AddFusionProcCode2(c,20721928,89252153,true,true)
	-- 这只怪兽不能作融合召唤以外的特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置特殊召唤条件的判定函数为aux.fuslimit，即仅当召唤类型为融合召唤时才允许特殊召唤，从而限制这张卡只能通过融合召唤出场。
	e1:SetValue(aux.fuslimit)
	c:RegisterEffect(e1)
	-- 这张卡攻击守备表示怪兽时，若这张卡的攻击力超过守备表示怪兽的守备力，给与对方基本分那个数值的战斗伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_PIERCE)
	c:RegisterEffect(e2)
	-- 这张卡攻击的场合，伤害步骤结束时变成守备表示。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_DAMAGE_STEP_END)
	e3:SetCondition(c41517968.poscon)
	e3:SetOperation(c41517968.posop)
	c:RegisterEffect(e3)
	-- 这张卡被破坏时，把对方场上1只怪兽破坏。
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
-- 该函数为e3（伤害步骤结束时变守备）效果的发动条件，判断此卡是否为当时进行战斗的攻击怪兽，并且此卡与本次战斗保持关联（未在战斗中离场），满足条件时才允许发动。
function c41517968.poscon(e,tp,eg,ep,ev,re,r,rp)
	-- 返回条件：效果持有者（此卡）是当前攻击怪兽，且此卡仍与本次战斗相关尚未离场，确保仅在它实际进行攻击的那个伤害步骤结束时触发变守备效果。
	return e:GetHandler()==Duel.GetAttacker() and e:GetHandler():IsRelateToBattle()
end
-- 该函数是e3的效果处理：在此卡处于攻击表示时将这张卡变更成表侧守备表示，实现在攻击过的伤害步骤结束时变为守备表示。
function c41517968.posop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsAttackPos() then
		-- 将这张卡的表示形式改变为表侧守备表示。当前判断了它处于攻击表示，因此只会把攻击表示的此卡转为守备。
		Duel.ChangePosition(c,POS_FACEUP_DEFENSE)
	end
end
-- 该函数是e4被破坏时效果的取对象目标处理：当连锁指定目标时，只接受对方场上主要怪兽区的怪兽；在发动时允许发动并选择对方场上1只怪兽作为破坏对象，同时登记破坏操作信息。
function c41517968.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) end
	if chk==0 then return true end
	-- 向发动玩家发送选择提示消息，提示内容是“请选择要破坏的卡”（HINTMSG_DESTROY），用于在下一步选择对象前进行界面提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让发动玩家从对方场上主要怪兽区选择1只怪兽作为效果对象（选择条件为aux.TRUE，即任意怪兽都可以），并将所选的卡登记为当前连锁的效果对象。
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置当前连锁的效果操作信息，声明该效果将破坏所选的g中的卡，破坏数量为g:GetCount()，以供连锁判定和相关效果（如星尘龙等）进行响应。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 该函数是e4被破坏时效果的破坏处理：取出之前选择的目标怪兽，若目标仍然与这个效果关联（没有离场或未被无效），则将其破坏。
function c41517968.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中登记的第一个效果对象卡片，也就是之前被选择的对方场上1只怪兽。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 将目标卡片以效果原因（REASON_EFFECT）破坏，送入墓地。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
