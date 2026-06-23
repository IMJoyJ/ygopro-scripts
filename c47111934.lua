--ワーム・ヤガン
-- 效果：
-- 自己场上存在的怪兽只有「泽克斯异虫」1只的场合，自己墓地存在的这张卡可以在自己场上里侧守备表示盖放。这个效果特殊召唤的这张卡从场上离开的场合从游戏中除外。这张卡反转时，对方场上表侧表示存在的1只怪兽回到持有者手卡。
function c47111934.initial_effect(c)
	-- 自己场上存在的怪兽只有「泽克斯异虫」1只的场合，自己墓地存在的这张卡可以在自己场上里侧守备表示盖放。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(47111934,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_MSET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCondition(c47111934.spcon)
	e1:SetTarget(c47111934.sptg)
	e1:SetOperation(c47111934.spop)
	c:RegisterEffect(e1)
	-- 这张卡反转时，对方场上表侧表示存在的1只怪兽回到持有者手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(47111934,1))  --"返回手牌"
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_FLIP)
	e2:SetTarget(c47111934.thtg)
	e2:SetOperation(c47111934.thop)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于判断场上是否存在「泽克斯异虫」
function c47111934.cfilter(c)
	return c:IsFaceup() and c:IsCode(11722335)
end
-- 效果条件函数，检查是否满足特殊召唤的条件
function c47111934.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否只有1只怪兽
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==1
		-- 检查自己场上是否存在「泽克斯异虫」
		and Duel.IsExistingMatchingCard(c47111934.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 设置特殊召唤的处理目标
function c47111934.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有足够的召唤位置
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE) end
	-- 设置特殊召唤操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 特殊召唤效果的处理函数
function c47111934.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断是否满足特殊召唤条件并检查召唤位置
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 or not c47111934.spcon(e,tp,eg,ep,ev,re,r,rp) then return end
	-- 执行特殊召唤操作
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)>0 then
		-- 向对方确认特殊召唤的卡片
		Duel.ConfirmCards(1-tp,c)
		-- 创建一个效果，使该卡从场上离开时被除外
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e1,true)
	end
end
-- 过滤函数，用于选择可以送回手牌的怪兽
function c47111934.filter(c)
	return c:IsFaceup() and c:IsAbleToHand()
end
-- 设置反转效果的处理目标
function c47111934.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and c47111934.filter(chkc) end
	if chk==0 then return true end
	-- 提示玩家选择要返回手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择对方场上的1只表侧表示怪兽作为目标
	local g=Duel.SelectTarget(tp,c47111934.filter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置将目标怪兽送回手牌的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,g:GetCount(),0,0)
end
-- 反转效果的处理函数
function c47111934.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标卡片
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 将目标怪兽送回持有者手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
