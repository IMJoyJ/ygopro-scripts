--ティンダングル・ドールス
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡从手卡·卡组送去墓地的场合，以「廷达魔三角之巨噬蠕虫」以外的自己墓地1只「廷达魔三角」怪兽为对象才能发动。那只怪兽里侧守备表示特殊召唤。
-- ②：这张卡反转的场合才能发动。从卡组把1张魔法·陷阱卡送去墓地。
-- ③：这张卡为连接素材的「廷达魔三角」连接怪兽在同1次的战斗阶段中可以作3次攻击。
function c12678601.initial_effect(c)
	-- 这个卡名的①②的效果1回合各能使用1次。①：这张卡从手卡·卡组送去墓地的场合，以「廷达魔三角之巨噬蠕虫」以外的自己墓地1只「廷达魔三角」怪兽为对象才能发动。那只怪兽里侧守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(12678601,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_MSET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCountLimit(1,12678601)
	e1:SetCondition(c12678601.spcon)
	e1:SetTarget(c12678601.sptg)
	e1:SetOperation(c12678601.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡反转的场合才能发动。从卡组把1张魔法·陷阱卡送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(12678601,1))
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,12678602)
	e2:SetTarget(c12678601.tgtg)
	e2:SetOperation(c12678601.tgop)
	c:RegisterEffect(e2)
	-- ③：这张卡为连接素材的「廷达魔三角」连接怪兽在同1次的战斗阶段中可以作3次攻击。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_BE_MATERIAL)
	e3:SetCondition(c12678601.effcon)
	e3:SetOperation(c12678601.effop)
	c:RegisterEffect(e3)
end
-- 判定这张卡在被送去墓地之前处于手牌或卡组，以满足“从手卡·卡组送去墓地”的发动条件。
function c12678601.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_HAND+LOCATION_DECK)
end
-- 定义效果①的检索对象过滤器：自己墓地中持有「廷达魔三角」字段、不是「廷达魔三角之巨噬蠕虫」自身、且可以里侧守备表示特殊召唤的怪兽。
function c12678601.spfilter(c,e,tp)
	return c:IsSetCard(0x10b) and not c:IsCode(12678601) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE)
end
-- 效果①的发动时处理：先确认所取对象是己方墓地的合法候选；在非连锁处理时则检查己方主要怪兽区是否有空位且墓地存在可特殊召唤的对象，作为能否发动的条件。
function c12678601.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c12678601.spfilter(chkc,e,tp) end
	-- 检查己方主要怪兽区是否有可用怪兽区域，以确保特殊召唤有格子可用。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 继续检查墓地是否存在至少1只满足spfilter且能成为效果对象的怪兽，从而满足取对象特殊召唤的发动条件。
		and Duel.IsExistingTarget(c12678601.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 在玩家选择特殊召唤对象前，显示“请选择要特殊召唤的卡”的提示信息并缓存选择消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让发动玩家从自己墓地中通过spfilter筛选出的合法对象里选择1只，并登记为当前连锁的效果对象。
	local g=Duel.SelectTarget(tp,c12678601.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置本连锁的处理信息：将进行1只怪兽的特殊召唤，对象为已选择的g，供相关效果检测与后续处理使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果①处理时：取得对象怪兽，若其仍与效果关联且成功以里侧守备表示特殊召唤，则向对方玩家展示该怪兽。
function c12678601.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁效果处理时的第一张对象卡，即之前选择的那只墓地怪兽。
	local tc=Duel.GetFirstTarget()
	-- 若对象卡仍与效果e相关联，且能以里侧守备表示特殊召唤成功（返回值为非0），则执行特殊召唤。
	if tc:IsRelateToEffect(e) and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)~=0 then
		-- 将特殊召唤成功的怪兽向对方玩家公开确认（确认其卡面信息）。
		Duel.ConfirmCards(1-tp,tc)
	end
end
-- 定义效果②的送墓过滤器：卡组中的魔法·陷阱卡，并且当前可以被送去墓地。
function c12678601.tgfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToGrave()
end
-- 效果②的发动判定与操作信息设置：发动时确认卡组存在1张可送墓的魔法·陷阱卡，并设置把1张卡送去墓地的操作信息。
function c12678601.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1张满足tgfilter的魔法·陷阱卡，作为效果②能否发动的条件。
	if chk==0 then return Duel.IsExistingMatchingCard(c12678601.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置本连锁的操作信息：预计会从己方卡组把1张卡送去墓地，供其他效果（如星尘龙等）的发动检测使用。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 效果②处理时：提示玩家从卡组选择1张魔法·陷阱卡，并以效果原因将其送去墓地。
function c12678601.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 显示“请选择要送去墓地的卡”的提示信息，并将选择消息写入缓存。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从卡组中挑选1张满足tgfilter的魔法·陷阱卡（不取对象，在处理时选择）。
	local g=Duel.SelectMatchingCard(tp,c12678601.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡以效果原因REASON_EFFECT从卡组送去墓地。
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
-- ③效果的发动条件：这张卡作为连接素材被使用（r为REASON_LINK），且由此连接召唤出的怪兽属于「廷达魔三角」字段。
function c12678601.effcon(e,tp,eg,ep,ev,re,r,rp)
	return r==REASON_LINK and e:GetHandler():GetReasonCard():IsSetCard(0x10b)
end
-- ③效果处理：为以这张卡为素材连接召唤出的「廷达魔三角」连接怪兽附加额外攻击次数+2的效果，使其在1次战斗阶段中可以攻击3次；该效果在怪兽离场、回手、除外、里侧变化等标准重置时机失效。
function c12678601.effop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=c:GetReasonCard()
	-- ③：这张卡为连接素材的「廷达魔三角」连接怪兽在同1次的战斗阶段中可以作3次攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(12678601,2))  --"「廷达魔三角之巨噬蠕虫」作为连接素材"
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_EXTRA_ATTACK)
	e1:SetValue(2)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	rc:RegisterEffect(e1,true)
end
