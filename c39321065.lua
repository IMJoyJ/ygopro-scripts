--サイレント・ソードマン・ゼロ
-- 效果：
-- 这个卡名的③的效果1回合只能使用1次。
-- ①：自己·对方的准备阶段发动。这张卡的等级上升1星。
-- ②：这张卡的等级比原本等级高的场合，这张卡的攻击力上升那个相差数值×500。
-- ③：以自己场上的「光之黄金柜」或者有那个卡名记述的怪兽为对象的效果由对方发动时才能发动。那个发动无效，这张卡的等级上升1星。
local s,id,o=GetID()
-- 注册“沉默剑士·零”的全部效果：①准备阶段等级上升效果、②攻击力随等级差提升的永续效果、③无效对方以自己场上相关卡为对象的效果并上升等级的诱发即时效果；同时通过 aux.AddCodeList 将「光之黄金柜」登记为卡名记述的卡片。
function s.initial_effect(c)
	-- 将卡号79791878（光之黄金柜）登记为该卡效果文本中记载的卡名，供 aux.IsCodeListed 查询。
	aux.AddCodeList(c,79791878)
	-- ①：自己·对方的准备阶段发动。这张卡的等级上升1星。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"等级上升"
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e1:SetOperation(s.lvop)
	c:RegisterEffect(e1)
	-- ②：这张卡的等级比原本等级高的场合，这张卡的攻击力上升那个相差数值×500。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(s.value)
	c:RegisterEffect(e2)
	-- 这个卡名的③的效果1回合只能使用1次。③：以自己场上的「光之黄金柜」或者有那个卡名记述的怪兽为对象的效果由对方发动时才能发动。那个发动无效，这张卡的等级上升1星。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"发动无效"
	e3:SetCategory(CATEGORY_NEGATE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e3:SetCode(EVENT_CHAINING)
	e3:SetCountLimit(1,id)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(s.negcon)
	e3:SetTarget(s.negtg)
	e3:SetOperation(s.negop)
	c:RegisterEffect(e3)
end
-- ①效果处理：准备阶段触发时，若这张卡表侧表示且仍与该效果关联，则为它附加等级上升1星的效果，该效果在卡片离场、无效等情况下重置。
function s.lvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFacedown() or not c:IsRelateToEffect(e) then return end
	-- 这张卡的等级上升1星。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_LEVEL)
	e1:SetValue(1)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
	c:RegisterEffect(e1)
end
-- ②效果攻击力上升值的计算：取“当前等级－原本等级”与0的较大值，再乘以500。
function s.value(e,c)
	return math.max(0,c:GetLevel()-c:GetOriginalLevel())*500
end
-- ③效果的目标筛选：判断一张卡是否为“自己场上表侧表示的「光之黄金柜」或卡名记述有「光之黄金柜」的怪兽”。
function s.tfilter(c,tp)
	return c:IsOnField() and c:IsControler(tp) and c:IsFaceup()
		-- 目标卡需满足：卡名是「光之黄金柜」（79791878），或是怪兽且其效果文本中记载有「光之黄金柜」的卡名。
		and (c:IsCode(79791878) or c:IsType(TYPE_MONSTER) and aux.IsCodeListed(c,79791878))
end
-- ③的发动条件：对方发动效果且该效果是取对象效果，对象中存在自己场上满足条件的卡，且该连锁可被无效；同时自身不处于战斗破坏确定状态。
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	if rp==tp or e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) then return false end
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	-- 取得对方发动的那个连锁效果所选取的对象卡组。
	local tg=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	-- 判断取对象的目标中是否存在至少1张「光之黄金柜」或有该卡名记述的怪兽，并且该连锁的发动能够被无效。
	return tg and tg:IsExists(s.tfilter,1,nil,tp) and Duel.IsChainNegatable(ev)
end
-- ③发动时的合法性判定：无需指定对象，直接允许发动，并登记本次处理为“无效发动”类。
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：将对方发动的那个效果（eg）标记为要被无效的目标，类别为 CATEGORY_NEGATE，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end
-- ③效果处理：先无效对方发动的效果；若无效成功且这张卡仍与该效果关联并表侧表示，则再让这张卡的等级上升1星。
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 调用 Duel.NegateActivation(ev) 执行无效对方发动，同时检查无效是否成功、这张卡是否仍关联且表侧表示。
	if Duel.NegateActivation(ev) and c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 这张卡的等级上升1星。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetValue(1)
		e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e1:SetRange(LOCATION_MZONE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
	end
end
