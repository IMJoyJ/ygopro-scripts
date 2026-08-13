--ワーム・ヤガン
-- 效果：
-- 自己场上存在的怪兽只有「泽克斯异虫」1只的场合，自己墓地存在的这张卡可以在自己场上里侧守备表示盖放。这个效果特殊召唤的这张卡从场上离开的场合从游戏中除外。这张卡反转时，对方场上表侧表示存在的1只怪兽回到持有者手卡。
function c47111934.initial_effect(c)
	-- 自己场上存在的怪兽只有「泽克斯异虫」1只的场合，自己墓地存在的这张卡可以在自己场上里侧守备表示盖放。这个效果特殊召唤的这张卡从场上离开的场合从游戏中除外。
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
-- 该过滤函数用于筛选表侧表示且卡号为11722335（即「泽克斯异虫」）的怪兽。
function c47111934.cfilter(c)
	return c:IsFaceup() and c:IsCode(11722335)
end
-- 特殊召唤条件的判定：自己场上存在的怪兽只有1只，且场上存在表侧表示的「泽克斯异虫」。
function c47111934.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上主要怪兽区域存在的怪兽数量是否恰好为1。
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==1
		-- 确认自己场上存在至少1张满足cfilter条件的表侧表示「泽克斯异虫」。
		and Duel.IsExistingMatchingCard(c47111934.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 发动时点的效果合法性检查：自己场上存在可用的怪兽区域，且墓地中的这张卡能够以里侧守备表示特殊召唤。
function c47111934.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在可用的主要怪兽区域空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE) end
	-- 登记本次连锁将进行特殊召唤的操作信息，对象为这张卡自身，数量为1，供其他效果进行发动判定。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理：若满足条件且场上仍有空位，则将这张卡以里侧守备表示特殊召唤；特殊召唤成功时向对方玩家确认该卡，并为其附加“从场上离开的场合除外”的效果。
function c47111934.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 效果处理时再次确认场上是否有空位以及特殊召唤条件是否仍然满足，若不满足则中止处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 or not c47111934.spcon(e,tp,eg,ep,ev,re,r,rp) then return end
	-- 确认这张卡仍与本效果关联，并成功以里侧守备表示特殊召唤后，继续执行后续的除外效果附加处理。
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)>0 then
		-- 向对方玩家确认这张特殊召唤成功的卡，以公开里侧守备表示特殊召唤的卡面信息。
		Duel.ConfirmCards(1-tp,c)
		-- 这个效果特殊召唤的这张卡从场上离开的场合从游戏中除外。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e1,true)
	end
end
-- 反转效果选择对象的过滤函数：选择对方场上表侧表示且能够加入手卡的怪兽。
function c47111934.filter(c)
	return c:IsFaceup() and c:IsAbleToHand()
end
-- 反转效果的发动与对象选择：选择对方场上的1只表侧表示且能够加入手卡的怪兽作为对象；取对象操作通过Duel.SelectTarget完成。
function c47111934.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and c47111934.filter(chkc) end
	if chk==0 then return true end
	-- 向玩家显示“请选择要返回手牌的卡”的选择提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 让玩家从对方场上选择1只满足filter条件的表侧表示怪兽，并将其设为效果的对象。
	local g=Duel.SelectTarget(tp,c47111934.filter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 登记本次连锁将执行返回手牌的操作信息，确定对象为已选择的怪兽，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,g:GetCount(),0,0)
end
-- 效果处理：取得选择的对象，若其仍然表侧表示且与本效果关联，则将它返回持有者手牌。
function c47111934.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得本效果发动时选择的怪兽对象。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 以效果原因将该怪兽返回持有者手牌。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
