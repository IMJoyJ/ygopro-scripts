--魔法妖精 バーガンディ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡在怪兽区域存在的状态，对方手卡被效果丢弃的场合才能发动。给与对方那个数量×400伤害。
-- ②：这张卡被战斗破坏送去墓地时才能发动。对方手卡随机1张丢弃。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数
function s.initial_effect(c)
	-- ①：这张卡在怪兽区域存在的状态，对方手卡被效果丢弃的场合才能发动。给与对方那个数量×400伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_DISCARD)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.dmgcon)
	e1:SetTarget(s.dmgtg)
	e1:SetOperation(s.dmgop)
	c:RegisterEffect(e1)
	-- ②：这张卡被战斗破坏送去墓地时才能发动。对方手卡随机1张丢弃。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_HANDES)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_DESTROYED)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.handescon)
	e2:SetTarget(s.handestg)
	e2:SetOperation(s.handesop)
	c:RegisterEffect(e2)
end
-- 过滤条件：被效果丢弃的、原本持有者为对方的手卡
function s.dmgfilter(c,tp)
	return c:IsPreviousLocation(LOCATION_HAND) and c:IsPreviousControler(tp)
		and c:IsReason(REASON_EFFECT) and c:IsReason(REASON_DISCARD)
end
-- 效果①的发动条件：有对方手卡被效果丢弃
function s.dmgcon(e,tp,eg,ep,ev,re,r,rp)
	return re and eg:IsExists(s.dmgfilter,1,nil,1-tp)
end
-- 效果①的靶向/目标处理：计算被丢弃卡片数量并设置伤害参数
function s.dmgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local ct=eg:FilterCount(s.dmgfilter,nil,1-tp)
	-- 设置当前连锁的对象玩家为对方
	Duel.SetTargetPlayer(1-tp)
	-- 设置当前连锁的对象参数为伤害数值（丢弃数量×400）
	Duel.SetTargetParam(ct*400)
	-- 设置当前连锁的操作信息：给与对方对应数值的伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,ct*400)
end
-- 效果①的操作处理：给与对方对应数量×400的伤害
function s.dmgop(e,tp,eg,ep,ev,re,r,rp)
	local ct=eg:FilterCount(s.dmgfilter,nil,1-tp)
	-- 给与对方对应数值的效果伤害
	Duel.Damage(1-tp,ct*400,REASON_EFFECT)
end
-- 效果②的发动条件：自身被送去墓地
function s.handescon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE)
end
-- 效果②的靶向/目标处理：确认对方手卡数量并设置丢弃手卡的操作信息
function s.handestg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断对方手卡数量是否大于0
	if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)>0 end
	-- 设置当前连锁的操作信息：将对方1张手卡送去墓地（丢弃）
	Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,1-tp,1)
end
-- 效果②的操作处理：随机选择对方1张手卡丢弃
function s.handesop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方手卡的所有卡片
	local g=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
	if g:GetCount()==0 then return end
	local sg=g:RandomSelect(tp,1)
	-- 将选中的卡片以效果丢弃的形式送去墓地
	Duel.SendtoGrave(sg,REASON_DISCARD+REASON_EFFECT)
end
