--トロイメア・グリフォン
-- 效果：
-- 卡名不同的怪兽2只以上
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡连接召唤的场合，丢弃1张手卡，以自己墓地1张魔法·陷阱卡为对象才能发动。那张卡在自己场上盖放。这个效果盖放的卡在这个回合不能发动。这个效果的发动时这张卡是互相连接状态的场合，再让自己可以抽1张。
-- ②：只要这张卡在怪兽区域存在，双方不能把不在连接状态的特殊召唤的场上的怪兽的效果发动。
function c65330383.initial_effect(c)
	-- 添加连接召唤手续，需要2只以上的怪兽作为素材，且素材需满足lcheck过滤条件（卡名不同）
	aux.AddLinkProcedure(c,nil,2,nil,c65330383.lcheck)
	c:EnableReviveLimit()
	-- 这个卡名的①的效果1回合只能使用1次。①：这张卡连接召唤的场合，丢弃1张手卡，以自己墓地1张魔法·陷阱卡为对象才能发动。那张卡在自己场上盖放。这个效果盖放的卡在这个回合不能发动。这个效果的发动时这张卡是互相连接状态的场合，再让自己可以抽1张。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(65330383,0))
	e1:SetCategory(CATEGORY_LEAVE_GRAVE+CATEGORY_SSET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,65330383)
	e1:SetCondition(c65330383.setcon)
	e1:SetCost(c65330383.setcost)
	e1:SetTarget(c65330383.settg)
	e1:SetOperation(c65330383.setop)
	c:RegisterEffect(e1)
	-- ②：只要这张卡在怪兽区域存在，双方不能把不在连接状态的特殊召唤的场上的怪兽的效果发动。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_ACTIVATE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(1,1)
	e2:SetValue(c65330383.aclimit)
	c:RegisterEffect(e2)
end
-- 连接素材过滤函数：检查用于连接召唤的怪兽卡名是否各不相同
function c65330383.lcheck(g,lc)
	return g:GetClassCount(Card.GetLinkCode)==g:GetCount()
end
-- 效果①的发动条件：这张卡是连接召唤成功的场合
function c65330383.setcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
-- 效果①的代价：丢弃1张手卡
function c65330383.setcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡中是否存在可以作为丢弃代价的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	-- 玩家选择并丢弃1张手卡作为发动代价
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 过滤函数：选择自己墓地可以盖放的魔法·陷阱卡
function c65330383.setfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSSetable()
end
-- 效果①的靶向与发动准备：检查魔法与陷阱区域是否有空位，以及墓地是否有可盖放的魔法·陷阱卡，并选择目标
function c65330383.settg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c65330383.setfilter(chkc) end
	-- 检查自己场上的魔法与陷阱区域是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查自己墓地是否存在可以作为对象盖放的魔法·陷阱卡
		and Duel.IsExistingTarget(c65330383.setfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 给玩家发送选择要盖放的卡的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 选择自己墓地1张满足条件的魔法·陷阱卡作为效果的对象
	local g=Duel.SelectTarget(tp,c65330383.setfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置效果处理信息：包含将卡片移出墓地的操作
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
	if e:GetHandler():GetMutualLinkedGroupCount()>0 then
		e:SetCategory(CATEGORY_LEAVE_GRAVE+CATEGORY_DRAW+CATEGORY_SSET)
		e:SetLabel(1)
	else
		e:SetCategory(CATEGORY_LEAVE_GRAVE+CATEGORY_SSET)
		e:SetLabel(0)
	end
end
-- 效果①的效果处理：将目标卡在场上盖放，并适用该回合不能发动的限制；若发动时处于互相连接状态，则可以抽1张卡
function c65330383.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果①选择的墓地魔法·陷阱卡对象
	local tc=Duel.GetFirstTarget()
	-- 若目标卡仍与效果相关，则将其在自己场上盖放，盖放成功时进行后续处理
	if tc:IsRelateToEffect(e) and Duel.SSet(tp,tc)~=0 then
		-- 这个效果盖放的卡在这个回合不能发动。这个效果的发动时这张卡是互相连接状态的场合，再让自己可以抽1张。双方不能把不在连接状态的特殊召唤的场上的怪兽的效果发动。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_TRIGGER)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1,true)
		-- 检查发动时是否处于互相连接状态（通过Label传递），以及玩家当前是否可以抽卡
		if e:GetLabel()==1 and Duel.IsPlayerCanDraw(tp,1)
			-- 询问玩家是否选择抽1张卡
			and Duel.SelectYesNo(tp,aux.Stringid(65330383,1)) then  --"是否抽卡？"
			-- 中断当前效果处理，使盖放和抽卡不视为同时处理
			Duel.BreakEffect()
			-- 玩家从卡组抽1张卡
			Duel.Draw(tp,1,REASON_EFFECT)
		end
	end
end
-- 限制发动效果的怪兽过滤：限制在怪兽区域存在、是特殊召唤、且不处于连接状态的怪兽发动效果
function c65330383.aclimit(e,re,tp)
	local tc=re:GetHandler()
	return tc:IsLocation(LOCATION_MZONE) and tc:IsSummonType(SUMMON_TYPE_SPECIAL) and not tc:IsLinkState() and re:IsActiveType(TYPE_MONSTER)
end
