--プロキシー・ドラゴン
-- 效果：
-- 怪兽2只
-- ①：自己场上的卡被战斗·效果破坏的场合，可以作为代替把这张卡所连接区1只自己怪兽破坏。
function c22862454.initial_effect(c)
	-- 为卡片添加连接召唤手续，需要2个连接素材
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
-- 判断目标卡片是否为己方在场怪兽且因战斗或效果破坏且不是代替破坏
function c22862454.repfilter(c,tp)
	return c:IsControler(tp) and c:IsOnField()
		and c:IsReason(REASON_BATTLE+REASON_EFFECT) and not c:IsReason(REASON_REPLACE)
end
-- 判断目标卡片是否为己方怪兽且可被破坏且未处于预定破坏或战斗破坏状态
function c22862454.desfilter(c,e,tp)
	return c:IsControler(tp) and c:IsType(TYPE_MONSTER)
		and c:IsDestructable(e) and not c:IsStatus(STATUS_DESTROY_CONFIRMED+STATUS_BATTLE_DESTROYED)
end
-- 判断是否满足代替破坏条件，即有己方在场怪兽因战斗或效果被破坏，且连接区有可破坏的己方怪兽
function c22862454.desreptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local g=c:GetLinkedGroup()
	if chk==0 then return eg:IsExists(c22862454.repfilter,1,nil,tp)
		and g:IsExists(c22862454.desfilter,1,nil,e,tp) end
	-- 向玩家询问是否发动此效果
	if Duel.SelectEffectYesNo(tp,c,96) then
		-- 提示玩家选择要代替破坏的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESREPLACE)  --"请选择要代替破坏的卡"
		local sg=g:FilterSelect(tp,c22862454.desfilter,1,1,nil,e,tp)
		e:SetLabelObject(sg:GetFirst())
		sg:GetFirst():SetStatus(STATUS_DESTROY_CONFIRMED,true)
		return true
	else return false end
end
-- 设置代替破坏效果的判断条件，返回目标卡片是否满足代替破坏条件
function c22862454.desrepval(e,c)
	return c22862454.repfilter(c,e:GetHandlerPlayer())
end
-- 执行代替破坏效果，将选定的怪兽破坏
function c22862454.desrepop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家提示此卡发动了效果
	Duel.Hint(HINT_CARD,0,22862454)
	local tc=e:GetLabelObject()
	tc:SetStatus(STATUS_DESTROY_CONFIRMED,false)
	-- 将选定的怪兽以效果和代替破坏原因进行破坏
	Duel.Destroy(tc,REASON_EFFECT+REASON_REPLACE)
end
