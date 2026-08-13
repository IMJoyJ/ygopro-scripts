--戦友の誓い
-- 效果：
-- 从额外卡组特殊召唤的怪兽不在自己场上存在的场合，选择对方场上表侧表示存在的1只从额外卡组特殊召唤的怪兽才能发动。选择的怪兽的控制权直到结束阶段时得到。这张卡发动的回合，自己不能把怪兽特殊召唤。
function c99311109.initial_effect(c)
	-- 从额外卡组特殊召唤的怪兽不在自己场上存在的场合，选择对方场上表侧表示存在的1只从额外卡组特殊召唤的怪兽才能发动。选择的怪兽的控制权直到结束阶段时得到。这张卡发动的回合，自己不能把怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_CONTROL)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c99311109.condition)
	e1:SetCost(c99311109.cost)
	e1:SetTarget(c99311109.target)
	e1:SetOperation(c99311109.activate)
	c:RegisterEffect(e1)
end
-- 定义筛选条件：该怪兽的召唤位置是额外卡组，即从额外卡组特殊召唤的怪兽。
function c99311109.cfilter(c)
	return c:IsSummonLocation(LOCATION_EXTRA)
end
-- 发动条件：自己场上不存在从额外卡组特殊召唤的怪兽时，才可能发动。
function c99311109.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上（主要怪兽区+额外怪兽区）是否存在从额外卡组特殊召唤的怪兽；不存在时返回真。
	return not Duel.IsExistingMatchingCard(c99311109.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 代价处理：本回合自己尚未进行过特殊召唤时才满足代价；随后给自己设置“本回合不能特殊召唤”的誓约效果。
function c99311109.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查本回合自己是否已经进行过特殊召唤，若次数为0则代价成立。
	if chk==0 then return Duel.GetActivityCount(tp,ACTIVITY_SPSUMMON)==0 end
	-- 选择对方场上表侧表示存在的1只从额外卡组特殊召唤的怪兽才能发动。选择的怪兽的控制权直到结束阶段时得到。这张卡发动的回合，自己不能把怪兽特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	-- 将禁止特殊召唤的效果注册到玩家tp，使该效果对tp生效。
	Duel.RegisterEffect(e1,tp)
end
-- 选择对象条件：对方场上的表侧表示怪兽、控制权可被改变、且是从额外卡组特殊召唤的怪兽。
function c99311109.filter(c)
	return c:IsFaceup() and c:IsControlerCanBeChanged() and c:IsSummonLocation(LOCATION_EXTRA)
end
-- 效果发动时选定对象：从对方场上选择1只符合条件的表侧表示怪兽，并记录改变控制权的操作信息。
function c99311109.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c99311109.filter(chkc) end
	-- 确认在对方场上是否存在至少1只符合条件的怪兽可以作为对象。
	if chk==0 then return Duel.IsExistingTarget(c99311109.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 显示选择卡的提示信息“请选择要改变控制权的怪兽”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
	-- 选择1只符合条件的对方怪兽作为效果对象，并将其设为当前连锁的对象。
	local g=Duel.SelectTarget(tp,c99311109.filter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息：该效果属于改变控制权效果，对象为g，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,0,0)
end
-- 效果处理：取得对象卡，若其仍与效果相关，则直到结束阶段获得其控制权。
function c99311109.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁中记录的对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 令tp获得对象怪兽的控制权，持续到结束阶段（1次）。
		Duel.GetControl(tc,tp,PHASE_END,1)
	end
end
