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
-- 选择目标怪兽，确保其在主要怪兽区且为守备表示
function c15658249.postg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsDefensePos() end
	if chk==0 then return true end
	-- 向玩家提示“请选择要改变表示形式的怪兽”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
	-- 选择场上1只守备表示的怪兽作为目标
	local g=Duel.SelectTarget(tp,Card.IsDefensePos,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置连锁操作信息，指定将要改变表示形式的怪兽数量
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,g:GetCount(),0,0)
end
-- 处理效果，将目标怪兽变为表侧攻击表示
function c15658249.posop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的首个目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsDefensePos() and tc:IsRelateToEffect(e) then
		-- 将目标怪兽变为表侧攻击表示
		Duel.ChangePosition(tc,0,0,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK)
	end
end
