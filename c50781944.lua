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
-- 筛选条件：该卡是被破坏、此前在怪兽区域、此前控制者为tp、且为怪兽卡，即满足“自己场上的怪兽被破坏送去墓地”这一条件的怪兽。
function c50781944.filter(c,tp)
	return c:IsReason(REASON_DESTROY) and c:IsPreviousLocation(LOCATION_MZONE) and
		c:IsPreviousControler(tp) and c:IsType(TYPE_MONSTER)
end
-- 触发条件：本次送去墓地的怪兽群中，是否存在至少1张满足上述条件的怪兽。
function c50781944.reccon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c50781944.filter,1,nil,tp)
end
-- 发动目标的合法性判定与效果信息登记：效果发动必定成立；将回复对象玩家设为自己、回复数值设为1000，并登记回复效果的操作信息。
function c50781944.rectg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将当前连锁的目标玩家设置为tp（自己），表示本次回复的受益玩家。
	Duel.SetTargetPlayer(tp)
	-- 将当前连锁的目标参数设置为1000，表示回复的基本分数值。
	Duel.SetTargetParam(1000)
	-- 登记操作信息：本连锁为回复效果，预计使玩家tp回复1000基本分。
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,1000)
end
-- 效果处理：从当前连锁中取得之前保存的目标玩家和回复数值，并执行回复。
function c50781944.recop(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中取出目标玩家和目标参数，分别赋给p和d。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 以效果原因使玩家p回复d点基本分，完成回复处理。
	Duel.Recover(p,d,REASON_EFFECT)
end
