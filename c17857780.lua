--EMチアモール
-- 效果：
-- ←5 【灵摆】 5→
-- ①：自己场上的灵摆怪兽的攻击力上升300。
-- 【怪兽效果】
-- 「娱乐伙伴 啦啦队鼹鼠」的怪兽效果1回合只能使用1次。
-- ①：自己主要阶段以持有和原本攻击力不同攻击力的1只怪兽为对象才能发动。那只怪兽的攻击力数值的以下效果适用。
-- ●那只怪兽的攻击力比原本攻击力高的场合，那只怪兽的攻击力上升1000。
-- ●那只怪兽的攻击力比原本攻击力低的场合，那只怪兽的攻击力下降1000。
function c17857780.initial_effect(c)
	-- 调用辅助函数为这张卡登记灵摆怪兽的基本属性（灵摆召唤、灵摆区发动等），是灵摆卡效果与召唤机制所必需的前置处理。
	aux.EnablePendulumAttribute(c)
	-- ①：自己场上的灵摆怪兽的攻击力上升300。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_PZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(c17857780.atktg)
	e2:SetValue(300)
	c:RegisterEffect(e2)
	-- 「娱乐伙伴 啦啦队鼹鼠」的怪兽效果1回合只能使用1次。①：自己主要阶段以持有和原本攻击力不同攻击力的1只怪兽为对象才能发动。那只怪兽的攻击力数值的以下效果适用。●那只怪兽的攻击力比原本攻击力高的场合，那只怪兽的攻击力上升1000。●那只怪兽的攻击力比原本攻击力低的场合，那只怪兽的攻击力下降1000。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(17857780,0))  --"攻守变化"
	e3:SetCategory(CATEGORY_ATKCHANGE)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,17857780)
	e3:SetTarget(c17857780.target)
	e3:SetOperation(c17857780.operation)
	c:RegisterEffect(e3)
end
-- 该函数为灵摆效果的适用范围判定：仅当被检查的怪兽是灵摆怪兽时返回真，使攻击力提升效果只作用于自己场上的灵摆怪兽。
function c17857780.atktg(e,c)
	return c:IsType(TYPE_PENDULUM)
end
-- 该函数是怪兽效果的对象筛选条件：要求怪兽表侧表示，并且当前攻击力不等于其原本攻击力。
function c17857780.filter(c)
	return c:IsFaceup() and not c:IsAttack(c:GetBaseAttack())
end
-- 效果目标选择函数：在自己主要阶段，从双方怪兽区域选择1只满足条件的表侧表示怪兽作为效果对象；连锁处理时也用于验证指定对象是否仍然合法，并完成取对象操作。
function c17857780.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c17857780.filter(chkc) end
	-- 发动合法性检查：在效果发动时（chk==0）判定场上是否存在至少1只满足filter且可作为效果对象的表侧表示怪兽，若不存在则不能发动。
	if chk==0 then return Duel.IsExistingTarget(c17857780.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向操作玩家显示“请选择表侧表示的卡”的选择提示信息，用于卡牌选择界面的引导。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让操作玩家在双方怪兽区域选择1只满足条件的表侧表示怪兽，并将其登记为本连锁的效果对象（取对象效果）。
	Duel.SelectTarget(tp,c17857780.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
-- 效果处理：取出对象怪兽后，若其仍与效果相关且表侧表示，则比较当前攻击力与原本攻击力：高于原本攻击力则使其攻击力上升1000，低于则下降1000；该增减效果在怪兽离开场上等标准重置时机被重置。
function c17857780.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本连锁中该效果唯一指定的对象怪兽，供后续攻击力比较与增减处理使用。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		local atk=tc:GetAttack()
		local batk=tc:GetBaseAttack()
		if atk==batk then return end
		-- 此段代码对应效果原文的两个分支：●那只怪兽的攻击力比原本攻击力高的场合，那只怪兽的攻击力上升1000。●那只怪兽的攻击力比原本攻击力低的场合，那只怪兽的攻击力下降1000。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		if atk>batk then
			e1:SetValue(1000)
		else
			e1:SetValue(-1000)
		end
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
