--A・O・J ディサイシブ・アームズ
-- 效果：
-- 调整＋调整以外的怪兽2只以上
-- 对方场上有光属性怪兽表侧表示存在的场合，1回合1次，可以从下面效果选择1个发动。
-- ●把对方场上盖放的1张卡破坏。
-- ●把1张手卡送去墓地，对方场上存在的魔法·陷阱卡全部破坏。
-- ●把自己手卡全部送去墓地，把对方手卡确认并从那之中把光属性怪兽全部送去墓地。那之后给与对方基本分送去墓地的对方怪兽的攻击力合计数值的伤害。
function c9888196.initial_effect(c)
	-- 设置同调召唤手续：需要1只调整和2只以上的调整以外的怪兽
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),2)
	c:EnableReviveLimit()
	-- ●把对方场上盖放的1张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(9888196,0))  --"把对方场上盖放的1张卡破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1,EFFECT_COUNT_CODE_SINGLE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c9888196.con)
	e1:SetTarget(c9888196.destg1)
	e1:SetOperation(c9888196.desop1)
	c:RegisterEffect(e1)
	-- ●把1张手卡送去墓地，对方场上存在的魔法·陷阱卡全部破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(9888196,1))  --"对方场上存在的魔法·陷阱卡全部破坏"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetCountLimit(1,EFFECT_COUNT_CODE_SINGLE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c9888196.con)
	e2:SetCost(c9888196.descost2)
	e2:SetTarget(c9888196.destg2)
	e2:SetOperation(c9888196.desop2)
	c:RegisterEffect(e2)
	-- ●把自己手卡全部送去墓地，把对方手卡确认并从那之中把光属性怪兽全部送去墓地。那之后给与对方基本分送去墓地的对方怪兽的攻击力合计数值的伤害。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(9888196,2))  --"把对方手卡光属性怪兽全部送去墓地"
	e3:SetCategory(CATEGORY_HANDES+CATEGORY_TOGRAVE+CATEGORY_DAMAGE)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetCountLimit(1,EFFECT_COUNT_CODE_SINGLE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(c9888196.con)
	e3:SetCost(c9888196.hdcost)
	e3:SetTarget(c9888196.hdtg)
	e3:SetOperation(c9888196.hdop)
	c:RegisterEffect(e3)
end
-- 过滤条件：表侧表示且为光属性的卡
function c9888196.confilter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_LIGHT)
end
-- 效果发动条件：对方场上存在表侧表示的光属性怪兽
function c9888196.con(e,tp,eg,ep,ev,re,r,rp)
	-- 检查对方场上是否存在至少1只表侧表示的光属性怪兽
	return Duel.IsExistingMatchingCard(c9888196.confilter,tp,0,LOCATION_MZONE,1,nil)
end
-- 过滤条件：里侧表示（盖放）的卡
function c9888196.filter1(c)
	return c:IsFacedown()
end
-- 效果1（破坏盖放卡）的靶向/发动准备阶段：进行合法性检查并选择对方场上1张盖放的卡作为对象
function c9888196.destg1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsOnField() and c9888196.filter1(chkc) end
	-- 在发动准备阶段，检查对方场上是否存在可以作为对象的里侧表示卡片
	if chk==0 then return Duel.IsExistingTarget(c9888196.filter1,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 向对方玩家提示当前选择发动的效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上1张盖放的卡作为效果对象
	local g=Duel.SelectTarget(tp,c9888196.filter1,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置效果处理信息：破坏选中的卡片
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果1（破坏盖放卡）的效果处理：破坏选中的对象
function c9888196.desop1(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选为对象的那张卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFacedown() then
		-- 因效果破坏该卡
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- 效果2（破坏魔陷）的发动代价：将1张手卡送去墓地
function c9888196.descost2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动准备阶段，检查自己手卡中是否存在可以作为代价送去墓地的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToGraveAsCost,tp,LOCATION_HAND,0,1,nil) end
	-- 向对方玩家提示当前选择发动的效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 玩家选择1张手卡作为送去墓地的代价
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToGraveAsCost,tp,LOCATION_HAND,0,1,1,nil)
	-- 将选中的手卡作为代价送去墓地
	Duel.SendtoGrave(g,REASON_COST)
end
-- 过滤条件：魔法或陷阱卡
function c9888196.filter2(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 效果2（破坏魔陷）的发动准备阶段：进行合法性检查并设置破坏信息
function c9888196.destg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动准备阶段，检查对方场上是否存在魔法·陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(c9888196.filter2,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 获取对方场上所有的魔法·陷阱卡
	local g=Duel.GetMatchingGroup(c9888196.filter2,tp,0,LOCATION_ONFIELD,nil)
	-- 设置效果处理信息：破坏对方场上所有的魔法·陷阱卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果2（破坏魔陷）的效果处理：破坏对方场上所有的魔法·陷阱卡
function c9888196.desop2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上所有的魔法·陷阱卡
	local g=Duel.GetMatchingGroup(c9888196.filter2,tp,0,LOCATION_ONFIELD,nil)
	-- 因效果破坏获取到的所有魔法·陷阱卡
	Duel.Destroy(g,REASON_EFFECT)
end
-- 效果3（丢手卡确认并送墓）的发动代价：将自己手卡全部送去墓地
function c9888196.hdcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动准备阶段，检查自己手卡中是否存在至少1张可以作为代价送去墓地的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToGraveAsCost,tp,LOCATION_HAND,0,1,nil) end
	-- 向对方玩家提示当前选择发动的效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 获取自己所有的手卡
	local g=Duel.GetFieldGroup(tp,LOCATION_HAND,0)
	-- 将自己所有的手卡作为代价送去墓地
	Duel.SendtoGrave(g,REASON_COST)
end
-- 效果3（丢手卡确认并送墓）的发动准备阶段：进行合法性检查并设置丢弃手卡、送去墓地的效果处理信息
function c9888196.hdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动准备阶段，检查对方手卡是否至少有1张
	if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)>0 end
	-- 设置效果处理信息：涉及对方手卡的操作
	Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,1-tp,0)
	-- 设置效果处理信息：将对方手卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,0,1-tp,LOCATION_HAND)
end
-- 效果3（丢手卡确认并送墓）的效果处理：确认对方手卡，将其中的光属性怪兽全部送去墓地，并给予对方相应的伤害
function c9888196.hdop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方所有的手卡
	local g=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
	-- 让己方玩家确认对方的所有手卡
	Duel.ConfirmCards(tp,g)
	local sg=g:Filter(Card.IsAttribute,nil,ATTRIBUTE_LIGHT)
	if sg:GetCount()>0 then
		local atk=0
		-- 将对方手卡中所有的光属性怪兽送去墓地
		Duel.SendtoGrave(sg,REASON_EFFECT)
		local tc=sg:GetFirst()
		while tc do
			local tatk=tc:GetAttack()
			if tatk<0 then tatk=0 end
			atk=atk+tatk
			tc=sg:GetNext()
		end
		-- 中断当前效果，使后续的伤害处理不与送去墓地同时处理
		Duel.BreakEffect()
		-- 给予对方等同于送去墓地的怪兽攻击力合计数值的伤害
		Duel.Damage(1-tp,atk,REASON_EFFECT)
	end
	-- 洗切对方的手卡
	Duel.ShuffleHand(1-tp)
end
