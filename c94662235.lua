--運命湾曲
-- 效果：
-- 自己场上表侧表示存在的怪兽只有名字带有「命运女郎」的怪兽的场合才能发动。魔法·陷阱卡的发动，怪兽的召唤的其中1个无效，那张卡从游戏中除外。这个回合的结束阶段时，这个效果从游戏中除外的卡回到持有者手卡。
function c94662235.initial_effect(c)
	-- 自己场上表侧表示存在的怪兽只有名字带有「命运女郎」的怪兽的场合才能发动。...怪兽的召唤的其中1个无效，那张卡从游戏中除外。这个回合的结束阶段时，这个效果从游戏中除外的卡回到持有者手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DISABLE_SUMMON+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_SUMMON)
	e1:SetCondition(c94662235.condition1)
	e1:SetTarget(c94662235.target1)
	e1:SetOperation(c94662235.activate1)
	c:RegisterEffect(e1)
	-- 自己场上表侧表示存在的怪兽只有名字带有「命运女郎」的怪兽的场合才能发动。魔法·陷阱卡的发动...其中1个无效，那张卡从游戏中除外。这个回合的结束阶段时，这个效果从游戏中除外的卡回到持有者手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_NEGATE+CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_ACTIVATE)
	e2:SetCode(EVENT_CHAINING)
	e2:SetCondition(c94662235.condition2)
	-- 设置效果2（无效魔法·陷阱卡发动）的靶向/目标处理函数为辅助函数aux.nbtg，用于处理无效化并除外的目标检测与操作信息设置。
	e2:SetTarget(aux.nbtg)
	e2:SetOperation(c94662235.activate2)
	c:RegisterEffect(e2)
end
-- 过滤条件：场上表侧表示且卡名带有「命运女郎」的怪兽。
function c94662235.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x31)
end
-- 检查自己场上的表侧表示怪兽是否仅有「命运女郎」怪兽。
function c94662235.check(tp)
	-- 获取自己场上所有表侧表示的怪兽。
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)
	return g:IsExists(c94662235.cfilter,1,nil)
		-- 过滤并确认自己场上不存在不满足「命运女郎」条件的怪兽（即场上怪兽必须全部是「命运女郎」）。
		and not g:IsExists(aux.NOT(c94662235.cfilter),1,nil)
end
-- 怪兽召唤无效效果的发动条件判定函数。
function c94662235.condition1(e,tp,eg,ep,ev,re,r,rp)
	-- 必须在没有连锁结算且自己场上仅有表侧表示「命运女郎」怪兽时才能发动。
	return aux.NegateSummonCondition() and c94662235.check(tp)
end
-- 怪兽召唤无效效果的目标处理与操作信息设置函数。
function c94662235.target1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:GetFirst():IsAbleToRemove() end
	-- 设置操作信息：包含无效召唤分类，涉及卡片为正在召唤的怪兽。
	Duel.SetOperationInfo(0,CATEGORY_DISABLE_SUMMON,eg,1,0,0)
	-- 设置操作信息：包含除外分类，涉及卡片为正在召唤的怪兽。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,eg,1,0,0)
end
-- 怪兽召唤无效效果的执行函数。
function c94662235.activate1(e,tp,eg,ep,ev,re,r,rp)
	-- 使正在召唤的怪兽的召唤无效。
	Duel.NegateSummon(eg:GetFirst())
	local ec=eg:GetFirst()
	-- 如果成功将该怪兽表侧表示除外，则注册一个在回合结束阶段将该卡送回手卡的效果。
	if Duel.Remove(ec,POS_FACEUP,REASON_EFFECT)~=0 then
		-- 这个回合的结束阶段时，这个效果从游戏中除外的卡回到持有者手卡。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetCountLimit(1)
		e1:SetLabelObject(ec)
		e1:SetCondition(c94662235.retcon)
		e1:SetOperation(c94662235.retop)
		-- 将用于在结束阶段将除外卡片送回手卡的效果注册给玩家。
		Duel.RegisterEffect(e1,tp)
		ec:RegisterFlagEffect(94662235,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
	end
end
-- 魔法·陷阱卡发动无效效果的发动条件判定函数。
function c94662235.condition2(e,tp,eg,ep,ev,re,r,rp)
	-- 被连锁的效果必须是魔法·陷阱卡的发动，且该发动可以被无效，同时自己场上仅有表侧表示「命运女郎」怪兽。
	return re:IsHasType(EFFECT_TYPE_ACTIVATE) and Duel.IsChainNegatable(ev) and c94662235.check(tp)
end
-- 魔法·陷阱卡发动无效效果的执行函数。
function c94662235.activate2(e,tp,eg,ep,ev,re,r,rp)
	local ec=eg:GetFirst()
	-- 如果成功无效该魔法·陷阱卡的发动，且该卡在场上与该效果相关联。
	if Duel.NegateActivation(ev) and ec:IsRelateToEffect(re) then
		-- 如果成功将该魔法·陷阱卡表侧表示除外，则注册一个在回合结束阶段将该卡送回手卡的效果。
		if Duel.Remove(ec,POS_FACEUP,REASON_EFFECT)~=0 then
			-- 这个回合的结束阶段时，这个效果从游戏中除外的卡回到持有者手卡。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e1:SetCode(EVENT_PHASE+PHASE_END)
			e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
			e1:SetCountLimit(1)
			e1:SetLabelObject(ec)
			e1:SetCondition(c94662235.retcon)
			e1:SetOperation(c94662235.retop)
			-- 将用于在结束阶段将除外卡片送回手卡的效果注册给玩家。
			Duel.RegisterEffect(e1,tp)
			ec:RegisterFlagEffect(94662235,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
		end
	end
end
-- 结束阶段卡片回到手卡效果的发动条件判定函数（检查卡片是否带有对应的标记）。
function c94662235.retcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	return tc:GetFlagEffect(94662235)~=0
end
-- 结束阶段卡片回到手卡效果的执行函数。
function c94662235.retop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	-- 将该卡片送回持有者的手卡。
	Duel.SendtoHand(tc,nil,REASON_EFFECT)
end
