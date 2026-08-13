--クイズ
-- 效果：
-- 这张卡发动中，对方不能确认墓地里的卡。对方玩家猜发动「谜题」的玩家墓地最下面1张怪兽卡的名字。如果猜中，将被猜的怪兽卡除外。如果猜错，将此怪兽卡在其持有者的场上特殊召唤。
function c38723936.initial_effect(c)
	-- 对方玩家猜发动「谜题」的玩家墓地最下面1张怪兽卡的名字。如果猜中，将被猜的怪兽卡除外。如果猜错，将此怪兽卡在其持有者的场上特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c38723936.cost)
	e1:SetTarget(c38723936.target)
	e1:SetOperation(c38723936.activate)
	c:RegisterEffect(e1)
end
-- 作为发动代价，生成一个持续到本次连锁结束的场上效果，使对方玩家受到“这张卡发动中不能确认墓地里的卡”的限制；该效果带誓约和客户端提示，并注册给发动者。
function c38723936.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		-- 对方玩家猜发动「谜题」的玩家墓地最下面1张怪兽卡的名字。如果猜中，将被猜的怪兽卡除外。如果猜错，将此怪兽卡在其持有者的场上特殊召唤。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH+EFFECT_FLAG_CLIENT_HINT)
		e1:SetDescription(CARD_QUESTION)
		e1:SetTargetRange(0,1)
		e1:SetReset(RESET_CHAIN)
		-- 将上述“对方不能确认墓地里的卡”的持续效果注册到场上，使其在本连锁内对对方玩家生效。
		Duel.RegisterEffect(e1,tp)
	end
end
-- 筛选条件：卡必须是怪兽卡且能够被除外，用于从发动者墓地中选出可被猜的怪兽。
function c38723936.filter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToRemove()
end
-- 发动前检查自己墓地是否存在满足条件的怪兽；若可以发动则登记操作信息，标明本次效果会使墓地的卡离开墓地（用于王家长眠之谷等联动判定）。
function c38723936.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动合法性检查：确认发动者墓地存在至少1张满足 filter 的怪兽卡。
	if chk==0 then return Duel.IsExistingTarget(c38723936.filter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 设置操作信息为 CATEGORY_LEAVE_GRAVE，预计处理发动者墓地的1张卡（目标未确定，故 targets 为 nil），用于涉及墓地卡的卡片的互动判定。
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,nil,1,tp,0)
end
-- 效果处理：从发动者墓地选出最下面1张怪兽，让对手宣言一个怪兽卡名；若宣言的卡名与那张怪兽卡的卡名不同则将其特殊召唤到持有者场上，若相同则将其除外。
function c38723936.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 取得发动者墓地中所有满足 filter 的怪兽卡集合，用于后续选出最下面1张。
	local g=Duel.GetMatchingGroup(c38723936.filter,tp,LOCATION_GRAVE,0,nil)
	if g:GetCount()==0 then return end
	local last=g:GetFirst()
	local tc=g:GetNext()
	while tc do
		if tc:GetSequence()<last:GetSequence() then last=tc end
		tc=g:GetNext()
	end
	-- 向对方玩家发送“请宣言一个卡名”的提示，将宣言卡名所需的提示信息写入客户端选择缓存。
	Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_CODE)  --"请宣言一个卡名"
	-- 让对方玩家宣言1张怪兽卡的卡名（限制为怪兽卡），返回值 ac 为宣言的卡号，对应“猜怪兽卡的名字”。
	local ac=Duel.AnnounceCard(1-tp,TYPE_MONSTER,OPCODE_ISTYPE)
	if ac~=last:GetCode() then
		-- 猜错时，将墓地最下面的那只怪兽表侧表示特殊召唤到其持有者（tp）的场上。
		Duel.SpecialSummon(last,0,tp,tp,false,false,POS_FACEUP)
	else
		-- 猜中时，将被猜中的墓地最下面的怪兽卡表侧表示除外，除外原因为效果。
		Duel.Remove(last,POS_FACEUP,REASON_EFFECT)
	end
end
