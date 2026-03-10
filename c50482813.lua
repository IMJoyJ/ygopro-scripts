--SR吹持童子
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤成功的场合才能发动。把这张卡以外的自己场上的风属性怪兽数量的卡从自己卡组上面翻开，从那之中选1张加入手卡，剩下的卡用喜欢的顺序回到卡组最下面。
-- ②：把墓地的这张卡除外，以自己场上1只3星以上的风属性怪兽为对象才能发动。那只怪兽的等级下降2星。
function c50482813.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤成功的场合才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(50482813,0))
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,50482813)
	e1:SetTarget(c50482813.thtg)
	e1:SetOperation(c50482813.thop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：把墓地的这张卡除外，以自己场上1只3星以上的风属性怪兽为对象才能发动。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(50482813,1))
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1,50482814)
	-- 将此卡除外作为cost
	e3:SetCost(aux.bfgcost)
	e3:SetTarget(c50482813.target)
	e3:SetOperation(c50482813.operation)
	c:RegisterEffect(e3)
end
-- 过滤场上表侧表示的风属性怪兽
function c50482813.cfilter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_WIND)
end
-- 计算满足条件的风属性怪兽数量并判断是否可以发动效果
function c50482813.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 计算自己场上的风属性怪兽数量
	local ct=Duel.GetMatchingGroupCount(c50482813.cfilter,tp,LOCATION_MZONE,0,e:GetHandler())
	-- 确认自己卡组数量是否足够翻开这些卡
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>=ct
		-- 确认翻开的卡中是否存在能加入手牌的卡
		and Duel.GetDecktopGroup(tp,ct):IsExists(Card.IsAbleToHand,1,nil) end
	-- 设置连锁操作信息为检索和回手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 处理①效果的主要流程：计算风属性怪兽数量、翻开卡组顶部的卡、选择一张加入手牌、其余卡放回卡组底部
function c50482813.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 计算除自身外自己场上的风属性怪兽数量
	local ct=Duel.GetMatchingGroupCount(c50482813.cfilter,tp,LOCATION_MZONE,0,aux.ExceptThisCard(e))
	-- 翻开自己卡组最上方的指定数量的卡
	Duel.ConfirmDecktop(tp,ct)
	-- 获取翻开的卡组成的Group
	local g=Duel.GetDecktopGroup(tp,ct)
	if #g>0 then
		-- 禁止接下来的操作进行洗牌检测
		Duel.DisableShuffleCheck()
		-- 提示玩家选择要加入手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		local sc=g:Select(tp,1,1,nil):GetFirst()
		if sc:IsAbleToHand() then
			-- 将选中的卡加入手牌
			Duel.SendtoHand(sc,nil,REASON_EFFECT)
			-- 向对方确认该卡
			Duel.ConfirmCards(1-tp,sc)
			-- 洗切自己的手牌
			Duel.ShuffleHand(tp)
		else
			-- 将未选中的卡送入墓地
			Duel.SendtoGrave(sc,REASON_RULE)
		end
	end
	if #g>1 then
		-- 对剩余的卡进行排序
		Duel.SortDecktop(tp,tp,#g-1)
		for i=1,#g-1 do
			-- 获取卡组顶部的一张卡
			local dg=Duel.GetDecktopGroup(tp,1)
			-- 将该卡移动到卡组最底部
			Duel.MoveSequence(dg:GetFirst(),SEQ_DECKBOTTOM)
		end
	end
end
-- 过滤场上表侧表示且等级3以上的风属性怪兽
function c50482813.filter(c)
	return c:IsFaceup() and c:IsLevelAbove(3) and c:IsAttribute(ATTRIBUTE_WIND)
end
-- 设置②效果的目标选择流程：选择符合条件的怪兽
function c50482813.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c50482813.filter(chkc) end
	-- 判断是否存在符合条件的怪兽作为目标
	if chk==0 then return Duel.IsExistingTarget(c50482813.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择表侧表示的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择符合条件的1只怪兽作为目标
	local g=Duel.SelectTarget(tp,c50482813.filter,tp,LOCATION_MZONE,0,1,1,nil,tp)
end
-- 处理②效果的主要流程：对目标怪兽的等级下降2星
function c50482813.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的效果对象
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 给目标怪兽的等级下降2星
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetValue(-2)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
