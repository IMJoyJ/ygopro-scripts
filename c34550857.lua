--LL－コバルト・スパロー
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡特殊召唤成功的场合才能发动。从卡组把1只鸟兽族·1星怪兽加入手卡。
-- ②：场上的这张卡为素材作超量召唤的风属性怪兽得到以下效果。
-- ●这张卡不会成为对方的效果的对象。
function c34550857.initial_effect(c)
	-- ①：这张卡特殊召唤成功的场合才能发动。从卡组把1只鸟兽族·1星怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(34550857,0))  --"卡组检索"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,34550857)
	e1:SetTarget(c34550857.thtg)
	e1:SetOperation(c34550857.thop)
	c:RegisterEffect(e1)
	-- ②：场上的这张卡为素材作超量召唤的风属性怪兽得到以下效果。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_BE_MATERIAL)
	e2:SetProperty(EFFECT_FLAG_EVENT_PLAYER)
	e2:SetCondition(c34550857.efcon)
	e2:SetOperation(c34550857.efop)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于检索满足条件的鸟兽族1星怪兽
function c34550857.thfilter(c)
	return c:IsRace(RACE_WINDBEAST) and c:IsLevel(1) and c:IsAbleToHand()
end
-- 设置连锁处理信息，确定效果发动时会从卡组检索1只鸟兽族1星怪兽
function c34550857.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足检索条件，即卡组中是否存在符合条件的鸟兽族1星怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c34550857.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁处理信息，指定效果处理时会将1张卡从卡组加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理函数，执行从卡组检索鸟兽族1星怪兽并加入手牌的操作
function c34550857.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的1只鸟兽族1星怪兽
	local g=Duel.SelectMatchingCard(tp,c34550857.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的怪兽加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 判断是否满足效果发动条件，即作为超量素材且为风属性
function c34550857.efcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return r==REASON_XYZ and c:GetReasonCard():IsAttribute(ATTRIBUTE_WIND)
end
-- 效果处理函数，为作为超量素材的风属性怪兽赋予不会成为对方效果对象的效果
function c34550857.efop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=c:GetReasonCard()
	-- 为作为超量素材的怪兽赋予不会成为对方效果对象的效果
	local e1=Effect.CreateEffect(rc)
	e1:SetDescription(aux.Stringid(34550857,1))  --"「抒情歌鸲-钴尖晶雀」效果适用中"
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1:SetProperty(EFFECT_FLAG_CLIENT_HINT+EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	-- 设置效果值为aux.tgoval函数，用于判断是否成为对方效果对象
	e1:SetValue(aux.tgoval)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	rc:RegisterEffect(e1,true)
	if not rc:IsType(TYPE_EFFECT) then
		-- 若作为超量素材的怪兽没有TYPE_EFFECT，则为其追加TYPE_EFFECT类型
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_ADD_TYPE)
		e2:SetValue(TYPE_EFFECT)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		rc:RegisterEffect(e2,true)
	end
end
