--覚醒の三幻魔
-- 效果：
-- ①：得到自己场上的「神炎皇 乌利亚」「降雷皇 哈蒙」「幻魔皇 拉比艾尔」种类数量的以下效果。
-- ●1种类以上：每次对方对怪兽的召唤·特殊召唤成功，自己回复那些怪兽的攻击力数值的基本分。
-- ●2种类以上：对方场上的怪兽发动的效果无效化。
-- ●3种类：被送去对方墓地的怪兽不去墓地而除外。
-- ②：自己回合1次，自己场上有10星怪兽存在的场合才能发动。从自己墓地选1张永续陷阱卡加入手卡。
function c53701259.initial_effect(c)
	-- 将本卡效果记载的三幻魔「神炎皇 乌利亚」「降雷皇 哈蒙」「幻魔皇 拉比艾尔」的卡号加入卡片代码列表，用于后续判断场上是否存在这些卡。
	aux.AddCodeList(c,6007213,32491822,69890967)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ●1种类以上：每次对方对怪兽的召唤·特殊召唤成功，自己回复那些怪兽的攻击力数值的基本分。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_SZONE)
	e2:SetLabel(1)
	e2:SetCondition(c53701259.lpcon)
	e2:SetOperation(c53701259.lpop1)
	c:RegisterEffect(e2)
	-- ●1种类以上：每次对方对怪兽的召唤·特殊召唤成功，自己回复那些怪兽的攻击力数值的基本分。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetRange(LOCATION_SZONE)
	e3:SetLabel(1)
	e3:SetCondition(c53701259.lpcon1)
	e3:SetOperation(c53701259.lpop1)
	c:RegisterEffect(e3)
	-- ●1种类以上：每次对方对怪兽的召唤·特殊召唤成功，自己回复那些怪兽的攻击力数值的基本分。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e4:SetRange(LOCATION_SZONE)
	e4:SetLabel(1)
	e4:SetCondition(c53701259.regcon)
	e4:SetOperation(c53701259.regop)
	c:RegisterEffect(e4)
	-- ●1种类以上：每次对方对怪兽的召唤·特殊召唤成功，自己回复那些怪兽的攻击力数值的基本分。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e5:SetCode(EVENT_CHAIN_SOLVED)
	e5:SetRange(LOCATION_SZONE)
	e5:SetCondition(c53701259.lpcon2)
	e5:SetOperation(c53701259.lpop2)
	e5:SetLabelObject(e4)
	c:RegisterEffect(e5)
	-- ●2种类以上：对方场上的怪兽发动的效果无效化。
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e6:SetCode(EVENT_CHAIN_SOLVING)
	e6:SetRange(LOCATION_SZONE)
	e6:SetLabel(2)
	e6:SetCondition(c53701259.discon)
	e6:SetOperation(c53701259.disop)
	c:RegisterEffect(e6)
	-- ●3种类：被送去对方墓地的怪兽不去墓地而除外。
	local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_FIELD)
	e7:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_RANGE+EFFECT_FLAG_IGNORE_IMMUNE)
	e7:SetCode(EFFECT_TO_GRAVE_REDIRECT)
	e7:SetRange(LOCATION_SZONE)
	e7:SetValue(LOCATION_REMOVED)
	e7:SetTargetRange(0,LOCATION_DECK)
	e7:SetTarget(c53701259.rmtg)
	e7:SetCondition(c53701259.rmcon)
	c:RegisterEffect(e7)
	-- ②：自己回合1次，自己场上有10星怪兽存在的场合才能发动。从自己墓地选1张永续陷阱卡加入手卡。
	local e8=Effect.CreateEffect(c)
	e8:SetDescription(aux.Stringid(53701259,0))
	e8:SetCategory(CATEGORY_TOHAND)
	e8:SetType(EFFECT_TYPE_QUICK_O)
	e8:SetCode(EVENT_FREE_CHAIN)
	e8:SetRange(LOCATION_SZONE)
	e8:SetCountLimit(1)
	e8:SetCost(c53701259.thcon)
	e8:SetTarget(c53701259.thtg)
	e8:SetOperation(c53701259.thop)
	c:RegisterEffect(e8)
end
-- 定义过滤器：判断卡是否为表侧表示且卡号为三幻魔之一。
function c53701259.filter(c)
	return c:IsFaceup() and c:IsCode(6007213,32491822,69890967)
end
-- 定义过滤器：判断怪兽是否由指定玩家sp召唤/特殊召唤成功且表侧表示。
function c53701259.cfilter(c,sp)
	return c:IsSummonPlayer(sp) and c:IsFaceup()
end
-- 通用条件：获取自己场上表侧表示的三幻魔种类数，并判断是否大于等于效果标签中存储的所需种类数（1、2或3）。
function c53701259.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上表侧表示的三幻魔怪兽集合。
	local g=Duel.GetMatchingGroup(c53701259.filter,tp,LOCATION_ONFIELD,0,nil)
	local ct=e:GetLabel()
	return ct and g:GetClassCount(Card.GetCode)>=ct
end
-- 通常召唤成功时的触发条件：达成①的1种类以上条件，且对方那组怪兽中存在由对方召唤成功并表侧表示的怪兽。
function c53701259.lpcon(e,tp,eg,ep,ev,re,r,rp)
	return c53701259.condition(e,tp,eg,ep,ev,re,r,rp)
		and eg:IsExists(c53701259.cfilter,1,nil,1-tp)
end
-- 特殊召唤成功时的触发条件：达成①的1种类以上条件且对方特殊召唤成功，并且当前不在连锁处理中（避免重复触发）。
function c53701259.lpcon1(e,tp,eg,ep,ev,re,r,rp)
	return c53701259.lpcon(e,tp,eg,ep,ev,re,r,rp)
		-- 当前没有连锁正在处理，作为特殊召唤成功回血效果不重复触发的判定。
		and not Duel.IsChainSolving()
end
-- 回血操作：取出对方召唤/特殊召唤成功的表侧表示怪兽组，计算其攻击力总和，然后让本卡控制者回复该数值的LP。
function c53701259.lpop1(e,tp,eg,ep,ev,re,r,rp)
	local lg=eg:Filter(c53701259.cfilter,nil,1-tp)
	local rnum=lg:GetSum(Card.GetAttack)
	-- 实际执行LP回复，回复数值为对方召唤/特殊召唤成功的怪兽攻击力合计。
	Duel.Recover(tp,rnum,REASON_EFFECT)
end
-- 特殊召唤成功且正处于连锁处理中时的触发条件：达成①的1种类以上条件且对方特殊召唤成功。
function c53701259.regcon(e,tp,eg,ep,ev,re,r,rp)
	return c53701259.lpcon(e,tp,eg,ep,ev,re,r,rp)
		-- 当前有连锁正在处理，需要延迟到连锁处理结束时统一回血。
		and Duel.IsChainSolving()
end
-- 延迟处理：将本次对方特殊召唤成功的怪兽组保存起来（若已有保存怪兽则合并），并给本卡设置标记，表示有未处理的回血。
function c53701259.regop(e,tp,eg,ep,ev,re,r,rp)
	local lg=eg:Filter(c53701259.cfilter,nil,1-tp)
	local g=e:GetLabelObject()
	if g==nil or #g==0 then
		lg:KeepAlive()
		e:SetLabelObject(lg)
	else
		g:Merge(lg)
	end
	e:GetHandler():RegisterFlagEffect(53701259,RESET_EVENT+RESETS_STANDARD+RESET_CHAIN,0,1)
end
-- 判断是否存在延迟回血的标记（即是否有待处理的特殊召唤成功怪兽）。
function c53701259.lpcon2(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(53701259)>0
end
-- 连锁结束后的统一回血：清除标记，取出保存的怪兽组，计算攻击力总和并回复LP，然后清空保存的怪兽组。
function c53701259.lpop2(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():ResetFlagEffect(53701259)
	local lg=e:GetLabelObject():GetLabelObject()
	local rnum=lg:GetSum(Card.GetAttack)
	local g=Group.CreateGroup()
	g:KeepAlive()
	e:GetLabelObject():SetLabelObject(g)
	lg:DeleteGroup()
	-- 实际执行LP回复，回复数值为连锁期间对方特殊召唤成功的怪兽攻击力合计。
	Duel.Recover(tp,rnum,REASON_EFFECT)
end
-- 无效化效果的发动条件：自己场上三幻魔种类数达到2，且当前连锁上发动的效果是对方怪兽在怪兽区域发动的怪兽效果。
function c53701259.discon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中触发效果的发生位置，用于判断是否为怪兽区域。
	local loc=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)
	return c53701259.condition(e,tp,eg,ep,ev,re,r,rp)
		and re:IsActiveType(TYPE_MONSTER) and loc==LOCATION_MZONE and rp==1-tp
end
-- 无效化操作：将当前连锁上对方怪兽发动的效果无效化。
function c53701259.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 执行无效化，使对方怪兽发动的效果无效。
	Duel.NegateEffect(ev)
end
-- 除外效果的目标过滤：判定要送去墓地的卡是否属于对方（卡片持有者不是本卡控制者），且满足次元裂缝判断（原类型为怪兽且不因超量素材或作为魔陷使用而送去墓地）。
function c53701259.rmtg(e,c)
	-- 判断卡片应被除外而非送去墓地：所有者不是本卡控制者且符合次元裂缝的除外条件。
	return c:GetOwner()~=e:GetHandlerPlayer() and aux.DimensionalFissureTarget(e,c)
end
-- 除外效果的发动条件：自己场上表侧表示存在三幻魔各1种类（即种类数为3）。
function c53701259.rmcon(e)
	local tp=e:GetHandlerPlayer()
	-- 获取自己场上表侧表示的三幻魔怪兽集合，用于计算种类数。
	local g=Duel.GetMatchingGroup(c53701259.filter,tp,LOCATION_ONFIELD,0,nil)
	return g:GetClassCount(Card.GetCode)==3
end
-- 定义过滤器：判断怪兽是否为表侧表示且等级为10。
function c53701259.ffilter(c)
	return c:IsFaceup() and c:IsLevel(10)
end
-- ②效果的发动条件：自己回合且自己场上有表侧表示10星怪兽存在。
function c53701259.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上有表侧表示10星怪兽且当前是本人回合。
	return Duel.IsExistingMatchingCard(c53701259.ffilter,tp,LOCATION_MZONE,0,1,nil) and Duel.GetTurnPlayer()==tp
end
-- 定义过滤器：判断墓地的卡是否为永续陷阱卡且能够加入手卡。
function c53701259.thfilter(c)
	return c:IsType(TYPE_CONTINUOUS) and c:IsType(TYPE_TRAP) and c:IsAbleToHand()
end
-- ②效果发动时的目标设定：检查墓地存在符合条件的永续陷阱卡，并设置要将1张墓地永续陷阱加入手卡的操作信息。
function c53701259.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时检查：自己墓地是否存在至少1张符合条件的永续陷阱卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c53701259.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 设置操作信息，声明本次效果将进行把墓地卡加入手卡的处理。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
-- ②效果的处理：玩家从自己墓地选择1张永续陷阱卡加入手卡，并让对方确认所选卡。
function c53701259.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 弹出选择卡片的提示消息，提示玩家选择要加入手卡的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从自己墓地的符合条件的永续陷阱卡中选择1张（使用王家长眠之谷过滤，避免受其影响无法移动的卡）。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c53701259.thfilter),tp,LOCATION_GRAVE,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入持有者手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手卡的卡展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
	end
end
