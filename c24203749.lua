--天下独歩の大義賊
-- 效果：
-- 自己场上没有怪兽存在的场合，这张卡可以从自己手卡以及对方场上之中把怪兽解放，表侧表示上级召唤。这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡是已通常召唤的场合，对方把手卡·墓地·除外状态的卡的效果发动时才能发动。那个效果无效并破坏。
-- ②：自己·对方的战斗阶段，把手卡全部给对方观看才能发动。对方场上的怪兽全部变成守备表示。
local s,id,o=GetID()
-- 初始化卡片效果：e0为自己场上没有怪兽时增加手卡和对方场上的额外祭品的永续效果，e1为对方发动手卡·墓地·除外状态的卡的效果时将其无效并破坏的诱发即时效果（1回合1次），e2为战斗阶段公开全部手卡使对方场上怪兽全部变成守备表示的诱发即时效果（1回合1次）
function s.initial_effect(c)
	-- 自己场上没有怪兽存在的场合，这张卡可以从自己手卡以及对方场上之中把怪兽解放，表侧表示上级召唤。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_ADD_EXTRA_TRIBUTE)
	e0:SetCondition(s.sumcon)
	e0:SetTargetRange(LOCATION_HAND,LOCATION_MZONE)
	e0:SetTarget(s.sumtg)
	e0:SetValue(POS_FACEUP_ATTACK)
	c:RegisterEffect(e0)
	-- ①：这张卡是已通常召唤的场合，对方把手卡·墓地·除外状态的卡的效果发动时才能发动。那个效果无效并破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))  --"效果无效"
	e1:SetCategory(CATEGORY_DISABLE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.discon)
	e1:SetTarget(s.distg)
	e1:SetOperation(s.disop)
	c:RegisterEffect(e1)
	-- ②：自己·对方的战斗阶段，把手卡全部给对方观看才能发动。对方场上的怪兽全部变成守备表示。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))  --"表示形式"
	e2:SetCategory(CATEGORY_POSITION)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.cpcon)
	e2:SetCost(s.cpcost)
	e2:SetTarget(s.cptg)
	e2:SetOperation(s.cpop)
	c:RegisterEffect(e2)
end
-- 额外祭品效果的适用条件：自己场上不存在任何怪兽
function s.sumcon(e)
	-- 检查自己场上（主要怪兽区和额外怪兽区）是否不存在怪兽
	return not Duel.IsExistingMatchingCard(aux.TRUE,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
-- 额外祭品的目标过滤：可作为祭品的是这张卡以外的怪兽卡
function s.sumtg(e,c)
	return c~=e:GetHandler() and c:IsType(TYPE_MONSTER)
end
-- ①效果发动条件：这张卡不是战斗破坏确定状态，该连锁的效果可以被无效，这张卡已通常召唤，连锁由对方发动且连锁发生位置在手卡·墓地·除外状态
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取该连锁的效果发动位置（手卡·墓地·除外等）
	local loc=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)
	-- 判断这张卡不是战斗破坏确定状态且该连锁的效果可以被无效
	return not c:IsStatus(STATUS_BATTLE_DESTROYED) and Duel.IsChainDisablable(ev)
		and c:IsSummonType(SUMMON_TYPE_NORMAL) and ep==1-tp
		and loc and bit.band(loc,LOCATION_HAND+LOCATION_GRAVE+LOCATION_REMOVED)~=0
end
-- ①效果的目标设定：标记将无效该连锁的卡；若发动效果的卡可以被破坏且仍与该效果相关，则同时标记将其破坏
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：将连锁的那张卡的效果无效
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置操作信息：破坏连锁的那张卡
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- ①效果的处理：使该连锁的效果无效，若发动效果的卡仍与该连锁相关则将其效果破坏
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 使该连锁的效果无效成功且发动效果的卡仍与该连锁相关时
	if Duel.NegateEffect(ev) and re:GetHandler():IsRelateToChain(ev) then
		-- 以效果破坏连锁的那张卡
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
-- ②效果发动条件：当前处于自己或对方的战斗阶段
function s.cpcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前是否处于战斗阶段
	return Duel.IsBattlePhase()
end
-- ②效果的代价：取得自己全部手卡，发动条件是手卡有卡且没有已公开的手卡，然后把全部手卡给对方观看并洗切自己的手卡
function s.cpcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 取得自己手卡的全部卡
	local g=Duel.GetFieldGroup(tp,LOCATION_HAND,0)
	-- 发动条件检查：自己手卡数量大于0且手卡中没有已公开的卡
	if chk==0 then return g:GetCount()>0 and not Duel.IsExistingMatchingCard(Card.IsPublic,tp,LOCATION_HAND,0,1,nil) end
	-- 把自己全部手卡给对方观看
	Duel.ConfirmCards(1-tp,g)
	-- 洗切自己的手卡
	Duel.ShuffleHand(tp)
end
-- 过滤函数：对象是表侧攻击表示且可以改变表示形式的怪兽
function s.posfilter(c)
	return c:IsPosition(POS_FACEUP_ATTACK) and c:IsCanChangePosition()
end
-- ②效果的目标设定：检查对方场上存在表侧攻击表示且可改变表示形式的怪兽，并将这些怪兽全部标记为改变表示形式的操作对象
function s.cptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方场上是否存在表侧攻击表示且可以改变表示形式的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.posfilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 取得对方场上全部表侧攻击表示且可以改变表示形式的怪兽
	local g=Duel.GetMatchingGroup(s.posfilter,tp,0,LOCATION_MZONE,nil)
	-- 设置操作信息：将这些怪兽全部作为改变表示形式的对象
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,g:GetCount(),0,0)
end
-- ②效果的处理：取得对方场上全部表侧攻击表示的怪兽并全部变成表侧守备表示
function s.cpop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得对方场上全部表侧攻击表示且可以改变表示形式的怪兽
	local g=Duel.GetMatchingGroup(s.posfilter,tp,0,LOCATION_MZONE,nil)
	if #g>0 then
		-- 将这些怪兽全部变成表侧守备表示
		Duel.ChangePosition(g,POS_FACEUP_DEFENSE)
	end
end
