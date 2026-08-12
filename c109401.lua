--闇次元の戦士
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：把1张手卡除外，以除外的1只自己的暗属性怪兽为对象才能发动。那只怪兽表侧守备表示或者里侧守备表示特殊召唤。
-- ②：自己·对方的结束阶段发动。给与对方为场上盖放的卡数量×100伤害。
function c109401.initial_effect(c)
	-- 添加同调召唤手续，要求1只调整和1只调整以外的怪兽
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ①：把1张手卡除外，以除外的1只自己的暗属性怪兽为对象才能发动。那只怪兽表侧守备表示或者里侧守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_MSET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,109401)
	e1:SetCost(c109401.spcost)
	e1:SetTarget(c109401.sptg)
	e1:SetOperation(c109401.spop)
	c:RegisterEffect(e1)
	-- ②：自己·对方的结束阶段发动。给与对方为场上盖放的卡数量×100伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCountLimit(1,109402)
	e2:SetTarget(c109401.damtg)
	e2:SetOperation(c109401.damop)
	c:RegisterEffect(e2)
end
-- 效果处理时的费用支付函数，检查是否能除外1张手卡
function c109401.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足除外手卡的条件
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemoveAsCost,tp,LOCATION_HAND,0,1,nil) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	-- 选择1张可除外的手卡
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToRemoveAsCost,tp,LOCATION_HAND,0,1,1,nil)
	-- 将选择的卡除外作为费用
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 特殊召唤目标怪兽的过滤函数，检查是否为暗属性且可特殊召唤
function c109401.spfilter(c,e,tp)
	return c:IsAttribute(ATTRIBUTE_DARK) and c:IsFaceup() and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_DEFENSE)
end
-- 效果处理时的发动选择函数，用于选择目标怪兽
function c109401.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_REMOVED) and c109401.spfilter(chkc,e,tp) end
	-- 检查是否有足够的召唤位置
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查是否存在满足条件的除外怪兽
		and Duel.IsExistingTarget(c109401.spfilter,tp,LOCATION_REMOVED,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	-- 选择满足条件的除外怪兽作为目标
	local g=Duel.SelectTarget(tp,c109401.spfilter,tp,LOCATION_REMOVED,0,1,1,nil,e,tp)
	-- 设置效果操作信息，确定特殊召唤的怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理时的发动处理函数，执行特殊召唤
function c109401.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查是否有足够的召唤位置
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 获取当前效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 执行特殊召唤操作，若成功且为里侧则确认其卡面
		if Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_DEFENSE)~=0 and tc:IsFacedown() then
			-- 向对方确认特殊召唤的怪兽卡面
			Duel.ConfirmCards(1-tp,tc)
		end
	end
end
-- 伤害效果处理时的发动选择函数，用于计算伤害
function c109401.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 计算场上盖放的卡数量并乘以100作为伤害值
	local dam=Duel.GetMatchingGroupCount(Card.IsFacedown,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)*100
	-- 设置伤害效果的目标玩家为对方
	Duel.SetTargetPlayer(1-tp)
	-- 设置伤害效果的目标伤害值
	Duel.SetTargetParam(dam)
	-- 设置效果操作信息，确定伤害效果的处理对象
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,dam)
end
-- 伤害效果处理时的发动处理函数，执行伤害效果
function c109401.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中设定的目标玩家
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 再次计算场上盖放的卡数量并乘以100作为伤害值
	local dam=Duel.GetMatchingGroupCount(Card.IsFacedown,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)*100
	-- 对目标玩家造成相应伤害
	Duel.Damage(p,dam,REASON_EFFECT)
end
