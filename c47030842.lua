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
	-- 此外，这张卡从场上送去墓地时，可以从自己墓地选择「齿轮齿轮加速人」以外的1只名字带有「齿轮齿轮」的怪兽加入手卡。
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
-- 过滤函数：判断怪兽是否为表侧表示且拥有「齿轮齿轮」字段，用于确认场上是否存在满足特殊召唤条件的「齿轮齿轮」怪兽。
function c47030842.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x72)
end
-- 规则特殊召唤的发动条件：若c为空表示仅进行规则检查则通过；否则要求己方怪兽区域有空位，且己方场上有表侧表示的名字带有「齿轮齿轮」的怪兽。
function c47030842.spcon(e,c)
	if c==nil then return true end
	-- 检查己方场上怪兽区域是否存在至少1个可用空格，以保证这张卡能够特殊召唤。
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
		-- 检查己方场上是否存在至少1只表侧表示且名字带有「齿轮齿轮」的怪兽，作为满足特殊召唤条件的依据。
		and Duel.IsExistingMatchingCard(c47030842.cfilter,c:GetControler(),LOCATION_MZONE,0,1,nil)
end
-- 诱发效果的发动条件：这张卡从场上送去墓地时才可发动，即其之前位置必须在场上。
function c47030842.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 墓地检索过滤：对象必须是名字带有「齿轮齿轮」的怪兽卡，卡名不是「齿轮齿轮加速人」，且能够被加入手卡。
function c47030842.filter(c)
	return c:IsSetCard(0x72) and not c:IsCode(47030842) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 目标选择函数：效果发动时先确认墓地存在满足条件的对象，再由玩家选择1张符合条件的「齿轮齿轮」怪兽作为对象，并设置回手牌的操作信息。
function c47030842.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c47030842.filter(chkc) end
	-- 效果发动的合法判定：检查自己墓地是否存在至少1张满足条件且能成为效果对象的「齿轮齿轮」怪兽。
	if chk==0 then return Duel.IsExistingTarget(c47030842.filter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 播放选择提示，提示玩家从墓地选择要加入手卡的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从自己墓地选择1张符合条件的「齿轮齿轮」怪兽（「齿轮齿轮加速人」除外）作为效果对象。
	local g=Duel.SelectTarget(tp,c47030842.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置操作信息，声明本次效果处理将对象卡加入手卡，处理分类为回手牌，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果处理：取得对象怪兽，若该怪兽仍与此效果关联，则将其加入持有者手卡，并向对方玩家公开确认。
function c47030842.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁中已选择的那张墓地怪兽作为对象。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象卡加入其持有者的手卡，处理原因为效果。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 向对方玩家展示并确认这张回到手卡的卡。
		Duel.ConfirmCards(1-tp,tc)
	end
end
