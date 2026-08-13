--寝姫の甘い夢
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：从卡组把1只「妮穆蕾莉娅」怪兽加入手卡。自己的额外卡组有表侧表示的「梦见之妮穆蕾莉娅」存在的场合，再在这个回合在「妮穆蕾莉娅」怪兽的召唤·特殊召唤成功时让对方不能把魔法·陷阱·怪兽的效果发动。
-- ②：让墓地的这张卡回到卡组最下面，以自己场上1张「梦见之妮穆蕾莉娅」为对象才能发动。那张卡表侧表示加入持有者的额外卡组。
function c44843954.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：从卡组把1只「妮穆蕾莉娅」怪兽加入手卡。自己的额外卡组有表侧表示的「梦见之妮穆蕾莉娅」存在的场合，再在这个回合在「妮穆蕾莉娅」怪兽的召唤·特殊召唤成功时让对方不能把魔法·陷阱·怪兽的效果发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(44843954,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,44843954+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c44843954.target)
	e1:SetOperation(c44843954.activate)
	c:RegisterEffect(e1)
	-- ②：让墓地的这张卡回到卡组最下面，以自己场上1张「梦见之妮穆蕾莉娅」为对象才能发动。那张卡表侧表示加入持有者的额外卡组。
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
-- 过滤条件：判断卡是否为「妮穆蕾莉娅」系列的怪兽且能够加入手卡（用于检索卡组）。
function c44843954.filter(c)
	return c:IsSetCard(0x191) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 发动时的条件判定与操作信息设置：在发动时确认卡组存在至少1只符合筛选条件的「妮穆蕾莉娅」怪兽，并设置“从卡组把1张卡加入手卡”的操作信息。
function c44843954.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查：己方卡组存在至少1只可加入手卡的「妮穆蕾莉娅」怪兽才允许发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c44843954.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：本次效果处理将从卡组把1张卡加入手卡（用于连锁判定与效果检测）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：从卡组选择1只「妮穆蕾莉娅」怪兽加入手卡并告知对方；若检索成功且己方额外卡组存在表侧「梦见之妮穆蕾莉娅」，则中断当前效果，追加本回合在「妮穆蕾莉娅」怪兽召唤·特殊召唤成功时对方不能发动效果的限制。
function c44843954.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 显示选择提示：请玩家选择要加入手卡的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组选择1张满足c44843954.filter的「妮穆蕾莉娅」怪兽。
	local g=Duel.SelectMatchingCard(tp,c44843954.filter,tp,LOCATION_DECK,0,1,1,nil)
	if #g==0 then return end
	-- 将选中的卡以效果原因加入其持有者的手卡。
	Duel.SendtoHand(g,nil,REASON_EFFECT)
	-- 将加入手卡的卡展示给对方玩家确认。
	Duel.ConfirmCards(1-tp,g)
	if g:GetFirst():IsLocation(LOCATION_HAND)
		-- 确认检索的卡仍存在于手卡，并且己方额外卡组存在表侧表示的「梦见之妮穆蕾莉娅」（卡号70155677）。
		and Duel.IsExistingMatchingCard(aux.AND(Card.IsFaceup,Card.IsCode),tp,LOCATION_EXTRA,0,1,nil,70155677) then
		-- 中断当前效果处理，使后续追加的“对方不能发动效果”限制作为独立处理生效，避免错过时点。
		Duel.BreakEffect()
		-- 展示「梦见之妮穆蕾莉娅」的卡片动画，用于提示追加效果的适用。
		Duel.Hint(HINT_CARD,0,70155677)
		local c=e:GetHandler()
		-- 再在这个回合在「妮穆蕾莉娅」怪兽的召唤·特殊召唤成功时让对方不能把魔法·陷阱·怪兽的效果发动。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_SUMMON_SUCCESS)
		e1:SetCondition(c44843954.sumcon)
		e1:SetOperation(c44843954.sumsuc)
		e1:SetReset(RESET_PHASE+PHASE_END)
		-- 将“通常召唤成功时”的连续效果注册到场上，用于监测「妮穆蕾莉娅」怪兽的通常召唤。
		Duel.RegisterEffect(e1,tp)
		local e2=e1:Clone()
		e2:SetCode(EVENT_SPSUMMON_SUCCESS)
		-- 将“特殊召唤成功时”的连续效果注册到场上，用于监测「妮穆蕾莉娅」怪兽的特殊召唤。
		Duel.RegisterEffect(e2,tp)
		-- 再在这个回合在「妮穆蕾莉娅」怪兽的召唤·特殊召唤成功时让对方不能把魔法·陷阱·怪兽的效果发动。
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e3:SetCode(EVENT_CHAIN_END)
		e3:SetOperation(c44843954.limop2)
		-- 注册“连锁结束时”的连续效果，用于在连锁结束后根据标记重新施加/维持“对方不能发动效果”的限制。
		Duel.RegisterEffect(e3,tp)
	end
end
-- 判断召唤/特殊召唤的怪兽是否为表侧表示且属于「妮穆蕾莉娅」系列（0x191）。
function c44843954.sumfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x191)
end
-- 监测条件：召唤/特殊召唤成功的怪兽中存在至少1只表侧表示的「妮穆蕾莉娅」怪兽。
function c44843954.sumcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c44843954.sumfilter,1,nil)
end
-- 召唤/特殊召唤成功时的处理：若当前不在连锁中，直接设置“直到连锁结束仅己方可发动效果”的限制；若当前为连锁1，则记录标记并注册重置标记的效果，以便在连锁结束后再次施加限制。
function c44843954.sumsuc(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前是否没有正在处理的连锁（即召唤成功不是连锁处理的一部分）。
	if Duel.GetCurrentChain()==0 then
		-- 设置直到连锁结束的连锁限制：只允许己方发动效果，从而让对方不能发动魔法·陷阱·怪兽效果。
		Duel.SetChainLimitTillChainEnd(c44843954.chainlm)
	-- 如果当前正处于连锁1，说明召唤成功发生在连锁处理中，需要延迟到连锁结束再施加限制。
	elseif Duel.GetCurrentChain()==1 then
		-- 为己方玩家注册标记，表示在本连锁结束后需要追加“对方不能发动效果”的限制，该标记会在阶段结束时重置。
		Duel.RegisterFlagEffect(tp,44843954,RESET_PHASE+PHASE_END,0,1)
		-- 再在这个回合在「妮穆蕾莉娅」怪兽的召唤·特殊召唤成功时让对方不能把魔法·陷阱·怪兽的效果发动。②：让墓地的这张卡回到卡组最下面，以自己场上1张「梦见之妮穆蕾莉娅」为对象才能发动。那张卡表侧表示加入持有者的额外卡组。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_CHAINING)
		e1:SetOperation(c44843954.resetop)
		-- 注册“连锁中”的连续效果：当对方连锁发动效果时，清除后续需要追加限制的标记，因为当前限制已直接生效。
		Duel.RegisterEffect(e1,tp)
		local e2=e1:Clone()
		e2:SetCode(EVENT_BREAK_EFFECT)
		e2:SetReset(RESET_CHAIN)
		-- 注册“效果中断”时的连续效果：连锁被中断时同样清除标记，避免残留。
		Duel.RegisterEffect(e2,tp)
	end
end
-- 重置标记并自我消除：当发生新的效果发动或效果中断时，清除“需要追加限制”的标记。
function c44843954.resetop(e,tp,eg,ep,ev,re,r,rp)
	-- 清除己方玩家身上的“需要追加限制”标记。
	Duel.ResetFlagEffect(tp,44843954)
	e:Reset()
end
-- 连锁结束时的处理：若标记仍存在，则重新设置“只允许己方发动效果”的连锁限制，然后清除标记。
function c44843954.limop2(e,tp,eg,ep,ev,re,r,rp)
	-- 检查是否存在“需要追加限制”的标记。
	if Duel.GetFlagEffect(tp,44843954)>0 then
		-- 设置连锁限制：只允许己方发动效果，使对方不能发动魔法·陷阱·怪兽效果。
		Duel.SetChainLimitTillChainEnd(c44843954.chainlm)
	end
	-- 清除标记，表示限制已施加完毕。
	Duel.ResetFlagEffect(tp,44843954)
end
-- 连锁限制条件：效果发动者必须为己方（tp），即对方无法发动效果。
function c44843954.chainlm(e,ep,tp)
	return ep==tp
end
-- ②效果的发动代价：将墓地的这张卡返回卡组最下面作为代价。
function c44843954.mvcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToDeckAsCost() end
	-- 将墓地的这张卡以代价原因返回持有者卡组最底部。
	Duel.SendtoDeck(c,nil,SEQ_DECKBOTTOM,REASON_COST)
end
-- 对象筛选：己方场上表侧表示的「梦见之妮穆蕾莉娅」灵摆怪兽，且能够表侧加入额外卡组。
function c44843954.mvfilter(c)
	return c:IsFaceup() and c:IsCode(70155677) and c:IsType(TYPE_PENDULUM) and c:IsAbleToExtra()
end
-- ②效果发动时的取对象处理：从己方场上选择1张符合条件的「梦见之妮穆蕾莉娅」作为对象，并设置将其加入额外卡组的操作信息。
function c44843954.mvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c44843954.mvfilter(chkc) end
	-- 发动合法性检查：己方场上存在至少1张可成为对象的「梦见之妮穆蕾莉娅」。
	if chk==0 then return Duel.IsExistingTarget(c44843954.mvfilter,tp,LOCATION_ONFIELD,0,1,nil) end
	-- 显示选择提示：请选择效果的对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 从己方场上选择1张符合条件的「梦见之妮穆蕾莉娅」作为效果对象（自动建立对象联系）。
	local g=Duel.SelectTarget(tp,c44843954.mvfilter,tp,LOCATION_ONFIELD,0,1,1,nil)
	-- 设置操作信息：本次效果处理将对象卡加入额外卡组（CATEGORY_TOEXTRA）。
	Duel.SetOperationInfo(0,CATEGORY_TOEXTRA,g,1,0,0)
end
-- ②效果处理：取得仍与效果关联的对象卡，并将其表侧表示加入持有者的额外卡组。
function c44843954.mvop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果处理时的对象卡（应为发动时选择的「梦见之妮穆蕾莉娅」）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象卡以效果原因表侧表示加入其持有者的额外卡组。
		Duel.SendtoExtraP(tc,nil,REASON_EFFECT)
	end
end
