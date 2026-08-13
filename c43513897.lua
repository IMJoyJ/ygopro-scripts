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
-- 筛选出己方场上表侧表示且卡名带有「星圣」字段的怪兽。
function c43513897.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x53)
end
-- 效果处理时：获取己方场上全部表侧表示且名字带有「星圣」的怪兽，为每只怪兽赋予攻击力上升500的效果（该效果不会被无效，并随怪兽离场等原因重置）。
function c43513897.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取己方场上所有满足filter条件的怪兽（表侧表示的「星圣」怪兽），作为本次攻击力上升的适用对象。
	local g=Duel.GetMatchingGroup(c43513897.filter,tp,LOCATION_MZONE,0,nil)
	local tc=g:GetFirst()
	while tc do
		-- 自己场上的全部名字带有「星圣」的怪兽的攻击力上升500。
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
