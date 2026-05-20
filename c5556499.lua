--マシンナーズ・フォートレス
-- 效果：
-- ①：这张卡可以把等级合计直到8以上的手卡的机械族怪兽丢弃，从手卡·墓地特殊召唤（把自身丢弃的场合，从墓地特殊召唤）。
-- ②：只要这张卡在怪兽区域存在，这张卡为对象发动的对方怪兽的效果适用之际，把对方手卡确认，从那之中选1张卡丢弃。
-- ③：这张卡被战斗破坏送去墓地的场合，以对方场上1张卡为对象发动。那张对方的卡破坏。
function c5556499.initial_effect(c)
	-- ①：这张卡可以把等级合计直到8以上的手卡的机械族怪兽丢弃，从手卡·墓地特殊召唤（把自身丢弃的场合，从墓地特殊召唤）。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetCondition(c5556499.spcon)
	e1:SetTarget(c5556499.sptg)
	e1:SetOperation(c5556499.spop)
	c:RegisterEffect(e1)
	-- ③：这张卡被战斗破坏送去墓地的场合，以对方场上1张卡为对象发动。那张对方的卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(5556499,0))  --"对方场上一张卡破坏"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_BATTLE_DESTROYED)
	e2:SetCondition(c5556499.condition)
	e2:SetTarget(c5556499.target)
	e2:SetOperation(c5556499.operation)
	c:RegisterEffect(e2)
	-- ②：只要这张卡在怪兽区域存在，这张卡为对象发动的对方怪兽的效果适用之际，把对方手卡确认，从那之中选1张卡丢弃。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_MZONE)
	-- 在连锁发生时，记录这张卡在场上存在，用于后续检测是否被选为对象
	e3:SetOperation(aux.chainreg)
	c:RegisterEffect(e3)
	-- ②：只要这张卡在怪兽区域存在，这张卡为对象发动的对方怪兽的效果适用之际，把对方手卡确认，从那之中选1张卡丢弃。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCode(EVENT_CHAIN_SOLVING)
	e4:SetOperation(c5556499.hdop)
	c:RegisterEffect(e4)
end
-- 过滤手卡中可以丢弃的机械族怪兽
function c5556499.spfilter(c)
	return c:IsRace(RACE_MACHINE) and c:IsDiscardable()
end
-- 特殊召唤规则的条件判断函数，检查手卡中是否存在等级合计达到8以上的机械族怪兽
function c5556499.spcon(e,c)
	if c==nil then return true end
	if c:IsHasEffect(EFFECT_NECRO_VALLEY) then return false end
	local tp=c:GetControler()
	-- 检查自己场上是否有可用的怪兽区域
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return false end
	-- 获取自己手卡中所有满足条件的机械族怪兽
	local g=Duel.GetMatchingGroup(c5556499.spfilter,tp,LOCATION_HAND,0,nil)
	-- 如果自身不能作为Cost送去墓地，或者受到王家之谷的影响，则不能将自身从手卡丢弃来特殊召唤
	if not c:IsAbleToGraveAsCost() or Duel.IsPlayerAffectedByEffect(tp,EFFECT_NECRO_VALLEY) then
		g:RemoveCard(c)
	end
	return g:CheckWithSumGreater(Card.GetLevel,8)
end
-- 辅助选择函数，用于检查所选卡片的等级合计是否达到8以上
function c5556499.fselect(g)
	-- 设置已选择的卡片，用于后续的等级合计计算
	Duel.SetSelectedCard(g)
	return g:CheckWithSumGreater(Card.GetLevel,8)
end
-- 特殊召唤规则的准备函数，让玩家选择要丢弃的机械族怪兽
function c5556499.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取手卡中可丢弃的机械族怪兽作为特殊召唤的候选Cost
	local g=Duel.GetMatchingGroup(c5556499.spfilter,tp,LOCATION_HAND,0,nil)
	-- 如果自身不能作为Cost送去墓地（例如在墓地时），或者受到王家之谷的影响，则从可选卡片中移除自身
	if not c:IsAbleToGraveAsCost() or Duel.IsPlayerAffectedByEffect(tp,EFFECT_NECRO_VALLEY) then
		g:RemoveCard(c)
	end
	-- 提示玩家选择要丢弃的手牌
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)  --"请选择要丢弃的手牌"
	local sg=g:SelectSubGroup(tp,c5556499.fselect,true,1,g:GetCount())
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 特殊召唤规则的执行函数，将选中的怪兽送去墓地并完成特殊召唤
function c5556499.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local sg=e:GetLabelObject()
	-- 将选中的怪兽作为特殊召唤的Cost丢弃送去墓地
	Duel.SendtoGrave(sg,REASON_SPSUMMON+REASON_DISCARD)
	sg:DeleteGroup()
end
-- 检查这张卡是否被战斗破坏并送去墓地
function c5556499.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and e:GetHandler():IsReason(REASON_BATTLE)
end
-- 破坏效果的靶向选择函数，确认并选择对方场上的1张卡作为对象
function c5556499.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) end
	if chk==0 then return true end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上的1张卡作为效果的对象
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置当前连锁的操作信息，表明此效果的处理为破坏选中的卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 破坏效果的执行函数，破坏选中的对方场上的卡
function c5556499.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选为对象的卡
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsControler(1-tp) then
		-- 因效果将目标卡片破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- 对方怪兽效果适用时的处理函数，确认对方手卡并选1张丢弃
function c5556499.hdop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():GetFlagEffect(FLAG_ID_CHAINING)==0 then return end
	if ep==tp then return end
	if not re:IsActiveType(TYPE_EFFECT) or not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return end
	-- 获取当前连锁中被选为对象的卡片组
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	if g and g:IsContains(e:GetHandler()) then
		-- 获取对方的所有手卡
		local hg=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
		if hg:GetCount()==0 then return end
		-- 让自身玩家确认对方的所有手卡
		Duel.ConfirmCards(tp,hg)
		-- 提示玩家选择要丢弃的对方手卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)  --"请选择要丢弃的手牌"
		local sg=hg:Select(tp,1,1,nil)
		-- 因效果将选中的对方手卡丢弃送去墓地
		Duel.SendtoGrave(sg,REASON_EFFECT+REASON_DISCARD)
		-- 洗切对方的手卡
		Duel.ShuffleHand(1-tp)
	end
end
