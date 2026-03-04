--エレクトリック・スネーク
-- 效果：
-- 这张卡被对方的卡的效果从手卡丢弃去墓地时，从自己卡组抽2张卡。
function c11324436.initial_effect(c)
	-- 这张卡被对方的卡的效果从手卡丢弃去墓地时，从自己卡组抽2张卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(11324436,0))  --"抽卡"
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCondition(c11324436.drcon)
	e1:SetTarget(c11324436.drtg)
	e1:SetOperation(c11324436.drop)
	c:RegisterEffect(e1)
end
-- 效果发动的条件判断函数
function c11324436.drcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_HAND) and bit.band(r,0x4040)==0x4040 and rp==1-tp
end
-- 效果的对象选择函数
function c11324436.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置效果的目标玩家为当前玩家
	Duel.SetTargetPlayer(tp)
	-- 设置效果的目标参数为2
	Duel.SetTargetParam(2)
	-- 设置连锁操作信息为抽卡效果，抽2张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
-- 效果的处理函数
function c11324436.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中设定的目标玩家和参数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 使目标玩家从卡组抽卡
	Duel.Draw(p,d,REASON_EFFECT)
end
