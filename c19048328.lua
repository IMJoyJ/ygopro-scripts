--幻竜星－チョウホウ
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- ①：只要同调召唤的这张卡在怪兽区域存在，对方不能把原本属性和作为这张卡的同调素材的「龙星」怪兽相同的怪兽的效果发动。
-- ②：同调召唤的这张卡被战斗·效果破坏送去墓地时才能发动。从卡组把1只调整加入手卡。
-- ③：1回合1次，对方场上的怪兽被战斗·效果破坏时才能发动。原本属性和那1只怪兽相同的1只幻龙族怪兽从自己卡组守备表示特殊召唤。
function c19048328.initial_effect(c)
	-- 添加同调召唤手续，要求1只调整和1只调整以外的怪兽作为素材
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ①：只要同调召唤的这张卡在怪兽区域存在，对方不能把原本属性和作为这张卡的同调素材的「龙星」怪兽相同的怪兽的效果发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_MATERIAL_CHECK)
	e1:SetValue(c19048328.matcheck)
	c:RegisterEffect(e1)
	-- ①：只要同调召唤的这张卡在怪兽区域存在，对方不能把原本属性和作为这张卡的同调素材的「龙星」怪兽相同的怪兽的效果发动。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(c19048328.regcon)
	e2:SetOperation(c19048328.regop)
	e2:SetLabelObject(e1)
	c:RegisterEffect(e2)
	-- ②：同调召唤的这张卡被战斗·效果破坏送去墓地时才能发动。从卡组把1只调整加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(19048328,0))  --"卡组调整加入手卡"
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCondition(c19048328.thcon)
	e3:SetTarget(c19048328.thtg)
	e3:SetOperation(c19048328.thop)
	c:RegisterEffect(e3)
	-- ③：1回合1次，对方场上的怪兽被战斗·效果破坏时才能发动。原本属性和那1只怪兽相同的1只幻龙族怪兽从自己卡组守备表示特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(19048328,1))  --"卡组怪兽特殊召唤"
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_DESTROYED)
	e4:SetRange(LOCATION_MZONE)
	e4:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e4:SetCountLimit(1)
	e4:SetCondition(c19048328.spcon)
	e4:SetTarget(c19048328.sptg)
	e4:SetOperation(c19048328.spop)
	c:RegisterEffect(e4)
end
-- 记录同调素材中「龙星」怪兽的属性并保存到效果标签中
function c19048328.matcheck(e,c)
	local g=c:GetMaterial():Filter(Card.IsSetCard,nil,0x9e)
	local att=0
	local tc=g:GetFirst()
	while tc do
		att=bit.bor(att,tc:GetOriginalAttribute())
		tc=g:GetNext()
	end
	e:SetLabel(att)
end
-- 判断此卡是否为同调召唤成功
function c19048328.regcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- 设置对方不能发动与同调素材属性相同的怪兽效果
function c19048328.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- ①：只要同调召唤的这张卡在怪兽区域存在，对方不能把原本属性和作为这张卡的同调素材的「龙星」怪兽相同的怪兽的效果发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(0,1)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e1:SetValue(c19048328.aclimit)
	e1:SetLabelObject(e:GetLabelObject())
	c:RegisterEffect(e1)
	local att=e:GetLabelObject():GetLabel()
	if bit.band(att,ATTRIBUTE_EARTH)~=0 then
		c:RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(19048328,2))  --"地属性「龙星」怪兽作为同调素材"
	end
	if bit.band(att,ATTRIBUTE_WATER)~=0 then
		c:RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(19048328,3))  --"水属性「龙星」怪兽作为同调素材"
	end
	if bit.band(att,ATTRIBUTE_FIRE)~=0 then
		c:RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(19048328,4))  --"炎属性「龙星」怪兽作为同调素材"
	end
	if bit.band(att,ATTRIBUTE_WIND)~=0 then
		c:RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(19048328,5))  --"风属性「龙星」怪兽作为同调素材"
	end
	if bit.band(att,ATTRIBUTE_LIGHT)~=0 then
		c:RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(19048328,6))  --"光属性「龙星」怪兽作为同调素材"
	end
	if bit.band(att,ATTRIBUTE_DARK)~=0 then
		c:RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(19048328,7))  --"暗属性「龙星」怪兽作为同调素材"
	end
	if bit.band(att,ATTRIBUTE_DIVINE)~=0 then
		c:RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(19048328,8))  --"神属性「龙星」怪兽作为同调素材"
	end
end
-- 判断对方发动的效果是否为怪兽效果且属性与同调素材属性相同
function c19048328.aclimit(e,re,tp)
	local att=e:GetLabelObject():GetLabel()
	return re:IsActiveType(TYPE_MONSTER) and bit.band(att,re:GetHandler():GetOriginalAttribute())~=0
end
-- 判断此卡是否为同调召唤成功且被战斗或效果破坏并送去墓地
function c19048328.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_DESTROY) and c:IsReason(REASON_BATTLE+REASON_EFFECT)
		and c:IsPreviousLocation(LOCATION_MZONE) and c:IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- 过滤满足条件的调整怪兽
function c19048328.thfilter(c)
	return c:IsType(TYPE_TUNER) and c:IsAbleToHand()
end
-- 设置效果发动时的操作信息，准备从卡组检索调整怪兽
function c19048328.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足检索调整怪兽的条件
	if chk==0 then return Duel.IsExistingMatchingCard(c19048328.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置效果发动时的操作信息，准备从卡组检索调整怪兽
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 执行从卡组检索调整怪兽并加入手牌的操作
function c19048328.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的调整怪兽
	local g=Duel.SelectMatchingCard(tp,c19048328.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的调整怪兽加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 过滤满足条件的被破坏怪兽
function c19048328.cfilter(c,p)
	return c:IsReason(REASON_BATTLE+REASON_EFFECT) and c:GetOriginalAttribute()~=0
		and c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousControler(p)
end
-- 判断是否有对方场上的怪兽被战斗或效果破坏
function c19048328.spcon(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(c19048328.cfilter,nil,1-tp)
	if g:GetCount()>0 then
		local att=0
		local tc=g:GetFirst()
		while tc do
			att=bit.bor(att,tc:GetOriginalAttribute())
			tc=g:GetNext()
		end
		e:SetLabel(att)
		return true
	else return false end
end
-- 过滤满足条件的幻龙族怪兽
function c19048328.spfilter(c,e,tp,att)
	return c:IsRace(RACE_WYRM) and bit.band(att,c:GetOriginalAttribute())~=0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 设置效果发动时的操作信息，准备从卡组特殊召唤幻龙族怪兽
function c19048328.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足特殊召唤幻龙族怪兽的条件
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查是否满足特殊召唤幻龙族怪兽的条件
		and Duel.IsExistingMatchingCard(c19048328.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp,e:GetLabel()) end
	-- 设置效果发动时的操作信息，准备从卡组特殊召唤幻龙族怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 执行从卡组特殊召唤幻龙族怪兽的操作
function c19048328.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否有足够的特殊召唤位置
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的幻龙族怪兽
	local g=Duel.SelectMatchingCard(tp,c19048328.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,e:GetLabel())
	if g:GetCount()>0 then
		-- 将选中的幻龙族怪兽以守备表示特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
