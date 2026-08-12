--ドラゴン・ウィッチ－ドラゴンの守護者－
-- 效果：
-- 只要这张卡在场上表侧表示存在，对方不能选择自己场上的龙族怪兽作为攻击对象。场上的这张卡被战斗或者卡的效果破坏的场合，可以作为代替从手卡把1只龙族怪兽送去墓地。
function c67511500.initial_effect(c)
	-- 只要这张卡在场上表侧表示存在，对方不能选择自己场上的龙族怪兽作为攻击对象。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetValue(c67511500.atlimit)
	c:RegisterEffect(e1)
	-- 场上的这张卡被战斗或者卡的效果破坏的场合，可以作为代替从手卡把1只龙族怪兽送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetTarget(c67511500.desreptg)
	c:RegisterEffect(e2)
end
-- 过滤函数，限制对方不能选择我方场上表侧表示的龙族怪兽作为攻击对象
function c67511500.atlimit(e,c)
	return c:IsFaceup() and c:IsRace(RACE_DRAGON)
end
-- 代替破坏效果的条件检查：自身因战斗或效果破坏，且手卡有可代替的龙族怪兽
function c67511500.desreptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsReason(REASON_BATTLE+REASON_EFFECT) and not c:IsReason(REASON_REPLACE)
		-- 检查手卡是否存在至少1只龙族怪兽
		and Duel.IsExistingMatchingCard(Card.IsRace,tp,LOCATION_HAND,0,1,nil,RACE_DRAGON) end
	-- 询问玩家是否使用代替破坏的效果
	if Duel.SelectEffectYesNo(tp,e:GetHandler(),96) then
		-- 设置系统提示信息：请选择要送去墓地的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		-- 让玩家从手卡选择1只龙族怪兽
		local g=Duel.SelectMatchingCard(tp,Card.IsRace,tp,LOCATION_HAND,0,1,1,nil,RACE_DRAGON)
		-- 将选中的怪兽送去墓地以代替破坏
		Duel.SendtoGrave(g,REASON_EFFECT+REASON_REPLACE)
		return true
	else return false end
end
