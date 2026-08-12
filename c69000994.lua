--炎王獣 バロン
-- 效果：
-- ①：自己场上的表侧表示的「炎王」怪兽被效果破坏的场合才能发动。这张卡从手卡特殊召唤。
-- ②：这张卡被效果破坏送去墓地的场合，下次的准备阶段发动。从卡组把「炎王兽 巴隆」以外的1张「炎王」卡加入手卡。
function c69000994.initial_effect(c)
	-- ①：自己场上的表侧表示的「炎王」怪兽被效果破坏的场合才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(69000994,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetRange(LOCATION_HAND)
	e1:SetCode(EVENT_DESTROYED)
	e1:SetCondition(c69000994.spcon)
	e1:SetTarget(c69000994.sptg)
	e1:SetOperation(c69000994.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡被效果破坏送去墓地的场合
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetOperation(c69000994.threg)
	c:RegisterEffect(e2)
	-- 下次的准备阶段发动。从卡组把「炎王兽 巴隆」以外的1张「炎王」卡加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(69000994,1))  --"卡组检索"
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e3:SetCondition(c69000994.thcon)
	e3:SetTarget(c69000994.thtg)
	e3:SetOperation(c69000994.thop)
	e3:SetLabelObject(e2)
	c:RegisterEffect(e3)
end
-- 过滤条件：自己场上表侧表示的「炎王」怪兽因效果被破坏
function c69000994.cfilter(c,tp)
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousControler(tp)
		and c:IsReason(REASON_EFFECT) and c:IsSetCard(0x81)
end
-- 特殊召唤效果的发动条件：确认是否有满足条件的卡被破坏
function c69000994.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c69000994.cfilter,1,nil,tp)
end
-- 特殊召唤效果的靶向/发动准备：检查怪兽区域空位以及自身是否能特殊召唤，并设置特殊召唤的操作信息
function c69000994.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁处理的操作信息：将自身特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 特殊召唤效果的处理：若自身仍在手卡，则将自身特殊召唤
function c69000994.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡以表侧表示特殊召唤到自己的场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 效果破坏送墓的注册处理：记录被破坏时的回合数，并为自身注册Flag以在下次准备阶段触发检索
function c69000994.threg(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if bit.band(r,0x41)~=0x41 then return end
	-- 判断当前是否已经是准备阶段（用于处理在准备阶段被破坏时，需要在“下次”即下个回合的准备阶段发动的规则）
	if Duel.GetCurrentPhase()==PHASE_STANDBY then
		-- 将当前回合数记录在效果的Label中，用于后续判断是否已经过了当前回合
		e:SetLabel(Duel.GetTurnCount())
		c:RegisterFlagEffect(69000994,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_STANDBY,0,2)
	else
		e:SetLabel(0)
		c:RegisterFlagEffect(69000994,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_STANDBY,0,1)
	end
end
-- 检索效果的发动条件：确认当前回合不是被破坏送墓的那个回合，且自身带有注册的Flag
function c69000994.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 确保当前回合数不等于被破坏时的回合数（即必须是“下次”准备阶段），且卡片仍带有Flag标记
	return e:GetLabelObject():GetLabel()~=Duel.GetTurnCount() and e:GetHandler():GetFlagEffect(69000994)>0
end
-- 过滤条件：卡组中「炎王兽 巴隆」以外的「炎王」卡片，且能加入手卡
function c69000994.thfilter(c)
	return c:IsSetCard(0x81) and not c:IsCode(69000994) and c:IsAbleToHand()
end
-- 检索效果的靶向/发动准备：设置检索的操作信息，并重置Flag标记
function c69000994.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁处理的操作信息：从卡组将1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	e:GetHandler():ResetFlagEffect(69000994)
end
-- 检索效果的处理：从卡组选择1张满足条件的「炎王」卡加入手卡，并给对方确认
function c69000994.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组中选择1张满足过滤条件的卡
	local g=Duel.SelectMatchingCard(tp,c69000994.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡片因效果加入手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手卡的卡片给对方玩家确认
		Duel.ConfirmCards(1-tp,g)
	end
end
