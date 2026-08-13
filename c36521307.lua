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
-- 定义代价筛选函数：选出卡组中「斩机」圆武以外的1只「斩机」怪兽，且该卡可以作为代价送去墓地。
function c36521307.costfilter(c)
	return c:IsSetCard(0x132) and c:IsType(TYPE_MONSTER) and not c:IsCode(36521307) and c:IsAbleToGraveAsCost()
end
-- ①效果的代价支付函数：确认卡组中存在符合条件的「斩机」怪兽后，由玩家选择1张送去墓地作为发动代价。
function c36521307.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时合法检查：确认卡组中存在至少1张满足costfilter条件的「斩机」怪兽（不包含「斩机 圆武」自身）可以作为代价。
	if chk==0 then return Duel.IsExistingMatchingCard(c36521307.costfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 显示“请选择要送去墓地的卡”的提示信息，引导玩家选择要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从自己卡组选择1张满足costfilter条件的「斩机」怪兽（排除「斩机 圆武」自身）。
	local g=Duel.SelectMatchingCard(tp,c36521307.costfilter,tp,LOCATION_DECK,0,1,1,nil)
	-- 将选择的「斩机」怪兽送去墓地，作为发动①效果的代价（REASON_COST）。
	Duel.SendtoGrave(g,REASON_COST)
end
-- ①效果的特殊召唤目标判断：只有自己的主要怪兽区域有空位且此卡能够被特殊召唤时，效果才能发动。
function c36521307.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己主要怪兽区域是否存在可用的空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁处理的操作信息：预告本效果将特殊召唤此卡，使「特殊召唤」相关时点能够正确检测到。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①效果处理：将此卡特殊召唤；随后在本回合内设置“自己只能用1只怪兽攻击”的限制，通过记录第一只攻击宣言的怪兽并禁止其他怪兽攻击宣言来实现。
function c36521307.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将此卡以表侧攻击表示特殊召唤到自己的主要怪兽区域。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
	-- 这个效果的发动后，直到回合结束时自己只能用1只怪兽攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetOperation(c36521307.checkop)
	-- 将攻击宣言监视效果e1注册给当前玩家，使其在回合内监听攻击宣言时点。
	Duel.RegisterEffect(e1,tp)
	-- 这个效果的发动后，直到回合结束时自己只能用1只怪兽攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetReset(RESET_PHASE+PHASE_END)
	e2:SetCondition(c36521307.atkcon)
	e2:SetTarget(c36521307.atktg)
	e1:SetLabelObject(e2)
	-- 将“不能攻击宣言”的限制效果e2注册给当前玩家，用于限制本回合的继续攻击。
	Duel.RegisterEffect(e2,tp)
end
-- 攻击宣言监视效果：当回合内第一次攻击宣言发生时，记录该攻击怪兽的FieldID并设置标记，作为允许攻击的怪兽标识。
function c36521307.checkop(e,tp,eg,ep,ev,re,r,rp)
	-- 若本回合已经记录过攻击怪兽（即不是第一次攻击宣言），则不再重复记录。
	if Duel.GetFlagEffect(tp,36521307)~=0 then return end
	local fid=eg:GetFirst():GetFieldID()
	-- 为本回合注册一个“已记录攻击怪兽”的标记，该标记在结束阶段重置。
	Duel.RegisterFlagEffect(tp,36521307,RESET_PHASE+PHASE_END,0,1)
	e:GetLabelObject():SetLabel(fid)
end
-- 限制攻击效果的生效条件：仅当本回合已记录第一只攻击怪兽（存在标记）时才生效。
function c36521307.atkcon(e)
	-- 判断当前玩家是否已有“已记录攻击怪兽”的标记，用于控制限制攻击效果是否有效。
	return Duel.GetFlagEffect(e:GetHandlerPlayer(),36521307)>0
end
-- 指定不能攻击宣言的怪兽：除第一只攻击宣言的怪兽（FieldID与记录值相同）以外的怪兽都不能进行攻击宣言。
function c36521307.atktg(e,c)
	return c:GetFieldID()~=e:GetLabel()
end
-- 定义「斩机」怪兽过滤器：表侧表示、由tp控制、属于「斩机」系列。
function c36521307.cfilter(c,tp)
	return c:IsSetCard(0x132) and c:IsControler(tp) and c:IsFaceup()
end
-- ②效果触发条件：当有「斩机」怪兽召唤·特殊召唤成功时，且该怪兽不是圆武自身，才满足发动条件。
function c36521307.thcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c36521307.cfilter,1,nil,tp) and not eg:IsContains(e:GetHandler())
end
-- 定义「斩机」魔法·陷阱卡过滤器：属于「斩机」系列、是魔法/陷阱卡、能够加入手卡。
function c36521307.thfilter(c)
	return c:IsSetCard(0x132) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- ②效果目标判断：检查卡组中是否存在可加入手卡的「斩机」魔法·陷阱卡，并设置从卡组检索加入手卡的操作信息。
function c36521307.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时检查卡组中是否存在满足条件的「斩机」魔法·陷阱卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c36521307.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：从卡组将1张卡加入手卡（此时不选择具体卡片，效果处理时再选择）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ②效果处理：从卡组选择1张「斩机」魔法·陷阱卡加入手卡，并让对方确认。
function c36521307.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 显示“请选择要加入手牌的卡”的提示信息，引导玩家选择要加入手卡的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从自己卡组选择1张满足thfilter条件的「斩机」魔法·陷阱卡。
	local g=Duel.SelectMatchingCard(tp,c36521307.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡加入其持有者的手卡，REASON_EFFECT表示这是效果处理导致的移动。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手卡的卡片展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
	end
end
