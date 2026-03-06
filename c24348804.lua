--一回休み
-- 效果：
-- 特殊召唤的怪兽不在自己场上存在的场合才能把这张卡发动。
-- ①：只要这张卡在魔法与陷阱区域存在，特殊召唤的怪兽直到那个回合结束时效果无效化。
-- ②：效果怪兽攻击表示特殊召唤的场合把这个效果发动。那些怪兽变成守备表示。
function c24348804.initial_effect(c)
	-- ①：只要这张卡在魔法与陷阱区域存在，特殊召唤的怪兽直到那个回合结束时效果无效化。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_SPSUMMON)
	e1:SetCondition(c24348804.condition)
	e1:SetTarget(c24348804.target1)
	e1:SetOperation(c24348804.operation)
	c:RegisterEffect(e1)
	-- ②：效果怪兽攻击表示特殊召唤的场合把这个效果发动。那些怪兽变成守备表示。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_POSITION)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTarget(c24348804.target2)
	e2:SetOperation(c24348804.operation)
	e2:SetLabel(1)
	c:RegisterEffect(e2)
	-- 特殊召唤的怪兽不在自己场上存在的场合才能把这张卡发动。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_DISABLE)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e3:SetTarget(c24348804.distg)
	c:RegisterEffect(e3)
end
-- 过滤函数，检查以player来看的指定位置是否存在至少count张满足过滤条件f并且不等于ex的卡
function c24348804.cfilter(c)
	return c:IsSummonType(SUMMON_TYPE_SPECIAL)
end
-- 检查是否满足发动条件：特殊召唤的怪兽不在自己场上存在
function c24348804.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查以player来看的指定位置是否存在至少count张满足过滤条件f并且不等于ex的卡
	return not Duel.IsExistingMatchingCard(c24348804.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 设置效果处理时点，检查是否触发特殊召唤成功时点并询问是否使用效果
function c24348804.target1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	e:SetLabel(0)
	-- 检查当前是否是EVENT_SPSUMMON_SUCCESS时点
	local res,teg,tep,tev,tre,tr,trp=Duel.CheckEvent(EVENT_SPSUMMON_SUCCESS,true)
	if res then
		local g=teg:Filter(c24348804.filter1,nil)
		-- 判断是否有满足条件的怪兽且玩家选择使用效果
		if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(24348804,0)) then  --"是否使用效果？"
			-- 设置当前正在处理的连锁的对象为g
			Duel.SetTargetCard(g)
			-- 设置当前处理的连锁的操作信息为改变表示形式
			Duel.SetOperationInfo(0,CATEGORY_POSITION,g,g:GetCount(),0,0)
			e:SetLabel(1)
			e:GetHandler():RegisterFlagEffect(0,RESET_CHAIN,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(24348804,1))  --"发动同时使用效果"
		end
	end
end
-- 过滤函数，检查以player来看的指定位置是否存在至少count张满足过滤条件f并且不等于ex的卡
function c24348804.filter1(c)
	return c:IsPosition(POS_FACEUP_ATTACK) and c:IsType(TYPE_EFFECT)
end
-- 设置效果处理时点，检查是否触发特殊召唤成功时点并询问是否使用效果
function c24348804.target2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(c24348804.filter1,1,nil) end
	local g=eg:Filter(c24348804.filter1,nil)
	-- 设置当前正在处理的连锁的对象为g
	Duel.SetTargetCard(g)
	-- 设置当前处理的连锁的操作信息为改变表示形式
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,g:GetCount(),0,0)
end
-- 处理效果发动后的操作，将符合条件的怪兽变为守备表示
function c24348804.operation(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==0 or not e:GetHandler():IsRelateToEffect(e) then return end
	-- 获取连锁中目标卡片组并筛选出与当前效果相关的卡片
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if g:GetCount()>0 then
		-- 将目标怪兽变为守备表示
		Duel.ChangePosition(g,POS_FACEUP_DEFENSE,POS_FACEDOWN_DEFENSE,POS_FACEUP_DEFENSE,POS_FACEDOWN_DEFENSE)
	end
end
-- 过滤函数，检查以player来看的指定位置是否存在至少count张满足过滤条件f并且不等于ex的卡
function c24348804.distg(e,c)
	return c:IsStatus(STATUS_SPSUMMON_TURN) and c:IsSummonType(SUMMON_TYPE_SPECIAL)
end
