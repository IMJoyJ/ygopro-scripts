--R.B.GA１０パイルバンカー
-- 效果：
-- 这个卡名的①的方法的特殊召唤1回合只能有1次，②的效果1回合只能使用1次。
-- ①：自己场上的表侧表示怪兽不存在的场合或者只有「反叛曲机器人」怪兽的场合，这张卡可以从手卡特殊召唤。
-- ②：有这张卡位于所连接区的「反叛曲机器人 粗暴蓝调斗牛犬」在和对方怪兽进行战斗的攻击宣言时，支付1500基本分才能发动。这张卡和对方场上的卡全部破坏。
local s,id,o=GetID()
-- 初始化卡片效果：注册①的手卡特殊召唤规则效果和②的攻击宣言时破坏双方场上卡的诱发效果
function s.initial_effect(c)
	-- 记录这张卡上记载着卡名「反叛曲机器人 粗暴蓝调斗牛犬」（卡号32216688）
	aux.AddCodeList(c,32216688)
	-- ①：自己场上的表侧表示怪兽不存在的场合或者只有「反叛曲机器人」怪兽的场合，这张卡可以从手卡特殊召唤。这个卡名的①的方法的特殊召唤1回合只能有1次
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.spcon)
	c:RegisterEffect(e1)
	-- ②：有这张卡位于所连接区的「反叛曲机器人 粗暴蓝调斗牛犬」在和对方怪兽进行战斗的攻击宣言时，支付1500基本分才能发动。这张卡和对方场上的卡全部破坏。这个卡名的②的效果1回合只能使用1次
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
-- 定义过滤器：表侧表示且不是「反叛曲机器人」（0x1cf）系列的怪兽
function s.cfilter(c)
	return c:IsFaceup() and not c:IsSetCard(0x1cf)
end
-- ①效果特殊召唤的发动条件：自己有可用的主要怪兽区，且自己场上不存在表侧表示的非「反叛曲机器人」怪兽（即场上没有怪兽或只有「反叛曲机器人」怪兽）
function s.spcon(e,c)
	if c==nil then return true end
	-- 检查自己场上是否有可用的主要怪兽区空格
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
		-- 检查自己场上不存在表侧表示的非「反叛曲机器人」怪兽
		and not Duel.IsExistingMatchingCard(s.cfilter,c:GetControler(),LOCATION_MZONE,0,1,nil)
end
-- ②效果的发动条件：正处于战斗中的自己怪兽是「反叛曲机器人 粗暴蓝调斗牛犬」，且对方有进行战斗的怪兽，并且这张卡位于那只怪兽所连接区
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 取得自己正在战斗中的怪兽（bc）和对方的战斗对象怪兽（oc）
	local bc,oc=Duel.GetBattleMonster(tp)
	return bc and oc and bc:IsCode(32216688) and bc:GetLinkedGroup():IsContains(e:GetHandler())
end
-- ②效果的发动代价：检查并支付1500基本分
function s.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否能支付1500基本分
	if chk==0 then return Duel.CheckLPCost(tp,1500) end
	-- 支付1500基本分作为发动代价
	Duel.PayLPCost(tp,1500)
end
-- ②效果的目标设定：取得对方场上的所有卡，确认对方场上有卡存在后，将这张卡加入其中，并设置破坏操作信息
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 取得对方场上的所有卡
	local g=Duel.GetFieldGroup(tp,0,LOCATION_ONFIELD)
	if chk==0 then return #g>0 end
	g:AddCard(e:GetHandler())
	-- 设置连锁的操作信息：这次效果将破坏这张卡和对方场上的全部卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end
-- ②效果的处理：取得对方场上的所有卡，若这张卡与当前连锁关联且对方场上有卡，则将这张卡加入并全部破坏
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得对方场上的所有卡
	local g=Duel.GetFieldGroup(tp,0,LOCATION_ONFIELD)
	if c:IsRelateToChain() and #g>0 then
		g:AddCard(c)
		-- 以效果破坏这张卡和对方场上的全部卡
		Duel.Destroy(g,REASON_EFFECT)
	end
end
