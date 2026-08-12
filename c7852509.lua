--破壊輪廻
-- 效果：
-- ①：这张卡只要在魔法与陷阱区域存在，卡名当作「破坏轮」使用。
-- ②：1回合1次，场上的怪兽被效果破坏的场合，以场上1只怪兽为对象才能发动。那只怪兽破坏，双方受到500伤害。
function c7852509.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 注册卡名变更效果，使这张卡在魔法与陷阱区域存在时卡名当作「破坏轮」使用。
	aux.EnableChangeCode(c,83555666)
	-- ②：1回合1次，场上的怪兽被效果破坏的场合，以场上1只怪兽为对象才能发动。那只怪兽破坏，双方受到500伤害。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetRange(LOCATION_SZONE)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1)
	e3:SetCondition(c7852509.descon)
	e3:SetTarget(c7852509.destg)
	e3:SetOperation(c7852509.desop)
	c:RegisterEffect(e3)
end
-- 过滤被效果破坏且原本在怪兽区域存在的卡。
function c7852509.cfilter(c)
	return c:IsReason(REASON_EFFECT) and c:IsPreviousLocation(LOCATION_MZONE)
end
-- 检查被破坏的卡中是否存在满足条件的怪兽，作为效果发动的条件。
function c7852509.descon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c7852509.cfilter,1,nil)
end
-- 效果发动时的目标选择与操作信息设置函数。
function c7852509.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) end
	-- 检查场上是否存在可以作为对象的怪兽。
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要破坏的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上1只怪兽作为效果的对象。
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息：破坏选中的怪兽。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 设置操作信息：给双方玩家造成500点伤害。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,PLAYER_ALL,500)
end
-- 效果处理函数，执行破坏对象怪兽并给双方造成伤害的操作。
function c7852509.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选为对象的怪兽。
	local tc=Duel.GetFirstTarget()
	-- 确认对象怪兽是否仍适用此效果，并将其因效果破坏。
	if tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)~=0 then
		-- 给与自己500点效果伤害（分步处理）。
		Duel.Damage(tp,500,REASON_EFFECT,true)
		-- 给与对方500点效果伤害（分步处理）。
		Duel.Damage(1-tp,500,REASON_EFFECT,true)
		-- 结束分步伤害处理，触发伤害结算时点。
		Duel.RDComplete()
	end
end
