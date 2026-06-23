--見世物ゴブリン
-- 效果：
-- 每次自己的结束阶段，自己卡组最下面的卡给双方确认，那张卡在自己卡组最上面放置或里侧表示从游戏中除外。
function c18658572.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 每次自己的结束阶段，自己卡组最下面的卡给双方确认，那张卡在自己卡组最上面放置或里侧表示从游戏中除外。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(18658572,0))  --"确认卡组"
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c18658572.cfcon)
	e2:SetOperation(c18658572.cfop)
	c:RegisterEffect(e2)
end
-- 判断是否为自己的结束阶段且自己卡组不为空
function c18658572.cfcon(e,tp,eg,ep,ev,re,r,rp)
	-- 当前回合玩家为效果持有者且自己卡组数量不为0
	return Duel.GetTurnPlayer()==tp and Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)~=0
end
-- 检索满足条件的卡片组并移动到卡组最上方，确认卡组最上方的卡，询问是否里侧表示从游戏中除外
function c18658572.cfop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己卡组中的所有卡片
	local g=Duel.GetFieldGroup(tp,LOCATION_DECK,0)
	if g:GetCount()==0 then return end
	local tc=g:GetMinGroup(Card.GetSequence):GetFirst()
	-- 将目标卡片移动到卡组最上方
	Duel.MoveSequence(tc,SEQ_DECKTOP)
	-- 确认玩家卡组最上方的1张卡
	Duel.ConfirmDecktop(tp,1)
	-- 判断目标卡是否可以除外且玩家选择里侧表示从游戏中除外
	if tc:IsAbleToRemove(tp,POS_FACEDOWN) and Duel.SelectYesNo(tp,aux.Stringid(18658572,1)) then  --"是否要里侧表示从游戏中除外？"
		-- 禁止接下来的除外操作进行洗卡检测
		Duel.DisableShuffleCheck()
		-- 以里侧表示从游戏中除外目标卡片
		Duel.Remove(tc,POS_FACEDOWN,REASON_EFFECT)
	end
end
