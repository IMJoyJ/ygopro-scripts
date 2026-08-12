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
-- 检查是否满足特殊召唤条件：场上没有其他卡存在且有可用怪兽区域。
function c4647954.spcon(e,c)
	if c==nil then return true end
	-- 检查当前玩家是否有可用的怪兽区域。
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
		-- 检查当前玩家场上是否没有卡存在。
		and Duel.GetFieldGroupCount(c:GetControler(),LOCATION_ONFIELD,0)==0
end
-- 判断该卡是否作为超量素材被使用且其来源为「希望皇 霍普」系列。
function c4647954.efcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return r==REASON_XYZ and c:GetReasonCard():IsSetCard(0x107f)
end
-- 设置并注册效果：当作为超量素材的此卡使怪兽特殊召唤成功时，发动检索升阶魔法的效果。
function c4647954.efop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=c:GetReasonCard()
	-- 创建一个诱发效果，用于在特定条件下从卡组检索升阶魔法通常魔法卡加入手牌。
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
		-- 若目标怪兽没有TYPE_EFFECT，则为其添加TYPE_EFFECT类型以使其能正常处理效果。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_ADD_TYPE)
		e2:SetValue(TYPE_EFFECT)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		rc:RegisterEffect(e2,true)
	end
end
-- 定义过滤函数：筛选出卡组中满足条件的升阶魔法通常魔法卡（魔法卡、升阶魔法系列、可送入手牌）。
function c4647954.thfilter(c)
	return c:GetType()==TYPE_SPELL and c:IsSetCard(0x95) and c:IsAbleToHand()
end
-- 设置效果的目标函数：检查是否可以检索一张符合条件的升阶魔法通常魔法卡。
function c4647954.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足检索条件，即卡组中是否存在至少一张符合条件的升阶魔法通常魔法卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c4647954.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 向对方玩家提示“对方选择了：检索升阶魔法（异热同心从者-升华贤者）”。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置操作信息：准备将一张升阶魔法通常魔法卡从卡组送入手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 设置效果的处理函数：选择并把符合条件的升阶魔法通常魔法卡加入手牌。
function c4647954.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的一张升阶魔法通常魔法卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 根据过滤条件从卡组中选择一张升阶魔法通常魔法卡。
	local g=Duel.SelectMatchingCard(tp,c4647954.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的升阶魔法通常魔法卡送入手牌。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家确认所选的升阶魔法通常魔法卡。
		Duel.ConfirmCards(1-tp,g)
	end
end
