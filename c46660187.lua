--ウォークライ・ビッグブロウ
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：自己·对方的主要阶段，自己场上的表侧表示的「战吼」怪兽因对方的效果从场上离开的场合才能发动。选对方场上最多2张卡破坏。
function c46660187.initial_effect(c)
	-- 效果原文内容：①：自己·对方的主要阶段，自己场上的表侧表示的「战吼」怪兽因对方的效果从场上离开的场合才能发动。选对方场上最多2张卡破坏。
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
-- 规则层面作用：判断是否满足条件，即被破坏的怪兽是「战吼」怪兽且为正面表示、在主要阶段离开场上的怪兽，并且是由对方效果导致的离开。
function c46660187.cfilter(c,tp,rp)
	return c:IsSetCard(0x15f) and c:IsPreviousPosition(POS_FACEUP) and c:GetPreviousControler()==tp
		and c:IsPreviousLocation(LOCATION_MZONE) and rp==1-tp and c:IsReason(REASON_EFFECT)
end
-- 规则层面作用：检查当前是否处于主要阶段1或主要阶段2，并且有符合条件的怪兽因对方效果离开场上。
function c46660187.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面作用：获取当前游戏阶段
	local ph=Duel.GetCurrentPhase()
	return (ph==PHASE_MAIN1 or ph==PHASE_MAIN2) and eg:IsExists(c46660187.cfilter,1,nil,tp,rp)
end
-- 规则层面作用：设置发动时的目标，即对方场上的任意卡，用于连锁信息记录。
function c46660187.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 规则层面作用：判断是否满足发动条件，即对方场上是否存在至少一张卡。
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 规则层面作用：获取对方场上的所有卡作为可能的破坏对象。
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
	-- 规则层面作用：设置当前效果处理中将要破坏的卡组和数量信息。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 规则层面作用：执行效果操作，选择并破坏对方场上最多2张卡。
function c46660187.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面作用：提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 规则层面作用：从对方场上选择1到2张卡作为破坏对象
	local g=Duel.SelectMatchingCard(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,2,nil)
	if #g>0 then
		-- 规则层面作用：显示所选卡被选为对象的动画效果
		Duel.HintSelection(g)
		-- 规则层面作用：以效果原因将所选卡破坏
		Duel.Destroy(g,REASON_EFFECT)
	end
end
