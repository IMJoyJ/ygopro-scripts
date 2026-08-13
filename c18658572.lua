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
-- 条件判断函数的整体：判定是否在己方结束阶段且己方卡组中还有卡。
function c18658572.cfcon(e,tp,eg,ep,ev,re,r,rp)
	-- 返回条件：当前回合玩家为自己（tp），且自己卡组中卡片数量不为0。
	return Duel.GetTurnPlayer()==tp and Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)~=0
end
-- 效果处理函数的整体：若己方卡组有卡，则取出卡组最下方的卡，将其移动到卡组最上方并展示，然后由自己选择是否将那张卡里侧表示从游戏中除外。
function c18658572.cfop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己卡组中的所有卡，存入组g。
	local g=Duel.GetFieldGroup(tp,LOCATION_DECK,0)
	if g:GetCount()==0 then return end
	local tc=g:GetMinGroup(Card.GetSequence):GetFirst()
	-- 将取出的那张卡移动到卡组最上方。
	Duel.MoveSequence(tc,SEQ_DECKTOP)
	-- 确认自己卡组最上方的1张卡（即刚移动上来的那张卡），展示给双方。
	Duel.ConfirmDecktop(tp,1)
	-- 检查该卡是否可以被自己里侧除外，并询问自己是否要将其里侧表示除外。
	if tc:IsAbleToRemove(tp,POS_FACEDOWN) and Duel.SelectYesNo(tp,aux.Stringid(18658572,1)) then  --"是否要里侧表示从游戏中除外？"
		-- 禁用系统自动洗牌检查，避免从卡组除外卡片后系统自动洗切卡组。
		Duel.DisableShuffleCheck()
		-- 将该卡以里侧表示从游戏中除外（原因：效果）。
		Duel.Remove(tc,POS_FACEDOWN,REASON_EFFECT)
	end
end
