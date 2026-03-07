--ジャブィアント・パンダ
-- 效果：
-- 这个卡名的①的方法的特殊召唤1回合只能有1次，②的效果1回合只能使用1次。
-- ①：场上有兽战士族怪兽2只以上存在的场合，这张卡可以从手卡特殊召唤。
-- ②：这张卡从场上送去墓地的场合，以自己场上1只表侧表示怪兽为对象才能发动。那只怪兽的攻击力上升500。
function c36539330.initial_effect(c)
	-- ①：场上有兽战士族怪兽2只以上存在的场合，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,36539330+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c36539330.spcon)
	c:RegisterEffect(e1)
	-- ②：这张卡从场上送去墓地的场合，以自己场上1只表侧表示怪兽为对象才能发动。那只怪兽的攻击力上升500。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,36539331)
	e2:SetCondition(c36539330.tgcon)
	e2:SetTarget(c36539330.tgtg)
	e2:SetOperation(c36539330.tgop)
	c:RegisterEffect(e2)
end
-- 检索满足条件的兽战士族怪兽
function c36539330.spfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_BEASTWARRIOR)
end
-- 判断是否满足特殊召唤条件
function c36539330.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 判断场上是否有足够的怪兽区域
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断场上是否存在至少2只兽战士族怪兽
		and Duel.IsExistingMatchingCard(c36539330.spfilter,tp,LOCATION_MZONE,LOCATION_MZONE,2,nil)
end
-- 判断此卡是否从场上送去墓地
function c36539330.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 选择并设置效果对象
function c36539330.tgtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and chkc:IsFaceup() end
	-- 检查是否存在满足条件的目标怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择效果对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择场上一只表侧表示的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置效果处理信息，指定攻击力变化效果
	Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,g,1,tp,500)
end
-- 执行攻击力上升效果
function c36539330.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前效果选择的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 为选中的怪兽添加攻击力上升500的效果
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(500)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
