--E・HERO カオス・ネオス
-- 效果：
-- 「元素英雄 新宇侠」＋「新空间侠·黑暗豹」＋「新空间侠·光辉青苔」
-- 把自己场上存在的上记的卡回到卡组的场合才能从融合卡组特殊召唤（不需要「融合」魔法卡）。结束阶段时这张卡回到融合卡组，场上存在的全部表侧表示怪兽变成盖放的状态。进行3次投掷硬币，进行表出现次数的以下处理。这个效果1回合只有1次在自己的主要阶段1才能使用。
-- ●3次：对方场上存在的全部怪兽破坏。
-- ●2次：这个回合对方场上表侧表示存在的效果怪兽全部效果无效化。
-- ●1次：自己场上存在的全部怪兽回到持有者手卡。
function c17032740.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加融合召唤所需的特定素材名：「元素英雄 新宇侠」＋「新空间侠·黑暗豹」＋「新空间侠·光辉青苔」
	aux.AddFusionProcCode3(c,89943723,43237273,17732278,false,false)
	-- 添加接触融合的特殊召唤手续：把自己场上存在的上述卡回到卡组的场合才能从额外卡组特殊召唤（不需要「融合」魔法卡）
	aux.AddContactFusionProcedure(c,Card.IsAbleToDeckOrExtraAsCost,LOCATION_ONFIELD,0,aux.ContactFusionSendToDeck(c))
	-- 设置特殊召唤限制：这只怪兽只能用上面写的方法进行特殊召唤
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(c17032740.splimit)
	c:RegisterEffect(e1)
	-- 设置「新宇」系列融合怪兽共通的结束阶段返回额外卡组的效果
	aux.EnableNeosReturn(c,c17032740.retop,c17032740.set_category)
	-- 起动效果：进行3次投掷硬币，根据表侧出现次数进行对应的效果处理
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
-- 特殊召唤条件限制函数：规定只能从额外卡组以外的区域特殊召唤
function c17032740.splimit(e,se,sp,st)
	return not e:GetHandler():IsLocation(LOCATION_EXTRA)
end
-- 设置返回额外卡组效果的分类：包含盖放怪兽的效果（里侧守备表示）
function c17032740.set_category(e,tp,eg,ep,ev,re,r,rp)
	e:SetCategory(CATEGORY_MSET)
end
-- 返回额外卡组以及将场上所有表侧表示怪兽变成里侧守备表示的具体操作函数
function c17032740.retop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	-- 将这张卡返回额外卡组并洗牌
	Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	if c:IsLocation(LOCATION_EXTRA) then
		-- 获取场上所有表侧表示的怪兽
		local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
		-- 将获取的怪兽全部变成里侧守备表示
		Duel.ChangePosition(g,POS_FACEDOWN_DEFENSE)
	end
end
-- 起动效果的发动条件：只能在自己的主要阶段1使用
function c17032740.coincon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前阶段是否为主要阶段1
	return Duel.GetCurrentPhase()==PHASE_MAIN1
end
-- 起动效果的发动目标：设置投掷硬币3次的操作信息
function c17032740.cointg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：投掷3次硬币
	Duel.SetOperationInfo(0,CATEGORY_COIN,nil,0,tp,3)
end
-- 起动效果的效果处理：投掷硬币并根据结果处理破坏对方场上怪兽、无效效果或怪兽回手牌的效果
function c17032740.coinop(e,tp,eg,ep,ev,re,r,rp)
	-- 进行3次投掷硬币
	local c1,c2,c3=Duel.TossCoin(tp,3)
	if c1+c2+c3==3 then
		-- 获取对方场上的全部怪兽
		local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
		-- ●3次：对方场上存在的全部怪兽破坏
		Duel.Destroy(g,REASON_EFFECT)
	elseif c1+c2+c3==2 then
		-- 获取对方场上的表侧表示怪兽
		local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
		local c=e:GetHandler()
		local tc=g:GetFirst()
		while tc do
			-- 在硬币出现2次正面时，使对方场上一只效果怪兽本回合效果无效
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e1)
			-- 在硬币出现2次正面时，使该效果怪兽发动的效果本回合无效
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e2)
			tc=g:GetNext()
		end
	elseif c1+c2+c3==1 then
		-- 获取自己场上可以回到手牌的怪兽
		local g=Duel.GetMatchingGroup(Card.IsAbleToHand,tp,LOCATION_MZONE,0,nil)
		-- ●1次：自己场上存在的全部怪兽回到持有者手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
	end
end
