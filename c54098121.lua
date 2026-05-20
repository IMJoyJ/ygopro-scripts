--謎の傀儡師
-- 效果：
-- 怪兽召唤·反转召唤成功时，自己回复500基本分。
function c54098121.initial_effect(c)
	-- 怪兽召唤成功时，自己回复500基本分。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(54098121,0))  --"LP回复"
	e1:SetCategory(CATEGORY_RECOVER)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c54098121.con)
	e1:SetTarget(c54098121.tg)
	e1:SetOperation(c54098121.op)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e2)
end
-- 过滤自身召唤成功的时点，确保自身召唤成功时不触发该效果
function c54098121.con(e,tp,eg,ep,ev,re,r,rp)
	return not eg:IsContains(e:GetHandler())
end
-- 效果发动的目标确认与操作信息设置
function c54098121.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置回复基本分的对象为自己
	Duel.SetTargetPlayer(tp)
	-- 设置回复基本分的数值为500
	Duel.SetTargetParam(500)
	-- 设置操作信息为玩家回复500基本分
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,500)
end
-- 效果处理：使玩家回复基本分
function c54098121.op(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标玩家和回复数值
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 执行回复基本分的操作
	Duel.Recover(p,d,REASON_EFFECT)
end
