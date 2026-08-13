--ウォークライ・ビッグブロウ
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：自己·对方的主要阶段，自己场上的表侧表示的「战吼」怪兽因对方的效果从场上离开的场合才能发动。选对方场上最多2张卡破坏。
function c46660187.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：自己·对方的主要阶段，自己场上的表侧表示的「战吼」怪兽因对方的效果从场上离开的场合才能发动。选对方场上最多2张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_LEAVE_FIELD)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,46660187+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c46660187.descon)
	e1:SetTarget(c46660187.destg)
	e1:SetOperation(c46660187.desop)
	c:RegisterEffect(e1)
end
-- 过滤离场怪兽组，判定其中是否存在满足以下条件的「战吼」怪兽：离场前是表侧表示、离场前由自己控制、离场前位于自己怪兽区、且是因对方发动的效果而离场。
function c46660187.cfilter(c,tp,rp)
	return c:IsSetCard(0x15f) and c:IsPreviousPosition(POS_FACEUP) and c:GetPreviousControler()==tp
		and c:IsPreviousLocation(LOCATION_MZONE) and rp==1-tp and c:IsReason(REASON_EFFECT)
end
-- 发动条件判定：当前必须是自己或对方的主要阶段，并且离场怪兽组中存在满足cfilter条件的「战吼」怪兽，即自己场上表侧表示的「战吼」怪兽因对方的效果从场上离开。
function c46660187.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前游戏阶段，用于判断是否处于主要阶段1或主要阶段2。
	local ph=Duel.GetCurrentPhase()
	return (ph==PHASE_MAIN1 or ph==PHASE_MAIN2) and eg:IsExists(c46660187.cfilter,1,nil,tp,rp)
end
-- 效果的目标设定（不取对象）：发动时确认对方场上是否存在至少1张可以破坏的卡；若存在，则获取对方场上所有卡并设置破坏操作信息。
function c46660187.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时的合法检查：对方场上必须至少有1张卡可供选择破坏，否则效果不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 获取对方场上的所有卡片作为可能被破坏的候选组，用于设置操作信息（不取对象破坏的预定范围）。
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
	-- 设置当前连锁的操作信息：效果类别为破坏，候选目标为对方场上所有卡，预计处理数量为1张，用于联动“破坏”相关效果的检测。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果处理：由发动玩家从对方场上选择1～2张卡，确认后将这些卡全部以效果原因破坏。
function c46660187.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 显示“请选择要破坏的卡”的选择提示，并让玩家进入卡片选择界面。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 从对方场上所有卡中选择1～2张卡作为这本卡效果破坏的对象。
	local g=Duel.SelectMatchingCard(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,2,nil)
	if #g>0 then
		-- 为选中的卡播放被选择的目标动画，并将这些卡记录为当前连锁的广义对象。
		Duel.HintSelection(g)
		-- 将所选卡片以效果原因（REASON_EFFECT）破坏并送去墓地。
		Duel.Destroy(g,REASON_EFFECT)
	end
end
