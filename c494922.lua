--超重荒神スサノ－O
-- 效果：
-- 机械族调整＋调整以外的「超重武者」怪兽1只以上
-- 这张卡在规则上也当作「超重武者」卡使用。
-- ①：这张卡可以用表侧守备表示的状态作出攻击。那个场合，这张卡用守备力当作攻击力使用进行伤害计算。
-- ②：1回合1次，自己墓地没有魔法·陷阱卡存在的场合，以对方墓地1张魔法·陷阱卡为对象才能发动。那张卡在自己场上盖放。这个效果盖放的卡从场上离开的场合除外。这个效果在对方回合也能发动。
function c494922.initial_effect(c)
	-- 为这张卡添加同调召唤手续：调整必须是机械族怪兽，调整以外必须为1只以上的「超重武者」系列怪兽。
	aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsRace,RACE_MACHINE),aux.NonTuner(Card.IsSetCard,0x9a),1)
	c:EnableReviveLimit()
	-- ①：这张卡可以用表侧守备表示的状态作出攻击。那个场合，这张卡用守备力当作攻击力使用进行伤害计算。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_DEFENSE_ATTACK)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	-- ②：1回合1次，自己墓地没有魔法·陷阱卡存在的场合，以对方墓地1张魔法·陷阱卡为对象才能发动。那张卡在自己场上盖放。这个效果盖放的卡从场上离开的场合除外。这个效果在对方回合也能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(494922,0))
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCategory(CATEGORY_SSET)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetHintTiming(0,TIMING_END_PHASE)
	e2:SetCondition(c494922.setcon)
	e2:SetTarget(c494922.settg)
	e2:SetOperation(c494922.setop)
	c:RegisterEffect(e2)
end
-- 定义过滤函数：判断一张卡是否为魔法·陷阱卡（SPELL+TRAP），用于后续检查墓地是否存在魔法·陷阱卡及选择对象。
function c494922.filter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 定义②效果的发动条件函数：仅当自己墓地没有魔法·陷阱卡时条件成立，方可发动。
function c494922.setcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检索当前玩家（tp）墓地是否存在至少1张魔法·陷阱卡；若不存在则返回true，满足『自己墓地没有魔法·陷阱卡存在』的发动条件。
	return not Duel.IsExistingMatchingCard(c494922.filter,tp,LOCATION_GRAVE,0,1,nil)
end
-- 定义选择对象的过滤函数：对象必须是魔法·陷阱卡、能够在魔法陷阱区盖放；若是场地魔法则不受魔陷区空格限制（因为有专用的场地区），否则需要己方魔陷区有空位。
function c494922.setfilter(c,tp)
	-- 判断目标卡是否为可盖放的魔法·陷阱卡：是魔法·陷阱卡，且可盖放（无视场地限制）；若为场地魔法则无需检查魔陷区空格，否则需存在空位。
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSSetable(true) and (c:IsType(TYPE_FIELD) or Duel.GetLocationCount(tp,LOCATION_SZONE)>0)
end
-- 定义效果的目标处理函数：在效果发动时选择对方墓地1张满足条件的魔法·陷阱卡作为对象，并设置操作信息；若已选择对象则先检查合法性。
function c494922.settg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_GRAVE) and c494922.setfilter(chkc,tp) end
	-- 在效果发动时（chk==0）确认是否存在合法目标：对方墓地存在至少1张满足 setfilter 条件的魔法·陷阱卡，从而允许发动效果。
	if chk==0 then return Duel.IsExistingTarget(c494922.setfilter,tp,0,LOCATION_GRAVE,1,nil,tp) end
	-- 向选择目标的玩家显示提示信息，提示其选择一张要盖放的卡（HINTMSG_SET）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 让玩家从对方墓地选择1张满足 setfilter 条件的魔法·陷阱卡作为效果对象，并自动将其注册为当前连锁的取对象目标。
	local g=Duel.SelectTarget(tp,c494922.setfilter,tp,0,LOCATION_GRAVE,1,1,nil,tp)
	-- 设置当前连锁的操作信息，声明该效果将涉及将对象卡从墓地离开（CATEGORY_LEAVE_GRAVE），用于供其他效果（如王家长眠之谷）进行连锁判定。
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
end
-- 定义效果的处理函数：获取盖放对象，若该对象仍与效果关联且成功盖放到己方场上，则为其附加『离场时除外』的持续效果（EFFECT_LEAVE_FIELD_REDIRECT）。
function c494922.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得本连锁中已选择的那1张对方墓地魔法·陷阱卡作为目标卡。
	local tc=Duel.GetFirstTarget()
	-- 确认目标卡仍与本次效果相关联（目标卡未因离场等原因失去关联），并尝试将其盖放到己方魔法陷阱区；若盖放成功（返回值非0）则继续附加除外效果。
	if tc:IsRelateToEffect(e) and Duel.SSet(tp,tc)~=0 then
		-- 这个效果盖放的卡从场上离开的场合除外。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		tc:RegisterEffect(e1,true)
	end
end
