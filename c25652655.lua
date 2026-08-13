--チェンジ・シンクロン
-- 效果：
-- 这张卡被同调怪兽的同调召唤使用送去墓地的场合，选择对方场上存在的1只怪兽把表示形式变更。
function c25652655.initial_effect(c)
	-- 这张卡被同调怪兽的同调召唤使用送去墓地的场合，选择对方场上存在的1只怪兽把表示形式变更。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(25652655,0))  --"变更表示形式"
	e1:SetCategory(CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_BE_MATERIAL)
	e1:SetCondition(c25652655.condition)
	e1:SetTarget(c25652655.target)
	e1:SetOperation(c25652655.operation)
	c:RegisterEffect(e1)
end
-- 效果发动条件：这张卡当前位于墓地，且作为同调召唤的素材被送去墓地（REASON_SYNCHRO）。
function c25652655.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and r==REASON_SYNCHRO
end
-- 对象选择过滤：选择对方场上可以变更表示形式的怪兽作为对象。
function c25652655.filter(c)
	return c:IsCanChangePosition()
end
-- 发动时选择取对象：从对方场上选择1只满足过滤条件的怪兽，并设置改变表示形式的操作信息。
function c25652655.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c25652655.filter(chkc) end
	if chk==0 then return true end
	-- 提示玩家选择要改变表示形式的怪兽（HINTMSG_POSCHANGE）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
	-- 选择对方场上1只可变更表示形式的怪兽作为效果对象（取对象效果）。
	local g=Duel.SelectTarget(tp,c25652655.filter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置本次连锁的操作信息：效果分类为改变表示形式（CATEGORY_POSITION），对象为已选择的怪兽，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,g:GetCount(),0,0)
end
-- 效果处理：取得选择的对象，若对象仍与效果关联，则变更其表示形式。
function c25652655.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 取得本次效果处理时第一个（也是唯一一个）对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 按规则变更对象怪兽的表示形式：表侧攻击变表侧守备、里侧攻击变里侧守备、表侧守备变表侧攻击、里侧守备变表侧攻击。
		Duel.ChangePosition(tc,POS_FACEUP_DEFENSE,POS_FACEDOWN_DEFENSE,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK)
	end
end
