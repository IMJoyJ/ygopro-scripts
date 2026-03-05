--アイヴィ・シャックル
-- 效果：
-- 只要这张卡在场上存在，对方场上表侧表示存在的全部怪兽只在自己回合变成植物族。场上表侧表示存在的这张卡被对方的效果破坏送去墓地时，从自己卡组抽1张卡。
function c14730606.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 永续效果，使对方场上表侧表示的怪兽在自己回合变为植物族
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetCode(EFFECT_CHANGE_RACE)
	e2:SetCondition(c14730606.raccon)
	e2:SetValue(RACE_PLANT)
	c:RegisterEffect(e2)
	-- 场上表侧表示存在的这张卡被对方的效果破坏送去墓地时，从自己卡组抽1张卡
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(14730606,0))  --"抽卡"
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCondition(c14730606.drcon)
	e3:SetTarget(c14730606.drtg)
	e3:SetOperation(c14730606.drop)
	c:RegisterEffect(e3)
end
-- 判断是否为自己的回合
function c14730606.raccon(e)
	-- 当前回合玩家等于效果持有者玩家
	return Duel.GetTurnPlayer()==e:GetHandlerPlayer()
end
-- 判断效果触发条件：卡牌从场上送去墓地且为破坏效果且为对方破坏
function c14730606.drcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsPreviousPosition(POS_FACEUP)
		and c:IsPreviousControler(tp) and c:IsReason(REASON_DESTROY) and rp==1-tp
end
-- 设置抽卡效果的目标玩家和抽卡数量
function c14730606.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置效果的目标玩家为当前玩家
	Duel.SetTargetPlayer(tp)
	-- 设置效果的目标参数为抽卡数量1
	Duel.SetTargetParam(1)
	-- 设置连锁操作信息为抽卡效果
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 执行抽卡效果
function c14730606.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中设定的目标玩家和抽卡数量
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让指定玩家从卡组抽指定数量的卡
	Duel.Draw(p,d,REASON_EFFECT)
end
