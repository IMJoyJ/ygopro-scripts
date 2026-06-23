--龍馬躓図
-- 效果：
-- 从额外卡组特殊召唤的怪兽在双方场上存在的场合才能把这张卡发动。
-- ①：只要这张卡在魔法与陷阱区域存在，从额外卡组特殊召唤的表侧表示怪兽的效果无效化。
-- ②：从额外卡组特殊召唤的怪兽之间的战斗让怪兽被破坏的场合发动。这张卡送去墓地，那次战斗破坏的怪兽的控制者受到1000伤害。
function c15462014.initial_effect(c)
	-- 从额外卡组特殊召唤的怪兽在双方场上存在的场合才能把这张卡发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c15462014.actcon)
	c:RegisterEffect(e1)
	-- 只要这张卡在魔法与陷阱区域存在，从额外卡组特殊召唤的表侧表示怪兽的效果无效化。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_DISABLE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetTarget(c15462014.distg)
	c:RegisterEffect(e2)
	-- 从额外卡组特殊召唤的怪兽之间的战斗让怪兽被破坏的场合发动。这张卡送去墓地，那次战斗破坏的怪兽的控制者受到1000伤害。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_TOGRAVE+CATEGORY_DAMAGE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_BATTLE_DESTROYED)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCondition(c15462014.tgcon)
	e3:SetTarget(c15462014.tgtg)
	e3:SetOperation(c15462014.tgop)
	c:RegisterEffect(e3)
end
-- 过滤函数，检查以player来看的指定位置是否存在至少count张满足过滤条件f并且不等于ex的卡
function c15462014.cfilter(c)
	return c:IsSummonLocation(LOCATION_EXTRA)
end
-- 检查以player来看的指定位置是否存在至少count张满足过滤条件f并且不等于ex的卡
function c15462014.actcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查以player来看的指定位置是否存在至少count张满足过滤条件f并且不等于ex的卡
	return Duel.IsExistingMatchingCard(c15462014.cfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 检查以player来看的指定位置是否存在至少count张满足过滤条件f并且不等于ex的卡
		and Duel.IsExistingMatchingCard(c15462014.cfilter,tp,0,LOCATION_MZONE,1,nil)
end
-- 过滤函数，检查以player来看的指定位置是否存在至少count张满足过滤条件f并且不等于ex的卡
function c15462014.distg(e,c)
	return c:IsSummonLocation(LOCATION_EXTRA)
end
-- 过滤函数，检查以player来看的指定位置是否存在至少count张满足过滤条件f并且不等于ex的卡
function c15462014.egfilter(c)
	local d=c:GetBattleTarget()
	return c:IsSummonLocation(LOCATION_EXTRA) and d:IsSummonLocation(LOCATION_EXTRA)
end
-- 过滤函数，检查以player来看的指定位置是否存在至少count张满足过滤条件f并且不等于ex的卡
function c15462014.pcheck(c,tp)
	return c:IsPreviousControler(tp)
end
-- 过滤函数，检查以player来看的指定位置是否存在至少count张满足过滤条件f并且不等于ex的卡
function c15462014.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c15462014.egfilter,1,nil)
end
-- 过滤函数，检查以player来看的指定位置是否存在至少count张满足过滤条件f并且不等于ex的卡
function c15462014.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置当前处理的连锁的操作信息此操作信息包含了效果处理中确定要处理的效果分类
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,e:GetHandler(),1,0,0)
	local tg,pct,player=eg:Filter(c15462014.egfilter,nil),0,0
	for p=0,1 do
		if tg:IsExists(c15462014.pcheck,1,nil,p) then
			pct=pct+1
			player=p
		end
	end
	if pct==2 then player=PLAYER_ALL end
	-- 设置当前处理的连锁的操作信息此操作信息包含了效果处理中确定要处理的效果分类
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,player,1000)
end
-- 过滤函数，检查以player来看的指定位置是否存在至少count张满足过滤条件f并且不等于ex的卡
function c15462014.tgop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 以reason原因把targets送去墓地，返回值是实际被操作的数量
		Duel.SendtoGrave(c,REASON_EFFECT)
		local tg=eg:Filter(c15462014.egfilter,nil)
		for p=0,1 do
			if tg:IsExists(c15462014.pcheck,1,nil,p) then
				-- 以reason原因给与玩家player造成value的伤害，返回实际收到的伤害值
				Duel.Damage(p,1000,REASON_EFFECT,true)
			end
		end
		-- 在调用Duel.Damage/Duel.Recover时，若is_step参数为true，则需调用此函数触发时点
		Duel.RDComplete()
	end
end
