--レベル・マイスター
-- 效果：
-- 把手卡1只怪兽送去墓地，选择自己场上表侧表示存在的最多2只怪兽才能发动。选择的怪兽的等级直到结束阶段时变成和为这张卡发动而送去墓地的怪兽的原本等级相同。
function c37198732.initial_effect(c)
	-- 把手卡1只怪兽送去墓地，选择自己场上表侧表示存在的最多2只怪兽才能发动。选择的怪兽的等级直到结束阶段时变成和为这张卡发动而送去墓地的怪兽的原本等级相同。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCost(c37198732.cost)
	e1:SetTarget(c37198732.target)
	e1:SetOperation(c37198732.activate)
	c:RegisterEffect(e1)
end
-- 代价筛选函数：判定卡牌是否为等级大于0且可以作为代价送去墓地的手牌怪兽。
function c37198732.cfilter(c)
	return c:GetLevel()>0 and c:IsAbleToGraveAsCost()
end
-- 代价处理：先确认手牌中有可送墓的怪兽，随后选择1只送去墓地，将其保存为LabelObject并与效果建立联系，供后续读取其等级。
function c37198732.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 检查tp方手牌中是否存在至少1张满足cfilter（等级大于0且可作代价送去墓地）的怪兽。
		if Duel.IsExistingMatchingCard(c37198732.cfilter,tp,LOCATION_HAND,0,1,nil) then
			e:SetLabel(1)
			return true
		else
			return false
		end
	end
	-- 显示选择提示，引导玩家选择要作为代价送去墓地的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从tp手牌中选出1只满足cfilter的怪兽作为代价。
	local g=Duel.SelectMatchingCard(tp,c37198732.cfilter,tp,LOCATION_HAND,0,1,1,nil)
	-- 将选中的怪兽以代价方式送去墓地。
	Duel.SendtoGrave(g,REASON_COST)
	e:SetLabelObject(g:GetFirst())
	g:GetFirst():CreateEffectRelation(e)
end
-- 对象筛选函数：判断怪兽是否表侧表示且等级大于0，用于选择场上要被改变等级的对象。
function c37198732.filter(c)
	return c:IsFaceup() and c:GetLevel()>0
end
-- 目标设定函数：确认已支付代价后，检查场上是否存在合法对象，并将Label清零；发动时选择自己场上表侧表示且等级大于0的1~2只怪兽，登记为连锁对象。
function c37198732.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c37198732.filter(chkc) end
	if chk==0 then
		if e:GetLabel()~=1 then return false end
		e:SetLabel(0)
		-- 检查自己场上是否存在至少1只满足filter且能够成为效果对象的表侧表示怪兽。
		return Duel.IsExistingTarget(c37198732.filter,tp,LOCATION_MZONE,0,1,nil)
	end
	-- 显示选择提示，引导玩家选择表侧表示的怪兽作为效果对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择自己场上表侧表示且等级大于0的1~2只怪兽作为效果对象，并把它们登记为当前连锁的对象。
	Duel.SelectTarget(tp,c37198732.filter,tp,LOCATION_MZONE,0,1,2,nil)
end
-- 效果处理：取出作为代价送去墓地的怪兽；若其仍与效果关联，则将该怪兽的等级作为目标等级，对连锁对象中仍关联且表侧表示的怪兽赋予等级变化效果，直到结束阶段。
function c37198732.activate(e,tp,eg,ep,ev,re,r,rp)
	local lc=e:GetLabelObject()
	if not lc:IsRelateToEffect(e) then return end
	local lv=lc:GetLevel()
	-- 获取当前连锁处理中登记的对象卡组，即发动时选择的1~2只对象怪兽。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local tc=g:GetFirst()
	while tc do
		if tc:IsRelateToEffect(e) and tc:IsFaceup() then
			-- 选择的怪兽的等级直到结束阶段时变成和为这张卡发动而送去墓地的怪兽的原本等级相同。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CHANGE_LEVEL)
			e1:SetValue(lv)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e1)
		end
		tc=g:GetNext()
	end
end
