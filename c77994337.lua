--ハロハロ
-- 效果：
-- ←2 【灵摆】 2→
-- ①：1回合1次，以场上1只表侧表示怪兽为对象才能发动。掷1次骰子。那只怪兽的等级直到回合结束时变成和出现的数目相同等级。
-- 【怪兽描述】
-- 万万圣爱甜甜糖。
-- 找糖糖，这逛逛，那瞧瞧。
-- 不给糖果就捣蛋，招招耍你团团转。
-- 
-- 心慌慌已来不及。
-- 花样万变请期待。
function c77994337.initial_effect(c)
	-- 启用灵摆怪兽属性（注册灵摆召唤和灵摆卡的发动）
	aux.EnablePendulumAttribute(c)
	-- ①：1回合1次，以场上1只表侧表示怪兽为对象才能发动。掷1次骰子。那只怪兽的等级直到回合结束时变成和出现的数目相同等级。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(77994337,0))
	e1:SetCategory(CATEGORY_DICE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(c77994337.lvtg)
	e1:SetOperation(c77994337.lvop)
	c:RegisterEffect(e1)
end
-- 过滤条件：场上表侧表示且有等级的怪兽
function c77994337.lvfilter(c)
	return c:IsFaceup() and c:GetLevel()>0
end
-- 效果发动的目标选择（Target）
function c77994337.lvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c77994337.lvfilter(chkc) end
	-- 检查场上是否存在至少1只满足条件的表侧表示怪兽
	if chk==0 then return Duel.IsExistingTarget(c77994337.lvfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择并锁定1只表侧表示怪兽作为效果对象
	Duel.SelectTarget(tp,c77994337.lvfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
-- 效果运行的处理（Operation）
function c77994337.lvop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 让发动效果的玩家掷1次骰子
		local dc=Duel.TossDice(tp,1)
		-- 那只怪兽的等级直到回合结束时变成和出现的数目相同等级。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetValue(dc)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
