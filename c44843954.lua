--寝姫の甘い夢
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：从卡组把1只「妮穆蕾莉娅」怪兽加入手卡。自己的额外卡组有表侧表示的「梦见之妮穆蕾莉娅」存在的场合，再在这个回合在「妮穆蕾莉娅」怪兽的召唤·特殊召唤成功时让对方不能把魔法·陷阱·怪兽的效果发动。
-- ②：让墓地的这张卡回到卡组最下面，以自己场上1张「梦见之妮穆蕾莉娅」为对象才能发动。那张卡表侧表示加入持有者的额外卡组。
function c44843954.initial_effect(c)
	-- 效果原文内容：①：从卡组把1只「妮穆蕾莉娅」怪兽加入手卡。自己的额外卡组有表侧表示的「梦见之妮穆蕾莉娅」存在的场合，再在这个回合在「妮穆蕾莉娅」怪兽的召唤·特殊召唤成功时让对方不能把魔法·陷阱·怪兽的效果发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(44843954,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,44843954+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c44843954.target)
	e1:SetOperation(c44843954.activate)
	c:RegisterEffect(e1)
	-- 效果原文内容：②：让墓地的这张卡回到卡组最下面，以自己场上1张「梦见之妮穆蕾莉娅」为对象才能发动。那张卡表侧表示加入持有者的额外卡组。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(44843954,1))
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCost(c44843954.mvcost)
	e2:SetTarget(c44843954.mvtg)
	e2:SetOperation(c44843954.mvop)
	c:RegisterEffect(e2)
end
-- 检索满足条件的「妮穆蕾莉娅」怪兽（类型为怪兽且可以加入手牌）
function c44843954.filter(c)
	return c:IsSetCard(0x191) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 判断是否可以发动效果（卡组中是否存在满足条件的怪兽）
function c44843954.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否可以发动效果（卡组中是否存在满足条件的怪兽）
	if chk==0 then return Duel.IsExistingMatchingCard(c44843954.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置效果处理信息（将1张卡从卡组加入手牌）
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果作用：选择并加入手牌1只满足条件的怪兽，若加入手牌的怪兽为「妮穆蕾莉娅」怪兽且己方额外卡组存在表侧表示的「梦见之妮穆蕾莉娅」则注册连锁限制效果
function c44843954.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的1张卡加入手牌
	local g=Duel.SelectMatchingCard(tp,c44843954.filter,tp,LOCATION_DECK,0,1,1,nil)
	if #g==0 then return end
	-- 将选中的卡加入手牌
	Duel.SendtoHand(g,nil,REASON_EFFECT)
	-- 向对方确认加入手牌的卡
	Duel.ConfirmCards(1-tp,g)
	if g:GetFirst():IsLocation(LOCATION_HAND)
		-- 判断加入手牌的卡是否为「妮穆蕾莉娅」怪兽且己方额外卡组存在表侧表示的「梦见之妮穆蕾莉娅」
		and Duel.IsExistingMatchingCard(aux.AND(Card.IsFaceup,Card.IsCode),tp,LOCATION_EXTRA,0,1,nil,70155677) then
		-- 中断当前效果处理
		Duel.BreakEffect()
		-- 提示对方宣言了「梦见之妮穆蕾莉娅」
		Duel.Hint(HINT_CARD,0,70155677)
		local c=e:GetHandler()
		-- 效果原文内容：①：从卡组把1只「妮穆蕾莉娅」怪兽加入手卡。自己的额外卡组有表侧表示的「梦见之妮穆蕾莉娅」存在的场合，再在这个回合在「妮穆蕾莉娅」怪兽的召唤·特殊召唤成功时让对方不能把魔法·陷阱·怪兽的效果发动。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_SUMMON_SUCCESS)
		e1:SetCondition(c44843954.sumcon)
		e1:SetOperation(c44843954.sumsuc)
		e1:SetReset(RESET_PHASE+PHASE_END)
		-- 注册召唤成功时的连锁限制效果
		Duel.RegisterEffect(e1,tp)
		local e2=e1:Clone()
		e2:SetCode(EVENT_SPSUMMON_SUCCESS)
		-- 注册特殊召唤成功时的连锁限制效果
		Duel.RegisterEffect(e2,tp)
		-- 效果原文内容：①：从卡组把1只「妮穆蕾莉娅」怪兽加入手卡。自己的额外卡组有表侧表示的「梦见之妮穆蕾莉娅」存在的场合，再在这个回合在「妮穆蕾莉娅」怪兽的召唤·特殊召唤成功时让对方不能把魔法·陷阱·怪兽的效果发动。
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e3:SetCode(EVENT_CHAIN_END)
		e3:SetOperation(c44843954.limop2)
		-- 注册连锁结束时的连锁限制效果
		Duel.RegisterEffect(e3,tp)
	end
end
-- 判断目标怪兽是否为表侧表示的「妮穆蕾莉娅」怪兽
function c44843954.sumfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x191)
end
-- 判断是否满足连锁限制条件（是否有「妮穆蕾莉娅」怪兽被召唤或特殊召唤）
function c44843954.sumcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c44843954.sumfilter,1,nil)
end
-- 效果作用：根据当前连锁序号设置连锁限制
function c44843954.sumsuc(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前连锁序号是否为0
	if Duel.GetCurrentChain()==0 then
		-- 设置连锁限制直到连锁结束
		Duel.SetChainLimitTillChainEnd(c44843954.chainlm)
	-- 判断当前连锁序号是否为1
	elseif Duel.GetCurrentChain()==1 then
		-- 注册标识效果用于标记连锁限制
		Duel.RegisterFlagEffect(tp,44843954,RESET_PHASE+PHASE_END,0,1)
		-- 效果原文内容：①：从卡组把1只「妮穆蕾莉娅」怪兽加入手卡。自己的额外卡组有表侧表示的「梦见之妮穆蕾莉娅」存在的场合，再在这个回合在「妮穆蕾莉娅」怪兽的召唤·特殊召唤成功时让对方不能把魔法·陷阱·怪兽的效果发动。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_CHAINING)
		e1:SetOperation(c44843954.resetop)
		-- 注册连锁中时的连锁限制效果
		Duel.RegisterEffect(e1,tp)
		local e2=e1:Clone()
		e2:SetCode(EVENT_BREAK_EFFECT)
		e2:SetReset(RESET_CHAIN)
		-- 注册连锁中断时的连锁限制效果
		Duel.RegisterEffect(e2,tp)
	end
end
-- 效果作用：重置标识效果并清除效果
function c44843954.resetop(e,tp,eg,ep,ev,re,r,rp)
	-- 重置标识效果
	Duel.ResetFlagEffect(tp,44843954)
	e:Reset()
end
-- 效果作用：根据标识效果状态设置连锁限制
function c44843954.limop2(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否存在标识效果
	if Duel.GetFlagEffect(tp,44843954)>0 then
		-- 设置连锁限制直到连锁结束
		Duel.SetChainLimitTillChainEnd(c44843954.chainlm)
	end
	-- 重置标识效果
	Duel.ResetFlagEffect(tp,44843954)
end
-- 连锁限制函数：仅允许自己发动的效果
function c44843954.chainlm(e,ep,tp)
	return ep==tp
end
-- 效果原文内容：②：让墓地的这张卡回到卡组最下面，以自己场上1张「梦见之妮穆蕾莉娅」为对象才能发动。那张卡表侧表示加入持有者的额外卡组。
function c44843954.mvcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToDeckAsCost() end
	-- 将此卡送回卡组最底端作为费用
	Duel.SendtoDeck(c,nil,SEQ_DECKBOTTOM,REASON_COST)
end
-- 判断目标是否为表侧表示的「梦见之妮穆蕾莉娅」灵摆怪兽
function c44843954.mvfilter(c)
	return c:IsFaceup() and c:IsCode(70155677) and c:IsType(TYPE_PENDULUM) and c:IsAbleToExtra()
end
-- 判断是否可以发动效果（场上是否存在满足条件的灵摆怪兽）
function c44843954.mvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c44843954.mvfilter(chkc) end
	-- 判断是否可以发动效果（场上是否存在满足条件的灵摆怪兽）
	if chk==0 then return Duel.IsExistingTarget(c44843954.mvfilter,tp,LOCATION_ONFIELD,0,1,nil) end
	-- 提示玩家选择效果对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择满足条件的灵摆怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c44843954.mvfilter,tp,LOCATION_ONFIELD,0,1,1,nil)
	-- 设置效果处理信息（将1张卡送入额外卡组）
	Duel.SetOperationInfo(0,CATEGORY_TOEXTRA,g,1,0,0)
end
-- 效果作用：将选中的灵摆怪兽送入额外卡组
function c44843954.mvop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前效果的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡送入额外卡组
		Duel.SendtoExtraP(tc,nil,REASON_EFFECT)
	end
end
