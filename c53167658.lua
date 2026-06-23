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
-- 判断目标卡片是否在场上且为玩家控制，且被战斗或对方效果破坏，且不是代替破坏
function c53167658.repfilter1(c,tp)
	return c:IsOnField() and c:IsControler(tp)
		and (c:IsReason(REASON_BATTLE) or (c:IsReason(REASON_EFFECT) and c:GetReasonPlayer()==1-tp)) and not c:IsReason(REASON_REPLACE)
end
-- 判断是否有满足条件的卡片被破坏，并且遮攻幕帘可以被破坏
function c53167658.reptg1(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return eg:IsExists(c53167658.repfilter1,1,c,tp)
		and c:IsDestructable(e) and not c:IsStatus(STATUS_DESTROY_CONFIRMED) end
	-- 询问玩家是否发动遮攻幕帘的效果
	if Duel.SelectEffectYesNo(tp,c,96) then
		local sg=eg:Filter(c53167658.repfilter1,c,tp)
		if sg:GetCount()>1 then
			-- 提示玩家选择要代替破坏的卡
			Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(53167658,0))  --"请选择要代替破坏的卡"
			sg=sg:Select(tp,1,1,nil)
		end
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 返回目标卡片是否为被代替破坏的卡片
function c53167658.repval(e,c)
	local g=e:GetLabelObject()
	return g:IsContains(c)
end
-- 将遮攻幕帘从场上破坏，完成代替破坏效果
function c53167658.repop1(e,tp,eg,ep,ev,re,r,rp)
	-- 将遮攻幕帘从场上破坏
	Duel.Destroy(e:GetHandler(),REASON_EFFECT+REASON_REPLACE)
	local g=e:GetLabelObject()
	g:DeleteGroup()
end
-- 判断目标卡片是否在场上且为对方控制，且被战斗或效果破坏，且不是代替破坏
function c53167658.repfilter2(c,tp)
	return c:IsOnField() and c:IsControler(1-tp)
		and c:IsReason(REASON_BATTLE+REASON_EFFECT) and not c:IsReason(REASON_REPLACE)
end
-- 判断是否有满足条件的卡片被破坏，并且遮攻幕帘可以被除外
function c53167658.reptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return eg:IsExists(c53167658.repfilter2,1,nil,tp) and c:IsAbleToRemove() end
	-- 询问玩家是否发动遮攻幕帘的效果
	if Duel.SelectEffectYesNo(tp,c,96) then
		local sg=eg:Filter(c53167658.repfilter2,nil,tp)
		if sg:GetCount()>1 then
			-- 提示玩家选择要代替破坏的卡
			Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(53167658,0))  --"请选择要代替破坏的卡"
			sg=sg:Select(tp,1,1,nil)
		end
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 将遮攻幕帘从墓地除外，完成代替破坏效果
function c53167658.repop2(e,tp,eg,ep,ev,re,r,rp)
	-- 将遮攻幕帘从墓地除外
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_EFFECT)
	local g=e:GetLabelObject()
	g:DeleteGroup()
end
