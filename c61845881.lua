--ミナイルカ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：水属性怪兽的效果发动时才能发动。这张卡从手卡特殊召唤。
-- ②：把自己场上1只表侧表示的鱼族·海龙族·水族怪兽除外，以场上1张表侧表示卡为对象才能发动。那张卡的效果直到对方回合结束时无效。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含①效果（手卡特召）和②效果（场上卡片效果无效）
function s.initial_effect(c)
	-- ①：水属性怪兽的效果发动时才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：把自己场上1只表侧表示的鱼族·海龙族·水族怪兽除外，以场上1张表侧表示卡为对象才能发动。那张卡的效果直到对方回合结束时无效。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DISABLE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCost(s.discost)
	e2:SetTarget(s.distg)
	e2:SetOperation(s.disop)
	c:RegisterEffect(e2)
end
-- ①效果的启动条件判定函数：检查是否有水属性怪兽的效果发动
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前连锁中发动的效果是否为怪兽效果，且该怪兽的属性为水属性
	return re:IsActiveType(TYPE_MONSTER) and Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_ATTRIBUTE)&ATTRIBUTE_WATER>0
end
-- ①效果的发动准备与合法性检测函数
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置效果处理信息，表明该效果包含将自身特殊召唤的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- ①效果的效果处理函数：将自身特殊召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 若此卡仍存在于原本位置，则以表侧表示特殊召唤到自身场上
	if c:IsRelateToEffect(e) then Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP) end
end
-- ②效果的Cost过滤函数：筛选自己场上表侧表示、可作为Cost除外的鱼族/海龙族/水族怪兽，且场上存在可被无效的卡
function s.cfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_FISH+RACE_SEASERPENT+RACE_AQUA) and c:IsAbleToRemoveAsCost()
		-- 检查场上是否存在至少1张可作为无效化对象的目标卡（排除作为Cost除外的卡本身）
		and Duel.IsExistingTarget(aux.NegateAnyFilter,0,LOCATION_ONFIELD,LOCATION_ONFIELD,1,c)
end
-- ②效果的Cost支付函数：除外自己场上1只表侧表示的鱼族/海龙族/水族怪兽
function s.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在满足Cost条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择要除外的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 玩家选择1只满足条件的鱼族/海龙族/水族怪兽
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 将选择的怪兽表侧表示除外作为发动的代价
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- ②效果的对象选择与合法性检测函数
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 连锁处理时的对象合法性检查：目标卡必须仍在场上且可被无效
	if chkc then return chkc:IsOnField() and aux.NegateAnyFilter(chkc) end
	-- 检查场上是否存在可作为无效化对象的目标卡
	if chk==0 then return Duel.IsExistingTarget(aux.NegateAnyFilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要无效的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
	-- 选择场上1张表侧表示的卡作为效果对象
	Duel.SelectTarget(tp,aux.NegateAnyFilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
end
-- ②效果的效果处理函数：使目标卡的效果直到对方回合结束时无效
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中选择的第一个（也是唯一的）对象卡
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) and tc:IsCanBeDisabledByEffect(e,false) then
		-- 使与目标卡相关的连锁在处理时无效化
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		-- 那张卡的效果直到对方回合结束时无效。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
		tc:RegisterEffect(e1)
		-- 那张卡的效果直到对方回合结束时无效。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
		tc:RegisterEffect(e2)
		if tc:IsType(TYPE_TRAPMONSTER) then
			-- 那张卡的效果直到对方回合结束时无效。
			local e3=Effect.CreateEffect(c)
			e3:SetType(EFFECT_TYPE_SINGLE)
			e3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
			e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
			tc:RegisterEffect(e3)
		end
	end
end
