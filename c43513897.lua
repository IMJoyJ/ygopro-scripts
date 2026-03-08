--セイクリッド・アクベス
-- 效果：
-- 这张卡召唤·特殊召唤成功时，自己场上的全部名字带有「星圣」的怪兽的攻击力上升500。
function c43513897.initial_effect(c)
	-- 这张卡召唤·特殊召唤成功时，自己场上的全部名字带有「星圣」的怪兽的攻击力上升500。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(43513897,0))  --"攻击力上升"
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetOperation(c43513897.atkop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	c43513897.star_knight_summon_effect=e1
end
-- 过滤出场上的表侧表示的「星圣」怪兽
function c43513897.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x53)
end
-- 检索满足条件的「星圣」怪兽组并给它们加上攻击力上升500的效果
function c43513897.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 检索满足条件的「星圣」怪兽组
	local g=Duel.GetMatchingGroup(c43513897.filter,tp,LOCATION_MZONE,0,nil)
	local tc=g:GetFirst()
	while tc do
		-- 给目标怪兽加上攻击力上升500的效果
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(500)
		tc:RegisterEffect(e1)
		tc=g:GetNext()
	end
end
