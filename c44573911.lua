--R.B.GA１０パイルバンカー
-- 效果：
-- 自己场上的表侧表示怪兽不存在的场合或者只有「奏悦机组」怪兽的场合，这张卡可以从手卡特殊召唤。「奏悦机组 筑工冲击锥」的这个方法的特殊召唤1回合只能有1次。
-- 有这张卡在所连接区的「奏悦机组 狂放蓝调号」和对方怪兽进行战斗的攻击宣言时：可以支付1500基本分；对方场上的卡和这张卡全部破坏。「奏悦机组 筑工冲击锥」的这个效果1回合只能使用1次。
local s,id,o=GetID()
-- 定义卡片效果处理函数，首先注册“奏悦机组”怪兽的代码列表，然后创建并注册特殊召唤流程效果和破坏效果。
function s.initial_effect(c)
	-- 将卡片32216688（「奏悦机组 狂放蓝调号」）的代码添加到代码列表中，用于后续的条件判断。
	aux.AddCodeList(c,32216688)
	-- 创建一个场上效果，设置其类型为字段效果，代码为特殊召唤流程，不可复制，生效位置为手牌，一回合只能发动一次，并设定特殊召唤的条件函数。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.spcon)
	c:RegisterEffect(e1)
	-- 创建一个诱发选发效果，描述为“破坏效果”，分类为破坏效果，生效位置为主怪兽区，触发条件为攻击宣言时，一回合只能发动一次，并设置条件、支付费用、目标选择和操作函数。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"破坏效果"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.descon)
	e2:SetCost(s.descost)
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
end
-- 定义一个过滤函数，用于判断场上表侧表示的非「奏悦机组」怪兽是否存在。
function s.cfilter(c)
	return c:IsFaceup() and not c:IsSetCard(0x1cf)
end
-- 定义特殊召唤的条件函数，检查当前玩家场上是否有怪兽，以及是否不存在满足过滤条件的表侧表示怪兽。
function s.spcon(e,c)
	if c==nil then return true end
	-- 检查当前玩家的主要怪兽区是否有卡片存在。
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
		-- 检查当前玩家的主要怪兽区中是否存在不属于「奏悦机组」的表侧表示怪兽。
		and not Duel.IsExistingMatchingCard(s.cfilter,c:GetControler(),LOCATION_MZONE,0,1,nil)
end
-- 定义破坏效果的条件函数，判断攻击宣言时，己方场上的「奏悦机组 狂放蓝调号」是否与对方怪兽进行战斗，并且该卡连接召唤了当前卡片。
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取攻击玩家和被攻击玩家的战斗怪兽。
	local bc,oc=Duel.GetBattleMonster(tp)
	return bc and oc and bc:IsCode(32216688) and bc:GetLinkedGroup():IsContains(e:GetHandler())
end
-- 定义破坏效果的支付费用函数，检查玩家是否能支付1500基本分，并支付费用。
function s.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否能够支付1500点生命值。
	if chk==0 then return Duel.CheckLPCost(tp,1500) end
	-- 让玩家支付1500点生命值。
	Duel.PayLPCost(tp,1500)
end
-- 定义破坏效果的目标选择函数，获取当前玩家的场上卡片组，如果存在卡片则返回true，并将当前卡片添加到目标卡片组中，并设置操作信息。
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取当前玩家的场上所有卡片。
	local g=Duel.GetFieldGroup(tp,0,LOCATION_ONFIELD)
	if chk==0 then return #g>0 end
	g:AddCard(e:GetHandler())
	-- 设置操作信息，指定破坏效果的分类、目标卡片组和数量。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end
-- 定义破坏效果的操作函数，获取当前卡片的handler，获取当前玩家的场上卡片组，如果当前卡片与连锁有关且场上存在卡片则将当前卡片添加到卡片组并进行破坏。
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前玩家的场上所有卡片。
	local g=Duel.GetFieldGroup(tp,0,LOCATION_ONFIELD)
	if c:IsRelateToChain() and #g>0 then
		g:AddCard(c)
		-- 以效果原因破坏目标卡片组中的所有卡片。
		Duel.Destroy(g,REASON_EFFECT)
	end
end
