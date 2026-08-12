--ヴァルモニカの神奏－ヴァーラル
-- 效果：
-- 包含「异响鸣」连接怪兽的怪兽2只
-- ①：只要自己场上有响鸣指示物6个以上存在，场上的这张卡不受「异响鸣」卡以外的卡的效果影响。
-- ②：这张卡在同1次的战斗阶段中在通常攻击外加上可以作出最多有自己场上的4星「异响鸣」怪兽数量的攻击。
-- ③：1回合1次，对方把怪兽特殊召唤之际才能发动。那次特殊召唤无效，那些怪兽破坏。那之后，自己场上3个响鸣指示物取除。
local s,id,o=GetID()
-- 初始化效果：注册连接召唤手续与苏生限制，并注册①不受「异响鸣」卡以外效果影响的永续效果、②增加攻击次数的永续效果、③对方特殊召唤之际无效并破坏的诱发即时效果
function s.initial_effect(c)
	-- 添加连接召唤手续：以2只怪兽为素材进行连接召唤，且素材组中必须包含「异响鸣」连接怪兽
	aux.AddLinkProcedure(c,nil,2,2,s.lcheck)
	c:EnableReviveLimit()
	-- ①：只要自己场上有响鸣指示物6个以上存在，场上的这张卡不受「异响鸣」卡以外的卡的效果影响。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(s.imcon)
	e1:SetValue(s.efilter)
	c:RegisterEffect(e1)
	-- ②：这张卡在同1次的战斗阶段中在通常攻击外加上可以作出最多有自己场上的4星「异响鸣」怪兽数量的攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_EXTRA_ATTACK)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(s.atkval)
	c:RegisterEffect(e2)
	-- ③：1回合1次，对方把怪兽特殊召唤之际才能发动。那次特殊召唤无效，那些怪兽破坏。那之后，自己场上3个响鸣指示物取除。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"多次攻击"
	e3:SetCategory(CATEGORY_DISABLE_SUMMON+CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EVENT_SPSUMMON)
	e3:SetCountLimit(1)
	e3:SetCondition(s.discon)
	e3:SetTarget(s.distg)
	e3:SetOperation(s.disop)
	c:RegisterEffect(e3)
end
s.mentioned_counter={
	[0x6a]=true,
}
-- 筛选条件：该卡是「异响鸣」系列的连接怪兽
function s.lfilter(c)
	return c:IsLinkType(TYPE_LINK) and c:IsLinkSetCard(0x1a3)
end
-- 检查连接素材组中是否至少存在1只「异响鸣」连接怪兽
function s.lcheck(g)
	return g:IsExists(s.lfilter,1,nil)
end
-- 筛选条件：该卡上放置有响鸣指示物
function s.cfilter(c)
	return c:GetCounter(0x6a)>0
end
-- 返回该卡上放置的响鸣指示物数量
function s.iee(c)
	return c:GetCounter(0x6a)
end
-- ①效果的适用条件：统计自己场上的响鸣指示物总数，在6个以上（即5以上）时这张卡获得效果免疫
function s.imcon(e)
	-- 检索自己场上所有放置有响鸣指示物的卡
	local sg=Duel.GetMatchingGroup(s.cfilter,e:GetHandler():GetControler(),LOCATION_ONFIELD,0,nil)
	local ct=sg:GetSum(s.iee)
	return ct>5
end
-- 免疫范围过滤：只对「异响鸣」卡以外的卡发动的效果免疫
function s.efilter(e,te)
	return not te:GetOwner():IsSetCard(0x1a3)
end
-- 筛选条件：表侧表示的4星「异响鸣」怪兽
function s.atkfilter(c)
	return c:IsLevel(4) and c:IsFaceup() and c:IsSetCard(0x1a3)
end
-- 计算这张卡可增加的攻击次数：等于自己场上4星「异响鸣」怪兽的数量
function s.atkval(e,c)
	-- 检索并统计自己怪兽区表侧表示的4星「异响鸣」怪兽数量
	return Duel.GetMatchingGroupCount(s.atkfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,nil)
end
-- ③效果的发动条件：是对方进行特殊召唤且当前没有正在处理的连锁
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定特殊召唤由对方进行且不在连锁处理中
	return tp~=ep and Duel.GetCurrentChain()==0
end
-- 目标设定：先确认自己能以效果为原因移除3个响鸣指示物才能发动，然后设置无效召唤的操作信息
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 发动可行性检查：自己必须能以效果为原因移除场上3个响鸣指示物，否则不能发动
	if chk==0 then return Duel.IsCanRemoveCounter(tp,1,0,0x6a,3,REASON_EFFECT) end
	-- 设置操作信息：这次连锁将对方正在特殊召唤的那些怪兽的特殊召唤无效，数量为eg中怪兽的数量
	Duel.SetOperationInfo(0,CATEGORY_DISABLE_SUMMON,eg,eg:GetCount(),0,0)
end
-- 效果处理：使那次特殊召唤无效并将那些怪兽破坏，之后若仍能移除指示物，则中断处理后取除自己场上3个响鸣指示物
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 使对方正在特殊召唤的那些怪兽的特殊召唤无效（无效后那些怪兽破坏）
	Duel.NegateSummon(eg)
	-- 再次确认自己能否以效果为原因移除3个响鸣指示物
	if Duel.IsCanRemoveCounter(tp,1,0,0x6a,3,REASON_EFFECT) then
		-- 中断当前效果处理，使之后的指示物取除视为不同时处理
		Duel.BreakEffect()
		-- 以效果为原因取除自己场上3个响鸣指示物
		Duel.RemoveCounter(tp,1,0,0x6a,3,REASON_EFFECT)
	end
end
