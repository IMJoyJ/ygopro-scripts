--コア・ブラスト
-- 效果：
-- 自己的准备阶段时只有1次，对方场上存在的怪兽数量比自己多的场合，可以直到变成和自己场上存在的怪兽数量相同数量为止把对方场上存在的卡破坏。这个效果在自己场上有名字带有「核成」的怪兽表侧表示存在的场合才能发动。
function c18517177.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 效果原文内容：自己的准备阶段时只有1次，对方场上存在的怪兽数量比自己多的场合，可以直到变成和自己场上存在的怪兽数量相同数量为止把对方场上存在的卡破坏。这个效果在自己场上有名字带有「核成」的怪兽表侧表示存在的场合才能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(18517177,0))  --"破坏"
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c18517177.descon)
	e2:SetTarget(c18517177.destg)
	e2:SetOperation(c18517177.desop)
	c:RegisterEffect(e2)
end
-- 效果作用：检查自己场上是否存在名字带有「核成」的表侧表示怪兽
function c18517177.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x1d)
end
-- 效果作用：判断是否满足发动条件，包括回合玩家为自身、对方怪兽数量大于自己且自己场上存在名字带有「核成」的怪兽
function c18517177.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：判断当前回合玩家是否为效果持有者
	return Duel.GetTurnPlayer()==tp
		-- 效果作用：判断对方场上怪兽数量是否大于自己场上怪兽数量
		and Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)<Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)
		-- 效果作用：判断自己场上是否存在名字带有「核成」的表侧表示怪兽
		and Duel.IsExistingMatchingCard(c18517177.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 效果作用：设置发动时的目标选择逻辑，确定要破坏的卡组及数量
function c18517177.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 效果作用：获取对方场上所有卡的集合
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
	-- 效果作用：计算需要破坏的卡的数量
	local ct=Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)-Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)
	-- 效果作用：设置连锁操作信息，指定破坏效果的目标和数量
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,ct,0,0)
end
-- 效果作用：执行破坏效果，选择并破坏指定数量的卡
function c18517177.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：获取对方场上所有卡的集合
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
	-- 效果作用：计算需要破坏的卡的数量
	local ct=g:GetCount()-Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)
	if ct<=0 then return end
	-- 效果作用：提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	local dg=g:Select(tp,ct,ct,nil)
	-- 效果作用：将选中的卡破坏
	Duel.Destroy(dg,REASON_EFFECT)
end
