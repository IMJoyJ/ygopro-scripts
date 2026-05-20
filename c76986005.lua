--サイバー・ジラフ
-- 效果：
-- 把这张卡做祭品。直到这个回合的结束阶段，这张卡的控制者受到的因效果造成的伤害变成0。
function c76986005.initial_effect(c)
	-- 把这张卡做祭品。直到这个回合的结束阶段，这张卡的控制者受到的因效果造成的伤害变成0。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(76986005,0))  --"效果伤害免疫"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c76986005.cost)
	e1:SetOperation(c76986005.operation)
	c:RegisterEffect(e1)
end
-- 检查自身是否可以被解放，并作为发动代价将自身解放
function c76986005.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 解放自身作为发动的代价
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 在全局注册“直到回合结束阶段，使玩家受到的效果伤害变成0”的效果
function c76986005.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 直到这个回合的结束阶段，这张卡的控制者受到的因效果造成的伤害变成0。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CHANGE_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetValue(c76986005.damval)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 给发动效果的玩家注册“改变受到的伤害”的全局效果
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_NO_EFFECT_DAMAGE)
	e2:SetReset(RESET_PHASE+PHASE_END)
	-- 给发动效果的玩家注册“不受效果伤害”的全局状态标记
	Duel.RegisterEffect(e2,tp)
end
-- 判断伤害原因，如果是效果伤害则将伤害值修改为0，否则保持原伤害值
function c76986005.damval(e,re,val,r,rp,rc)
	if bit.band(r,REASON_EFFECT)~=0 then return 0
	else return val end
end
