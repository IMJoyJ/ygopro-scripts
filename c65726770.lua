--サイレント・マジシャン・ゼロ
-- 效果：
-- 这个卡名的③的效果1回合只能使用1次。
-- ①：对方抽卡的场合发动。这张卡的等级上升抽出数量的数值。
-- ②：这张卡的等级比原本等级高的场合，这张卡的攻击力上升那个相差数值×500。
-- ③：自己场上有「光之黄金柜」存在，对方把魔法卡的效果发动时才能发动。那个发动无效，这张卡的等级上升1星。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数。
function s.initial_effect(c)
	-- 记录这张卡的效果文本中记载了「光之黄金柜」（卡号79791878）。
	aux.AddCodeList(c,79791878)
	-- ①：对方抽卡的场合发动。这张卡的等级上升抽出数量的数值。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"等级上升"
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EVENT_DRAW)
	e1:SetCondition(s.lucon)
	e1:SetOperation(s.luop)
	c:RegisterEffect(e1)
	-- ②：这张卡的等级比原本等级高的场合，这张卡的攻击力上升那个相差数值×500。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(s.value)
	c:RegisterEffect(e2)
	-- ③：自己场上有「光之黄金柜」存在，对方把魔法卡的效果发动时才能发动。那个发动无效，这张卡的等级上升1星。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"魔法卡效果的发动无效"
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
-- 效果①（等级上升）的发动条件：对方抽卡，并将抽卡数量记录在Label中。
function s.lucon(e,tp,eg,ep,ev,re,r,rp)
	e:SetLabel(#eg)
	return ep~=tp
end
-- 效果①（等级上升）的效果处理：使这张卡的等级上升抽出的数量。
function s.luop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 这张卡的等级上升抽出数量的数值。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetValue(e:GetLabel())
		e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e1:SetRange(LOCATION_MZONE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
	end
end
-- 效果②（攻击力上升）的数值计算：当前等级与原本等级的差值乘以500。
function s.value(e,c)
	return math.max(0,c:GetLevel()-c:GetOriginalLevel())*500
end
-- 过滤条件：场上表侧表示的「光之黄金柜」。
function s.cfilter(c)
	return c:IsFaceup() and c:IsCode(79791878)
end
-- 效果③（无效魔法发动）的发动条件：自己场上有「光之黄金柜」存在，对方发动魔法卡的效果时，且该发动可以被无效。
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查自己场上是否存在表侧表示的「光之黄金柜」，若不存在则不能发动。
	if not Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_ONFIELD,0,1,nil) then return false end
	-- 检查自身未被战斗破坏、是对方发动的效果、该效果是魔法卡的效果，且该发动可以被无效。
	return not c:IsStatus(STATUS_BATTLE_DESTROYED) and ep~=tp and re:IsActiveType(TYPE_SPELL) and Duel.IsChainNegatable(ev)
end
-- 效果③（无效魔法发动）的发动准备：设置无效操作信息。
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息为使该魔法卡的效果发动无效。
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end
-- 效果③（无效魔法发动）的效果处理：使发动无效，并使这张卡的等级上升1星。
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 成功使发动无效，且此卡仍在场上表侧表示存在的场合。
	if Duel.NegateActivation(ev) and c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 那个发动无效，这张卡的等级上升1星。
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
