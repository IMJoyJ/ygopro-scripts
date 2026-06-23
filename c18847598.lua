--A宝玉獣 アンバー・マンモス
-- 效果：
-- ①：场地区域没有「高等暗黑结界」存在的场合这只怪兽送去墓地。
-- ②：1回合1次，以自己的「高等宝玉兽」卡或者自己的「高等暗黑结界」为对象的效果由对方发动时才能发动。那个发动无效。
-- ③：1回合1次，自己的「高等宝玉兽」怪兽被选择作为攻击对象时才能发动。那次攻击无效。
-- ④：表侧表示的这张卡在怪兽区域被破坏的场合，可以不送去墓地当作永续魔法卡使用在自己的魔法与陷阱区域表侧表示放置。
function c18847598.initial_effect(c)
	-- 注册卡片代码列表，记录该卡与「高等暗黑结界」的关联
	aux.AddCodeList(c,12644061)
	-- 启用全局标记，使卡片破坏时可不入连锁送入墓地
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
-- 判断是否满足①效果的触发条件：场地区域没有「高等暗黑结界」存在
function c18847598.tgcon(e)
	-- 检查当前是否在场地区域存在「高等暗黑结界」
	return not Duel.IsEnvironment(12644061)
end
-- 判断是否满足④效果的触发条件：卡片处于正面表示、在怪兽区域、因破坏而离场
function c18847598.repcon(e)
	local c=e:GetHandler()
	return c:IsFaceup() and c:IsLocation(LOCATION_MZONE) and c:IsReason(REASON_DESTROY)
end
-- 将被破坏的卡片改为永续魔法卡类型并放置于魔法与陷阱区域
function c18847598.repop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 将卡片类型更改为永续魔法卡
	local e1=Effect.CreateEffect(c)
	e1:SetCode(EFFECT_CHANGE_TYPE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
	e1:SetValue(TYPE_SPELL+TYPE_CONTINUOUS)
	c:RegisterEffect(e1)
end
-- 用于筛选目标卡片的过滤器函数：判断是否为己方场上的「高等宝玉兽」或「高等暗黑结界」
function c18847598.tfilter(c,tp)
	return c:IsLocation(LOCATION_ONFIELD) and (c:IsSetCard(0x5034) or c:IsCode(12644061))
		and c:IsControler(tp) and c:IsFaceup()
end
-- 判断是否满足②效果的触发条件：对方发动效果且目标包含己方的「高等宝玉兽」或「高等暗黑结界」
function c18847598.discon(e,tp,eg,ep,ev,re,r,rp)
	if rp==tp or e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) then return false end
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	-- 获取当前连锁的目标卡片组
	local tg=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	-- 检查目标卡片组中是否存在己方的「高等宝玉兽」或「高等暗黑结界」
	return tg and tg:IsExists(c18847598.tfilter,1,nil,tp) and Duel.IsChainNegatable(ev)
end
-- 设置②效果的处理信息：将发动无效
function c18847598.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁处理信息，表示将使发动无效
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end
-- 执行②效果的处理操作：使连锁发动无效
function c18847598.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 使当前连锁发动无效
	Duel.NegateActivation(ev)
end
-- 判断是否满足③效果的触发条件：己方「高等宝玉兽」被选为攻击对象
function c18847598.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前攻击对象
	local d=Duel.GetAttackTarget()
	return d and d:IsControler(tp) and d:IsFaceup() and d:IsSetCard(0x5034)
end
-- 执行③效果的处理操作：使攻击无效
function c18847598.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 使当前攻击无效
	Duel.NegateAttack()
end
