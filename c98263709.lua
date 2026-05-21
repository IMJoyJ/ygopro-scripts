--銀河魔鏡士
-- 效果：
-- 反转：自己回复自己墓地的名字带有「银河」的怪兽数量×500基本分。此外，反转过的这张卡被破坏送去墓地时，可以从自己的卡组·墓地选1只4星以下的名字带有「银河」的怪兽里侧守备表示特殊召唤。这个效果特殊召唤的怪兽从场上离开的场合从游戏中除外。
function c98263709.initial_effect(c)
	-- 反转：自己回复自己墓地的名字带有「银河」的怪兽数量×500基本分。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(98263709,0))  --"抽卡"
	e1:SetCategory(CATEGORY_RECOVER)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTarget(c98263709.rectg)
	e1:SetOperation(c98263709.recop)
	c:RegisterEffect(e1)
	-- 反转过的这张卡
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_FLIP)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetOperation(c98263709.flipop)
	c:RegisterEffect(e2)
	-- 此外，反转过的这张卡被破坏送去墓地时，可以从自己的卡组·墓地选1只4星以下的名字带有「银河」的怪兽里侧守备表示特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(98263709,1))  --"特殊召唤并除外"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_MSET)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e3:SetCondition(c98263709.spcon)
	e3:SetTarget(c98263709.sptg)
	e3:SetOperation(c98263709.spop)
	c:RegisterEffect(e3)
end
-- 过滤条件：自己墓地的名字带有「银河」的怪兽
function c98263709.filter(c)
	return c:IsSetCard(0x7b) and c:IsType(TYPE_MONSTER)
end
-- 反转效果的目标处理函数：计算回复数值并设置回复操作信息
function c98263709.rectg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 计算自己墓地名字带有「银河」的怪兽数量乘以500的数值
	local val=Duel.GetMatchingGroupCount(c98263709.filter,tp,LOCATION_GRAVE,0,nil)*500
	-- 设置回复效果的对象玩家为自己
	Duel.SetTargetPlayer(tp)
	-- 设置回复效果的对象参数为计算出的回复数值
	Duel.SetTargetParam(val)
	-- 设置当前连锁的操作信息为回复LP
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,val)
end
-- 反转效果的执行函数：使目标玩家回复对应的基本分
function c98263709.recop(e,tp,eg,ep,ev,re,r,rp)
	-- 重新计算当前自己墓地名字带有「银河」的怪兽数量乘以500的数值
	local val=Duel.GetMatchingGroupCount(c98263709.filter,tp,LOCATION_GRAVE,0,nil)*500
	-- 获取当前连锁设定的目标玩家
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 以效果原因使目标玩家回复计算出的基本分数值
	Duel.Recover(p,val,REASON_EFFECT)
end
-- 反转时为自身注册一个已反转的标记（Flag）
function c98263709.flipop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(98263709,RESET_EVENT+0x57a0000,0,0)
end
-- 特殊召唤效果的发动条件：自身带有已反转标记且是被破坏送去墓地
function c98263709.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(98263709)~=0 and e:GetHandler():IsReason(REASON_DESTROY)
end
-- 过滤条件：4星以下的名字带有「银河」且可以里侧守备表示特殊召唤的怪兽
function c98263709.spfilter(c,e,tp)
	return c:IsSetCard(0x7b) and c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE)
end
-- 特殊召唤效果的目标处理函数：检查怪兽区域空位及是否存在可特召的怪兽，并设置特召操作信息
function c98263709.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己的卡组或墓地是否存在至少1只满足特召条件的怪兽
		and Duel.IsExistingMatchingCard(c98263709.spfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置当前连锁的操作信息为从卡组或墓地特殊召唤1张卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
-- 特殊召唤效果的执行函数：从卡组或墓地选择1只满足条件的怪兽里侧守备表示特殊召唤，并添加离场除外的约束
function c98263709.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否有可用的怪兽区域空格，若无则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 给玩家发送选择要特殊召唤的卡片的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从卡组或墓地选择1只满足特召条件且不受王家之谷影响的怪兽
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c98263709.spfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if not tc then return end
	-- 尝试将选中的怪兽以里侧守备表示特殊召唤到场上
	if Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE) then
		-- 这个效果特殊召唤的怪兽从场上离开的场合从游戏中除外。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		tc:RegisterEffect(e1,true)
		-- 让对方玩家确认里侧守备表示特殊召唤的怪兽
		Duel.ConfirmCards(1-tp,tc)
	end
	-- 完成特殊召唤的流程处理
	Duel.SpecialSummonComplete()
end
