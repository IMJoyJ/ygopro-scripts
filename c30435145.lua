--古代の機械工場
-- 效果：
-- 选择手卡1张名字带有「古代的机械」的怪兽卡。把墓地中合计为选择的卡2倍等级数量的名字带有「古代的机械」的卡从游戏中除外。选择的卡在这个回合召唤时不需要祭品。
function c30435145.initial_effect(c)
	-- 创建并注册一张永续效果，使此卡可以在自由时点发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c30435145.target)
	e1:SetOperation(c30435145.operation)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于判断手卡中是否存在等级大于等于5且为古代的机械卡组、并且其等级的两倍总和可以在墓地中找到满足条件的卡
function c30435145.filter(c,g)
	return c:IsLevelAbove(5) and c:IsSetCard(0x7) and g:CheckWithSumEqual(Card.GetLevel,c:GetLevel()*2,1,99)
end
-- 过滤函数，用于判断墓地中是否存在等级大于0、为古代的机械卡组且可被除外的卡
function c30435145.rfilter(c)
	return c:GetLevel()>0 and c:IsSetCard(0x7) and c:IsAbleToRemove()
end
-- 效果的发动条件判断，检查手卡中是否存在满足条件的卡，若存在则设置操作信息为除外卡
function c30435145.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 获取玩家墓地中所有满足条件的卡组
		local rg=Duel.GetMatchingGroup(c30435145.rfilter,tp,LOCATION_GRAVE,0,nil)
		-- 检查手卡中是否存在至少一张满足条件的卡
		return Duel.IsExistingMatchingCard(c30435145.filter,tp,LOCATION_HAND,0,1,nil,rg)
	end
	-- 设置操作信息，表示本次效果将要处理从墓地除外的卡
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_GRAVE)
end
-- 效果的处理函数，选择手卡中的卡并处理后续效果
function c30435145.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取玩家墓地中所有满足条件的卡组
	local rg=Duel.GetMatchingGroup(c30435145.rfilter,tp,LOCATION_GRAVE,0,nil)
	-- 提示玩家选择一张名字带有「古代的机械」的怪兽卡
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(30435145,1))  --"请选择一张名字带有「古代的机械」的怪兽卡"
	-- 选择满足条件的手卡中的卡
	local g=Duel.SelectMatchingCard(tp,c30435145.filter,tp,LOCATION_HAND,0,1,1,nil,rg)
	local tc=g:GetFirst()
	if tc then
		-- 确认对方玩家看到所选的卡
		Duel.ConfirmCards(1-tp,tc)
		-- 将玩家手卡洗牌
		Duel.ShuffleHand(tp)
		-- 提示玩家选择要除外的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		local sg=rg:SelectWithSumEqual(tp,Card.GetLevel,tc:GetLevel()*2,1,99)
		-- 将满足条件的卡从游戏中除外
		Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)
		-- 创建并注册一个召唤规则效果，使选择的卡在这个回合召唤时不需要祭品
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(aux.Stringid(30435145,0))  --"不使用解放召唤"
		e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SUMMON_PROC)
		e1:SetCondition(c30435145.ntcon)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
-- 召唤规则效果的条件函数，判断是否满足不使用解放召唤的条件
function c30435145.ntcon(e,c,minc)
	if c==nil then return true end
	-- 判断召唤时是否不需要祭品，条件为：最小祭品数为0、卡等级大于等于5、场上存在空位
	return minc==0 and c:IsLevelAbove(5) and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
end
