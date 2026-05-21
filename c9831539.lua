--タンホイザーゲート
-- 效果：
-- 选择自己场上2只攻击力1000以下的相同种族的怪兽才能发动。选择的2只怪兽变成那2只的等级合计的等级。
function c9831539.initial_effect(c)
	-- 选择自己场上2只攻击力1000以下的相同种族的怪兽才能发动。选择的2只怪兽变成那2只的等级合计的等级。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c9831539.target)
	e1:SetOperation(c9831539.activate)
	c:RegisterEffect(e1)
end
-- 过滤第一只怪兽：等级1以上、攻击力1000以下、表侧表示，且场上存在另一只满足相同种族等条件的怪兽
function c9831539.filter1(c,tp)
	return c:IsLevelAbove(1) and c:IsAttackBelow(1000) and c:IsFaceup()
		-- 检查自己场上是否存在另一只与该怪兽种族相同、等级1以上且攻击力1000以下的表侧表示怪兽
		and Duel.IsExistingTarget(c9831539.filter2,tp,LOCATION_MZONE,0,1,c,c:GetRace())
end
-- 过滤第二只怪兽：等级1以上、攻击力1000以下、表侧表示，且种族与第一只怪兽相同
function c9831539.filter2(c,rac)
	return c:IsLevelAbove(1) and c:IsAttackBelow(1000) and c:IsFaceup() and c:IsRace(rac)
end
-- 效果发动时的对象选择处理：依次选择自己场上2只攻击力1000以下且种族相同的表侧表示怪兽作为对象
function c9831539.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	-- 检查可行性：是否存在至少一只满足条件1的怪兽（即存在一对满足条件的怪兽）
	if chk==0 then return Duel.IsExistingTarget(c9831539.filter1,tp,LOCATION_MZONE,0,1,nil,tp) end
	-- 提示玩家选择第一张表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让玩家选择第一只满足条件的怪兽并作为效果对象
	local g1=Duel.SelectTarget(tp,c9831539.filter1,tp,LOCATION_MZONE,0,1,1,nil,tp)
	-- 提示玩家选择第二张表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 排除第一只怪兽，让玩家选择第二只与其种族相同的满足条件的怪兽并作为效果对象
	Duel.SelectTarget(tp,c9831539.filter2,tp,LOCATION_MZONE,0,1,1,g1:GetFirst(),g1:GetFirst():GetRace())
end
-- 效果处理：获取选中的2只怪兽，若它们仍表侧表示存在，则将它们的等级都变为两者的等级合计值
function c9831539.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中作为效果对象的卡片组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local tc1=g:GetFirst()
	local tc2=g:GetNext()
	if tc1:IsRelateToEffect(e) and tc1:IsFaceup() and tc2:IsRelateToEffect(e) and tc2:IsFaceup() then
		local lv=tc1:GetLevel()+tc2:GetLevel()
		-- 选择的2只怪兽变成那2只的等级合计的等级。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetValue(lv)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc1:RegisterEffect(e1)
		local e2=e1:Clone()
		tc2:RegisterEffect(e2)
	end
end
