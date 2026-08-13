--ゴーストリックの妖精
-- 效果：
-- 自己场上有「鬼计」怪兽存在的场合才能让这张卡表侧表示召唤。
-- ①：自己主要阶段才能发动。这张卡变成里侧守备表示（1回合只有1次）。
-- ②：这张卡反转时，以自己墓地1张「鬼计」卡为对象才能发动。那张卡在自己场上盖放。那张卡从场上离开的场合除外。那之后，可以选最多有自己场上盖放的卡数量的对方场上的表侧表示怪兽变成里侧守备表示。
function c36239585.initial_effect(c)
	-- 自己场上有「鬼计」怪兽存在的场合才能让这张卡表侧表示召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_SUMMON)
	e1:SetCondition(c36239585.sumcon)
	c:RegisterEffect(e1)
	-- ①：自己主要阶段才能发动。这张卡变成里侧守备表示（1回合只有1次）。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(36239585,0))
	e2:SetCategory(CATEGORY_POSITION+CATEGORY_MSET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTarget(c36239585.postg)
	e2:SetOperation(c36239585.posop)
	c:RegisterEffect(e2)
	-- ②：这张卡反转时，以自己墓地1张「鬼计」卡为对象才能发动。那张卡在自己场上盖放。那张卡从场上离开的场合除外。那之后，可以选最多有自己场上盖放的卡数量的对方场上的表侧表示怪兽变成里侧守备表示。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(36239585,1))
	e3:SetCategory(CATEGORY_MSET+CATEGORY_SSET)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_FLIP)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetTarget(c36239585.settg)
	e3:SetOperation(c36239585.setop)
	c:RegisterEffect(e3)
end
-- 筛选自己场上表侧表示且卡名具有「鬼计」字段的怪兽。
function c36239585.sfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x8d)
end
-- 召唤限制条件：若自己场上不存在表侧表示「鬼计」怪兽，则该卡不能表侧表示召唤。
function c36239585.sumcon(e)
	-- 检查以自己视角看，自己场上是否存在1张以上表侧表示「鬼计」怪兽，不存在时返回true使召唤限制生效。
	return not Duel.IsExistingMatchingCard(c36239585.sfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
-- ①效果的发动条件判定和标记设置：确认这张卡可以变为里侧守备表示且本回合尚未使用过①效果；满足时注册1次使用标记并设置操作信息。
function c36239585.postg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsCanTurnSet() and c:GetFlagEffect(36239585)==0 end
	c:RegisterFlagEffect(36239585,RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET+RESET_PHASE+PHASE_END,0,1)
	-- 设置操作信息：告知系统本连锁将进行表示形式变更（变为里侧守备），对象为这张卡。
	Duel.SetOperationInfo(0,CATEGORY_POSITION,c,1,0,0)
end
-- ①效果处理：确认这张卡仍与效果相关且表侧表示时，将其变为里侧守备表示。
function c36239585.posop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 把这张卡的表示形式改变为里侧守备表示。
		Duel.ChangePosition(c,POS_FACEDOWN_DEFENSE)
	end
end
-- 墓地「鬼计」卡的选择条件：怪兽需可里侧守备特殊召唤且自己主要怪兽区有空位；魔法·陷阱卡需可盖放。
function c36239585.setfilter(c,e,tp)
	if not c:IsSetCard(0x8d) then return false end
	if c:IsType(TYPE_MONSTER) then
		-- 怪兽目标的具体判定：我方主要怪兽区有空闲格子，并且该怪兽可以被里侧守备表示特殊召唤。
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE)
	else return c:IsSSetable() end
end
-- 对方场上可被变为里侧守备表示的怪兽的筛选条件：表侧表示且允许变里侧。
function c36239585.posfilter(c)
	return c:IsFaceup() and c:IsCanTurnSet()
end
-- ②效果的目标选择和类别设定：取对象选择墓地1张「鬼计」卡，并根据所选卡是怪兽还是魔陷动态变更效果类别与操作信息。
function c36239585.settg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c36239585.setfilter(chkc,e,tp) end
	-- 发动的合法性检查：确认自己墓地存在1张以上符合条件、可作为对象的「鬼计」卡。
	if chk==0 then return Duel.IsExistingTarget(c36239585.setfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 给玩家显示“请选择要盖放的卡”的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 让玩家从自己墓地的「鬼计」卡中选择1张，并将其登记为效果对象。
	local g=Duel.SelectTarget(tp,c36239585.setfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetFirst():IsType(TYPE_MONSTER) then
		e:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_POSITION+CATEGORY_MSET)
		-- 当选择的是怪兽时，将操作信息类别设为特殊召唤（用于后续处理与连锁检测）。
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
	else
		e:SetCategory(CATEGORY_POSITION+CATEGORY_SSET+CATEGORY_MSET)
		-- 当选择的是魔陷时，设置操作信息类别为“涉及墓地离场”，用于配合墓场相关限制。
		Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
	end
end
-- ②效果处理：将对象卡在自己场上里侧表示放置（怪兽为里侧守备特殊召唤，魔陷为盖放）；成功后再给该卡附加离场除外效果，并可选将对方表侧怪兽变里侧。
function c36239585.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得本次效果从墓地选为对象的「鬼计」卡。
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	local res=0
	if tc:IsType(TYPE_MONSTER) then
		-- 若对象是怪兽，以里侧守备表示特殊召唤到自己的主要怪兽区。
		res=Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)
		-- 特殊召唤成功时，向对方玩家确认这只里侧守备表示的怪兽（让对方知道是什么卡）。
		if res~=0 then Duel.ConfirmCards(1-tp,tc) end
	else
		-- 若对象是魔法·陷阱卡，则直接盖放到自己的魔法与陷阱区域。
		res=Duel.SSet(tp,tc)
	end
	if res~=0 then
		-- 那张卡从场上离开的场合除外。那之后，可以选最多有自己场上盖放的卡数量的对方场上的表侧表示怪兽变成里侧守备表示。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		tc:RegisterEffect(e1,true)
		-- 统计自己场上里侧表示卡的数量（即自己场上盖放着的卡的数量）。
		local ct=Duel.GetMatchingGroupCount(Card.IsFacedown,tp,LOCATION_ONFIELD,0,nil)
		-- 确认自己场上有里侧表示卡，且对方场上有表侧表示且可变成里侧守备表示的怪兽存在。
		if ct>0 and Duel.IsExistingMatchingCard(c36239585.posfilter,tp,0,LOCATION_MZONE,1,nil)
			-- 询问玩家是否发动“那之后”的选择效果：把对方表侧怪兽变成里侧守备表示。
			and Duel.SelectYesNo(tp,aux.Stringid(36239585,2)) then  --"是否选对方怪兽变成里侧守备表示？"
			-- 中断当前效果，使之后的表示形式变更处理视为另一段处理，避免错过时点。
			Duel.BreakEffect()
			-- 给玩家显示“请选择要改变表示形式的怪兽”的提示。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
			-- 选择1到ct只对方场上符合条件的表侧表示怪兽（上限为自己场上里侧表示卡的数量）。
			local g=Duel.SelectMatchingCard(tp,c36239585.posfilter,tp,0,LOCATION_MZONE,1,ct,nil)
			-- 为选中的怪兽显示对象动画并记录它们被选为对象。
			Duel.HintSelection(g)
			-- 将选中的所有对方怪兽变成里侧守备表示。
			Duel.ChangePosition(g,POS_FACEDOWN_DEFENSE)
		end
	end
end
