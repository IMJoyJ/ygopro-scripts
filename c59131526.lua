--アクアの輪唱
-- 效果：
-- ①：选自己1张手卡除外。下次的自己准备阶段，可以把最多2张这个效果除外的卡的同名卡从卡组加入手卡。对方场上没有卡存在的状态把这张卡发动过的场合，直到发动的回合的结束时自己不能把这个效果除外的卡以及原本卡名和那张卡相同的卡的效果发动。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数
function s.initial_effect(c)
	-- ①：选自己1张手卡除外。下次的自己准备阶段，可以把最多2张这个效果除外的卡的同名卡从卡组加入手卡。对方场上没有卡存在的状态把这张卡发动过的场合，直到发动的回合的结束时自己不能把这个效果除外的卡以及原本卡名和那张卡相同的卡的效果发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
-- 效果发动的靶向与检测函数，检查手卡是否有可除外的卡，并记录发动时对方场上是否有卡
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己手卡是否存在至少1张可以除外的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,LOCATION_HAND,0,1,nil) end
	-- 设置当前连锁的操作信息为：从手卡除外1张卡
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_HAND)
	-- 检查对方场上是否有卡，若没有卡则将效果的Label设为1，否则设为0
	if Duel.GetFieldGroupCount(tp,0,LOCATION_ONFIELD)==0 then e:SetLabel(1) else e:SetLabel(0) end
end
-- 效果发动的处理函数，执行除外手卡、注册下次准备阶段检索同名卡的效果，以及在满足条件时限制同名卡效果的发动
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从手卡选择1张可以除外的卡
	local tc=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,LOCATION_HAND,0,1,1,nil):GetFirst()
	-- 将选中的手卡表侧表示除外，若除外失败则结束处理
	if not tc or Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)==0 then return end
	-- 下次的自己准备阶段，可以把最多2张这个效果除外的卡的同名卡从卡组加入手卡。对方场上没有卡存在的状态把这张卡发动过的场合
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e1:SetCountLimit(1)
	-- 将当前回合数和被除外卡片的卡号作为Label保存，用于后续判断和检索
	e1:SetLabel(Duel.GetTurnCount(),tc:GetCode())
	e1:SetCondition(s.condition)
	e1:SetOperation(s.operation)
	e1:SetReset(RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN,2)
	-- 注册用于在下次自己准备阶段检索同名卡的延迟触发效果
	Duel.RegisterEffect(e1,tp)
	if e:GetLabel()==1 and e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		-- 直到发动的回合的结束时自己不能把这个效果除外的卡以及原本卡名和那张卡相同的卡的效果发动。/下次的自己准备阶段，可以把最多2张这个效果除外的卡的同名卡从卡组加入手卡。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD)
		e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e2:SetCode(EFFECT_CANNOT_ACTIVATE)
		e2:SetTargetRange(1,0)
		e2:SetValue(s.aclimit)
		e2:SetLabel(tc:GetOriginalCodeRule())
		e2:SetReset(RESET_PHASE+PHASE_END)
		-- 注册限制玩家发动该同名卡效果的领域效果
		Duel.RegisterEffect(e2,tp)
	end
end
-- 延迟触发效果的发动条件函数，确保在下次自己的准备阶段触发
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前是否为自己的回合，且当前回合数大于发动时的回合数（即下次自己的回合）
	return Duel.GetTurnPlayer()==tp and Duel.GetTurnCount()>(e:GetLabel())
end
-- 过滤函数，用于在卡组中检索与被除外卡片同名且可以加入手卡的卡
function s.filter(c,_,...)
	return c:IsCode(...) and c:IsAbleToHand()
end
-- 延迟触发效果的处理函数，询问玩家是否将最多2张同名卡从卡组加入手卡并执行
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local t={e:GetLabel()}
	e:Reset()
	-- 检查卡组中是否存在至少1张被除外卡片的同名卡
	if not (Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil,table.unpack(t))
		-- 询问玩家是否发动该效果，若玩家选择“否”则结束处理
		and Duel.SelectYesNo(tp,aux.Stringid(id,1))) then return end  --"是否把「水之轮唱」除外的卡的同名卡加入手卡？"
	-- 在场上展示该卡（水之轮唱）的卡片发动提示
	Duel.Hint(HINT_CARD,0,id)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1到2张同名卡
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,2,nil,table.unpack(t))
	-- 将选中的卡片通过效果加入手卡
	Duel.SendtoHand(g,nil,REASON_EFFECT)
	-- 给对方玩家确认加入手卡的卡片
	Duel.ConfirmCards(1-tp,g)
end
-- 限制发动效果的判定函数，阻止玩家发动与被除外卡片原本卡名相同的卡的效果
function s.aclimit(e,re)
	return re:GetOwner():IsOriginalCodeRule(table.unpack{e:GetLabel()})
end
