--クシャトリラ・ライズハート
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己场上有「俱舍怒威族」怪兽存在的场合才能发动。这张卡从手卡特殊召唤。这个回合，自己不是超量怪兽不能从额外卡组特殊召唤。
-- ②：这张卡召唤·特殊召唤成功的回合的自己主要阶段，从卡组把「俱舍怒威族·莱斯哈特」以外的1张「俱舍怒威族」卡除外才能发动。从对方卡组上面把3张卡里侧表示除外，这张卡的等级变成7星。
local s,id,o=GetID()
-- 注册这张卡的①效果（手牌特殊召唤并附加额外卡组自肃）和②效果（除外卡组1张俱舍怒威族卡，除外对方卡组顶3张并变为7星），并注册监听通常召唤/特殊召唤成功的全局效果，为②的发动条件提供标记。
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
		-- ①：自己场上有「俱舍怒威族」怪兽存在的场合才能发动。这张卡从手卡特殊召唤。这个回合，自己不是超量怪兽不能从额外卡组特殊召唤。②：这张卡召唤·特殊召唤成功的回合的自己主要阶段
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_SUMMON_SUCCESS)
		ge1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		ge1:SetLabel(id)
		-- 设置ge1的操作函数为aux.sumreg，用于在怪兽通常召唤成功时记录该卡的召唤成功标记（为②的发动条件提供依据）。
		ge1:SetOperation(aux.sumreg)
		-- 将ge1注册为全局效果（player=0），监听通常召唤成功事件。
		Duel.RegisterEffect(ge1,0)
		local ge2=ge1:Clone()
		ge2:SetCode(EVENT_SPSUMMON_SUCCESS)
		-- 将ge2注册为全局效果，监听特殊召唤成功事件，补充②中“特殊召唤成功”的条件检测。
		Duel.RegisterEffect(ge2,0)
	end
end
-- 定义过滤条件s.cfilter：对象卡须表侧表示且属于「俱舍怒威族」系列（0x189）。
function s.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x189)
end
-- 定义①的发动条件s.spcon：自己场上有1张以上满足s.cfilter的「俱舍怒威族」怪兽存在。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在至少1张表侧表示的「俱舍怒威族」怪兽，存在则返回true。
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 定义①的发动目标流程：在chk==0时确认己方主要怪兽区有空位且这张卡可以被特殊召唤，满足才可发动。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动检查时，确认己方主要怪兽区存在空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置本次效果的操作信息为特殊召唤这张卡，供规则时点检测使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 定义①的效果处理：若这张卡仍与效果关联则将其表侧特殊召唤；随后给己方玩家附加“本回合不能从额外卡组特殊召唤非超量怪兽”的自肃效果（回合结束重置）。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡以表侧攻击表示特殊召唤到己方场上，不检查召唤条件与苏生限制。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
	-- ①：自己场上有「俱舍怒威族」怪兽存在的场合才能发动。这张卡从手卡特殊召唤。这个回合，自己不是超量怪兽不能从额外卡组特殊召唤。②：这张卡召唤·特殊召唤成功的回合的自己主要阶段，从卡组把「俱舍怒威族·莱斯哈特」以外的1张「俱舍怒威族」卡除外才能发动。从对方卡组上面把3张卡里侧表示除外，这张卡的等级变成7星。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将自肃效果e1注册给己方玩家tp，使其本回合受到“不能从额外卡组特殊召唤非超量怪兽”的限制。
	Duel.RegisterEffect(e1,tp)
end
-- 定义自肃效果的判定s.splimit：从额外卡组特殊召唤的卡若不是超量怪兽，则禁止其特殊召唤。
function s.splimit(e,c)
	return not c:IsType(TYPE_XYZ) and c:IsLocation(LOCATION_EXTRA)
end
-- 定义②的发动条件s.lvcon：这张卡拥有召唤/特殊召唤成功的标记（通过flag记录）时才可发动。
function s.lvcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(id)>0
end
-- 定义cost筛选s.costfilter：卡组中除这张卡（莱斯哈特）以外、属于「俱舍怒威族」系列且可作为cost除外的卡。
function s.costfilter(c)
	return not c:IsCode(id) and c:IsSetCard(0x189) and c:IsAbleToRemoveAsCost()
end
-- 定义②的cost处理：从卡组选择1张满足条件的「俱舍怒威族」卡表侧除外作为发动代价。
function s.lvcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在cost合法性检查时，确认卡组中存在可被选择作为代价的「俱舍怒威族」卡。
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 给玩家显示“请选择要除外的卡”的提示消息，为选择卡片做准备。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从卡组中选出1张满足s.costfilter的「俱舍怒威族」卡作为cost。
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_DECK,0,1,1,nil)
	-- 将选择好的卡以表侧表示除外，作为②效果的发动代价。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 定义②的目标条件：对方卡组顶3张卡都可以被里侧除外，且这张卡当前等级不是7；随后设置除外对方卡组顶3张的操作信息。
function s.lvtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 获取对方卡组最上方的3张卡，作为待除外对象。
	local tg=Duel.GetDecktopGroup(1-tp,3)
	if chk==0 then return c:IsLevelAbove(0) and not c:IsLevel(7)
		and tg:FilterCount(Card.IsAbleToRemove,nil,tp,POS_FACEDOWN)==3 end
	-- 设置本次连锁的操作信息：将对方卡组顶3张里侧表示除外（不取对象、数量3、归属对方、位置卡组）。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,3,1-tp,LOCATION_DECK)
end
-- 定义②的效果处理：将对方卡组顶3张里侧除外，若成功且这张卡仍在场并表侧表示，则使其等级变为7星。
function s.lvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 再次获取对方卡组最上方的3张卡，用于实际除外。
	local tg=Duel.GetDecktopGroup(1-tp,3)
	if #tg==0 then return end
	-- 禁用本次操作的洗牌检查，因为是从卡组顶端除外固定张数，不需要洗牌。
	Duel.DisableShuffleCheck()
	-- 将对方卡组顶3张卡里侧表示除外，并判断是否至少除掉了1张，以决定是否继续处理等级变更。
	if Duel.Remove(tg,POS_FACEDOWN,REASON_EFFECT)>0
		and c:IsFaceup() and c:IsRelateToChain() then
		-- 这张卡的等级变成7星。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetValue(7)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
	end
end
