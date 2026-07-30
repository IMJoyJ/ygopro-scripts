--ヴァルモニカの神奏－ヴァーラル
-- 效果：
-- 包含「异响鸣」连接怪兽的怪兽2只
-- ①：只要自己场上有响鸣指示物6个以上存在，场上的这张卡不受「异响鸣」卡以外的卡的效果影响。
-- ②：这张卡在同1次的战斗阶段中在通常攻击外加上可以作出最多有自己场上的4星「异响鸣」怪兽数量的攻击。
-- ③：1回合1次，对方把怪兽特殊召唤之际才能发动。那次特殊召唤无效，那些怪兽破坏。那之后，自己场上3个响鸣指示物取除。
local s,id,o=GetID()
-- 初始化效果，设置连接召唤手续、苏生限制和三个效果
function s.initial_effect(c)
	-- 添加连接召唤手续，要求使用2只以上满足条件的怪兽作为连接素材
	aux.AddLinkProcedure(c,nil,2,2,s.lcheck)
	c:EnableReviveLimit()
	-- 效果①：只要自己场上有响鸣指示物6个以上存在，场上的这张卡不受「异响鸣」卡以外的卡的效果影响
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(s.imcon)
	e1:SetValue(s.efilter)
	c:RegisterEffect(e1)
	-- 效果②：这张卡在同1次的战斗阶段中在通常攻击外加上可以作出最多有自己场上的4星「异响鸣」怪兽数量的攻击
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_EXTRA_ATTACK)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(s.atkval)
	c:RegisterEffect(e2)
	-- 效果③：1回合1次，对方把怪兽特殊召唤之际才能发动。那次特殊召唤无效，那些怪兽破坏。那之后，自己场上3个响鸣指示物取除
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
-- 连接素材过滤函数，判断是否为「异响鸣」连接怪兽
function s.lfilter(c)
	return c:IsLinkType(TYPE_LINK) and c:IsLinkSetCard(0x1a3)
end
-- 连接召唤检查函数，判断是否存在满足条件的连接素材
function s.lcheck(g)
	return g:IsExists(s.lfilter,1,nil)
end
-- 指示物数量过滤函数，判断是否有响鸣指示物
function s.cfilter(c)
	return c:GetCounter(0x6a)>0
end
-- 获取指示物数量函数，用于计算总指示物数
function s.iee(c)
	return c:GetCounter(0x6a)
end
-- 效果①的发动条件函数，判断己方场上响鸣指示物总数是否大于5
function s.imcon(e)
	-- 获取己方场上的所有有响鸣指示物的卡
	local sg=Duel.GetMatchingGroup(s.cfilter,e:GetHandler():GetControler(),LOCATION_ONFIELD,0,nil)
	local ct=sg:GetSum(s.iee)
	return ct>5
end
-- 效果①的过滤函数，判断效果来源是否为「异响鸣」卡
function s.efilter(e,te)
	return not te:GetOwner():IsSetCard(0x1a3)
end
-- 攻击次数计算用的怪兽过滤函数，筛选4星且为「异响鸣」的表侧表示怪兽
function s.atkfilter(c)
	return c:IsLevel(4) and c:IsFaceup() and c:IsSetCard(0x1a3)
end
-- 效果②的值函数，返回己方场上的4星「异响鸣」怪兽数量
function s.atkval(e,c)
	-- 返回己方场上的4星「异响鸣」怪兽数量
	return Duel.GetMatchingGroupCount(s.atkfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,nil)
end
-- 效果③的发动条件函数，判断是否为对方特殊召唤且当前无连锁处理
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否为对方特殊召唤且当前无连锁处理
	return tp~=ep and Duel.GetCurrentChain()==0
end
-- 效果③的目标设定函数，检查是否可以移除3个响鸣指示物并设置操作信息
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查是否可以移除3个响鸣指示物
	if chk==0 then return Duel.IsCanRemoveCounter(tp,1,0,0x6a,3,REASON_EFFECT) end
	-- 设置操作信息，指定要无效召唤和破坏的卡组
	Duel.SetOperationInfo(0,CATEGORY_DISABLE_SUMMON,eg,eg:GetCount(),0,0)
end
-- 效果③的处理函数，使特殊召唤无效并破坏相关怪兽，随后移除3个响鸣指示物
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 使特殊召唤无效
	Duel.NegateSummon(eg)
	-- 检查是否可以移除3个响鸣指示物
	if Duel.IsCanRemoveCounter(tp,1,0,0x6a,3,REASON_EFFECT) then
		-- 中断当前连锁处理
		Duel.BreakEffect()
		-- 移除己方场上的3个响鸣指示物
		Duel.RemoveCounter(tp,1,0,0x6a,3,REASON_EFFECT)
	end
end
