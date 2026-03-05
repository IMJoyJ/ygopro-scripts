--E・HERO カオス・ネオス
-- 效果：
-- 「元素英雄 新宇侠」＋「新空间侠·黑暗豹」＋「新空间侠·光辉青苔」
-- 把自己场上存在的上记的卡回到卡组的场合才能从融合卡组特殊召唤（不需要「融合」魔法卡）。结束阶段时这张卡回到融合卡组，场上存在的全部表侧表示怪兽变成盖放的状态。进行3次投掷硬币，进行表出现次数的以下处理。这个效果1回合只有1次在自己的主要阶段1才能使用。
-- ●3次：对方场上存在的全部怪兽破坏。
-- ●2次：这个回合对方场上表侧表示存在的效果怪兽全部效果无效化。
-- ●1次：自己场上存在的全部怪兽回到持有者手卡。
function c17032740.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加融合召唤手续，使用卡号为89943723,43237273,17732278的3只怪兽为融合素材
	aux.AddFusionProcCode3(c,89943723,43237273,17732278,false,false)
	-- 添加接触融合特殊召唤规则，要求自己场上存在的怪兽返回卡组或额外卡组作为召唤条件
	aux.AddContactFusionProcedure(c,Card.IsAbleToDeckOrExtraAsCost,LOCATION_ONFIELD,0,aux.ContactFusionSendToDeck(c))
	-- 设置特殊召唤条件，限制只能从额外卡组特殊召唤
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(c17032740.splimit)
	c:RegisterEffect(e1)
	-- 为卡片注册结束阶段返回卡组效果，使该卡在结束阶段回到融合卡组并使场上表侧表示怪兽变为盖放状态
	aux.EnableNeosReturn(c,c17032740.retop,CATEGORY_MSET)
	-- 设置投掷硬币效果，该效果只能在主要阶段1发动，投掷3次硬币并根据结果执行不同处理
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(17032740,1))  --"投掷硬币"
	e5:SetCategory(CATEGORY_COIN+CATEGORY_DESTROY+CATEGORY_TOHAND)
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCountLimit(1)
	e5:SetCondition(c17032740.coincon)
	e5:SetTarget(c17032740.cointg)
	e5:SetOperation(c17032740.coinop)
	c:RegisterEffect(e5)
end
c17032740.material_setcode=0x8
-- 限制该卡只能从额外卡组特殊召唤，不能从手牌或场上特殊召唤
function c17032740.splimit(e,se,sp,st)
	return not e:GetHandler():IsLocation(LOCATION_EXTRA)
end
-- 结束阶段返回卡组并使场上表侧表示怪兽变为盖放状态
function c17032740.retop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	-- 将该卡返回卡组并洗牌
	Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	if c:IsLocation(LOCATION_EXTRA) then
		-- 获取场上所有表侧表示怪兽的卡片组
		local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
		-- 将指定的怪兽组全部变为盖放状态
		Duel.ChangePosition(g,POS_FACEDOWN_DEFENSE)
	end
end
-- 设置效果发动条件，限制只能在主要阶段1发动
function c17032740.coincon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前阶段是否为主要阶段1
	return Duel.GetCurrentPhase()==PHASE_MAIN1
end
-- 设置效果的发动目标，准备投掷3次硬币
function c17032740.cointg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁操作信息，表示将进行3次硬币投掷
	Duel.SetOperationInfo(0,CATEGORY_COIN,nil,0,tp,3)
end
-- 执行投掷硬币效果，根据硬币结果执行破坏、无效化或回手处理
function c17032740.coinop(e,tp,eg,ep,ev,re,r,rp)
	-- 投掷3次硬币，返回3个结果（0或1）
	local c1,c2,c3=Duel.TossCoin(tp,3)
	if c1+c2+c3==3 then
		-- 获取对方场上所有怪兽的卡片组
		local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
		-- 以效果原因破坏指定的怪兽组
		Duel.Destroy(g,REASON_EFFECT)
	elseif c1+c2+c3==2 then
		-- 获取对方场上所有表侧表示怪兽的卡片组
		local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
		local c=e:GetHandler()
		local tc=g:GetFirst()
		while tc do
			-- 为指定怪兽添加效果无效化效果
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e1)
			-- 为指定怪兽添加效果无效化效果
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e2)
			tc=g:GetNext()
		end
	elseif c1+c2+c3==1 then
		-- 获取自己场上所有可以送入手牌的怪兽的卡片组
		local g=Duel.GetMatchingGroup(Card.IsAbleToHand,tp,LOCATION_MZONE,0,nil)
		-- 以效果原因将指定的怪兽送入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
	end
end
