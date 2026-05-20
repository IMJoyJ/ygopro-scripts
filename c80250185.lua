--オートヴァレット・ドラゴン
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：场上的这张卡为对象的连接怪兽的效果发动时才能发动。这张卡破坏。那之后，选场上1张魔法·陷阱卡送去墓地。
-- ②：场上的这张卡被战斗·效果破坏送去墓地的回合的结束阶段才能发动。从卡组把「自动手枪弹丸龙」以外的1只「弹丸」怪兽特殊召唤。
function c80250185.initial_effect(c)
	-- ①：场上的这张卡为对象的连接怪兽的效果发动时才能发动。这张卡破坏。那之后，选场上1张魔法·陷阱卡送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(80250185,0))
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,80250185)
	e1:SetCondition(c80250185.descon)
	e1:SetTarget(c80250185.destg)
	e1:SetOperation(c80250185.desop)
	c:RegisterEffect(e1)
	-- ②：场上的这张卡被战斗·效果破坏送去墓地的回合
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetOperation(c80250185.regop)
	c:RegisterEffect(e2)
end
-- 过滤条件：检查发动效果的连锁是否以场上的这张卡为对象，且该效果是否为连接怪兽的效果
function c80250185.descon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	-- 获取当前连锁的对象卡片组
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	if not g or not g:IsContains(c) then return false end
	return re:IsActiveType(TYPE_LINK)
end
-- 效果①的发动准备：检查自身是否可破坏、场上是否存在魔法·陷阱卡，并设置破坏和送去墓地的操作信息
function c80250185.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 获取双方场上的所有魔法·陷阱卡
	local g=Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil,TYPE_SPELL+TYPE_TRAP)
	if chk==0 then return c:IsDestructable() and g:GetCount()>0 end
	-- 设置当前连锁的操作信息为：破坏1张卡（自身）
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,c,1,0,0)
	-- 设置当前连锁的操作信息为：将场上的1张魔法·陷阱卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,1,0,0)
end
-- 效果①的效果处理：破坏自身，之后让玩家选择场上1张魔法·陷阱卡送去墓地
function c80250185.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自身是否仍与效果相关，并将其破坏
	if e:GetHandler():IsRelateToEffect(e) and Duel.Destroy(e:GetHandler(),REASON_EFFECT)>0 then
		-- 重新获取双方场上的所有魔法·陷阱卡
		local g=Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil,TYPE_SPELL+TYPE_TRAP)
		if g:GetCount()==0 then return end
		-- 中断当前效果，使后续的送去墓地处理与破坏处理视为不同时进行
		Duel.BreakEffect()
		-- 提示玩家选择要送去墓地的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 将选中的魔法·陷阱卡送去墓地
		Duel.SendtoGrave(sg,REASON_EFFECT)
	end
end
-- 检查自身是否因战斗或效果破坏送去墓地，并在结束阶段注册特殊召唤效果
function c80250185.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsReason(REASON_BATTLE+REASON_EFFECT) and c:IsReason(REASON_DESTROY) and c:IsPreviousLocation(LOCATION_ONFIELD) then
		-- 结束阶段才能发动。从卡组把「自动手枪弹丸龙」以外的1只「弹丸」怪兽特殊召唤。
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(80250185,1))
		e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetCountLimit(1,80250186)
		e1:SetRange(LOCATION_GRAVE)
		e1:SetTarget(c80250185.sptg)
		e1:SetOperation(c80250185.spop)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
-- 过滤条件：卡组中除「自动手枪弹丸龙」以外的「弹丸」怪兽，且该怪兽可以被特殊召唤
function c80250185.spfilter(c,e,tp)
	return c:IsSetCard(0x102) and not c:IsCode(80250185) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②的发动准备：检查自身怪兽区域是否有空位，以及卡组中是否存在可特殊召唤的合法怪兽，并设置特殊召唤的操作信息
function c80250185.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自身怪兽区域是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在满足条件的「弹丸」怪兽
		and Duel.IsExistingMatchingCard(c80250185.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置当前连锁的操作信息为：从卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果②的效果处理：从卡组选择1只「自动手枪弹丸龙」以外的「弹丸」怪兽特殊召唤到场上
function c80250185.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查怪兽区域是否仍有空位，若无则结束处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组中选择1只满足条件的「弹丸」怪兽
	local g=Duel.SelectMatchingCard(tp,c80250185.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
