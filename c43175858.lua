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
	-- 使这张卡在场地区域存在时，卡名视为「卡通世界」
	aux.EnableChangeCode(c,15259703,LOCATION_FZONE)
	-- ③：只要这张卡在场地区域存在，自己场上的卡通怪兽不会成为对方的效果的对象。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e3:SetRange(LOCATION_FZONE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	-- 过滤目标为场上的卡通怪兽
	e3:SetTarget(aux.TargetBoolFunction(Card.IsType,TYPE_TOON))
	-- 设置效果值为判断是否为对方效果的对象
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
-- 效果处理时检索卡组最上方3张卡，判断是否满足除外条件
function c43175858.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取玩家卡组最上方3张卡
	local g=Duel.GetDecktopGroup(tp,3)
	if chk==0 then return g:FilterCount(Card.IsAbleToRemove,nil,tp,POS_FACEDOWN)==3 end
	-- 设置连锁操作信息为除外3张卡
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,3,tp,LOCATION_DECK)
end
-- 发动效果时，从卡组最上方除外3张卡
function c43175858.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取玩家卡组中卡的数量
	local ct=Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)
	if ct==0 then return end
	if ct>3 then ct=3 end
	-- 获取玩家卡组最上方指定数量的卡
	local g=Duel.GetDecktopGroup(tp,ct)
	-- 禁止接下来的除外操作进行洗切卡组检查
	Duel.DisableShuffleCheck()
	-- 将指定的卡以里侧表示的方式除外
	Duel.Remove(g,POS_FACEDOWN,REASON_EFFECT)
end
-- 判断目标是否为场上表侧表示的卡通怪兽且因战斗或效果被破坏
function c43175858.repfilter(c,tp)
	return c:IsFaceup() and c:IsControler(tp) and c:IsLocation(LOCATION_MZONE)
		and c:IsType(TYPE_TOON) and c:IsReason(REASON_BATTLE+REASON_EFFECT) and not c:IsReason(REASON_REPLACE)
end
-- 判断是否满足代替破坏的条件并提示玩家选择是否发动
function c43175858.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct=eg:FilterCount(c43175858.repfilter,nil,tp)
	-- 获取玩家卡组最上方指定数量的卡
	local g=Duel.GetDecktopGroup(tp,ct)
	if chk==0 then return g:IsExists(Card.IsAbleToRemove,ct,nil,tp,POS_FACEDOWN) end
	-- 提示玩家选择是否发动代替破坏效果
	if Duel.SelectEffectYesNo(tp,e:GetHandler(),96) then
		-- 禁止接下来的除外操作进行洗切卡组检查
		Duel.DisableShuffleCheck()
		-- 将指定的卡以里侧表示的方式除外
		Duel.Remove(g,POS_FACEDOWN,REASON_EFFECT)
		return true
	else return false end
end
-- 返回代替破坏效果的过滤函数
function c43175858.repval(e,c)
	return c43175858.repfilter(c,e:GetHandlerPlayer())
end
