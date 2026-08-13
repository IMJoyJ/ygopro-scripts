--光の封札剣
-- 效果：
-- ①：对方手卡随机选1张里侧表示除外。这张卡的发动后，用对方回合计算的第4回合的对方准备阶段，那张卡回到对方手卡。
function c49587034.initial_effect(c)
	-- ①：对方手卡随机选1张里侧表示除外。这张卡的发动后，用对方回合计算的第4回合的对方准备阶段，那张卡回到对方手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetTarget(c49587034.target)
	e1:SetOperation(c49587034.activate)
	c:RegisterEffect(e1)
end
-- 发动前判定：检查对方手牌是否存在可被里侧除外（POS_FACEDOWN）的卡作为发动条件；若存在则登记本次除外1张对方手牌的操作信息，但具体哪张在效果处理时随机决定。
function c49587034.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件判定（chk==0）：从对方手牌中检索是否存在至少1张能够被里侧表示除外的卡，存在则返回true，否则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_HAND,1,nil,tp,POS_FACEDOWN) end
	-- 登记操作信息：将本连锁的处理数据设为除外对方1张手牌（因为具体卡片要随机不确定，targets设nil；对方玩家为1-tp，位置为手牌）。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,1-tp,LOCATION_HAND)
end
-- 效果处理：随机从对方手牌选1张里侧表示除外；若除外成功且该效果确实是魔法卡发动效果，则给那张被除外的卡注册一个准备阶段触发效果，用于在对方第4个准备阶段把卡送回手牌；同时登记标志效果和引用用于后续计数/清除。
function c49587034.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方手牌的所有卡（以1-tp为视角看自己手牌，即发动者的对手的手牌）。
	local g=Duel.GetFieldGroup(1-tp,LOCATION_HAND,0)
	local rs=g:RandomSelect(1-tp,1)
	local card=rs:GetFirst()
	if card==nil then return end
	-- 将随机选中的手牌里侧表示除外；如果除外成功，并且当前效果确实是魔法的发动效果，才继续设置归还效果。
	if Duel.Remove(card,POS_FACEDOWN,REASON_EFFECT)>0 and e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		-- 获取当前阶段并保存到局部变量ph（该变量在本段后续逻辑中未直接使用）。
		local ph=Duel.GetCurrentPhase()
		-- 获取当前回合玩家并保存到局部变量cp（该变量在本段后续逻辑中未直接使用）。
		local cp=Duel.GetTurnPlayer()
		-- 这张卡的发动后，用对方回合计算的第4回合的对方准备阶段，那张卡回到对方手卡。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetRange(LOCATION_REMOVED)
		e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
		e1:SetCountLimit(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN,4)
		e1:SetCondition(c49587034.thcon)
		e1:SetOperation(c49587034.thop)
		e1:SetLabel(1)
		card:RegisterEffect(e1)
		e:GetHandler():RegisterFlagEffect(1082946,RESET_PHASE+PHASE_END+RESET_SELF_TURN,0,3)
		c49587034[e:GetHandler()]=e1
	end
end
-- 归还延迟效果的条件：当前回合玩家为效果所属者（被除外卡的持有者/控制者，即发动者的对手）时，才允许在对方准备阶段进行计数或归还处理。
function c49587034.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否等于tp，是则条件成立（确保只在对方回合的准备阶段触发）。
	return Duel.GetTurnPlayer()==tp
end
-- 归还效果的结算：读取当前计数并同步到光之封札剑的回合计数器；若计数已为4，则将除外的那张卡返回持有者手牌并清除标志效果；否则将计数加1，等待下一个对方准备阶段。
function c49587034.thop(e,tp,eg,ep,ev,re,r,rp)
	local ct=e:GetLabel()
	e:GetOwner():SetTurnCounter(ct)
	if ct==4 then
		-- 将被除外的卡加入其持有者的手牌（player参数为nil表示回到原持有者手牌），原因设为效果处理。
		Duel.SendtoHand(e:GetHandler(),nil,REASON_EFFECT)
		e:GetOwner():ResetFlagEffect(1082946)
	else
		e:SetLabel(ct+1)
	end
end
