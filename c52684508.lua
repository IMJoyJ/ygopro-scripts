--黒炎弾
-- 效果：
-- 这张卡发动的回合，「真红眼黑龙」不能攻击。
-- ①：以自己的怪兽区域1只「真红眼黑龙」为对象才能发动。给与对方那只「真红眼黑龙」的原本攻击力数值的伤害。
function c52684508.initial_effect(c)
	-- 这张卡发动的回合，「真红眼黑龙」不能攻击。①：以自己的怪兽区域1只「真红眼黑龙」为对象才能发动。给与对方那只「真红眼黑龙」的原本攻击力数值的伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c52684508.cost)
	e1:SetTarget(c52684508.target)
	e1:SetOperation(c52684508.activate)
	c:RegisterEffect(e1)
	-- 注册攻击活动计数器：在本回合内每当有怪兽进行攻击时，以该怪兽调用counterfilter，若返回false则计数+1；该计数用于黑炎弹发动代价的判定。
	Duel.AddCustomActivityCounter(52684508,ACTIVITY_ATTACK,c52684508.counterfilter)
end
-- counterfilter过滤函数：对攻击的怪兽判断，若非「真红眼黑龙」则返回true（不计数），若是「真红眼黑龙」则返回false（计数+1），因此计数器实际标记本回合「真红眼黑龙」是否进行过攻击。
function c52684508.counterfilter(c)
	return not c:IsCode(74677422)
end
-- cost函数：先确认本回合「真红眼黑龙」尚未攻击过（计数器为0），然后创建并注册一个持续到结束阶段的「真红眼黑龙不能攻击」的誓约效果，作为发动代价/自肃。
function c52684508.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- cost检查阶段：当chk==0时返回自定义计数器52684508在当前玩家tp的计数是否为0，即本回合「真红眼黑龙」尚未进行过攻击，满足此条件才允许发动。
	if chk==0 then return Duel.GetCustomActivityCount(52684508,tp,ACTIVITY_ATTACK)==0 end
	-- 这张卡发动的回合，「真红眼黑龙」不能攻击。①：以自己的怪兽区域1只「真红眼黑龙」为对象才能发动。给与对方那只「真红眼黑龙」的原本攻击力数值的伤害。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetProperty(EFFECT_FLAG_OATH+EFFECT_FLAG_IGNORE_IMMUNE)
	-- 设置自肃效果的影响对象：只有卡号74677422的「真红眼黑龙」会被禁止攻击的效果所影响。
	e1:SetTarget(aux.TargetBoolFunction(Card.IsCode,74677422))
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将上述「真红眼黑龙不能攻击」的自肃效果注册到当前玩家tp的场上，使其实际生效。
	Duel.RegisterEffect(e1,tp)
end
-- filter过滤函数：定义黑炎弹可选对象的条件——表侧表示、卡号为74677422（真红眼黑龙）、原本攻击力大于0。
function c52684508.filter(c)
	return c:IsFaceup() and c:IsCode(74677422) and c:GetBaseAttack()>0
end
-- target函数：进行发动前判定和目标选择。若自己场上存在满足filter的真红眼黑龙，则提示玩家选择其中1只作为对象，并设置连锁的伤害信息。
function c52684508.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c52684508.filter(chkc) end
	-- 发动条件检查：确认自己场上主要怪兽区是否存在至少1只满足filter条件的「真红眼黑龙」，否则不能发动。
	if chk==0 then return Duel.IsExistingTarget(c52684508.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 向操作玩家发送“请选择表侧表示的卡”的提示信息，用于选择对象的UI提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让当前玩家从自己场上主要怪兽区选择1只满足filter条件的「真红眼黑龙」，并将其登记为本次连锁的对象。
	local g=Duel.SelectTarget(tp,c52684508.filter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置操作信息：本次效果分类为伤害，目标为对方玩家，伤害数值等于所选对象怪兽的原本攻击力。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,g:GetFirst():GetBaseAttack())
end
-- activate函数：效果处理时，取得对象怪兽，若其仍表侧表示且与效果相关联，则给予对方该怪兽原本攻击力数值的伤害。
function c52684508.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁的第一个对象卡，即黑炎弹发动时选择的那只「真红眼黑龙」。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 给予对方玩家该「真红眼黑龙」原本攻击力数值的效果伤害（真红眼黑龙的原本攻击力为2400）。
		Duel.Damage(1-tp,tc:GetBaseAttack(),REASON_EFFECT)
	end
end
