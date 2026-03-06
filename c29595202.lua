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
-- 效果发动时的条件判断，确保发动的是速攻魔法卡
function c29595202.rmcon(e,tp,eg,ep,ev,re,r,rp)
	return re:IsActiveType(TYPE_QUICKPLAY) and re:IsHasType(EFFECT_TYPE_ACTIVATE)
end
-- 设置效果的处理目标，指定将对方卡组最上方的1张卡除外
function c29595202.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁操作信息，表明该效果会将对方卡组最上方的1张卡除外
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,1-tp,LOCATION_DECK)
end
-- 效果的处理函数，负责执行将卡除外的操作
function c29595202.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查对方卡组是否为空，若为空则不执行除外操作
	if Duel.GetFieldGroupCount(tp,0,LOCATION_DECK)==0 then return end
	-- 获取对方卡组最上方的1张卡作为除外目标
	local g=Duel.GetDecktopGroup(1-tp,1)
	-- 禁用洗牌检查，防止除外操作后自动洗切卡组
	Duel.DisableShuffleCheck()
	-- 将目标卡以除外形式从对方卡组最上方移除
	Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
end
