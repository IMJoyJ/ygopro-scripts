--亡龍の戦慄－デストルドー
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：这张卡在手卡·墓地存在的场合，把基本分支付一半，以自己场上1只6星以下的怪兽为对象才能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡等级下降作为对象的怪兽的等级数值，从场上离开的场合回到卡组最下面。
function c5560911.initial_effect(c)
	-- ①：这张卡在手卡·墓地存在的场合，把基本分支付一半，以自己场上1只6星以下的怪兽为对象才能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡等级下降作为对象的怪兽的等级数值，从场上离开的场合回到卡组最下面。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(5560911,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetCountLimit(1,5560911)
	e1:SetCost(c5560911.cost)
	e1:SetTarget(c5560911.target)
	e1:SetOperation(c5560911.operation)
	c:RegisterEffect(e1)
end
-- 效果发动的Cost处理函数（支付一半基本分）
function c5560911.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 支付一半的基本分
	Duel.PayLPCost(tp,math.floor(Duel.GetLP(tp)/2))
end
-- 过滤自己场上表侧表示且等级在6星以下的怪兽
function c5560911.filter(c)
	return c:IsFaceup() and c:IsLevelBelow(6)
end
-- 效果发动的Target处理函数（检查发动条件并选择对象）
function c5560911.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c5560911.filter(chkc) end
	-- 检查自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查自己场上是否存在可作为对象的6星以下怪兽
		and Duel.IsExistingTarget(c5560911.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择表侧表示的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择自己场上1只表侧表示且等级在6星以下的怪兽作为效果对象
	Duel.SelectTarget(tp,c5560911.filter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置效果处理信息为特殊召唤自身
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 效果处理的Operation函数（特殊召唤、等级下降、离场回卡组底部）
function c5560911.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取作为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) then
		-- 尝试将这张卡以表侧表示特殊召唤
		if Duel.SpecialSummonStep(c,0,tp,tp,false,false,POS_FACEUP) then
			if tc:IsRelateToEffect(e) and tc:IsFaceup() then
				local lv=tc:GetLevel()
				-- 这个效果特殊召唤的这张卡等级下降作为对象的怪兽的等级数值
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_UPDATE_LEVEL)
				e1:SetValue(-lv)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
				c:RegisterEffect(e1)
			end
			-- 从场上离开的场合回到卡组最下面
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
			e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e2:SetReset(RESET_EVENT+RESETS_REDIRECT)
			e2:SetValue(LOCATION_DECKBOT)
			c:RegisterEffect(e2)
		end
		-- 完成特殊召唤的后续处理
		Duel.SpecialSummonComplete()
	end
end
