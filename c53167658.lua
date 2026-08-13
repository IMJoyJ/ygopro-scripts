--遮攻カーテン
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己场上的卡被战斗或者对方的效果破坏的场合，可以作为那1张破坏的卡的代替而把这张卡破坏。
-- ②：对方场上的卡被战斗·效果破坏的场合，可以作为那1张破坏的卡的代替而把墓地的这张卡除外。
function c53167658.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：自己场上的卡被战斗或者对方的效果破坏的场合，可以作为那1张破坏的卡的代替而把这张卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTarget(c53167658.reptg1)
	e2:SetValue(c53167658.repval)
	e2:SetOperation(c53167658.repop1)
	c:RegisterEffect(e2)
	-- ②：对方场上的卡被战斗·效果破坏的场合，可以作为那1张破坏的卡的代替而把墓地的这张卡除外。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EFFECT_DESTROY_REPLACE)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetTarget(c53167658.reptg2)
	e3:SetValue(c53167658.repval)
	e3:SetOperation(c53167658.repop2)
	c:RegisterEffect(e3)
end
-- 筛选被破坏的卡中满足条件的己方场上的卡：位于场上、由己方控制、破坏原因是战斗或对方造成的效果破坏，且不是替代破坏。
function c53167658.repfilter1(c,tp)
	return c:IsOnField() and c:IsControler(tp)
		and (c:IsReason(REASON_BATTLE) or (c:IsReason(REASON_EFFECT) and c:GetReasonPlayer()==1-tp)) and not c:IsReason(REASON_REPLACE)
end
-- ①效果的发动条件判定：存在满足repfilter1的将被破坏的己方卡，且这张卡自身可被效果破坏且未处于预定破坏状态。
function c53167658.reptg1(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return eg:IsExists(c53167658.repfilter1,1,c,tp)
		and c:IsDestructable(e) and not c:IsStatus(STATUS_DESTROY_CONFIRMED) end
	-- 询问己方玩家是否发动①效果，以这张卡作为代替破坏的对象。
	if Duel.SelectEffectYesNo(tp,c,96) then
		local sg=eg:Filter(c53167658.repfilter1,c,tp)
		if sg:GetCount()>1 then
			-- 当存在多张符合条件的己方卡时，提示己方玩家选择其中一张作为被代替破坏的卡。
			Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(53167658,0))  --"请选择要代替破坏的卡"
			sg=sg:Select(tp,1,1,nil)
		end
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 判定效果对象：若某张将被破坏的卡正是之前选定要代替破坏的卡，则允许本效果代替其破坏。
function c53167658.repval(e,c)
	local g=e:GetLabelObject()
	return g:IsContains(c)
end
-- ①效果的代破处理：破坏这张卡自身以代替选定卡的破坏，并清除临时记录的对象组。
function c53167658.repop1(e,tp,eg,ep,ev,re,r,rp)
	-- 实际执行将“遮攻幕帘”自身破坏，破坏原因为效果并标记为代替破坏。
	Duel.Destroy(e:GetHandler(),REASON_EFFECT+REASON_REPLACE)
	local g=e:GetLabelObject()
	g:DeleteGroup()
end
-- 筛选被破坏的卡中满足条件的对方场上的卡：位于场上、由对方控制、破坏原因是战斗或效果，且不是替代破坏。
function c53167658.repfilter2(c,tp)
	return c:IsOnField() and c:IsControler(1-tp)
		and c:IsReason(REASON_BATTLE+REASON_EFFECT) and not c:IsReason(REASON_REPLACE)
end
-- ②效果的发动条件判定与对象选择：存在满足repfilter2的对方将被破坏的卡，且墓地中的这张卡可除外；询问玩家是否发动，若发动则从多张候选卡中选择一张作为代破对象。
function c53167658.reptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return eg:IsExists(c53167658.repfilter2,1,nil,tp) and c:IsAbleToRemove() end
	-- 询问己方玩家是否发动②效果，以将墓地的这张卡除外作为代替破坏。
	if Duel.SelectEffectYesNo(tp,c,96) then
		local sg=eg:Filter(c53167658.repfilter2,nil,tp)
		if sg:GetCount()>1 then
			-- 当存在多张符合条件的对方卡时，提示己方玩家选择其中一张作为被代替破坏的卡。
			Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(53167658,0))  --"请选择要代替破坏的卡"
			sg=sg:Select(tp,1,1,nil)
		end
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- ②效果的代破处理：除外墓地中的这张卡以代替选定卡的破坏，并清除临时记录的对象组。
function c53167658.repop2(e,tp,eg,ep,ev,re,r,rp)
	-- 实际执行将墓地中的“遮攻幕帘”表侧除外，作为代替破坏的处理。
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_EFFECT)
	local g=e:GetLabelObject()
	g:DeleteGroup()
end
