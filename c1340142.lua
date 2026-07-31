--ヴァルモニカの神奏－ヴァーラル
-- 效果：
-- 包含「异响鸣」连接怪兽的怪兽2只
-- ①：只要自己场上有响鸣指示物6个以上存在，场上的这张卡不受「异响鸣」卡以外的卡的效果影响。
-- ②：这张卡在同1次的战斗阶段中在通常攻击外加上可以作出最多有自己场上的4星「异响鸣」怪兽数量的攻击。
-- ③：1回合1次，对方把怪兽特殊召唤之际才能发动。那次特殊召唤无效，那些怪兽破坏。那之后，自己场上3个响鸣指示物取除。
local s,id,o=GetID()
-- 初始化效果处理函数，为卡片添加连接召唤手续、苏生限制以及三个主要效果的注册
function s.initial_effect(c)
	-- 为c添加连接召唤手续，需要2-2只满足lcheck条件的「异响鸣」连接怪兽作为素材
	aux.AddLinkProcedure(c,nil,2,2,s.lcheck)
	c:EnableReviveLimit()
	-- 创建第一个效果对象e1：设置类型为单卡永续效果（EFFECT_TYPE_SINGLE），代码为效果免疫（EFFECT_IMMUNE_EFFECT），范围为场上主要怪兽区，条件函数s.imcon用于判断是否生效，Value函数s.efilter用于筛选不受影响的敌方卡片集合
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(s.imcon)
	e1:SetValue(s.efilter)
	c:RegisterEffect(e1)
	-- 创建第二个效果对象e2：设置类型为单卡永续效果，代码为增加攻击次数（EFFECT_EXTRA_ATTACK），范围为场上主要怪兽区，Value函数s.atkval动态计算可增加的额外攻击次数
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_EXTRA_ATTACK)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(s.atkval)
	c:RegisterEffect(e2)
	-- 创建第三个效果对象e3：设置为诱发即时效果（二速），触发时机为对方特殊召唤时，类别包含无效召唤和破坏，限制1回合1次使用，条件、目标判断和操作处理分别由对应的子函数负责
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
-- 定义连接素材过滤函数lfilter，返回满足「异响鸣」系列且类型为连接的怪兽组
function s.lfilter(c)
	return c:IsLinkType(TYPE_LINK) and c:IsLinkSetCard(0x1a3)
end
-- 定义辅助检查函数lcheck，用于验证场上是否存在至少一只符合条件的「异响鸣」连接怪兽（通常配合AddLinkProcedure使用）
function s.lcheck(g)
	return g:IsExists(s.lfilter,1,nil)
end
-- 定义计数器筛选函数cfilter，判断卡片是否拥有响鸣指示物（Counter ID 0x6a），即效果①的触发条件基础
function s.cfilter(c)
	return c:GetCounter(0x6a)>0
end
-- 定义辅助计数函数iee，用于获取单张卡片的响鸣指示物数量，供后续求和计算使用
function s.iee(c)
	return c:GetCounter(0x6a)
end
-- 定义免疫效果的发动条件imcon：检索场上所有拥有响鸣指示物的怪兽组并累加总数，当总数大于5时效果生效（对应原文①）
function s.imcon(e)
	-- 从全场中筛选出满足cfilter条件的怪兽组（即拥有至少一个响鸣指示物的怪兽），用于后续计数判断
	local sg=Duel.GetMatchingGroup(s.cfilter,e:GetHandler():GetControler(),LOCATION_ONFIELD,0,nil)
	local ct=sg:GetSum(s.iee)
	return ct>5
end
-- 定义免疫效果的Value函数efilter：返回敌方场上不属于「异响鸣」系列的卡片集合，表示这些卡的效果会被e1效果免疫
function s.efilter(e,te)
	return not te:GetOwner():IsSetCard(0x1a3)
end
-- 定义额外攻击次数的计算辅助函数atkfilter：筛选出己方场上的4星且表侧存在的「异响鸣」怪兽（对应原文②的素材条件）
function s.atkfilter(c)
	return c:IsLevel(4) and c:IsFaceup() and c:IsSetCard(0x1a3)
end
-- 定义额外攻击次数Value函数的具体实现atklval：统计满足atkfilter条件的怪兽数量，作为e2效果的动态数值来源
function s.atkval(e,c)
	-- 从玩家视角检索场上所有满足atkfilter条件的怪兽组并计算总数，用于确定e2效果的实际增加攻击次数上限
	return Duel.GetMatchingGroupCount(s.atkfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,nil)
end
-- 定义即时效果的发动条件discon：限制为对方回合（tp~=ep）且当前连锁序号为0时才能发动（对应原文③的「……之际」触发时机）
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否为对方玩家且在无连锁状态下，确保e3效果仅在对方特殊召唤事件链开始时可被响应
	return tp~=ep and Duel.GetCurrentChain()==0
end
-- 定义即时效果的Target函数distg：首先检查是否具备移除指示物的能力条件，然后设置操作信息为无效召唤类别并指定目标怪兽组及其数量
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 在chk==0分支中预判是否能成功移除3个响鸣指示物（REASON_EFFECT），确保后续破坏效果有资源支撑
	if chk==0 then return Duel.IsCanRemoveCounter(tp,1,0,0x6a,3,REASON_EFFECT) end
	-- 调用SetOperationInfo将e3的操作分类设为CATEGORY_DISABLE_SUMMON，目标设定为被特殊召唤的怪兽组eg，数量为实际召唤数量，用于连锁处理时的对象确认
	Duel.SetOperationInfo(0,CATEGORY_DISABLE_SUMMON,eg,eg:GetCount(),0,0)
end
-- 定义即时效果的Operation函数disop：首先无效化正在进行的特殊召唤（Duel.NegateSummon），然后检查指示物移除条件并执行破坏和取除操作
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 调用NegateSummon使当前被特殊召唤的怪兽组eg的召唤过程失效，对应原文③中「那次特殊召唤无效」的效果处理第一步
	Duel.NegateSummon(eg)
	-- 判断场上是否仍有至少3个响鸣指示物可供移除（REASON_EFFECT），确保后续破坏效果不会因资源不足而失败
	if Duel.IsCanRemoveCounter(tp,1,0,0x6a,3,REASON_EFFECT) then
		-- 调用BreakEffect插入错时点延迟，使后续的Duel.RemoveCounter操作在NegateSummon之后独立执行，避免连锁冲突
		Duel.BreakEffect()
		-- 成功移除己方场上的3个响鸣指示物（LOCATION_MZONE侧，REASON_EFFECT原因），完成原文③中「那之后」的资源消耗效果
		Duel.RemoveCounter(tp,1,0,0x6a,3,REASON_EFFECT)
	end
end
