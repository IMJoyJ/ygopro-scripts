--弱者の意地
-- 效果：
-- 自己手卡是0张的场合，自己场上存在的2星以下的怪兽战斗破坏对方怪兽送去墓地时，从自己卡组抽2张卡。
function c86016245.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 自己手卡是0张的场合，自己场上存在的2星以下的怪兽战斗破坏对方怪兽送去墓地时，从自己卡组抽2张卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(86016245,0))  --"抽卡"
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EVENT_BATTLE_DESTROYED)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCondition(c86016245.drcon)
	e2:SetTarget(c86016245.drtg)
	e2:SetOperation(c86016245.drop)
	c:RegisterEffect(e2)
end
-- 判断是否满足发动条件：自己手卡为0张，且自己场上2星以下的怪兽战斗破坏对方怪兽并送去墓地
function c86016245.drcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	local bc=tc:GetBattleTarget()
	-- 检查自己手卡数量是否为0，且被破坏的怪兽数量是否为1
	return Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)==0 and eg:GetCount()==1
		and tc:IsLocation(LOCATION_GRAVE) and tc:IsReason(REASON_BATTLE)
		and bc:IsRelateToBattle() and bc:IsControler(tp) and bc:IsLevelBelow(2)
end
-- 设置效果发动的目标：确定抽卡玩家为自己，抽卡数量为2张
function c86016245.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置当前连锁的目标玩家为自己
	Duel.SetTargetPlayer(tp)
	-- 设置当前连锁的目标参数为2（抽卡张数）
	Duel.SetTargetParam(2)
	-- 设置连锁的操作信息为：由自己抽2张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
-- 执行效果处理：在满足手卡为0等条件时，让目标玩家抽2张卡
function c86016245.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 若此卡已离场或自己手卡不为0，则不处理效果
	if not e:GetHandler():IsRelateToEffect(e) or Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)~=0 then return end
	-- 获取当前连锁设定的目标玩家和抽卡张数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让目标玩家因效果抽指定张数的卡
	Duel.Draw(p,d,REASON_EFFECT)
end
