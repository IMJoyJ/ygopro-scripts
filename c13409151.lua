--砂バク
-- 效果：
-- ①：这张卡反转的场合，以「沙貘」以外的场上1只表侧表示怪兽为对象发动。那只怪兽变成里侧守备表示。
function c13409151.initial_effect(c)
	-- ①：这张卡反转的场合，以「沙貘」以外的场上1只表侧表示怪兽为对象发动。那只怪兽变成里侧守备表示。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(13409151,0))  --"变成里侧守备"
	e1:SetCategory(CATEGORY_POSITION+CATEGORY_MSET)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP)
	e1:SetTarget(c13409151.postg)
	e1:SetOperation(c13409151.posop)
	c:RegisterEffect(e1)
end
-- 过滤函数：选择场上表侧表示、卡名不是「沙貘」（13409151）且可以变成里侧守备表示的怪兽作为可选对象。
function c13409151.filter(c)
	return c:IsFaceup() and not c:IsCode(13409151) and c:IsCanTurnSet()
end
-- 发动时的目标选择处理：若检查已选对象则验证其位于怪兽区且满足过滤条件；非连锁处理时确认可以发动，提示玩家选择表侧表示的怪兽，选择1只符合条件的对象，并设置将改变其表示形式的操作信息。
function c13409151.postg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c13409151.filter(chkc) end
	if chk==0 then return true end
	-- 向当前玩家发出选择提示消息，提示文字为“请选择表侧表示的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 从双方怪兽区选择1只满足过滤条件的表侧表示怪兽作为效果对象（取对象）。
	local g=Duel.SelectTarget(tp,c13409151.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 将本次连锁处理的操作信息设置为：改变表示形式（CATEGORY_POSITION），对象为已选择的怪兽组，数量为选择的数量。
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,g:GetCount(),0,0)
end
-- 效果处理时的操作：取得效果对象，若对象仍与效果关联且为表侧表示，则将其变成里侧守备表示。
function c13409151.posop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁的效果处理对象卡（即发动时选择的怪兽）。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将该对象怪兽的表示形式变更为里侧守备表示。
		Duel.ChangePosition(tc,POS_FACEDOWN_DEFENSE)
	end
end
