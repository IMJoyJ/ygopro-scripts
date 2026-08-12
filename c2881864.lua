--炎の王 ナグルファー
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：「炎界王战 纳吉尔法王」在自己场上只能有1只表侧表示存在。
-- ②：自己场上的卡被战斗·效果破坏的场合，可以作为代替把自己场上1只「王战」怪兽或者兽战士族怪兽破坏。
function c2881864.initial_effect(c)
	c:SetUniqueOnField(1,0,2881864)
	-- 创建一个代替破坏效果，用于处理自己场上的卡被战斗或效果破坏时的代替破坏处理
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
-- 过滤函数，用于判断被破坏的卡是否为战斗或效果破坏且未被替换
function c2881864.repfilter(c,tp)
	return c:IsControler(tp) and c:IsOnField()
		and c:IsReason(REASON_BATTLE+REASON_EFFECT) and not c:IsReason(REASON_REPLACE)
end
-- 过滤函数，用于选择可以作为代替破坏的「王战」怪兽或兽战士族怪兽
function c2881864.desfilter(c,e,tp)
	return c:IsFaceup() and c:IsControler(tp) and c:IsLocation(LOCATION_MZONE) and (c:IsSetCard(0x134) or c:IsRace(RACE_BEASTWARRIOR))
		and c:IsDestructable(e) and not c:IsStatus(STATUS_DESTROY_CONFIRMED+STATUS_BATTLE_DESTROYED)
end
-- 判断是否满足代替破坏的条件，即存在被破坏的卡且自己场上存在可代替破坏的怪兽
function c2881864.desreptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(c2881864.repfilter,1,nil,tp)
		-- 检查自己场上是否存在满足代替破坏条件的怪兽
		and Duel.IsExistingMatchingCard(c2881864.desfilter,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	-- 询问玩家是否发动此效果
	if Duel.SelectEffectYesNo(tp,e:GetHandler(),96) then
		-- 提示玩家选择要代替破坏的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESREPLACE)  --"请选择要代替破坏的卡"
		-- 让玩家选择1只满足条件的怪兽作为代替破坏的对象
		local g=Duel.SelectMatchingCard(tp,c2881864.desfilter,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
		e:SetLabelObject(g:GetFirst())
		g:GetFirst():SetStatus(STATUS_DESTROY_CONFIRMED,true)
		return true
	end
	return false
end
-- 设置代替破坏效果的值，返回是否满足代替破坏条件
function c2881864.desrepval(e,c)
	return c2881864.repfilter(c,e:GetHandlerPlayer())
end
-- 执行代替破坏操作，将选中的怪兽破坏
function c2881864.desrepop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家显示此卡发动的动画提示
	Duel.Hint(HINT_CARD,0,2881864)
	local tc=e:GetLabelObject()
	tc:SetStatus(STATUS_DESTROY_CONFIRMED,false)
	-- 将选中的怪兽以效果和代替破坏的原因进行破坏
	Duel.Destroy(tc,REASON_EFFECT+REASON_REPLACE)
end
