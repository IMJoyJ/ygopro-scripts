--竜宮之姫
-- 效果：
-- 这张卡不能特殊召唤。召唤·反转回合的结束阶段时回到主人的手卡。这张卡召唤·反转时，可以选择对方场上的1只表侧表示的怪兽改变表示形式。
function c39751093.initial_effect(c)
	-- 为这张卡添加灵魂怪兽效果：在召唤成功或反转的回合结束阶段，这张卡回到持有者手卡。
	aux.EnableSpiritReturn(c,EVENT_SUMMON_SUCCESS,EVENT_FLIP)
	-- 这张卡不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置特殊召唤条件的判定值恒为假，使这张卡不能被特殊召唤。
	e1:SetValue(aux.FALSE)
	c:RegisterEffect(e1)
	-- 这张卡召唤·反转时，可以选择对方场上的1只表侧表示的怪兽改变表示形式。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(39751093,1))  --"改变表示形式"
	e4:SetCategory(CATEGORY_POSITION)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_SUMMON_SUCCESS)
	e4:SetTarget(c39751093.target)
	e4:SetOperation(c39751093.operation)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EVENT_FLIP)
	c:RegisterEffect(e5)
end
-- 定义可选对象的条件：怪兽需为表侧表示，且能够被改变表示形式（通常在对方场上范围内选择）。
function c39751093.filter(c)
	return c:IsFaceup() and c:IsCanChangePosition()
end
-- 效果发动的目标选择处理：若存在合法对象，则从对方场上选择1只满足条件的表侧表示怪兽作为效果对象，并设定操作信息。
function c39751093.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and c39751093.filter(chkc) end
	-- 在效果发动合法性检查时，判断对方场上是否存在至少1只满足条件的表侧表示怪兽；若不存在则不能发动。
	if chk==0 then return Duel.IsExistingTarget(c39751093.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 显示“请选择要改变表示形式的怪兽”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
	-- 玩家选择对方场上的1只满足条件的表侧表示怪兽，并将其登记为本次效果的对象（取对象效果）。
	local g=Duel.SelectTarget(tp,c39751093.filter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 将本次效果处理信息登记为“变更表示形式”，并记录对象为已选择的怪兽，用于连锁处理中的效果检测。
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
end
-- 效果处理时，取回对象怪兽，若其仍表侧表示且与效果关联，则将其表示形式反转（攻击变守备、守备变攻击）。
function c39751093.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果处理时已选择的对象怪兽（第一张目标卡）。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 变更对象怪兽的表示形式：表侧攻击表示改为表侧守备表示，表侧守备表示改为表侧攻击表示。
		Duel.ChangePosition(tc,POS_FACEUP_DEFENSE,0,POS_FACEUP_ATTACK,0)
	end
end
