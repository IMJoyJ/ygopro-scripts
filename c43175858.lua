--トゥーン・キングダム
-- 效果：
-- ①：作为这张卡的发动时的效果处理，从自己卡组上面把3张卡里侧表示除外。
-- ②：这张卡只要在场地区域存在，卡名当作「卡通世界」使用。
-- ③：只要这张卡在场地区域存在，自己场上的卡通怪兽不会成为对方的效果的对象。
-- ④：自己场上的卡通怪兽被战斗·效果破坏的场合，可以作为代替把破坏的怪兽每1只1张卡从自己卡组上面里侧表示除外。
function c43175858.initial_effect(c)
	-- ①：作为这张卡的发动时的效果处理，从自己卡组上面把3张卡里侧表示除外。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c43175858.target)
	e1:SetOperation(c43175858.activate)
	c:RegisterEffect(e1)
	-- 注册效果，使这张卡只要在场地区域存在，卡名当作「卡通世界」（15259703）使用。
	aux.EnableChangeCode(c,15259703,LOCATION_FZONE)
	-- ③：只要这张卡在场地区域存在，自己场上的卡通怪兽不会成为对方的效果的对象。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e3:SetRange(LOCATION_FZONE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	-- 设置该效果的适用对象筛选条件：仅限自己场上的卡通怪兽（TYPE_TOON）。
	e3:SetTarget(aux.TargetBoolFunction(Card.IsType,TYPE_TOON))
	-- 设置效果值为判断条件，使对方的效果不能以自己场上的卡通怪兽为对象。
	e3:SetValue(aux.tgoval)
	c:RegisterEffect(e3)
	-- ④：自己场上的卡通怪兽被战斗·效果破坏的场合，可以作为代替把破坏的怪兽每1只1张卡从自己卡组上面里侧表示除外。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EFFECT_DESTROY_REPLACE)
	e4:SetRange(LOCATION_FZONE)
	e4:SetTarget(c43175858.reptg)
	e4:SetValue(c43175858.repval)
	c:RegisterEffect(e4)
end
-- 效果①发动时的目标判定：检查自己卡组最上方3张卡是否都能里侧表示除外，若满足则设置除外卡组3张卡的操作信息。
function c43175858.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取自己卡组最上方3张卡作为候选，用于判定能否除外。
	local g=Duel.GetDecktopGroup(tp,3)
	if chk==0 then return g:FilterCount(Card.IsAbleToRemove,nil,tp,POS_FACEDOWN)==3 end
	-- 设置本次连锁的处理信息：从自己卡组将3张卡里侧表示除外（类别为除外），以供后续检测。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,3,tp,LOCATION_DECK)
end
-- 效果①发动时的实际处理：根据卡组数量取最多3张卡，从卡组最上方里侧表示除外，并禁止洗牌检测。
function c43175858.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己卡组当前的卡牌数量，用于决定实际除外的张数。
	local ct=Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)
	if ct==0 then return end
	if ct>3 then ct=3 end
	-- 获取卡组最上方ct张卡（ct为实际要除外的数量）。
	local g=Duel.GetDecktopGroup(tp,ct)
	-- 禁用本次操作的洗牌检测，因为从卡组最上方里侧除外不涉及卡组洗切。
	Duel.DisableShuffleCheck()
	-- 将选中的卡从卡组最上方里侧表示除外，除外原因标记为效果。
	Duel.Remove(g,POS_FACEDOWN,REASON_EFFECT)
end
-- 代替破坏的筛选条件：满足表侧表示、自己场上怪兽区、卡通怪兽、因战斗或效果被破坏且未被代替破坏的怪兽。
function c43175858.repfilter(c,tp)
	return c:IsFaceup() and c:IsControler(tp) and c:IsLocation(LOCATION_MZONE)
		and c:IsType(TYPE_TOON) and c:IsReason(REASON_BATTLE+REASON_EFFECT) and not c:IsReason(REASON_REPLACE)
end
-- 代替破坏效果的判定与处理：计算被破坏且符合条件的卡通怪兽数量，检查卡组最上方是否有足够数量的卡可里侧除外，询问玩家是否发动代替破坏；若同意则除外对应数量卡，返回true使破坏被代替，否则返回false。
function c43175858.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct=eg:FilterCount(c43175858.repfilter,nil,tp)
	-- 获取卡组最上方ct张卡（ct为可代替破坏的卡通怪兽数量），用于代替除外。
	local g=Duel.GetDecktopGroup(tp,ct)
	if chk==0 then return g:IsExists(Card.IsAbleToRemove,ct,nil,tp,POS_FACEDOWN) end
	-- 询问我方是否发动该代替破坏效果（使用提示编号96），选择是则执行除外代替破坏。
	if Duel.SelectEffectYesNo(tp,e:GetHandler(),96) then
		-- 禁用本次操作的洗牌检测，因为从卡组最上方里侧除外不涉及洗切。
		Duel.DisableShuffleCheck()
		-- 将卡组最上方的卡里侧表示除外，作为破坏的代替处理（原因：效果）。
		Duel.Remove(g,POS_FACEDOWN,REASON_EFFECT)
		return true
	else return false end
end
-- 作为EFFECT_DESTROY_REPLACE的Value函数，通过效果控制者判断当前怪兽是否满足代替破坏的过滤条件，返回真则允许代替破坏。
function c43175858.repval(e,c)
	return c43175858.repfilter(c,e:GetHandlerPlayer())
end
