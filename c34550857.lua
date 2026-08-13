--LL－コバルト・スパロー
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡特殊召唤成功的场合才能发动。从卡组把1只鸟兽族·1星怪兽加入手卡。
-- ②：场上的这张卡为素材作超量召唤的风属性怪兽得到以下效果。
-- ●这张卡不会成为对方的效果的对象。
function c34550857.initial_effect(c)
	-- 这个卡名的①的效果1回合只能使用1次。①：这张卡特殊召唤成功的场合才能发动。从卡组把1只鸟兽族·1星怪兽加入手卡。
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
	-- ②：场上的这张卡为素材作超量召唤的风属性怪兽得到以下效果。●这张卡不会成为对方的效果的对象。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_BE_MATERIAL)
	e2:SetProperty(EFFECT_FLAG_EVENT_PLAYER)
	e2:SetCondition(c34550857.efcon)
	e2:SetOperation(c34550857.efop)
	c:RegisterEffect(e2)
end
-- 过滤函数：判断卡是否为鸟兽族·1星怪兽且能被加入手卡，用于检索目标的筛选条件。
function c34550857.thfilter(c)
	return c:IsRace(RACE_WINDBEAST) and c:IsLevel(1) and c:IsAbleToHand()
end
-- 效果的发动条件和处理信息设定：在发动时确认卡组存在检索目标，并声明将要把1张卡加入手卡。
function c34550857.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动合法性判定时，检查卡组中是否存在1张以上满足“鸟兽族·1星且可加入手卡”的卡，作为能否发动①效果的前提。
	if chk==0 then return Duel.IsExistingMatchingCard(c34550857.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 将本连锁的效果处理信息登记为：从卡组把1张卡加入手卡（由于选牌在处理时进行，目标暂不确定）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ①效果处理的实际操作：从卡组选择1张符合条件的鸟兽族·1星怪兽加入手卡，并向对方展示。
function c34550857.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示当前玩家从卡组选择“要加入手牌的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从己方卡组筛选并选择1张鸟兽族·1星且可加入手卡的怪兽作为检索对象。
	local g=Duel.SelectMatchingCard(tp,c34550857.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡以效果原因送入持有者的手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将刚加入手卡的卡展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 判定②效果的触发条件：本卡作为超量素材使用后，所超量召唤出的怪兽必须是风属性。
function c34550857.efcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return r==REASON_XYZ and c:GetReasonCard():IsAttribute(ATTRIBUTE_WIND)
end
-- ②效果处理：将“不会成为对方效果对象”的效果赋予超量召唤出的风属性怪兽；若该怪兽不是效果怪兽，则先追加效果怪兽类型以保证效果正确适用。
function c34550857.efop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=c:GetReasonCard()
	-- 对应“●这张卡不会成为对方的效果的对象。”
	local e1=Effect.CreateEffect(rc)
	e1:SetDescription(aux.Stringid(34550857,1))  --"「抒情歌鸲-钴尖晶雀」效果适用中"
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1:SetProperty(EFFECT_FLAG_CLIENT_HINT+EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	-- 设置“不能成为效果对象”功能的判定值为“仅对方发动的效果不能以该卡为对象”，即使用简易判断函数实现。
	e1:SetValue(aux.tgoval)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	rc:RegisterEffect(e1,true)
	if not rc:IsType(TYPE_EFFECT) then
		-- 对应“②：场上的这张卡为素材作超量召唤的风属性怪兽得到以下效果。”中的“得到以下效果”：若被赋予效果的怪兽不是效果怪兽，则将其变为效果怪兽以便适用该效果。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_ADD_TYPE)
		e2:SetValue(TYPE_EFFECT)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		rc:RegisterEffect(e2,true)
	end
end
