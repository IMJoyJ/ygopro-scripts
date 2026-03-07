--クイズ
-- 效果：
-- 这张卡发动中，对方不能确认墓地里的卡。对方玩家猜发动「谜题」的玩家墓地最下面1张怪兽卡的名字。如果猜中，将被猜的怪兽卡除外。如果猜错，将此怪兽卡在其持有者的场上特殊召唤。
function c38723936.initial_effect(c)
	-- 效果原文：这张卡发动中，对方不能确认墓地里的卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c38723936.cost)
	e1:SetTarget(c38723936.target)
	e1:SetOperation(c38723936.activate)
	c:RegisterEffect(e1)
end
-- 效果作用：注册一个场地方效果，使对方玩家在发动此卡时无法确认墓地中的卡。
function c38723936.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		-- 效果原文：对方玩家猜发动「谜题」的玩家墓地最下面1张怪兽卡的名字。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH+EFFECT_FLAG_CLIENT_HINT)
		e1:SetDescription(CARD_QUESTION)
		e1:SetTargetRange(0,1)
		e1:SetReset(RESET_CHAIN)
		-- 效果作用：将效果注册到全局环境，使对方玩家在发动此卡时无法确认墓地中的卡。
		Duel.RegisterEffect(e1,tp)
	end
end
-- 效果原文：如果猜中，将被猜的怪兽卡除外。
function c38723936.filter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToRemove()
end
-- 效果作用：设置连锁处理时需要处理的卡组信息，包括墓地离开和特殊召唤/除外操作。
function c38723936.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果作用：判断是否满足发动条件，即在墓地中存在至少一张怪兽卡。
	if chk==0 then return Duel.IsExistingTarget(c38723936.filter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 效果作用：设置操作信息，表示本次连锁将处理从墓地离开的卡。
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,nil,1,tp,0)
end
-- 效果原文：如果猜错，将此怪兽卡在其持有者的场上特殊召唤。
function c38723936.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：获取满足条件的墓地怪兽卡组。
	local g=Duel.GetMatchingGroup(c38723936.filter,tp,LOCATION_GRAVE,0,nil)
	if g:GetCount()==0 then return end
	local last=g:GetFirst()
	local tc=g:GetNext()
	while tc do
		if tc:GetSequence()<last:GetSequence() then last=tc end
		tc=g:GetNext()
	end
	-- 效果作用：提示对方玩家选择一个卡名。
	Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_CODE)  --"请宣言一个卡名"
	-- 效果作用：让对方玩家宣言一个怪兽卡的卡号。
	local ac=Duel.AnnounceCard(1-tp,TYPE_MONSTER,OPCODE_ISTYPE)
	if ac~=last:GetCode() then
		-- 效果作用：将该怪兽卡特殊召唤到其持有者的场上。
		Duel.SpecialSummon(last,0,tp,tp,false,false,POS_FACEUP)
	else
		-- 效果作用：将该怪兽卡除外。
		Duel.Remove(last,POS_FACEUP,REASON_EFFECT)
	end
end
