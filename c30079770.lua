--真紅眼の黒炎竜
-- 效果：
-- ①：这张卡只要在场上·墓地存在，当作通常怪兽使用。
-- ②：可以把场上的当作通常怪兽使用的这张卡作为通常召唤作再1次召唤。那个场合这张卡变成当作效果怪兽使用并得到以下效果。
-- ●这张卡进行战斗的战斗阶段结束时才能发动。给与对方这张卡的原本攻击力数值的伤害。「真红眼黑炎龙」的这个效果1回合只能使用1次。
function c30079770.initial_effect(c)
	-- 为卡片添加二重怪兽属性
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
-- 判断是否为再度召唤状态且本回合已进行过战斗
function c30079770.damcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否为再度召唤状态且本回合已进行过战斗
	return aux.IsDualState(e) and e:GetHandler():GetBattledGroupCount()>0
end
-- 设置伤害效果的处理信息
function c30079770.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local atk=e:GetHandler():GetBaseAttack()
	-- 设置连锁操作信息，指定将对对方造成伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,atk)
end
-- 执行伤害效果的处理函数
function c30079770.damop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		local atk=c:GetBaseAttack()
		-- 对对方玩家造成等于自身攻击力的伤害
		Duel.Damage(1-tp,atk,REASON_EFFECT)
	end
end
