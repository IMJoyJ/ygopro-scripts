--黒炎弾
-- 效果：
-- 这张卡发动的回合，「真红眼黑龙」不能攻击。
-- ①：以自己的怪兽区域1只「真红眼黑龙」为对象才能发动。给与对方那只「真红眼黑龙」的原本攻击力数值的伤害。
function c52684508.initial_effect(c)
	-- ①：以自己的怪兽区域1只「真红眼黑龙」为对象才能发动。给与对方那只「真红眼黑龙」的原本攻击力数值的伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c52684508.cost)
	e1:SetTarget(c52684508.target)
	e1:SetOperation(c52684508.activate)
	c:RegisterEffect(e1)
	-- 设置一个计数器，用于记录玩家在回合中是否已经进行过攻击操作，该计数器将用于cost函数中判断是否可以发动效果。
	Duel.AddCustomActivityCounter(52684508,ACTIVITY_ATTACK,c52684508.counterfilter)
end
-- 定义计数器过滤函数，当卡片不是「真红眼黑龙」时，计数器增加1。
function c52684508.counterfilter(c)
	return not c:IsCode(74677422)
end
-- cost函数：检查当前玩家在本回合是否已经进行过攻击操作，若未进行则设置一个使「真红眼黑龙」不能攻击的效果。
function c52684508.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断当前玩家在本回合是否已经进行过攻击操作，若为0则表示尚未攻击，可以发动此卡效果。
	if chk==0 then return Duel.GetCustomActivityCount(52684508,tp,ACTIVITY_ATTACK)==0 end
	-- 设置一个场上的效果，使所有「真红眼黑龙」不能攻击。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetProperty(EFFECT_FLAG_OATH+EFFECT_FLAG_IGNORE_IMMUNE)
	-- 设置该效果的目标为所有「真红眼黑龙」卡片。
	e1:SetTarget(aux.TargetBoolFunction(Card.IsCode,74677422))
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将该效果注册给当前玩家，使其生效。
	Duel.RegisterEffect(e1,tp)
end
-- 定义过滤函数，用于筛选表侧表示的「真红眼黑龙」且攻击力大于0的怪兽。
function c52684508.filter(c)
	return c:IsFaceup() and c:IsCode(74677422) and c:GetBaseAttack()>0
end
-- target函数：选择一个满足条件的「真红眼黑龙」作为效果对象，并设置操作信息为对对方造成该怪兽攻击力数值的伤害。
function c52684508.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c52684508.filter(chkc) end
	-- 判断场上是否存在满足条件的「真红眼黑龙」作为效果对象。
	if chk==0 then return Duel.IsExistingTarget(c52684508.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择一张表侧表示的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 从己方场上选择一只满足条件的「真红眼黑龙」作为效果对象。
	local g=Duel.SelectTarget(tp,c52684508.filter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置操作信息，表明本次连锁将对对方造成伤害，伤害值为所选怪兽的原本攻击力。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,g:GetFirst():GetBaseAttack())
end
-- activate函数：对选定的目标怪兽造成其原本攻击力数值的伤害。
function c52684508.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的效果目标卡片。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 以效果发动者为伤害来源，对目标怪兽造成其原本攻击力数值的伤害。
		Duel.Damage(1-tp,tc:GetBaseAttack(),REASON_EFFECT)
	end
end
