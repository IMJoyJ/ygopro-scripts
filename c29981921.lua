--真六武衆－シエン
-- 效果：
-- 战士族调整＋调整以外的「六武众」怪兽1只以上
-- ①：1回合1次，对方把魔法·陷阱卡发动时才能发动。那个发动无效并破坏。
-- ②：场上的这张卡被战斗·效果破坏的场合，可以作为代替把自己场上1只「六武众」怪兽破坏。
function c29981921.initial_effect(c)
	-- 添加同调召唤手续，需要1只战士族调整和1只以上六武众调整以外的怪兽
	aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsRace,RACE_WARRIOR),aux.NonTuner(Card.IsSetCard,0x103d),1)
	c:EnableReviveLimit()
	-- ①：1回合1次，对方把魔法·陷阱卡发动时才能发动。那个发动无效并破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(29981921,0))  --"魔法陷阱发动无效并破坏"
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(c29981921.discon)
	e1:SetTarget(c29981921.distg)
	e1:SetOperation(c29981921.disop)
	c:RegisterEffect(e1)
	-- ②：场上的这张卡被战斗·效果破坏的场合，可以作为代替把自己场上1只「六武众」怪兽破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTarget(c29981921.desreptg)
	e2:SetOperation(c29981921.desrepop)
	c:RegisterEffect(e2)
end
-- 效果发动时的条件判断，确保不是战斗破坏且对方发动魔法或陷阱卡且该连锁可无效
function c29981921.discon(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED)
		-- 对方发动魔法或陷阱卡且该连锁可无效
		and ep~=tp and re:IsHasType(EFFECT_TYPE_ACTIVATE) and Duel.IsChainNegatable(ev)
end
-- 设置连锁处理信息，标记将使发动无效和破坏
function c29981921.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁处理信息，标记将使发动无效
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置连锁处理信息，标记将破坏
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 效果处理函数，使连锁无效并破坏对应卡片
function c29981921.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 使连锁无效且对应卡片存在并关联到效果
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 破坏对应的目标卡片
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
-- 代替破坏的过滤函数，筛选场上满足条件的六武众怪兽
function c29981921.repfilter(c,e)
	return c:IsFaceup() and c:IsSetCard(0x103d)
		and c:IsDestructable(e) and not c:IsStatus(STATUS_DESTROY_CONFIRMED+STATUS_BATTLE_DESTROYED)
end
-- 代替破坏效果的发动条件判断，确认是战斗或效果破坏且场上存在可代替的六武众怪兽
function c29981921.desreptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsReason(REASON_BATTLE+REASON_EFFECT) and not c:IsReason(REASON_REPLACE)
		-- 场上存在满足代替破坏条件的六武众怪兽
		and Duel.IsExistingMatchingCard(c29981921.repfilter,tp,LOCATION_MZONE,0,1,c,e) end
	-- 玩家选择是否发动代替破坏效果
	if Duel.SelectEffectYesNo(tp,c,96) then
		-- 提示玩家选择要代替破坏的六武众怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESREPLACE)  --"请选择要代替破坏的卡"
		-- 选择场上满足代替破坏条件的六武众怪兽
		local g=Duel.SelectMatchingCard(tp,c29981921.repfilter,tp,LOCATION_MZONE,0,1,1,c,e)
		e:SetLabelObject(g:GetFirst())
		g:GetFirst():SetStatus(STATUS_DESTROY_CONFIRMED,true)
		return true
	else return false end
end
-- 代替破坏效果的处理函数，将选中的怪兽破坏
function c29981921.desrepop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	tc:SetStatus(STATUS_DESTROY_CONFIRMED,false)
	-- 将选中的怪兽以效果和代替破坏原因进行破坏
	Duel.Destroy(tc,REASON_EFFECT+REASON_REPLACE)
end
