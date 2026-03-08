--R.B. Ga10 Pile Bunker
-- 效果：
-- 自己场上的表侧表示怪兽不存在的场合或者只有「奏悦机组」怪兽的场合，这张卡可以从手卡特殊召唤。「奏悦机组 筑工冲击锥」的这个方法的特殊召唤1回合只能有1次。
-- 有这张卡在所连接区的「奏悦机组 狂放蓝调号」和对方怪兽进行战斗的攻击宣言时：可以支付1500基本分；对方场上的卡和这张卡全部破坏。「奏悦机组 筑工冲击锥」的这个效果1回合只能使用1次。
local s,id,o=GetID()
-- 初始化卡片效果，注册两个效果：特殊召唤效果和战斗时破坏效果
function s.initial_effect(c)
	-- 记录该卡与「奏悦机组 狂放蓝调号」（卡号32216688）的关联
	aux.AddCodeList(c,32216688)
	-- 自己场上的表侧表示怪兽不存在的场合或者只有「奏悦机组」怪兽的场合，这张卡可以从手卡特殊召唤。「奏悦机组 筑工冲击锥」的这个方法的特殊召唤1回合只能有1次。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.spcon)
	c:RegisterEffect(e1)
	-- 有这张卡在所连接区的「奏悦机组 狂放蓝调号」和对方怪兽进行战斗的攻击宣言时：可以支付1500基本分；对方场上的卡和这张卡全部破坏。「奏悦机组 筑工冲击锥」的这个效果1回合只能使用1次。
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
-- 过滤函数，用于判断场上是否存在非「奏悦机组」怪兽
function s.cfilter(c)
	return c:IsFaceup() and not c:IsSetCard(0x1cf)
end
-- 判断是否满足特殊召唤条件：场上存在空位且没有非「奏悦机组」怪兽
function s.spcon(e,c)
	if c==nil then return true end
	-- 检查玩家是否有可用的怪兽区域
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
		-- 检查场上是否不存在非「奏悦机组」怪兽
		and not Duel.IsExistingMatchingCard(s.cfilter,c:GetControler(),LOCATION_MZONE,0,1,nil)
end
-- 判断是否满足破坏效果发动条件：当前处于战斗状态且攻击怪兽为「奏悦机组 狂放蓝调号」且连接区包含此卡
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前战斗中的攻击怪兽和防守怪兽
	local bc,oc=Duel.GetBattleMonster(tp)
	return bc and oc and bc:IsCode(32216688) and bc:GetLinkedGroup():IsContains(e:GetHandler())
end
-- 支付1500基本分的费用处理函数
function s.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否能支付1500基本分
	if chk==0 then return Duel.CheckLPCost(tp,1500) end
	-- 支付1500基本分
	Duel.PayLPCost(tp,1500)
end
-- 设置破坏效果的目标：对方场上的所有卡加上此卡
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取对方场上的所有卡
	local g=Duel.GetFieldGroup(tp,0,LOCATION_ONFIELD)
	if chk==0 then return #g>0 end
	g:AddCard(e:GetHandler())
	-- 设置连锁操作信息，指定破坏效果的处理对象和数量
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end
-- 执行破坏效果：将目标卡破坏
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取对方场上的所有卡
	local g=Duel.GetFieldGroup(tp,0,LOCATION_ONFIELD)
	if c:IsRelateToChain() and #g>0 then
		g:AddCard(c)
		-- 执行破坏操作，将目标卡组全部破坏
		Duel.Destroy(g,REASON_EFFECT)
	end
end
