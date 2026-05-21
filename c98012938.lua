--獣神ヴァルカン
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 这个卡名的效果1回合只能使用1次。
-- ①：这张卡同调召唤的场合，以自己以及对方场上的表侧表示卡各1张为对象发动。那些自己以及对方的表侧表示卡回到手卡。这个回合，自己不能把这个效果回到手卡的卡以及那些同名卡的效果发动。
function c98012938.initial_effect(c)
	-- 添加同调召唤手续：调整+调整以外的怪兽1只以上
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ①：这张卡同调召唤的场合，以自己以及对方场上的表侧表示卡各1张为对象发动。那些自己以及对方的表侧表示卡回到手卡。这个回合，自己不能把这个效果回到手卡的卡以及那些同名卡的效果发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(98012938,0))  --"返回手牌"
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,98012938)
	e1:SetCondition(c98012938.condition)
	e1:SetTarget(c98012938.target)
	e1:SetOperation(c98012938.operation)
	c:RegisterEffect(e1)
end
-- 判定发动条件：这张卡同调召唤成功
function c98012938.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- 过滤条件：场上表侧表示且可以回到手牌的卡
function c98012938.filter(c)
	return c:IsFaceup() and c:IsAbleToHand()
end
-- 判定是否能选择对象，并选择自己和对方场上各1张表侧表示的卡作为对象，设置操作信息为回到手牌
function c98012938.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then return true end
	-- 检查自己场上是否存在至少1张满足过滤条件的表侧表示卡
	if Duel.IsExistingTarget(c98012938.filter,tp,LOCATION_ONFIELD,0,1,nil)
		-- 检查对方场上是否存在至少1张满足过滤条件的表侧表示卡
		and Duel.IsExistingTarget(c98012938.filter,tp,0,LOCATION_ONFIELD,1,nil) then
		-- 提示玩家选择要返回手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
		-- 选择自己场上1张表侧表示的卡作为效果对象
		local g1=Duel.SelectTarget(tp,c98012938.filter,tp,LOCATION_ONFIELD,0,1,1,nil)
		-- 提示玩家选择要返回手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
		-- 选择对方场上1张表侧表示的卡作为效果对象
		local g2=Duel.SelectTarget(tp,c98012938.filter,tp,0,LOCATION_ONFIELD,1,1,nil)
		g1:Merge(g2)
		-- 设置操作信息：将选中的2张卡送回手牌
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,g1,2,0,0)
	end
end
-- 过滤条件：仍与该效果相关联且在场上表侧表示的对象卡
function c98012938.hfilter(c,e)
	return c:IsRelateToEffect(e) and c:IsFaceup()
end
-- 效果处理：将作为对象的卡送回手牌，并对回到手牌的卡及其同名卡施加本回合不能发动效果的限制
function c98012938.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中被选为对象的卡片组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	if not g then return end
	g=g:Filter(c98012938.hfilter,nil,e)
	if g:GetCount()>0 then
		-- 因效果将目标卡片组送回持有者手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		local tc=g:GetFirst()
		while tc do
			if tc:IsLocation(LOCATION_HAND) then
				-- 这个回合，自己不能把这个效果回到手卡的卡以及那些同名卡的效果发动。
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_FIELD)
				e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
				e1:SetCode(EFFECT_CANNOT_ACTIVATE)
				e1:SetTargetRange(1,0)
				e1:SetValue(c98012938.aclimit)
				e1:SetLabel(tc:GetCode())
				e1:SetReset(RESET_PHASE+PHASE_END)
				-- 向玩家注册该不能发动效果的限制
				Duel.RegisterEffect(e1,tp)
			end
			tc=g:GetNext()
		end
	end
end
-- 限制条件：禁止发动与被送回手牌的卡同名的卡的效果
function c98012938.aclimit(e,re,tp)
	return re:GetHandler():IsCode(e:GetLabel())
end
