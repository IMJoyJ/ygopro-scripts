--ギアギアクセル
-- 效果：
-- 自己场上有名字带有「齿轮齿轮」的怪兽存在的场合，这张卡可以从手卡表侧守备表示特殊召唤。此外，这张卡从场上送去墓地时，可以从自己墓地选择「齿轮齿轮加速人」以外的1只名字带有「齿轮齿轮」的怪兽加入手卡。
function c47030842.initial_effect(c)
	-- 自己场上有名字带有「齿轮齿轮」的怪兽存在的场合，这张卡可以从手卡表侧守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_SPSUM_PARAM)
	e1:SetRange(LOCATION_HAND)
	e1:SetTargetRange(POS_FACEUP_DEFENSE,0)
	e1:SetCondition(c47030842.spcon)
	c:RegisterEffect(e1)
	-- 这张卡从场上送去墓地时，可以从自己墓地选择「齿轮齿轮加速人」以外的1只名字带有「齿轮齿轮」的怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(47030842,0))  --"加入手卡"
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCondition(c47030842.thcon)
	e2:SetTarget(c47030842.thtg)
	e2:SetOperation(c47030842.thop)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于判断场上是否存在名字带有「齿轮齿轮」的表侧表示怪兽。
function c47030842.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x72)
end
-- 特殊召唤条件函数，检查是否满足特殊召唤的条件（有空位且场上有名字带有「齿轮齿轮」的怪兽）。
function c47030842.spcon(e,c)
	if c==nil then return true end
	-- 检查自己场上是否有足够的怪兽区域。
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
		-- 检查自己场上是否存在至少1只名字带有「齿轮齿轮」的表侧表示怪兽。
		and Duel.IsExistingMatchingCard(c47030842.cfilter,c:GetControler(),LOCATION_MZONE,0,1,nil)
end
-- 墓地触发效果的发动条件，判断此卡是否从场上送去墓地。
function c47030842.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 过滤函数，用于筛选墓地中名字带有「齿轮齿轮」且不是此卡本身的怪兽。
function c47030842.filter(c)
	return c:IsSetCard(0x72) and not c:IsCode(47030842) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 选择目标阶段函数，设置选择墓地中符合条件的怪兽作为效果对象。
function c47030842.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c47030842.filter(chkc) end
	-- 检查在选择目标阶段是否有满足条件的卡片存在。
	if chk==0 then return Duel.IsExistingTarget(c47030842.filter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 向玩家提示“请选择要加入手牌的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从玩家墓地中选择一只符合条件的怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,c47030842.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置当前连锁的操作信息，表示将选择的怪兽加入手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果处理函数，执行将目标怪兽加入手牌并确认其卡片内容的操作。
function c47030842.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的目标怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽以效果原因送入手牌。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 向对方玩家确认目标怪兽的卡片内容。
		Duel.ConfirmCards(1-tp,tc)
	end
end
