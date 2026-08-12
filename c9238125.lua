--山と雪解の春化精
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：把这张卡和1只怪兽或者和1张「春化精」卡从手卡丢弃才能发动。自己从卡组抽1张。那之后，可以从自己墓地选1只地属性怪兽特殊召唤。这个回合，自己不能把地属性以外的怪兽的效果发动。
-- ②：以自己场上1只「春化精」怪兽为对象才能发动。这个回合，那只怪兽在同1次的战斗阶段中可以作2次攻击。
function c9238125.initial_effect(c)
	-- ①：把这张卡和1只怪兽或者和1张「春化精」卡从手卡丢弃才能发动。自己从卡组抽1张。那之后，可以从自己墓地选1只地属性怪兽特殊召唤。这个回合，自己不能把地属性以外的怪兽的效果发动。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW+CATEGORY_SPECIAL_SUMMON+CATEGORY_GRAVE_SPSUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,9238125)
	e1:SetCost(c9238125.drcost)
	e1:SetTarget(c9238125.drtg)
	e1:SetOperation(c9238125.drop)
	c:RegisterEffect(e1)
	-- ②：以自己场上1只「春化精」怪兽为对象才能发动。这个回合，那只怪兽在同1次的战斗阶段中可以作2次攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,9238126)
	e2:SetCondition(c9238125.atkcon)
	e2:SetTarget(c9238125.atktg)
	e2:SetOperation(c9238125.atkop)
	c:RegisterEffect(e2)
end
-- 过滤手牌中可以丢弃的怪兽卡或「春化精」卡
function c9238125.costfilter(c)
	return (c:IsType(TYPE_MONSTER) or c:IsSetCard(0x182)) and c:IsDiscardable()
end
-- 执行丢弃这张卡和1张手牌（怪兽或「春化精」卡）的Cost，并处理「春化精的花冠」的替代效果
function c9238125.drcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查玩家是否受到「春化精的花冠」效果的影响（可以用该卡代替丢弃手牌的Cost）
	local fe=Duel.IsPlayerAffectedByEffect(tp,14108995)
	-- 检查手牌中是否存在除这张卡以外可以作为Cost丢弃的卡
	local b2=Duel.IsExistingMatchingCard(c9238125.costfilter,tp,LOCATION_HAND,0,1,c)
	if chk==0 then return c:IsDiscardable() and (fe or b2) end
	-- 如果适用「春化精的花冠」的效果，且玩家选择适用该效果
	if fe and (not b2 or Duel.SelectYesNo(tp,aux.Stringid(14108995,0))) then  --"是否适用「春化精的花冠」的效果？"
		-- 在场上展示「春化精的花冠」以示适用其效果
		Duel.Hint(HINT_CARD,0,14108995)
		fe:UseCountLimit(tp)
		-- 将这张卡作为Cost从手牌丢弃
		Duel.SendtoGrave(c,REASON_COST+REASON_DISCARD)
	else
		-- 提示玩家选择要丢弃的手牌
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)  --"请选择要丢弃的手牌"
		-- 让玩家从手牌选择1张除这张卡以外的怪兽卡或「春化精」卡
		local g=Duel.SelectMatchingCard(tp,c9238125.costfilter,tp,LOCATION_HAND,0,1,1,c)
		g:AddCard(c)
		-- 将选择的卡作为Cost从手牌丢弃
		Duel.SendtoGrave(g,REASON_COST+REASON_DISCARD)
	end
end
-- 检查是否能抽卡，并设置抽卡的操作信息
function c9238125.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动准备阶段，检查玩家当前是否可以抽卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 设置当前连锁的效果处理对象玩家为自己
	Duel.SetTargetPlayer(tp)
	-- 设置当前连锁的效果处理参数为1（抽1张卡）
	Duel.SetTargetParam(1)
	-- 设置当前连锁的操作信息为：自己从卡组抽1张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 过滤墓地中可以特殊召唤的地属性怪兽
function c9238125.spfilter(c,e,tp)
	return c:IsAttribute(ATTRIBUTE_EARTH) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 执行抽卡，并可以从墓地特殊召唤1只地属性怪兽，最后对自身施加本回合不能发动地属性以外怪兽效果的限制
function c9238125.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中设定的目标玩家和抽卡数量
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 如果成功通过效果抽卡
	if Duel.Draw(p,d,REASON_EFFECT)>0 then
		-- 获取自己墓地中不受「王家长眠之谷」影响且满足特殊召唤条件的地属性怪兽
		local sg=Duel.GetMatchingGroup(aux.NecroValleyFilter(c9238125.spfilter),tp,LOCATION_GRAVE,0,nil,e,tp)
		-- 如果墓地存在可特殊召唤的怪兽，且自己场上有可用的怪兽区域
		if sg:GetCount()>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			-- 询问玩家是否选择从墓地特殊召唤
			and Duel.SelectYesNo(tp,aux.Stringid(9238125,0)) then  --"是否从墓地特殊召唤？"
			-- 中断当前效果处理，使后续的特殊召唤处理不与抽卡同时进行（会造成错时点）
			Duel.BreakEffect()
			-- 提示玩家选择要特殊召唤的怪兽
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			local sc=sg:Select(tp,1,1,nil)
			-- 将选择的怪兽以表侧表示特殊召唤到自己场上
			Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)
		end
	end
	-- 这个回合，自己不能把地属性以外的怪兽的效果发动。②：以自己场上1只「春化精」怪兽为对象才能发动。这个回合，那只怪兽在同1次的战斗阶段中可以作2次攻击。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetTargetRange(1,0)
	e1:SetValue(c9238125.aclimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 在全局环境中注册该玩家限制效果
	Duel.RegisterEffect(e1,tp)
end
-- 限制玩家不能发动地属性以外的怪兽的效果
function c9238125.aclimit(e,re,tp)
	return re:IsActiveType(TYPE_MONSTER) and re:GetHandler():IsNonAttribute(ATTRIBUTE_EARTH)
end
-- 检查当前回合玩家是否可以进入战斗阶段
function c9238125.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 返回当前回合玩家是否可以进入战斗阶段
	return Duel.IsAbleToEnterBP()
end
-- 过滤自己场上表侧表示、且未拥有追加攻击效果的「春化精」怪兽
function c9238125.atkfilter(c)
	return c:IsSetCard(0x182) and c:IsFaceup() and not c:IsHasEffect(EFFECT_EXTRA_ATTACK)
end
-- 选择自己场上1只表侧表示的「春化精」怪兽作为效果对象
function c9238125.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c9238125.atkfilter(chkc) end
	-- 在发动准备阶段，检查自己场上是否存在符合条件的「春化精」怪兽
	if chk==0 then return Duel.IsExistingTarget(c9238125.atkfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择表侧表示的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择自己场上1只符合条件的「春化精」怪兽作为对象
	Duel.SelectTarget(tp,c9238125.atkfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 使作为对象的怪兽在同一次战斗阶段中可以作2次攻击
function c9238125.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 这个回合，那只怪兽在同1次的战斗阶段中可以作2次攻击。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(aux.Stringid(9238125,1))  --"「山与雪解的春化精」效果适用中"
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
		e1:SetCode(EFFECT_EXTRA_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(1)
		tc:RegisterEffect(e1)
	end
end
