--ワーム・バルサス
-- 效果：
-- 这张卡召唤成功时，把场上守备表示存在的1只怪兽变成表侧攻击表示。
function c15658249.initial_effect(c)
	-- 这张卡召唤成功时，把场上守备表示存在的1只怪兽变成表侧攻击表示。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(15658249,0))  --"变更表示形式"
	e1:SetType(EFFECT_TYPE_TRIGGER_F+EFFECT_TYPE_SINGLE)
	e1:SetCategory(CATEGORY_POSITION)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c15658249.postg)
	e1:SetOperation(c15658249.posop)
	c:RegisterEffect(e1)
end
-- 效果发动时的目标处理：先过滤出场上守备表示的怪兽；发动必定成功；然后提示玩家选择1只守备表示怪兽作为对象，并登记改变表示形式的操作信息。
function c15658249.postg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsDefensePos() end
	if chk==0 then return true end
	-- 向操作玩家显示选择提示，提示内容为“请选择要改变表示形式的怪兽”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
	-- 让玩家从双方场上主要怪兽区域选择1只守备表示的怪兽作为效果对象，且该对象会被记录为当前连锁的对象。
	local g=Duel.SelectTarget(tp,Card.IsDefensePos,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息：本次效果处理将改变表示形式，对象为已选择的怪兽组，数量为g中卡的数量。
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,g:GetCount(),0,0)
end
-- 效果处理操作：从连锁对象中取得对象卡，若该卡仍在场上且为守备表示且与效果关联，则改变其表示形式为表侧攻击表示。
function c15658249.posop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中登记的第一个对象卡（即发动时选择的那只守备表示怪兽）。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsDefensePos() and tc:IsRelateToEffect(e) then
		-- 将对象怪兽的表示形式变更为表侧攻击表示。
		Duel.ChangePosition(tc,0,0,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK)
	end
end
