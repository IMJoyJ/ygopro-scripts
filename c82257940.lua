--プレゼント交換
-- 效果：
-- ①：双方玩家各自从自己卡组选1张卡里侧表示除外。这个回合的结束阶段，双方各自把作为对方的玩家除外的那张卡加入自己手卡。
function c82257940.initial_effect(c)
	-- ①：双方玩家各自从自己卡组选1张卡里侧表示除外。这个回合的结束阶段，双方各自把作为对方的玩家除外的那张卡加入自己手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c82257940.target)
	e1:SetOperation(c82257940.activate)
	c:RegisterEffect(e1)
end
-- 检查双方玩家的卡组是否都存在至少1张可以里侧表示除外的卡
function c82257940.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己卡组是否存在至少1张可以里侧表示除外的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,LOCATION_DECK,0,1,nil,tp,POS_FACEDOWN)
		-- 检查对方卡组是否存在至少1张可以里侧表示除外的卡
		and Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_DECK,1,nil,1-tp,POS_FACEDOWN) end
end
-- 双方玩家各自从自己卡组选1张卡里侧表示除外，并注册在回合结束阶段将对方除外的卡加入自己手卡的效果
function c82257940.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己卡组中可以里侧表示除外的卡片
	local g1=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,LOCATION_DECK,0,nil,tp,POS_FACEDOWN)
	-- 获取对方卡组中可以里侧表示除外的卡片
	local g2=Duel.GetMatchingGroup(Card.IsAbleToRemove,1-tp,LOCATION_DECK,0,nil,1-tp,POS_FACEDOWN)
	if g1:GetCount()==0 or g2:GetCount()==0 then return end
	-- 提示自己选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local rg1=g1:Select(tp,1,1,nil)
	-- 提示对方选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local rg2=g2:Select(1-tp,1,1,nil)
	rg1:Merge(rg2)
	local c=e:GetHandler()
	local fid=c:GetFieldID()
	-- 将双方选择的卡里侧表示除外
	Duel.Remove(rg1,POS_FACEDOWN,REASON_EFFECT)
	rg1:GetFirst():RegisterFlagEffect(82257940,RESET_EVENT+RESETS_STANDARD,0,0,fid)
	rg1:GetNext():RegisterFlagEffect(82257940,RESET_EVENT+RESETS_STANDARD,0,0,fid)
	rg1:KeepAlive()
	-- 这个回合的结束阶段，双方各自把作为对方的玩家除外的那张卡加入自己手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetCountLimit(1)
	e1:SetLabel(fid)
	e1:SetLabelObject(rg1)
	e1:SetCondition(c82257940.thcon)
	e1:SetOperation(c82257940.thop)
	-- 注册在回合结束阶段执行的延迟效果
	Duel.RegisterEffect(e1,tp)
end
-- 过滤出带有特定关系标识的卡片
function c82257940.thfilter(c,fid)
	return c:GetFlagEffectLabel(82257940)==fid
end
-- 检查被除外的2张卡是否依然存在于除外区，若不足2张则重置效果
function c82257940.thcon(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	if g:FilterCount(c82257940.thfilter,nil,e:GetLabel())<2 then
		g:DeleteGroup()
		e:Reset()
		return false
	else return true end
end
-- 将双方除外的卡分别加入对方玩家的手卡
function c82257940.thop(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	local tc1=g:GetFirst()
	local tc2=g:GetNext()
	g:DeleteGroup()
	-- 将第一张被除外的卡加入其原本持有者的对手的手卡
	Duel.SendtoHand(tc1,1-tc1:GetControler(),REASON_EFFECT)
	-- 将第二张被除外的卡加入其原本持有者的对手的手卡
	Duel.SendtoHand(tc2,1-tc2:GetControler(),REASON_EFFECT)
end
