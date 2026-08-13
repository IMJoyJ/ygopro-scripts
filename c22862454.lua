--プロキシー・ドラゴン
-- 效果：
-- 怪兽2只
-- ①：自己场上的卡被战斗·效果破坏的场合，可以作为代替把这张卡所连接区1只自己怪兽破坏。
function c22862454.initial_effect(c)
	-- 为“代理龙”添加连接召唤手续：用且仅用2只怪兽作为连接素材。
	aux.AddLinkProcedure(c,nil,2,2)
	c:EnableReviveLimit()
	-- ①：自己场上的卡被战斗·效果破坏的场合，可以作为代替把这张卡所连接区1只自己怪兽破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_DESTROY_REPLACE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(c22862454.desreptg)
	e1:SetValue(c22862454.desrepval)
	e1:SetOperation(c22862454.desrepop)
	c:RegisterEffect(e1)
end
-- 判定被破坏的卡是否满足代破条件：是自己场上的卡、在场、因战斗或效果被破坏、且不是因代替效果被破坏。
function c22862454.repfilter(c,tp)
	return c:IsControler(tp) and c:IsOnField()
		and c:IsReason(REASON_BATTLE+REASON_EFFECT) and not c:IsReason(REASON_REPLACE)
end
-- 判定所连接区的怪兽是否可作为代替破坏的对象：是自己场上的怪兽、可被效果破坏、且未处于已被确定破坏的状态。
function c22862454.desfilter(c,e,tp)
	return c:IsControler(tp) and c:IsType(TYPE_MONSTER)
		and c:IsDestructable(e) and not c:IsStatus(STATUS_DESTROY_CONFIRMED+STATUS_BATTLE_DESTROYED)
end
-- 代替破坏效果的发动条件：当自己场上有卡将被战斗或效果破坏，且所连接区存在符合条件的可代替破坏的怪兽时，该效果才可能发动。
function c22862454.desreptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local g=c:GetLinkedGroup()
	if chk==0 then return eg:IsExists(c22862454.repfilter,1,nil,tp)
		and g:IsExists(c22862454.desfilter,1,nil,e,tp) end
	-- 询问玩家是否发动代替破坏效果。
	if Duel.SelectEffectYesNo(tp,c,96) then
		-- 显示选择提示，让玩家从所连接区中选择1只要代替破坏的自己怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESREPLACE)  --"请选择要代替破坏的卡"
		local sg=g:FilterSelect(tp,c22862454.desfilter,1,1,nil,e,tp)
		e:SetLabelObject(sg:GetFirst())
		sg:GetFirst():SetStatus(STATUS_DESTROY_CONFIRMED,true)
		return true
	else return false end
end
-- 效果值判定函数：将即将被破坏的卡交由repfilter检查，确认它是否属于可被代替破坏的“自己场上被战斗/效果破坏的卡”。
function c22862454.desrepval(e,c)
	return c22862454.repfilter(c,e:GetHandlerPlayer())
end
-- 代替破坏的实际处理：播放卡片动画，取消被选怪兽的预定破坏状态，然后将该怪兽破坏。
function c22862454.desrepop(e,tp,eg,ep,ev,re,r,rp)
	-- 展示“代理龙”的卡片动画，提示玩家正在发动代替破坏效果。
	Duel.Hint(HINT_CARD,0,22862454)
	local tc=e:GetLabelObject()
	tc:SetStatus(STATUS_DESTROY_CONFIRMED,false)
	-- 以效果破坏并附带代替破坏原因，将被选择的连接区怪兽破坏。
	Duel.Destroy(tc,REASON_EFFECT+REASON_REPLACE)
end
