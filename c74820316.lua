--宵星の騎士エンリルギルス
-- 效果：
-- 包含「自奏圣乐」连接怪兽的怪兽2只以上
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：以自己的除外状态的1张「自奏圣乐」卡或「星遗物」卡为对象才能发动。那张卡加入手卡。那之后，可以选自己1张手卡回到卡组并得到对方场上1只表侧表示怪兽的控制权。
-- ②：这张卡从额外怪兽区域送去墓地的回合的自己主要阶段，把这张卡除外才能发动。场上1张卡送去墓地。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数
function s.initial_effect(c)
	-- 添加连接召唤手续：怪兽2只以上，其中必须包含「自奏圣乐」连接怪兽
	aux.AddLinkProcedure(c,nil,2,99,s.lcheck)
	c:EnableReviveLimit()
	-- ②：这张卡从额外怪兽区域送去墓地的回合
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e0:SetCode(EVENT_TO_GRAVE)
	e0:SetCondition(s.regcon)
	e0:SetOperation(s.regop)
	c:RegisterEffect(e0)
	-- ①：以自己的除外状态的1张「自奏圣乐」卡或「星遗物」卡为对象才能发动。那张卡加入手卡。那之后，可以选自己1张手卡回到卡组并得到对方场上1只表侧表示怪兽的控制权。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"回收&得到控制权"
	e1:SetCategory(CATEGORY_TOHAND|CATEGORY_TODECK|CATEGORY_CONTROL)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.thcon1)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCondition(s.thcon2)
	c:RegisterEffect(e2)
	-- ②：这张卡从额外怪兽区域送去墓地的回合的自己主要阶段，把这张卡除外才能发动。场上1张卡送去墓地。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"送墓"
	e3:SetCategory(CATEGORY_TOGRAVE)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,id+o)
	e3:SetHintTiming(0,TIMING_END_PHASE)
	e3:SetCondition(s.tgcon1)
	-- 设置效果的发动成本：把墓地的这张卡除外
	e3:SetCost(aux.bfgcost)
	e3:SetTarget(s.tgtg)
	e3:SetOperation(s.tgop)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetCondition(s.tgcon2)
	c:RegisterEffect(e4)
end
-- 过滤条件：属于「自奏圣乐」系列的连接怪兽
function s.lfilter(c)
	return c:IsLinkType(TYPE_LINK) and c:IsLinkSetCard(0x11b)
end
-- 连接素材检查：素材组中必须存在至少1只满足过滤条件的怪兽
function s.lcheck(g)
	return g:IsExists(s.lfilter,1,nil)
end
-- 送墓时效果注册条件：从额外怪兽区域（序号大于4）送去墓地
function s.regcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:GetPreviousSequence()>4 and c:IsPreviousLocation(LOCATION_MZONE)
end
-- 送墓时效果注册处理：给自身注册一个持续到回合结束的Flag，用于标记该回合从额外怪兽区域送去墓地
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
end
-- 效果①起动效果版本的发动条件：场上不存在能让该效果变为即时效果的卡
function s.thcon1(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前是否不满足将效果转变为即时效果的条件（即只能在自己主要阶段作为起动效果发动）
	return not aux.IsCanBeQuickEffect(e:GetHandler(),tp,90351981)
end
-- 效果①即时效果版本的发动条件：场上存在能让该效果变为即时效果的卡
function s.thcon2(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前是否满足将效果转变为即时效果的条件（即可以在对方回合作为诱发即时效果发动）
	return aux.IsCanBeQuickEffect(e:GetHandler(),tp,90351981)
end
-- 回收对象过滤条件：除外状态的「自奏圣乐」卡或「星遗物」卡
function s.thfilter(c)
	return c:IsSetCard(0x11b,0xfe) and c:IsAbleToHand() and c:IsFaceupEx()
end
-- 控制权转移对象过滤条件：对方场上表侧表示且可以转移控制权的怪兽
function s.gcfilter2(c)
	return c:IsFaceup() and c:IsControlerCanBeChanged()
end
-- 效果①的发动准备：选择除外状态的目标卡，并设置回收手牌和回卡组的操作信息
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_REMOVED) and s.thfilter(chkc) end
	-- 检查自己除外状态是否存在至少1张满足条件的卡
	if chk==0 then return Duel.IsExistingTarget(s.thfilter,tp,LOCATION_REMOVED,0,1,nil) end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择除外状态的1张满足条件的卡作为效果对象
	local g=Duel.SelectTarget(tp,s.thfilter,tp,LOCATION_REMOVED,0,1,1,nil)
	-- 设置操作信息：将选中的除外卡片加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,LOCATION_REMOVED)
	-- 设置操作信息：将1张手牌送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,0,LOCATION_HAND)
end
-- 效果①的效果处理：将对象卡加入手牌，之后可选择让1张手牌回到卡组并夺取对方怪兽控制权
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果发动的对象卡
	local tc=Duel.GetFirstTarget()
	-- 若对象卡仍适用此效果，则将其加入手牌，并确认成功加入
	if tc:IsRelateToEffect(e) and Duel.SendtoHand(tc,nil,REASON_EFFECT)>0
		and tc:IsLocation(LOCATION_HAND)
		-- 检查自己手牌中是否存在可以送回卡组的卡
		and Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,LOCATION_HAND,0,1,nil)
		-- 检查对方场上是否存在可以夺取控制权的表侧表示怪兽
		and Duel.IsExistingMatchingCard(s.gcfilter2,tp,0,LOCATION_MZONE,1,nil)
		-- 询问玩家是否选择执行后续的“手牌回卡组并夺取控制权”效果
		and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否要得到对方怪兽的控制权？"
		-- 提示玩家选择要送回卡组的手牌
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
		-- 玩家选择1张手牌送回卡组
		local g=Duel.SelectMatchingCard(tp,Card.IsAbleToDeck,tp,LOCATION_HAND,0,1,1,nil)
		-- 洗切玩家的手牌
		Duel.ShuffleHand(tp)
		-- 中断效果处理，使后续的送回卡组与夺取控制权不与加入手牌视为同时处理
		Duel.BreakEffect()
		-- 若成功将选中的手牌送回卡组并洗卡组
		if #g>0 and Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)~=0 then
			-- 提示玩家选择要夺取控制权的怪兽
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
			-- 玩家选择对方场上1只表侧表示怪兽
			local cg=Duel.SelectMatchingCard(tp,s.gcfilter2,tp,0,LOCATION_MZONE,1,1,nil)
			if cg:GetCount()>0 then
				-- 为选中的怪兽显示被选择的动画效果
				Duel.HintSelection(cg)
				-- 夺取该怪兽的控制权
				Duel.GetControl(cg:GetFirst(),tp)
			end
		end
	end
end
-- 效果②起动效果版本的发动条件：本回合从额外怪兽区域送去墓地，且场上不存在能让该效果变为即时效果的卡
function s.tgcon1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查自身是否带有送墓标记，且当前不满足将效果转变为即时效果的条件
	return c:GetFlagEffect(id)~=0 and not aux.IsCanBeQuickEffect(c,tp,90351981)
end
-- 效果②即时效果版本的发动条件：本回合从额外怪兽区域送去墓地，且场上存在能让该效果变为即时效果的卡
function s.tgcon2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查自身是否带有送墓标记，且当前满足将效果转变为即时效果的条件
	return c:GetFlagEffect(id)~=0 and aux.IsCanBeQuickEffect(c,tp,90351981)
end
-- 效果②的发动准备：检查场上是否有卡可以送去墓地，并设置送墓的操作信息
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上（双方场上）是否存在至少1张可以送去墓地的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToGrave,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 设置操作信息：将场上的1张卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,0,0)
end
-- 效果②的效果处理：选择场上1张卡送去墓地
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 玩家选择场上1张可以送去墓地的卡
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToGrave,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	if g:GetCount()>0 then
		-- 为选中的卡片显示被选择的动画效果
		Duel.HintSelection(g)
		-- 将选中的卡送去墓地
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
