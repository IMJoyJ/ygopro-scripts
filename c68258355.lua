--ZS－武装賢者
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：自己场上的怪兽只有「异热同心从者-武装贤者」以外的4星怪兽1只的场合，这张卡可以从手卡特殊召唤。
-- ②：场上的这张卡为素材作超量召唤的「希望皇 霍普」怪兽得到以下效果。
-- ●这张卡超量召唤的场合才能发动。从卡组把1只「异热同心武器」怪兽加入手卡。
function c68258355.initial_effect(c)
	-- ①：自己场上的怪兽只有「异热同心从者-武装贤者」以外的4星怪兽1只的场合，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(68258355,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c68258355.sprcon)
	c:RegisterEffect(e1)
	-- ②：场上的这张卡为素材作超量召唤的「希望皇 霍普」怪兽得到以下效果。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_BE_MATERIAL)
	e2:SetProperty(EFFECT_FLAG_EVENT_PLAYER)
	e2:SetCountLimit(1,68258355)
	e2:SetCondition(c68258355.efcon)
	e2:SetOperation(c68258355.efop)
	c:RegisterEffect(e2)
end
-- 特殊召唤规则的条件：自己场上仅存在1只表侧表示的4星怪兽，且该怪兽不是「异热同心从者-武装贤者」
function c68258355.sprcon(e,c)
	if c==nil then return true end
	-- 获取自己场上的所有怪兽
	local g=Duel.GetFieldGroup(c:GetControler(),LOCATION_MZONE,0)
	local tc=g:GetFirst()
	return #g==1 and tc:IsFaceup() and tc:IsLevel(4) and not tc:IsCode(68258355)
end
-- 作为素材的效果赋予条件：作为超量素材，且超量召唤的怪兽是「希望皇 霍普」怪兽
function c68258355.efcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return r==REASON_XYZ and c:GetReasonCard():IsSetCard(0x107f)
end
-- 为超量召唤的怪兽赋予效果：超量召唤成功的场合可以发动，从卡组检索1只「异热同心武器」怪兽；若该怪兽原本不是效果怪兽，则为其添加“效果怪兽”类型
function c68258355.efop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=c:GetReasonCard()
	-- ●这张卡超量召唤的场合才能发动。从卡组把1只「异热同心武器」怪兽加入手卡。
	local e1=Effect.CreateEffect(rc)
	e1:SetDescription(aux.Stringid(68258355,1))  --"检索异热同心武器（异热同心从者-武装贤者）"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetTarget(c68258355.thtg)
	e1:SetOperation(c68258355.thop)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	rc:RegisterEffect(e1,true)
	if not rc:IsType(TYPE_EFFECT) then
		-- ●这张卡超量召唤的场合才能发动。从卡组把1只「异热同心武器」怪兽加入手卡。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_ADD_TYPE)
		e2:SetValue(TYPE_EFFECT)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		rc:RegisterEffect(e2,true)
	end
end
-- 过滤卡组中满足是「异热同心武器」怪兽且能加入手牌的卡
function c68258355.thfilter(c)
	return c:IsSetCard(0x107e) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 检索效果的发动准备：检查卡组中是否存在可检索的卡，并在发动时向对方展示效果提示、设置操作信息
function c68258355.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1张满足条件的「异热同心武器」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c68258355.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 向对方玩家提示选择发动了该效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置当前连锁的操作信息为从卡组将1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 检索效果的处理：从卡组选择1张「异热同心武器」怪兽加入手牌，并给对方确认
function c68258355.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 设置选择卡片的提示信息为“加入手牌”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1张满足条件的「异热同心武器」怪兽
	local g=Duel.SelectMatchingCard(tp,c68258355.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡因效果加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示并确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
