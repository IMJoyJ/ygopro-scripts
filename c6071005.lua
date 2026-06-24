--ウィッチクラフト・マルカ
local s,id,o=GetID()
-- 创建两个效果，第一个为起动效果，第二个为诱发效果。
function s.initial_effect(c)
	-- 此卡在手牌或主要怪兽区时可以发动的效果：从卡组检索1张「魔导」魔法·场地永续魔法卡加入手牌。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND+LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.thcost)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	-- 此卡在墓地时的诱发效果：当对方场上的「魔导」怪兽离开场上的场合，可以特殊召唤此卡，并解放对方场上1只怪兽。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_RELEASE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
-- 支付1点费用，解放此卡。
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 将此卡解放作为费用。
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 定义检索过滤器，用于筛选「魔导」魔法·场地永续魔法卡。
function s.thfilter(c)
	return c:IsSetCard(0x128) and c:IsType(TYPE_SPELL) and c:IsType(TYPE_FIELD+TYPE_CONTINUOUS) and c:IsAbleToHand()
end
-- 设置检索目标，准备发动检索效果。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足检索条件，即在卡组中存在至少1张符合条件的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息，表示将要进行检索并加入手牌的操作。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 执行检索并加入手牌的操作。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择1张符合条件的卡。
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡送入手牌。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 确认对方查看了送入手牌的卡。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 定义条件过滤器，用于判断是否满足特殊召唤条件。
function s.cfilter(c,tp,rp)
	return c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousControler(tp) and c:IsPreviousSetCard(0x128) and c:IsPreviousLocation(LOCATION_MZONE)
		and rp==1-tp and c:IsReason(REASON_EFFECT)
end
-- 判断是否有符合条件的怪兽离开场上的情况。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp,rp) and not eg:IsContains(e:GetHandler())
end
-- 设置特殊召唤目标，准备发动特殊召唤效果。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足特殊召唤条件，即场上存在空位且此卡可特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查是否满足特殊召唤条件，即对方场上存在至少1只可解放的怪兽。
		and Duel.IsExistingMatchingCard(Card.IsReleasableByEffect,tp,0,LOCATION_MZONE,1,nil) end
	-- 设置操作信息，表示将要进行特殊召唤的操作。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
	-- 设置操作信息，表示将要进行解放的操作。
	Duel.SetOperationInfo(0,CATEGORY_RELEASE,nil,1,1-tp,LOCATION_MZONE)
end
-- 执行特殊召唤并随后解放对方怪兽的操作。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断此卡是否与连锁相关且成功特殊召唤。
	if c:IsRelateToChain() and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 特殊召唤后将此卡移除，并提示玩家选择要解放的怪兽。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e1,true)
		-- 提示玩家选择要解放的怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
		-- 从对方场上选择1只可解放的怪兽。
		local g=Duel.SelectMatchingCard(tp,Card.IsReleasableByEffect,tp,0,LOCATION_MZONE,1,1,nil)
		local tc=g:GetFirst()
		if tc then
			-- 中断当前效果处理，使后续效果错时处理。
			Duel.BreakEffect()
			-- 显示被选为对象的卡的动画效果。
			Duel.HintSelection(g)
			-- 将选中的怪兽解放作为费用。
			Duel.Release(g,REASON_EFFECT)
		end
	end
end
