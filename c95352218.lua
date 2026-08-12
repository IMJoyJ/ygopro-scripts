--天下統一
-- 效果：
-- 双方的准备阶段时，回合玩家从自己场上的怪兽的等级之内选1个，持有那个等级以外的等级的自己场上表侧表示存在的怪兽全部送去墓地。
function c95352218.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_STANDBY_PHASE)
	c:RegisterEffect(e1)
	-- 双方的准备阶段时，回合玩家从自己场上的怪兽的等级之内选1个，持有那个等级以外的等级的自己场上表侧表示存在的怪兽全部送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(95352218,0))  --"送去墓地"
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetOperation(c95352218.adjustop)
	c:RegisterEffect(e2)
end
-- 辅助函数：检查传入的怪兽组中所有怪兽的等级是否完全相同
function c95352218.checklv(g)
	local tc=g:GetFirst()
	local lv=tc:GetLevel()
	tc=g:GetNext()
	while tc do
		if not tc:IsLevel(lv) then return false end
		tc=g:GetNext()
	end
	return true
end
-- 过滤函数：筛选场上表侧表示且具有等级的怪兽
function c95352218.filter1(c)
	return c:IsFaceup() and c:IsLevelAbove(1)
end
-- 过滤函数：筛选场上表侧表示、具有等级且等级不等于指定等级的怪兽
function c95352218.filter2(c,lv)
	return c:IsFaceup() and not c:IsLevel(lv) and c:IsLevelAbove(1)
end
-- 效果处理：回合玩家获取自身场上的怪兽，若满足条件则选择一个等级，并将该等级以外的表侧表示怪兽全部送去墓地
function c95352218.adjustop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前的回合玩家
	local turnp=Duel.GetTurnPlayer()
	-- 获取回合玩家自己场上所有表侧表示且持有等级的怪兽组
	local g=Duel.GetMatchingGroup(c95352218.filter1,turnp,LOCATION_MZONE,0,nil)
	if g:GetCount()<2 then return end
	if c95352218.checklv(g) then return end
	-- 向回合玩家提示选择要保留的等级对应的怪兽
	Duel.Hint(HINT_SELECTMSG,turnp,aux.Stringid(95352218,1))  --"请选择要保留的等级对应的怪兽"
	local clv=g:Select(turnp,1,1,nil):GetFirst():GetLevel()
	local dg=g:Filter(c95352218.filter2,nil,clv)
	-- 将筛选出的其他等级的怪兽全部因效果送去墓地
	Duel.SendtoGrave(dg,REASON_EFFECT)
end
