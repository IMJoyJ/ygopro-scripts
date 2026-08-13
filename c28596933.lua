--巨竜の羽ばたき
-- 效果：
-- ①：选自己场上1只5星以上的龙族怪兽回到持有者手卡，场上的魔法·陷阱卡全部破坏。
function c28596933.initial_effect(c)
	-- ①：选自己场上1只5星以上的龙族怪兽回到持有者手卡，场上的魔法·陷阱卡全部破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c28596933.target)
	e1:SetOperation(c28596933.activate)
	c:RegisterEffect(e1)
end
-- 筛选可作为回手对象的龙族怪兽：需要表侧表示、龙族、5星以上且能被效果送回手卡，用于从自己场上选择符合条件的龙族。
function c28596933.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_DRAGON) and c:IsLevelAbove(5) and c:IsAbleToHand()
end
-- 筛选可被破坏的魔法·陷阱卡：卡片类型为魔法卡或陷阱卡，用于确定场上要被破坏的魔法陷阱。
function c28596933.dfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 效果发动时的合法性判定部分：若chk==0，检查是否满足发动所需的两个条件并返回结果，条件为存在可回手的龙族怪兽且场上存在可破坏的魔法陷阱卡。
function c28596933.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上主要怪兽区是否存在至少1只符合条件的龙族怪兽（表侧、龙族、5星以上、可回手牌）。
	if chk==0 then return Duel.IsExistingMatchingCard(c28596933.filter,tp,LOCATION_MZONE,0,1,nil)
		-- 检查双方场上是否存在至少1张这张卡以外的魔法·陷阱卡（用于作为将被破坏的魔法陷阱）。
		and Duel.IsExistingMatchingCard(c28596933.dfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler()) end
	-- 在发动条件满足后，获取当前场上（双方区域）除这张卡以外的所有魔法·陷阱卡，作为破坏对象集合，用于后续设置操作信息。
	local sg=Duel.GetMatchingGroup(c28596933.dfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,e:GetHandler())
	-- 登记操作信息：声明效果将把1张卡从自己场上主要怪兽区返回持有者手卡（由于对象在处理时才确定，目标暂设为nil，数量为1）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_MZONE)
	-- 登记操作信息：声明效果将破坏当前场上的这些魔法·陷阱卡，数量为集合中的卡数。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,sg:GetCount(),0,0)
end
-- 效果处理：先由玩家选择自己场上1只5星以上龙族怪兽送回持有者手卡，若送回成功且该卡确实在手卡，则将场上除这张发动卡以外的所有魔法·陷阱卡破坏。
function c28596933.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 显示选择提示，提示玩家选择要返回手卡的龙族怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 从自己场上主要怪兽区选择1只满足条件的龙族怪兽（表侧、龙族、5星以上、可回手牌）。
	local g=Duel.SelectMatchingCard(tp,c28596933.filter,tp,LOCATION_MZONE,0,1,1,nil)
	local tc=g:GetFirst()
	-- 判断回手是否成功：选择的龙族怪兽存在，且通过效果送回持有者手卡后确实位于手卡，才继续执行破坏；否则不破坏。
	if tc and Duel.SendtoHand(tc,nil,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_HAND) then
		-- 获取当前场上除这张发动卡以外的所有魔法·陷阱卡，作为本次要破坏的对象集合。
		local sg=Duel.GetMatchingGroup(c28596933.dfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,aux.ExceptThisCard(e))
		-- 以效果原因破坏这些魔法·陷阱卡，将它们全部破坏并送去墓地。
		Duel.Destroy(sg,REASON_EFFECT)
	end
end
