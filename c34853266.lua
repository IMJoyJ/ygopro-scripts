--月読命
-- 效果：
-- 这张卡不能特殊召唤。
-- ①：这张卡召唤·反转的场合，以场上1只表侧表示怪兽为对象发动。那只怪兽变成里侧守备表示。
-- ②：这张卡召唤·反转的回合的结束阶段发动。这张卡回到持有者手卡。
function c34853266.initial_effect(c)
	-- 为月读命添加灵魂怪兽共通效果：使其在召唤或反转的回合结束阶段时回到持有者手卡，对应效果②“这张卡召唤·反转的回合的结束阶段发动。这张卡回到持有者手卡。”
	aux.EnableSpiritReturn(c,EVENT_SUMMON_SUCCESS,EVENT_FLIP)
	-- 这张卡不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 将特殊召唤条件的判定值设为始终为false，从而禁止这张卡以任何方式特殊召唤。
	e1:SetValue(aux.FALSE)
	c:RegisterEffect(e1)
	-- ①：这张卡召唤·反转的场合，以场上1只表侧表示怪兽为对象发动。那只怪兽变成里侧守备表示。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(34853266,1))  --"改变表示形式"
	e4:SetCategory(CATEGORY_POSITION+CATEGORY_MSET)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e4:SetCode(EVENT_SUMMON_SUCCESS)
	e4:SetTarget(c34853266.postg)
	e4:SetOperation(c34853266.posop)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EVENT_FLIP)
	c:RegisterEffect(e5)
end
-- 定义可选择为对象的怪兽条件：必须处于表侧表示，并且可以被变成里侧表示。
function c34853266.filter(c)
	return c:IsFaceup() and c:IsCanTurnSet()
end
-- 效果发动时的目标选择处理：从双方主要怪兽区选择1只满足条件的表侧表示怪兽作为对象，并设置对应的操作信息为变更表示形式。
function c34853266.postg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c34853266.filter(chkc) end
	if chk==0 then return true end
	-- 向操作者展示“请选择表侧表示的卡”的提示信息，引导玩家进行对象选择。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让玩家从双方主要怪兽区选择1只表侧表示且可变成里侧表示的怪兽作为效果对象，同时自动将其登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,c34853266.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 将本次连锁的操作信息登记为“变更表示形式”，对象为已选择的怪兽，数量为1，供后续处理及连锁反应检测使用。
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,g:GetCount(),0,0)
end
-- 效果处理阶段：取得效果对象，若该怪兽仍与效果存在关联且为表侧表示，则将其变为里侧守备表示。
function c34853266.posop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果发动时选择的第一张对象怪兽卡。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将该对象怪兽的表示形式变为里侧守备表示。
		Duel.ChangePosition(tc,POS_FACEDOWN_DEFENSE)
	end
end
