--幻日灯火
-- 效果：
-- 这个卡名的③的效果1回合只能使用1次。
-- ①：战斗阶段以外，对方不能把场上的这张卡作为效果的对象。
-- ②：这张卡和怪兽进行战斗的场合，那2只不会被那次战斗破坏。
-- ③：自己·对方的结束阶段才能发动。自己抽1张。那之后，选自己手卡任意数量除外，这张卡的攻击力上升这个效果除外的卡数量×500。
local s,id,o=GetID()
-- 初始化函数，用于注册卡片的所有效果。
function s.initial_effect(c)
	-- ①：战斗阶段以外，对方不能把场上的这张卡作为效果的对象。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCondition(s.tgcon)
	-- 设置不能成为效果对象的效果只对对方玩家生效。
	e1:SetValue(aux.tgoval)
	c:RegisterEffect(e1)
	-- ②：这张卡和怪兽进行战斗的场合，那2只不会被那次战斗破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetTarget(s.indtg)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	-- ③：自己·对方的结束阶段才能发动。自己抽1张。那之后，选自己手卡任意数量除外，这张卡的攻击力上升这个效果除外的卡数量×500。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_DRAW+CATEGORY_REMOVE+CATEGORY_ATKCHANGE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id)
	e3:SetTarget(s.drtg)
	e3:SetOperation(s.drop)
	c:RegisterEffect(e3)
end
-- 效果①的生效条件函数，判断当前是否不处于战斗阶段。
function s.tgcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前的阶段。
	local ph=Duel.GetCurrentPhase()
	return not (ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE)
end
-- 过滤战斗破坏抗性的适用对象，即自身以及与自身进行战斗的怪兽。
function s.indtg(e,c)
	local tc=e:GetHandler()
	return c==tc or c==tc:GetBattleTarget()
end
-- 效果③的发动准备函数，进行可行性检测并设置操作信息。
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动准备阶段，检查玩家是否可以抽卡以及是否可以除外卡片。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) and Duel.IsPlayerCanRemove(tp) end
	-- 设置操作信息，表示该效果包含抽1张卡的操作。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
	-- 检查玩家手牌数量是否大于0。
	if Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)>0 then
		-- 设置操作信息，表示该效果可能从手牌除外卡片。
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_HAND)
	end
end
-- 效果③的效果处理函数，执行抽卡、除外手牌并增加攻击力。
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 执行抽1张卡的操作，若未能成功抽卡则后续处理不适用。
	if Duel.Draw(tp,1,REASON_EFFECT)<1 then return end
	-- 洗切玩家的手牌。
	Duel.ShuffleHand(tp)
	-- 提示玩家选择要除外的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从手牌中选择任意数量可以除外的卡片。
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,LOCATION_HAND,0,1,99,nil)
	-- 将选中的卡片表侧表示除外，若未能成功除外则后续处理不适用。
	if Duel.Remove(g,POS_FACEUP,REASON_EFFECT)<1 then return end
	local c=e:GetHandler()
	-- 获取实际上被成功除外并移动到除外区的卡片数量。
	local ct=Duel.GetOperatedGroup():FilterCount(Card.IsLocation,nil,LOCATION_REMOVED)
	if c:IsRelateToEffect(e) and c:IsFaceup() and ct>0 then
		-- 这张卡的攻击力上升这个效果除外的卡数量×500。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		e1:SetValue(ct*500)
		c:RegisterEffect(e1)
	end
end
