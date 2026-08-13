--炎の王 ナグルファー
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：「炎界王战 纳吉尔法王」在自己场上只能有1只表侧表示存在。
-- ②：自己场上的卡被战斗·效果破坏的场合，可以作为代替把自己场上1只「王战」怪兽或者兽战士族怪兽破坏。
function c2881864.initial_effect(c)
	c:SetUniqueOnField(1,0,2881864)
	-- 这个卡名的②的效果1回合只能使用1次。②：自己场上的卡被战斗·效果破坏的场合，可以作为代替把自己场上1只「王战」怪兽或者兽战士族怪兽破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_DESTROY_REPLACE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,2881864)
	e1:SetTarget(c2881864.desreptg)
	e1:SetValue(c2881864.desrepval)
	e1:SetOperation(c2881864.desrepop)
	c:RegisterEffect(e1)
end
-- 过滤出被战斗或效果破坏且仍在自己场上的卡，并排除已经由代替破坏引起破坏的卡。
function c2881864.repfilter(c,tp)
	return c:IsControler(tp) and c:IsOnField()
		and c:IsReason(REASON_BATTLE+REASON_EFFECT) and not c:IsReason(REASON_REPLACE)
end
-- 过滤条件：可作为代替破坏的卡必须是表侧表示、己方控制、位于主要怪兽区，且是「王战」怪兽或兽战士族怪兽，可被效果破坏，且未被预定破坏或处于战斗破坏确定状态。
function c2881864.desfilter(c,e,tp)
	return c:IsFaceup() and c:IsControler(tp) and c:IsLocation(LOCATION_MZONE) and (c:IsSetCard(0x134) or c:IsRace(RACE_BEASTWARRIOR))
		and c:IsDestructable(e) and not c:IsStatus(STATUS_DESTROY_CONFIRMED+STATUS_BATTLE_DESTROYED)
end
-- 代替破坏的发动条件判定：存在满足条件的被破坏卡片，且己方场上存在可选的代替破坏对象。
function c2881864.desreptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(c2881864.repfilter,1,nil,tp)
		-- 检查己方场上是否存在至少1张满足条件的代替破坏对象（王战或兽战士族怪兽）。
		and Duel.IsExistingMatchingCard(c2881864.desfilter,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	-- 让己方玩家选择是否发动这个代替破坏效果。
	if Duel.SelectEffectYesNo(tp,e:GetHandler(),96) then
		-- 显示选择提示，要求玩家选择要代替破坏的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESREPLACE)  --"请选择要代替破坏的卡"
		-- 从己方场上选择1张符合条件的「王战」怪兽或兽战士族怪兽作为代替破坏的对象。
		local g=Duel.SelectMatchingCard(tp,c2881864.desfilter,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
		e:SetLabelObject(g:GetFirst())
		g:GetFirst():SetStatus(STATUS_DESTROY_CONFIRMED,true)
		return true
	end
	return false
end
-- 该值函数对每张要被破坏的卡判断是否满足己方场上、因战斗/效果破坏且非代破，以此决定是否触发本次代替破坏。
function c2881864.desrepval(e,c)
	return c2881864.repfilter(c,e:GetHandlerPlayer())
end
-- 执行代替破坏：将之前选择的那只怪兽破坏，使其代替原本要被破坏的己方卡片。
function c2881864.desrepop(e,tp,eg,ep,ev,re,r,rp)
	-- 向双方展示该卡的发动动画，提示正在处理代替破坏效果。
	Duel.Hint(HINT_CARD,0,2881864)
	local tc=e:GetLabelObject()
	tc:SetStatus(STATUS_DESTROY_CONFIRMED,false)
	-- 将选定的卡以效果破坏并标记为代替破坏原因，完成代替破坏。
	Duel.Destroy(tc,REASON_EFFECT+REASON_REPLACE)
end
