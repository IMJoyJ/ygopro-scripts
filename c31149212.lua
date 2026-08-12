--クシャトリラ・ライズハート
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己场上有「俱舍怒威族」怪兽存在的场合才能发动。这张卡从手卡特殊召唤。这个回合，自己不是超量怪兽不能从额外卡组特殊召唤。
-- ②：这张卡召唤·特殊召唤成功的回合的自己主要阶段，从卡组把「俱舍怒威族·莱斯哈特」以外的1张「俱舍怒威族」卡除外才能发动。从对方卡组上面把3张卡里侧表示除外，这张卡的等级变成7星。
local s,id,o=GetID()
-- 创建两个效果，分别对应①和②效果，①效果为起动效果，②效果为起动效果且只能在召唤或特殊召唤成功后的自己主要阶段发动
function s.initial_effect(c)
	-- ①：自己场上有「俱舍怒威族」怪兽存在的场合才能发动。这张卡从手卡特殊召唤。这个回合，自己不是超量怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡召唤·特殊召唤成功的回合的自己主要阶段，从卡组把「俱舍怒威族·莱斯哈特」以外的1张「俱舍怒威族」卡除外才能发动。从对方卡组上面把3张卡里侧表示除外，这张卡的等级变成7星。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.lvcon)
	e2:SetCost(s.lvcost)
	e2:SetTarget(s.lvtg)
	e2:SetOperation(s.lvop)
	c:RegisterEffect(e2)
	if not s.global_check then
		s.global_check=true
		-- 全局注册用于记录召唤和特殊召唤成功的卡片，以便②效果判断是否在召唤或特殊召唤成功后的自己主要阶段发动
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_SUMMON_SUCCESS)
		ge1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		ge1:SetLabel(id)
		-- 设置效果操作为aux.sumreg，用于记录召唤或特殊召唤成功的卡片
		ge1:SetOperation(aux.sumreg)
		-- 将效果注册到玩家0（双方）
		Duel.RegisterEffect(ge1,0)
		local ge2=ge1:Clone()
		ge2:SetCode(EVENT_SPSUMMON_SUCCESS)
		-- 将效果注册到玩家0（双方）
		Duel.RegisterEffect(ge2,0)
	end
end
-- 过滤函数，用于判断场上是否有「俱舍怒威族」怪兽
function s.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x189)
end
-- ①效果的发动条件，判断自己场上是否有「俱舍怒威族」怪兽
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- ①效果的发动条件，判断自己场上是否有「俱舍怒威族」怪兽
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- ①效果的发动时的处理，判断是否满足特殊召唤条件
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- ①效果的发动时的处理，判断是否满足特殊召唤条件
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息，表示将要特殊召唤此卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①效果的发动处理，将此卡特殊召唤到场上，并设置不能从额外卡组特殊召唤非超量怪兽的效果
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将此卡特殊召唤到场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
	-- 设置不能从额外卡组特殊召唤非超量怪兽的效果
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将不能从额外卡组特殊召唤非超量怪兽的效果注册给玩家
	Duel.RegisterEffect(e1,tp)
end
-- 不能从额外卡组特殊召唤非超量怪兽的效果的过滤函数
function s.splimit(e,c)
	return not c:IsType(TYPE_XYZ) and c:IsLocation(LOCATION_EXTRA)
end
-- ②效果的发动条件，判断此卡是否在召唤或特殊召唤成功后的自己主要阶段
function s.lvcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(id)>0
end
-- ②效果的发动时的费用过滤函数，用于判断是否能除外卡组中的「俱舍怒威族」卡
function s.costfilter(c)
	return not c:IsCode(id) and c:IsSetCard(0x189) and c:IsAbleToRemoveAsCost()
end
-- ②效果的发动时的费用处理，选择并除外卡组中的「俱舍怒威族」卡
function s.lvcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- ②效果的发动时的费用处理，判断是否满足除外卡的条件
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择要除外的卡
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_DECK,0,1,1,nil)
	-- 将选中的卡除外作为费用
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- ②效果的发动时的处理，判断是否满足发动条件
function s.lvtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 获取对方卡组最上方的3张卡
	local tg=Duel.GetDecktopGroup(1-tp,3)
	if chk==0 then return c:IsLevelAbove(0) and not c:IsLevel(7)
		and tg:FilterCount(Card.IsAbleToRemove,nil,tp,POS_FACEDOWN)==3 end
	-- 设置操作信息，表示将要除外对方卡组的3张卡
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,3,1-tp,LOCATION_DECK)
end
-- ②效果的发动处理，将对方卡组最上方的3张卡除外，并将此卡等级变为7星
function s.lvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取对方卡组最上方的3张卡
	local tg=Duel.GetDecktopGroup(1-tp,3)
	if #tg==0 then return end
	-- 禁止洗切卡组检查，防止除外卡组最上方的卡时自动洗切
	Duel.DisableShuffleCheck()
	-- 将对方卡组最上方的3张卡除外
	if Duel.Remove(tg,POS_FACEDOWN,REASON_EFFECT)>0
		and c:IsFaceup() and c:IsRelateToChain() then
		-- 将此卡等级变为7星的效果
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetValue(7)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
	end
end
