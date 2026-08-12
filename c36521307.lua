--斬機サーキュラー
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：从卡组把「斩机 圆武」以外的1只「斩机」怪兽送去墓地才能发动。这张卡从手卡特殊召唤。这个效果的发动后，直到回合结束时自己只能用1只怪兽攻击。
-- ②：这张卡在怪兽区域存在的状态，自己场上有「斩机」怪兽召唤·特殊召唤的场合才能发动。从卡组把1张「斩机」魔法·陷阱卡加入手卡。
function c36521307.initial_effect(c)
	-- ①：从卡组把「斩机 圆武」以外的1只「斩机」怪兽送去墓地才能发动。这张卡从手卡特殊召唤。这个效果的发动后，直到回合结束时自己只能用1只怪兽攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(36521307,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,36521307)
	e1:SetCost(c36521307.spcost)
	e1:SetTarget(c36521307.sptg)
	e1:SetOperation(c36521307.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡在怪兽区域存在的状态，自己场上有「斩机」怪兽召唤·特殊召唤的场合才能发动。从卡组把1张「斩机」魔法·陷阱卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(36521307,1))
	e2:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,36521308)
	e2:SetCondition(c36521307.thcon)
	e2:SetTarget(c36521307.thtg)
	e2:SetOperation(c36521307.thop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
end
-- 过滤函数，用于检查卡组中是否包含满足条件的「斩机」怪兽（不包括圆武自身）
function c36521307.costfilter(c)
	return c:IsSetCard(0x132) and c:IsType(TYPE_MONSTER) and not c:IsCode(36521307) and c:IsAbleToGraveAsCost()
end
-- 效果发动时的费用支付处理，需要从卡组中选择一只「斩机」怪兽送去墓地
function c36521307.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足支付费用的条件，即卡组中是否存在符合条件的「斩机」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c36521307.costfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择满足条件的「斩机」怪兽并将其加入到墓地
	local g=Duel.SelectMatchingCard(tp,c36521307.costfilter,tp,LOCATION_DECK,0,1,1,nil)
	-- 将选中的卡送去墓地作为效果的发动费用
	Duel.SendtoGrave(g,REASON_COST)
end
-- 设置效果的发动条件，检查是否满足特殊召唤的条件
function c36521307.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否有足够的空间进行特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置效果发动后要处理的卡组信息，准备特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果发动时的处理，将自身从手牌特殊召唤到场上
function c36521307.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将自身从手牌特殊召唤到场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
	-- ①：从卡组把「斩机 圆武」以外的1只「斩机」怪兽送去墓地才能发动。这张卡从手卡特殊召唤。这个效果的发动后，直到回合结束时自己只能用1只怪兽攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetOperation(c36521307.checkop)
	-- 注册一个持续到回合结束的攻击限制效果
	Duel.RegisterEffect(e1,tp)
	-- ②：这张卡在怪兽区域存在的状态，自己场上有「斩机」怪兽召唤·特殊召唤的场合才能发动。从卡组把1张「斩机」魔法·陷阱卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetReset(RESET_PHASE+PHASE_END)
	e2:SetCondition(c36521307.atkcon)
	e2:SetTarget(c36521307.atktg)
	e1:SetLabelObject(e2)
	-- 注册一个持续到回合结束的攻击限制效果
	Duel.RegisterEffect(e2,tp)
end
-- 当有怪兽攻击时，记录该攻击的场ID并设置攻击限制
function c36521307.checkop(e,tp,eg,ep,ev,re,r,rp)
	-- 如果已经记录过攻击ID，则不再重复记录
	if Duel.GetFlagEffect(tp,36521307)~=0 then return end
	local fid=eg:GetFirst():GetFieldID()
	-- 注册一个标识效果，用于记录攻击ID
	Duel.RegisterFlagEffect(tp,36521307,RESET_PHASE+PHASE_END,0,1)
	e:GetLabelObject():SetLabel(fid)
end
-- 判断是否已经记录过攻击ID，以决定是否启用攻击限制
function c36521307.atkcon(e)
	-- 判断是否已经记录过攻击ID，以决定是否启用攻击限制
	return Duel.GetFlagEffect(e:GetHandlerPlayer(),36521307)>0
end
-- 设置攻击限制的目标，禁止特定ID的怪兽攻击
function c36521307.atktg(e,c)
	return c:GetFieldID()~=e:GetLabel()
end
-- 过滤函数，用于检查场上是否有「斩机」怪兽被召唤或特殊召唤
function c36521307.cfilter(c,tp)
	return c:IsSetCard(0x132) and c:IsControler(tp) and c:IsFaceup()
end
-- 判断是否满足效果发动条件，即自己场上有「斩机」怪兽被召唤或特殊召唤
function c36521307.thcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c36521307.cfilter,1,nil,tp) and not eg:IsContains(e:GetHandler())
end
-- 过滤函数，用于检查卡组中是否包含「斩机」魔法或陷阱卡
function c36521307.thfilter(c)
	return c:IsSetCard(0x132) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- 设置效果的发动条件，检查是否满足检索卡组的条件
function c36521307.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足检索卡组的条件，即卡组中是否存在符合条件的「斩机」魔法或陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(c36521307.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置效果发动后要处理的卡组信息，准备检索卡组
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果发动时的处理，从卡组中选择一张「斩机」魔法或陷阱卡加入手牌
function c36521307.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的「斩机」魔法或陷阱卡并将其加入手牌
	local g=Duel.SelectMatchingCard(tp,c36521307.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 确认对方查看加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
