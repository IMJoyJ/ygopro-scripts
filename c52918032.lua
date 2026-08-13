--メメント・ウラモン
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤的场合，以「莫忘阁楼怪」以外的自己墓地1张「莫忘」卡为对象才能发动。那张卡加入手卡。
-- ②：这张卡被「莫忘」怪兽的效果送去墓地的场合才能发动。这张卡特殊召唤。
local s,id,o=GetID()
-- 注册本卡的两个效果：①效果分为特殊召唤成功和通常召唤成功两个触发效果，均执行回收墓地「莫忘」卡；②效果为被「莫忘」怪兽效果送去墓地时自身特殊召唤。
function s.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤的场合，以「莫忘阁楼怪」以外的自己墓地1张「莫忘」卡为对象才能发动。那张卡加入手卡。（此处为特殊召唤成功时的触发效果；通常召唤成功时由克隆效果处理）
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1,id)
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)
	local e2=e3:Clone()
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：这张卡被「莫忘」怪兽的效果送去墓地的场合才能发动。这张卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCountLimit(1,id+o)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
end
-- 定义①效果可回收的墓地卡过滤条件：必须是「莫忘」卡、能够加入手卡、且不是「莫忘阁楼怪」自身。
function s.thfilter(c,tp)
	return c:IsSetCard(0x1a1) and c:IsAbleToHand() and not c:IsCode(id)
end
-- ①效果发动时的目标选择流程：先验证连锁参数合法性，再检查是否存在可回收对象，存在则提示选择1张并登记为效果对象，同时设置回手牌的操作信息。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.thfilter(chkc) end
	-- 效果发动合法性检查：确认自己墓地存在至少1张满足条件的「莫忘」卡可作为对象。
	if chk==0 then return Duel.IsExistingTarget(s.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 给玩家显示“请选择要加入手牌的卡”的选择提示，并缓存该选择消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从自己墓地中选择1张符合条件的「莫忘」卡（不能选本卡）作为效果对象，同时将所选卡登记为当前连锁的对象。
	local sg=Duel.SelectTarget(tp,s.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置本次连锁的操作信息为“把对象卡加入手卡”，供后续效果检测和发动判定使用。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,sg,1,0,0)
end
-- ①效果处理：取得回收对象卡，若该卡仍与效果关联，则将其加入持有者手卡。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁选定的效果对象卡，即被回收的墓地「莫忘」卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象卡加入持有者手卡，原因为效果。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
-- ②效果的发动条件判定：本卡是因其效果被送去墓地，且该效果来源卡为「莫忘」怪兽。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	if not re then return false end
	local rc=re:GetHandler()
	return e:GetHandler():IsReason(REASON_EFFECT) and rc:IsSetCard(0x1a1) and rc:IsType(TYPE_MONSTER)
end
-- ②效果发动条件：己方主要怪兽区有空位且本卡能够被特殊召唤，同时设置将自身特殊召唤的操作信息。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查己方场上是否存在可用的主要怪兽区域空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：本连锁要将本卡特殊召唤，供后续效果检测和发动判定使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ②效果处理：若本卡仍与该效果关联，则将其表侧表示特殊召唤到己方场上。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将本卡以表侧表示特殊召唤到己方怪兽区，不检查召唤条件也不限制苏生限制。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
