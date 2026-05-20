--屍界のバンシー
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：只要这张卡在怪兽区域存在，场地区域的「不死世界」不会被效果破坏，双方不能把那些卡作为效果的对象。
-- ②：自己·对方回合，把场上·墓地的这张卡除外才能发动。从手卡·卡组把1张「不死世界」发动。
function c66570171.initial_effect(c)
	-- ①：只要这张卡在怪兽区域存在，场地区域的「不死世界」不会被效果破坏
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_FZONE,LOCATION_FZONE)
	-- 设置效果影响的目标为卡名是「不死世界」的卡
	e1:SetTarget(aux.TargetBoolFunction(Card.IsCode,4064256))
	e1:SetValue(1)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	c:RegisterEffect(e2)
	-- ②：自己·对方回合，把场上·墓地的这张卡除外才能发动。从手卡·卡组把1张「不死世界」发动。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(66570171,0))
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetRange(LOCATION_MZONE+LOCATION_GRAVE)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetCountLimit(1,66570171)
	-- 设置发动成本为将场上·墓地的这张卡除外
	e3:SetCost(aux.bfgcost)
	e3:SetTarget(c66570171.actg)
	e3:SetOperation(c66570171.acop)
	c:RegisterEffect(e3)
end
-- 过滤卡名是「不死世界」且可以发动的卡
function c66570171.filter(c,tp)
	return c:IsCode(4064256) and c:GetActivateEffect() and c:GetActivateEffect():IsActivatable(tp,true,true)
end
-- 效果发动的目标选择（检查手卡·卡组是否存在可以发动的「不死世界」）
function c66570171.actg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段，检查手卡·卡组是否存在至少1张可以发动的「不死世界」
	if chk==0 then return Duel.IsExistingMatchingCard(c66570171.filter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,tp) end
end
-- 效果处理（从手卡·卡组将1张「不死世界」在场上发动）
function c66570171.acop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要放置到场上的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
	-- 从手卡·卡组选择1张满足条件的「不死世界」
	local tc=Duel.SelectMatchingCard(tp,c66570171.filter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,tp):GetFirst()
	if tc then
		-- 获取自己场地区域已存在的卡
		local fc=Duel.GetFieldCard(tp,LOCATION_FZONE,0)
		if fc then
			-- 根据规则将原本存在的场地区域卡送去墓地
			Duel.SendtoGrave(fc,REASON_RULE)
			-- 中断当前效果，使之后的效果处理视为不同时处理
			Duel.BreakEffect()
		end
		-- 将选中的「不死世界」表侧表示移动到场地区域
		Duel.MoveToField(tc,tp,tp,LOCATION_FZONE,POS_FACEUP,true)
		local te=tc:GetActivateEffect()
		te:UseCountLimit(tp,1,true)
		local tep=tc:GetControler()
		local cost=te:GetCost()
		if cost then cost(te,tep,eg,ep,ev,re,r,rp,1) end
		-- 触发发动场上魔法卡的时点事件
		Duel.RaiseEvent(tc,4179255,te,0,tp,tp,Duel.GetCurrentChain())
	end
end
