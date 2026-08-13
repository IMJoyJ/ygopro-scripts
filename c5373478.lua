--サイバー・ドラゴン・ツヴァイ
-- 效果：
-- ①：这张卡的卡名只要在墓地存在当作「电子龙」使用。
-- ②：1回合1次，把手卡1张魔法卡给对方观看才能发动。这张卡的卡名直到结束阶段当作「电子龙」使用。
-- ③：这张卡向对方怪兽攻击的伤害步骤内，这张卡的攻击力上升300。
function c5373478.initial_effect(c)
	-- 这张卡向对方怪兽攻击的伤害步骤内，这张卡的攻击力上升300。
	local e1=Effect.CreateEffect(c)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c5373478.atkcon)
	e1:SetValue(300)
	c:RegisterEffect(e1)
	-- 1回合1次，把手卡1张魔法卡给对方观看才能发动。这张卡的卡名直到结束阶段当作「电子龙」使用。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(5373478,0))  --"卡名当成「电子龙」"
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCost(c5373478.cost)
	e2:SetOperation(c5373478.cdop)
	c:RegisterEffect(e2)
	-- 为这张卡注册在墓地时卡名当作「电子龙」（70095154）的永续效果，对应效果①。
	aux.EnableChangeCode(c,70095154,LOCATION_GRAVE)
end
-- 判断攻击力上升效果的发动条件：当前处于伤害步骤或伤害计算时，且攻击者为这张卡、存在攻击目标，对应效果③的“向对方怪兽攻击的伤害步骤内”。
function c5373478.atkcon(e)
	-- 获取当前阶段，用于判断是否处于伤害步骤或伤害计算阶段。
	local phase=Duel.GetCurrentPhase()
	return (phase==PHASE_DAMAGE or phase==PHASE_DAMAGE_CAL)
		-- 确认攻击者为这张卡且攻击目标不为空，即满足此卡向对方怪兽攻击的条件。
		and Duel.GetAttacker()==e:GetHandler() and Duel.GetAttackTarget()~=nil
end
-- 定义COST筛选函数：选择手卡中1张魔法卡，且该卡不能是公开状态（需要从非公开手卡中展示）。
function c5373478.costfilter(c)
	return c:IsType(TYPE_SPELL) and not c:IsPublic()
end
-- 发动COST处理：检查手卡是否存在符合条件的魔法卡；若存在，则选择1张，给对方确认，然后洗切手卡。
function c5373478.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- COST合法性检查：若在check时手卡中存在至少1张满足costfilter条件的魔法卡，则COST合法。
	if chk==0 then return Duel.IsExistingMatchingCard(c5373478.costfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 弹出选择提示，让玩家选择一张要展示给对方确认的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 从手卡中选取1张满足costfilter的魔法卡作为COST。
	local g=Duel.SelectMatchingCard(tp,c5373478.costfilter,tp,LOCATION_HAND,0,1,1,nil)
	-- 将选出的卡展示给对方玩家确认。
	Duel.ConfirmCards(1-tp,g)
	-- 确认完毕后洗切手卡，避免展示导致手卡顺序信息泄露。
	Duel.ShuffleHand(tp)
end
-- 效果处理：若此卡仍在场上表侧表示且与此效果关联，则给它赋予改变卡名为「电子龙」的效果直到结束阶段。
function c5373478.cdop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFacedown() or not c:IsRelateToEffect(e) then return end
	-- 这张卡的卡名直到结束阶段当作「电子龙」使用。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CHANGE_CODE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e1:SetValue(70095154)
	c:RegisterEffect(e1)
end
