--真紅眼の黒炎竜
-- 效果：
-- ①：这张卡只要在场上·墓地存在，当作通常怪兽使用。
-- ②：可以把场上的当作通常怪兽使用的这张卡作为通常召唤作再1次召唤。那个场合这张卡变成当作效果怪兽使用并得到以下效果。
-- ●这张卡进行战斗的战斗阶段结束时才能发动。给与对方这张卡的原本攻击力数值的伤害。「真红眼黑炎龙」的这个效果1回合只能使用1次。
function c30079770.initial_effect(c)
	-- 为这张卡附加二重怪兽属性，使其视为二重怪兽并适用“只要在场上·墓地存在当作通常怪兽使用”的规则。
	aux.EnableDualAttribute(c)
	-- ●这张卡进行战斗的战斗阶段结束时才能发动。给与对方这张卡的原本攻击力数值的伤害。「真红眼黑炎龙」的这个效果1回合只能使用1次。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_PHASE+PHASE_BATTLE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCountLimit(1,30079770)
	e1:SetCondition(c30079770.damcon)
	e1:SetTarget(c30079770.damtg)
	e1:SetOperation(c30079770.damop)
	c:RegisterEffect(e1)
end
-- 定义战斗阶段结束时伤害效果的发动条件判断函数。
function c30079770.damcon(e,tp,eg,ep,ev,re,r,rp)
	-- 发动条件：这张卡处于再度召唤状态（当作效果怪兽使用），并且本回合这张卡进行过战斗。
	return aux.IsDualState(e) and e:GetHandler():GetBattledGroupCount()>0
end
-- 定义伤害效果的发动时处理：在发动确认时判定合法并登记预计造成的伤害信息。
function c30079770.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local atk=e:GetHandler():GetBaseAttack()
	-- 登记连锁操作信息：该效果属于不取对象的伤害效果，伤害对象为对方玩家，伤害数值为这张卡的原本攻击力。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,atk)
end
-- 定义伤害效果的实际结算处理函数。
function c30079770.damop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		local atk=c:GetBaseAttack()
		-- 给对方造成这张卡原本攻击力数值的效果伤害。
		Duel.Damage(1-tp,atk,REASON_EFFECT)
	end
end
