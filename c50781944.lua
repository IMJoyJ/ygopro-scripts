--エンシェント・クリムゾン・エイプ
-- 效果：
-- 自己场上存在的怪兽被破坏送去墓地时，自己回复1000基本分。
function c50781944.initial_effect(c)
	-- 自己场上存在的怪兽被破坏送去墓地时，自己回复1000基本分。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(50781944,0))  --"回复"
	e1:SetCategory(CATEGORY_RECOVER)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCondition(c50781944.reccon)
	e1:SetTarget(c50781944.rectg)
	e1:SetOperation(c50781944.recop)
	c:RegisterEffect(e1)
end
-- 检查目标怪兽是否因破坏被送入墓地且之前在自己场上
function c50781944.filter(c,tp)
	return c:IsReason(REASON_DESTROY) and c:IsPreviousLocation(LOCATION_MZONE) and
		c:IsPreviousControler(tp) and c:IsType(TYPE_MONSTER)
end
-- 判断是否有满足条件的怪兽被送入墓地
function c50781944.reccon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c50781944.filter,1,nil,tp)
end
-- 设置效果的对象玩家和参数为1000
function c50781944.rectg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将当前处理连锁的目标玩家设为自己
	Duel.SetTargetPlayer(tp)
	-- 将当前处理连锁的目标参数设为1000
	Duel.SetTargetParam(1000)
	-- 设置连锁操作信息为回复效果，对象为自己，回复值为1000
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,1000)
end
-- 执行回复效果，恢复指定玩家基本分
function c50781944.recop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标玩家和目标参数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 以效果原因使目标玩家回复对应数值的基本分
	Duel.Recover(p,d,REASON_EFFECT)
end
