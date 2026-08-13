--ワルキューレの抱擁
-- 效果：
-- 这个卡名的卡在1回合只能发动1张，这张卡发动的回合，自己不是「女武神」怪兽不能特殊召唤。
-- ①：自己场上的怪兽只有「女武神」怪兽的场合，以自己场上1只攻击表示的「女武神」怪兽和对方场上1只表侧表示怪兽为对象才能发动。那只自己怪兽变成守备表示，那只对方怪兽除外。
function c45584727.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张，这张卡发动的回合，自己不是「女武神」怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,45584727+EFFECT_COUNT_CODE_OATH)
	e1:SetCost(c45584727.rmcost)
	e1:SetCondition(c45584727.rmcon)
	e1:SetTarget(c45584727.rmtg)
	e1:SetOperation(c45584727.rmop)
	c:RegisterEffect(e1)
	-- 注册自定义活动计数器，记录本回合特殊召唤非「女武神」怪兽的次数（counterfilter对非「女武神」返回false使计数+1），用于发动条件的检测。
	Duel.AddCustomActivityCounter(45584727,ACTIVITY_SPSUMMON,c45584727.counterfilter)
end
-- 定义计数器过滤函数：若特殊召唤的怪兽是「女武神」字段则返回true，否则返回false；返回false时计数器增加，即记录非「女武神」怪兽的特殊召唤。
function c45584727.counterfilter(c)
	return c:IsSetCard(0x122)
end
-- 发动代价/自肃函数：先确认本回合没有特殊召唤过非「女武神」怪兽，然后给自己施加一个直到回合结束的“不能特殊召唤非「女武神」怪兽”的誓约效果。
function c45584727.rmcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查活动计数器为0，即本回合尚未特殊召唤过非「女武神」怪兽，满足才能发动。
	if chk==0 then return Duel.GetCustomActivityCount(45584727,tp,ACTIVITY_SPSUMMON)==0 end
	-- ①：自己场上的怪兽只有「女武神」怪兽的场合，以自己场上1只攻击表示的「女武神」怪兽和对方场上1只表侧表示怪兽为对象才能发动。那只自己怪兽变成守备表示，那只对方怪兽除外。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetLabelObject(e)
	e1:SetTarget(c45584727.splimit)
	-- 将自肃效果e1注册到玩家tp的场上，使该玩家在本回合内不能特殊召唤非「女武神」怪兽。
	Duel.RegisterEffect(e1,tp)
end
-- 自肃过滤函数：若尝试特殊召唤的怪兽不是「女武神」字段，则禁止该特殊召唤。
function c45584727.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsSetCard(0x122)
end
-- 条件过滤函数：判断怪兽是否为「女武神」字段（0x122）。
function c45584727.cfilter(c)
	return c:IsSetCard(0x122)
end
-- 条件过滤函数：判断怪兽是否为里侧表示或不是「女武神」，用于检测是否存在不满足“自己场上的怪兽只有「女武神」”条件的怪兽。
function c45584727.cfilter2(c)
	return c:IsFacedown() or not c:IsSetCard(0x122)
end
-- 发动条件函数：自己场上有至少1只「女武神」怪兽，且不存在里侧表示或非「女武神」怪兽，即自己场上的怪兽全部为表侧表示的「女武神」怪兽。
function c45584727.rmcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在至少1只「女武神」怪兽。
	return Duel.IsExistingMatchingCard(c45584727.cfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 检查自己场上不存在里侧表示或非「女武神」的怪兽。
		and not Duel.IsExistingMatchingCard(c45584727.cfilter2,tp,LOCATION_MZONE,0,1,nil)
end
-- 选择对象过滤函数：选择自己场上表侧攻击表示且为「女武神」字段的怪兽。
function c45584727.tgfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x122) and c:IsPosition(POS_FACEUP_ATTACK)
end
-- 选择对象过滤函数：选择对方场上表侧表示且可以被除外的怪兽。
function c45584727.rmfilter(c)
	return c:IsFaceup() and c:IsAbleToRemove()
end
-- 目标选择函数：确认存在合法对象后，选择自己场上1只攻击表示「女武神」怪兽和对方场上1只表侧可除外怪兽作为对象，保存对方怪兽到LabelObject，并设置变更表示形式和除外的操作信息。
function c45584727.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 检查是否存在至少1只符合条件的自己怪兽（表侧攻击表示「女武神」）。
	if chk==0 then return Duel.IsExistingTarget(c45584727.tgfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 检查是否存在至少1只符合条件的对方怪兽（表侧表示且可除外）。
		and Duel.IsExistingTarget(c45584727.rmfilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 向玩家弹出选择提示，要求选择要变更表示形式的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
	-- 选择自己场上1只攻击表示的「女武神」怪兽作为效果对象。
	local g1=Duel.SelectTarget(tp,c45584727.tgfilter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 向玩家弹出选择提示，要求选择要除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择对方场上1只表侧表示且可除外的怪兽作为效果对象。
	local g2=Duel.SelectTarget(tp,c45584727.rmfilter,tp,0,LOCATION_MZONE,1,1,nil)
	e:SetLabelObject(g2:GetFirst())
	-- 设置连锁操作信息：将选中的自己怪兽的表示形式变更（CATEGORY_POSITION）。
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g1,1,0,0)
	-- 设置连锁操作信息：将选中的对方怪兽除外（CATEGORY_REMOVE）。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g2,1,0,0)
end
-- 效果处理函数：从连锁对象中区分自己怪兽与对方怪兽；若对方怪兽表侧表示、与效果关联且不免疫此效果，并且自己怪兽成功变为表侧守备表示且仍与效果关联，则将对方怪兽除外。
function c45584727.rmop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local hc=e:GetLabelObject()
	-- 获取当前连锁处理的目标卡组。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local tc=g:GetFirst()
	if tc==hc then tc=g:GetNext() end
	if tc:IsFaceup() and tc:IsRelateToEffect(e) and not tc:IsImmuneToEffect(e)
		-- 判定条件：对方怪兽表侧表示、与效果关联且不免疫效果，同时自己怪兽成功变更表示为表侧守备表示且与效果关联，才执行后续除外。
		and Duel.ChangePosition(tc,POS_FACEUP_DEFENSE)>0 and hc:IsRelateToEffect(e) then
		-- 将对方怪兽以表侧表示除外（REASON_EFFECT）。
		Duel.Remove(hc,POS_FACEUP,REASON_EFFECT)
	end
end
