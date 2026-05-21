--ブーギートラップ
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：丢弃2张手卡，以自己墓地1张陷阱卡为对象才能发动。那张卡在自己场上盖放。这个效果盖放的卡在盖放的回合也能发动。
function c96704974.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：丢弃2张手卡，以自己墓地1张陷阱卡为对象才能发动。那张卡在自己场上盖放。这个效果盖放的卡在盖放的回合也能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SSET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,96704974+EFFECT_COUNT_CODE_OATH)
	e1:SetCost(c96704974.cost)
	e1:SetTarget(c96704974.target)
	e1:SetOperation(c96704974.activate)
	c:RegisterEffect(e1)
end
-- 效果发动的代价（Cost）处理函数
function c96704974.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡中是否存在除这张卡以外的至少2张可以丢弃的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,2,e:GetHandler()) end
	-- 玩家选择并丢弃2张手卡作为发动代价
	Duel.DiscardHand(tp,nil,2,2,REASON_COST+REASON_DISCARD,e:GetHandler())
end
-- 过滤函数：筛选自己墓地可以盖放的陷阱卡
function c96704974.filter(c)
	return c:IsType(TYPE_TRAP) and c:IsSSetable()
end
-- 效果发动时的对象选择与合法性检查（Target）处理函数
function c96704974.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c96704974.filter(chkc) end
	-- 获取玩家魔法与陷阱区域的可用空格数
	local ct=Duel.GetLocationCount(tp,LOCATION_SZONE)
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) and not e:GetHandler():IsLocation(LOCATION_SZONE) then ct=ct-1 end
	-- 检查魔法与陷阱区域是否有空位，且自己墓地是否存在至少1张满足条件的陷阱卡
	if chk==0 then return ct>0 and Duel.IsExistingTarget(c96704974.filter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要盖放的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 选择自己墓地1张满足条件的陷阱卡作为效果的对象
	local g=Duel.SelectTarget(tp,c96704974.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置连锁处理信息：涉及1张卡离开墓地
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
end
-- 效果处理（Operation）函数：将目标卡盖放，并赋予其在盖放回合也能发动的效果
function c96704974.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果处理时作为对象的卡片
	local tc=Duel.GetFirstTarget()
	-- 检查对象卡是否仍与效果相关联，并成功将其在自己场上盖放
	if tc:IsRelateToEffect(e) and Duel.SSet(tp,tc)~=0 then
		-- 这个效果盖放的卡在盖放的回合也能发动。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(aux.Stringid(96704974,0))  --"适用「鬼雷弦阱」的效果来发动"
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
		e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
