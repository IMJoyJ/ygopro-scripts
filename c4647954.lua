--ZS－昇華賢者
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：自己场上没有卡存在的场合，这张卡可以从手卡特殊召唤。
-- ②：场上的这张卡为素材作超量召唤的「希望皇 霍普」怪兽得到以下效果。
-- ●这张卡超量召唤的场合才能发动。从卡组把1张「升阶魔法」通常魔法卡加入手卡。
function c4647954.initial_effect(c)
	-- ①：自己场上没有卡存在的场合，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(4647954,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c4647954.spcon)
	c:RegisterEffect(e1)
	-- ②：场上的这张卡为素材作超量召唤的「希望皇 霍普」怪兽得到以下效果。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_BE_MATERIAL)
	e2:SetProperty(EFFECT_FLAG_EVENT_PLAYER)
	e2:SetCountLimit(1,4647954)
	e2:SetCondition(c4647954.efcon)
	e2:SetOperation(c4647954.efop)
	c:RegisterEffect(e2)
end
-- ①效果的特殊召唤规则条件判定：若c为nil则允许查询能否特殊召唤；否则需要自己主要怪兽区有空位且自己场上没有任何卡。
function c4647954.spcon(e,c)
	if c==nil then return true end
	-- 检查自己主要怪兽区是否有可用空格，确保有地方特殊召唤。
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
		-- 确认自己场上（怪兽区和魔法陷阱区）没有卡存在，满足①的‘自己场上没有卡’条件。
		and Duel.GetFieldGroupCount(c:GetControler(),LOCATION_ONFIELD,0)==0
end
-- ②效果的触发条件：这张卡作为超量素材，且超量召唤的怪兽属于「希望皇 霍普」系列（0x107f）。
function c4647954.efcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return r==REASON_XYZ and c:GetReasonCard():IsSetCard(0x107f)
end
-- 当这张卡成为「希望皇 霍普」怪兽的超量召唤素材时，给那只怪兽赋予后续检索「升阶魔法」的效果；若其不是效果怪兽，则追加将其变为效果怪兽的效果。
function c4647954.efop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=c:GetReasonCard()
	-- ●这张卡超量召唤的场合才能发动。从卡组把1张「升阶魔法」通常魔法卡加入手卡。
	local e1=Effect.CreateEffect(rc)
	e1:SetDescription(aux.Stringid(4647954,1))  --"检索升阶魔法（异热同心从者-升华贤者）"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetTarget(c4647954.thtg)
	e1:SetOperation(c4647954.thop)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	rc:RegisterEffect(e1,true)
	if not rc:IsType(TYPE_EFFECT) then
		-- ●这张卡超量召唤的场合才能发动。从卡组把1张「升阶魔法」通常魔法卡加入手卡。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_ADD_TYPE)
		e2:SetValue(TYPE_EFFECT)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		rc:RegisterEffect(e2,true)
	end
end
-- 确认检索对象：是通常魔法卡（type恰为TYPE_SPELL），且属于「升阶魔法」字段（0x95），并且可以加入手卡。
function c4647954.thfilter(c)
	return c:GetType()==TYPE_SPELL and c:IsSetCard(0x95) and c:IsAbleToHand()
end
-- 检索效果的目标部分：检查卡组是否存在符合条件的升阶魔法；向对方提示发动效果，并设置操作信息（将1张卡加入手卡）。
function c4647954.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：卡组中是否存在至少1张满足thfilter的「升阶魔法」通常魔法卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c4647954.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 向对方玩家提示已选择的发动效果，显示本效果描述。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置效果处理信息：从卡组将1张卡加入手卡（非指定对象，数量为1）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：从卡组选择符合条件的升阶魔法通常魔法卡，加入手卡并让对方确认。
function c4647954.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 显示选择提示，要求当前玩家从卡组里选择要加入手卡的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 当前玩家从卡组中选出1张满足条件的「升阶魔法」通常魔法卡。
	local g=Duel.SelectMatchingCard(tp,c4647954.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入其持有者手卡（由效果处理导致）。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示刚才加入手卡的卡。
		Duel.ConfirmCards(1-tp,g)
	end
end
