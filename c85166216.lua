--恵みの像
-- 效果：
-- 当这张卡因对方控制的卡的效果从手卡被送去墓地时，自己回复2000基本分。
function c85166216.initial_effect(c)
	-- 当这张卡因对方控制的卡的效果从手卡被送去墓地时，自己回复2000基本分。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(85166216,0))  --"回复"
	e1:SetCategory(CATEGORY_RECOVER)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCondition(c85166216.condition)
	e1:SetTarget(c85166216.target)
	e1:SetOperation(c85166216.operation)
	c:RegisterEffect(e1)
end
-- 检查触发条件：这张卡原本在手卡、因对方卡片的效果被送去墓地
function c85166216.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_HAND) and rp==1-tp and bit.band(r,REASON_EFFECT)==REASON_EFFECT
end
-- 设置效果发动的目标：确定回复对象为自己，回复数值为2000，并注册回复操作信息
function c85166216.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置当前连锁的对象玩家为自己
	Duel.SetTargetPlayer(tp)
	-- 设置当前连锁的对象参数（回复数值）为2000
	Duel.SetTargetParam(2000)
	-- 设置当前连锁的操作信息：使自己回复2000基本分
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,2000)
end
-- 执行效果处理：获取目标玩家和回复数值，使该玩家回复基本分
function c85166216.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁设定的目标玩家和目标参数（回复数值）
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 因效果使目标玩家回复对应的基本分
	Duel.Recover(p,d,REASON_EFFECT)
end
