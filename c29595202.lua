--神碑の誑かし
-- 效果：
-- ①：「神碑的欺诳」在自己场上只能有1张表侧表示存在。
-- ②：每次自己或者对方把速攻魔法卡发动才发动。从对方卡组上面把1张卡除外。
function c29595202.initial_effect(c)
	c:SetUniqueOnField(1,0,29595202)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ②：每次自己或者对方把速攻魔法卡发动才发动。从对方卡组上面把1张卡除外。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(29595202,0))  --"对方卡组1张卡除外"
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCondition(c29595202.rmcon)
	e2:SetTarget(c29595202.rmtg)
	e2:SetOperation(c29595202.rmop)
	c:RegisterEffect(e2)
end
-- 判定触发本效果的连锁是否为速攻魔法卡的发动（效果类型为速攻魔法且属于卡的发动），仅在满足此条件时本效果才发动。
function c29595202.rmcon(e,tp,eg,ep,ev,re,r,rp)
	return re:IsActiveType(TYPE_QUICKPLAY) and re:IsHasType(EFFECT_TYPE_ACTIVATE)
end
-- 效果发动时的合法性判定：无额外条件，始终允许发动；同时登记本次操作信息，为后续处理声明将除外对方卡组1张卡。
function c29595202.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置本次连锁的操作信息：除外类别，对象在处理时确定，预定除外对方卡组上方的1张卡。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,1-tp,LOCATION_DECK)
end
-- 效果处理时执行除外：先确认对方卡组有卡，若无则不处理；否则取对方卡组最上方1张卡，以表侧表示除外。
function c29595202.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 检测对方卡组是否有卡，若卡组数量为0则直接结束，不进行除外处理。
	if Duel.GetFieldGroupCount(tp,0,LOCATION_DECK)==0 then return end
	-- 获取对方卡组最上方的那1张卡，作为本次要除外的对象。
	local g=Duel.GetDecktopGroup(1-tp,1)
	-- 禁止本次操作后的自动洗卡组检测，因为从卡组顶端除外1张卡不需要洗切卡组。
	Duel.DisableShuffleCheck()
	-- 将该卡以表侧表示除外，除外原因为效果。
	Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
end
