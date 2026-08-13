--A宝玉獣 アンバー・マンモス
-- 效果：
-- ①：场地区域没有「高等暗黑结界」存在的场合这只怪兽送去墓地。
-- ②：1回合1次，以自己的「高等宝玉兽」卡或者自己的「高等暗黑结界」为对象的效果由对方发动时才能发动。那个发动无效。
-- ③：1回合1次，自己的「高等宝玉兽」怪兽被选择作为攻击对象时才能发动。那次攻击无效。
-- ④：表侧表示的这张卡在怪兽区域被破坏的场合，可以不送去墓地当作永续魔法卡使用在自己的魔法与陷阱区域表侧表示放置。
function c18847598.initial_effect(c)
	-- 登记本卡效果文本中提到的「高等暗黑结界」（卡号12644061），使相关卡名查询与关联可用。
	aux.AddCodeList(c,12644061)
	-- 启用全局标志GLOBALFLAG_SELF_TOGRAVE，使不入连锁的自我送墓效果（本卡①效果）可以正常处理。
	Duel.EnableGlobalFlag(GLOBALFLAG_SELF_TOGRAVE)
	-- ①：场地区域没有「高等暗黑结界」存在的场合这只怪兽送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SELF_TOGRAVE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCondition(c18847598.tgcon)
	c:RegisterEffect(e1)
	-- ④：表侧表示的这张卡在怪兽区域被破坏的场合，可以不送去墓地当作永续魔法卡使用在自己的魔法与陷阱区域表侧表示放置。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_TO_GRAVE_REDIRECT_CB)
	e2:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e2:SetCondition(c18847598.repcon)
	e2:SetOperation(c18847598.repop)
	c:RegisterEffect(e2)
	-- ②：1回合1次，以自己的「高等宝玉兽」卡或者自己的「高等暗黑结界」为对象的效果由对方发动时才能发动。那个发动无效。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(18847598,0))  --"发动无效"
	e3:SetCategory(CATEGORY_NEGATE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e3:SetCountLimit(1)
	e3:SetCondition(c18847598.discon)
	e3:SetTarget(c18847598.distg)
	e3:SetOperation(c18847598.disop)
	c:RegisterEffect(e3)
	-- ③：1回合1次，自己的「高等宝玉兽」怪兽被选择作为攻击对象时才能发动。那次攻击无效。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(18847598,1))  --"攻击无效"
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_BE_BATTLE_TARGET)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1)
	e4:SetCondition(c18847598.atkcon)
	e4:SetOperation(c18847598.atkop)
	c:RegisterEffect(e4)
end
-- 条件函数：判断当前场上是否存在「高等暗黑结界」，若不存在则①效果条件成立，自身将被送去墓地。
function c18847598.tgcon(e)
	-- 检查卡号12644061的场地卡是否生效，返回其否定值；若场上没有「高等暗黑结界」，则满足自我送墓条件。
	return not Duel.IsEnvironment(12644061)
end
-- 条件函数：判断这张卡是否满足④的适用条件，即表侧表示存在于主要怪兽区域且被破坏。
function c18847598.repcon(e)
	local c=e:GetHandler()
	return c:IsFaceup() and c:IsLocation(LOCATION_MZONE) and c:IsReason(REASON_DESTROY)
end
-- 操作函数：将这张卡的种类变为永续魔法，使其作为永续魔法卡继续放置在魔法与陷阱区域（配合重定向效果实际转移位置）。
function c18847598.repop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- ④：可以不送去墓地当作永续魔法卡使用在自己的魔法与陷阱区域表侧表示放置。
	local e1=Effect.CreateEffect(c)
	e1:SetCode(EFFECT_CHANGE_TYPE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
	e1:SetValue(TYPE_SPELL+TYPE_CONTINUOUS)
	c:RegisterEffect(e1)
end
-- 筛选函数：判断一张卡是否为控制者tp的表侧表示卡片，且卡名属于「高等宝玉兽」（0x5034）或为「高等暗黑结界」，用于②检查对象。
function c18847598.tfilter(c,tp)
	return c:IsLocation(LOCATION_ONFIELD) and (c:IsSetCard(0x5034) or c:IsCode(12644061))
		and c:IsControler(tp) and c:IsFaceup()
end
-- 发动条件：对方发动了以我方场上「高等宝玉兽」卡或「高等暗黑结界」为对象的取对象效果，且该效果可以被无效；自身未被战斗破坏后才能发动②。
function c18847598.discon(e,tp,eg,ep,ev,re,r,rp)
	if rp==tp or e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) then return false end
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	-- 获取连锁ev中被取对象的效果所选中的所有对象卡片（Group对象）。
	local tg=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	-- 若对象卡组中至少存在1张满足tfilter条件的卡（即以我方「高等宝玉兽」或「高等暗黑结界」为对象），且该连锁能够被无效，则②条件成立。
	return tg and tg:IsExists(c18847598.tfilter,1,nil,tp) and Duel.IsChainNegatable(ev)
end
-- 发动时无需额外选择卡片，只要满足条件即可发动；同时登记本次效果为无效发动类别。
function c18847598.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置本连锁的操作信息为「无效发动」，用于宣告将把对象效果无效化。
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end
-- 效果处理时执行无效对方那次发动的操作。
function c18847598.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 将连锁ev的发动无效（无效对方发动的那个取对象效果）。
	Duel.NegateActivation(ev)
end
-- 发动条件：自己的表侧表示的「高等宝玉兽」怪兽被选择为攻击对象时，满足③的发动条件。
function c18847598.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前战斗阶段被选择为攻击对象的怪兽（即攻击目标）。
	local d=Duel.GetAttackTarget()
	return d and d:IsControler(tp) and d:IsFaceup() and d:IsSetCard(0x5034)
end
-- 效果处理时执行无效那次攻击的操作。
function c18847598.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 使当前宣言的攻击无效化。
	Duel.NegateAttack()
end
