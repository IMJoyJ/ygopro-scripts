--Kozmo－グリンドル
-- 效果：
-- 「星际仙踪-格琳德尔」的①的效果1回合只能使用1次。
-- ①：把场上的这张卡除外才能发动。从手卡把1只5星以上的「星际仙踪」怪兽特殊召唤。这个效果在对方回合也能发动。
-- ②：1回合1次，支付500基本分，以对方场上1只表侧表示怪兽为对象才能发动。那只怪兽变成里侧守备表示。
function c67050396.initial_effect(c)
	-- 「星际仙踪-格琳德尔」的①的效果1回合只能使用1次。①：把场上的这张卡除外才能发动。从手卡把1只5星以上的「星际仙踪」怪兽特殊召唤。这个效果在对方回合也能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(67050396,0))  --"从手卡把「星际仙踪」怪兽特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,67050396)
	e1:SetCost(c67050396.spcost)
	e1:SetTarget(c67050396.sptg)
	e1:SetOperation(c67050396.spop)
	c:RegisterEffect(e1)
	-- ②：1回合1次，支付500基本分，以对方场上1只表侧表示怪兽为对象才能发动。那只怪兽变成里侧守备表示。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(67050396,1))  --"怪兽变成里侧守备表示"
	e2:SetCategory(CATEGORY_POSITION+CATEGORY_MSET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1)
	e2:SetCost(c67050396.poscost)
	e2:SetTarget(c67050396.postg)
	e2:SetOperation(c67050396.posop)
	c:RegisterEffect(e2)
end
-- ①效果的代价判定与执行函数：将场上的自身除外
function c67050396.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost() end
	-- 将自身以表侧表示除外作为发动代价
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_COST)
end
-- 过滤条件：手卡中5星以上的「星际仙踪」怪兽，且能被特殊召唤
function c67050396.spfilter(c,e,tp)
	return c:IsSetCard(0xd2) and c:IsLevelAbove(5) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①效果的发动条件判定与效果分类设置函数
function c67050396.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判定自己场上是否有可用的怪兽区域（因为自身除外会空出一个格子，所以可用格子数大于-1即可）
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
		-- 判定手卡中是否存在满足特殊召唤条件的「星际仙踪」怪兽
		and Duel.IsExistingMatchingCard(c67050396.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置连锁信息：包含从手卡特殊召唤1只怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- ①效果的效果处理（特殊召唤）函数
function c67050396.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否有可用的怪兽区域，若无则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家从手卡选择1只满足条件的「星际仙踪」怪兽
	local g=Duel.SelectMatchingCard(tp,c67050396.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- ②效果的代价判定与执行函数：支付500基本分
function c67050396.poscost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判定玩家是否能够支付500基本分
	if chk==0 then return Duel.CheckLPCost(tp,500) end
	-- 扣除玩家500基本分作为发动代价
	Duel.PayLPCost(tp,500)
end
-- 过滤条件：场上表侧表示且可以变成里侧表示的怪兽
function c67050396.posfilter(c)
	return c:IsFaceup() and c:IsCanTurnSet()
end
-- ②效果的对象选择与效果分类设置函数
function c67050396.postg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and c67050396.posfilter(chkc) end
	-- 判定对方场上是否存在可以变成里侧守备表示的表侧表示怪兽
	if chk==0 then return Duel.IsExistingTarget(c67050396.posfilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 玩家选择对方场上1只表侧表示怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c67050396.posfilter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置连锁信息：包含改变1张卡表示形式的操作
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
end
-- ②效果的效果处理（改变表示形式）函数
function c67050396.posop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将对象怪兽变成里侧守备表示
		Duel.ChangePosition(tc,POS_FACEDOWN_DEFENSE)
	end
end
