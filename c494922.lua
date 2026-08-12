--超重荒神スサノ－O
-- 效果：
-- 机械族调整＋调整以外的「超重武者」怪兽1只以上
-- 这张卡在规则上也当作「超重武者」卡使用。
-- ①：这张卡可以用表侧守备表示的状态作出攻击。那个场合，这张卡用守备力当作攻击力使用进行伤害计算。
-- ②：1回合1次，自己墓地没有魔法·陷阱卡存在的场合，以对方墓地1张魔法·陷阱卡为对象才能发动。那张卡在自己场上盖放。这个效果盖放的卡从场上离开的场合除外。这个效果在对方回合也能发动。
function c494922.initial_effect(c)
	-- 添加同调召唤手续，需要1只机械族调整和1只以上非调整的超重武者怪兽
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
-- 过滤函数，用于判断卡片是否为魔法或陷阱类型
function c494922.filter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 条件函数，判断自己墓地是否存在魔法·陷阱卡
function c494922.setcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断自己墓地中不存在魔法·陷阱卡
	return not Duel.IsExistingMatchingCard(c494922.filter,tp,LOCATION_GRAVE,0,1,nil)
end
-- 过滤函数，用于判断卡片是否为魔法或陷阱类型且可以盖放
function c494922.setfilter(c,tp)
	-- 判断卡片为魔法或陷阱类型、可以盖放、且为场地魔法或场上存在空位
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSSetable(true) and (c:IsType(TYPE_FIELD) or Duel.GetLocationCount(tp,LOCATION_SZONE)>0)
end
-- 设置效果的目标选择逻辑，选择对方墓地的魔法·陷阱卡作为目标
function c494922.settg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_GRAVE) and c494922.setfilter(chkc,tp) end
	-- 检查是否满足效果发动条件，即对方墓地存在魔法·陷阱卡
	if chk==0 then return Duel.IsExistingTarget(c494922.setfilter,tp,0,LOCATION_GRAVE,1,nil,tp) end
	-- 提示玩家选择要盖放的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 选择对方墓地的一张魔法·陷阱卡作为目标
	local g=Duel.SelectTarget(tp,c494922.setfilter,tp,0,LOCATION_GRAVE,1,1,nil,tp)
	-- 设置操作信息，记录将要离开墓地的卡
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
end
-- 效果处理函数，执行将目标卡在自己场上盖放的操作
function c494922.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的效果目标卡
	local tc=Duel.GetFirstTarget()
	-- 判断目标卡是否有效且成功盖放
	if tc:IsRelateToEffect(e) and Duel.SSet(tp,tc)~=0 then
		-- 设置效果盖放的卡离场时的重新指定去向为除外
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		tc:RegisterEffect(e1,true)
	end
end
