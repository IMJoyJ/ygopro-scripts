--E・HERO マリン・ネオス
-- 效果：
-- 「元素英雄 新宇侠」＋「新空间侠·海洋海豚」
-- 让自己场上的上记卡回到卡组的场合才能从额外卡组特殊召唤。
-- ①：1回合1次，自己主要阶段才能发动。对方手卡随机选1张破坏。
function c5128859.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡添加以「元素英雄 新宇侠」和「新空间侠·海洋海豚」为融合素材的融合召唤手续（不允许使用融合素材代用品），使其能通过通常融合召唤从额外卡组出场。
	aux.AddFusionProcCode2(c,89943723,78734254,false,false)
	-- 为这张卡添加接触融合手续：将自己场上可以作为COST送回卡组/额外卡组的怪兽作为素材，素材位置仅限己方场上（对方区域为0），素材通过aux.ContactFusionSendToDeck送回持有者卡组并洗牌，从而无需融合魔法即可从额外卡组特殊召唤。
	aux.AddContactFusionProcedure(c,Card.IsAbleToDeckOrExtraAsCost,LOCATION_ONFIELD,0,aux.ContactFusionSendToDeck(c))
	-- 对应效果原文中“才能从额外卡组特殊召唤”的限制：通过特殊召唤条件辅助限制，使此卡不能被其他效果直接从额外卡组特殊召唤，必须经由上述正规融合/接触融合手续出场。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(c5128859.splimit)
	c:RegisterEffect(e1)
	-- 对应效果原文：“①：1回合1次，自己主要阶段才能发动。对方手卡随机选1张破坏。”
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(5128859,0))  --"手牌破坏"
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetTarget(c5128859.destg)
	e3:SetOperation(c5128859.desop)
	c:RegisterEffect(e3)
end
c5128859.material_setcode=0x8
-- 作为特殊召唤条件判定函数：当这张卡不在额外卡组时返回真（允许特殊召唤），若在额外卡组则返回假（禁止从额外卡组以非正规方式特殊召唤），以卡住从额外卡组直接特招的通用路径。
function c5128859.splimit(e,se,sp,st)
	return not e:GetHandler():IsLocation(LOCATION_EXTRA)
end
-- 作为①效果的发动条件与目标设定函数：先判定对方手牌存在卡片时才能发动，再在发动时设置破坏对方手牌1张的操作信息，供连锁检测及处理使用。
function c5128859.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动条件判定：当chk为0（发动前合法性检查）时，若对方手牌数量大于0则返回真，表示该效果可以发动。
	if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)>0 end
	-- 设置本次连锁的操作信息：声明将执行破坏效果，破坏对象为对方手牌（区域LOCATION_HAND）中随机1张（数量为1），目标玩家为对方（1-tp），因具体对象在效果处理时随机选出，所以targets传nil。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,1-tp,LOCATION_HAND)
end
-- ①效果的最终处理函数：从对方手牌取得全部卡片，随机选出1张后将其破坏，实际完成“对方手卡随机选1张破坏”。
function c5128859.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方手牌中的所有卡片，以卡片组g的形式保存，用于后续随机筛选。
	local g=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
	local sg=g:RandomSelect(tp,1)
	-- 将随机选出的那张对方手牌以“效果”为原因破坏，送入墓地。
	Duel.Destroy(sg,REASON_EFFECT)
end
