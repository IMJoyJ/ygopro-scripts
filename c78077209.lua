--魔竜将ディアボリカ
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：这张卡在手卡·墓地存在，「魔龙将 迪亚波利卡」以外的恶魔族怪兽被效果送去自己墓地的场合才能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
-- ②：这张卡被效果送去墓地的场合，以「魔龙将 迪亚波利卡」以外的自己墓地1只恶魔族怪兽为对象才能发动。那只怪兽加入手卡。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含①效果（手卡·墓地特召）和②效果（送墓回收墓地恶魔族）。
function s.initial_effect(c)
	-- ①：这张卡在手卡·墓地存在，「魔龙将 迪亚波利卡」以外的恶魔族怪兽被效果送去自己墓地的场合才能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡被效果送去墓地的场合，以「魔龙将 迪亚波利卡」以外的自己墓地1只恶魔族怪兽为对象才能发动。那只怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.thcon)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
-- 过滤条件：被效果送去自己墓地的、「魔龙将 迪亚波利卡」以外的恶魔族怪兽。
function s.cfilter(c,tp)
	return c:IsRace(RACE_FIEND) and c:IsReason(REASON_EFFECT) and c:IsControler(tp) and not c:IsCode(id)
end
-- ①效果的发动条件：不包含自身，且存在满足条件的恶魔族怪兽被效果送去自己墓地。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return not eg:IsContains(e:GetHandler()) and eg:IsExists(s.cfilter,1,nil,tp)
end
-- ①效果的发动准备与合法性检测（检测怪兽区域空位及自身是否能特殊召唤）。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁信息，表明该效果包含将自身特殊召唤的操作。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①效果的处理：将自身特殊召唤，并添加离场时除外的永续效果。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 若此卡仍与效果关联，则将其以表侧表示特殊召唤。
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 这个效果特殊召唤的这张卡从场上离开的场合除外。②：这张卡被效果送去墓地的场合，以「魔龙将 迪亚波利卡」以外的自己墓地1只恶魔族怪兽为对象才能发动。那只怪兽加入手卡。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e1,true)
	end
end
-- ②效果的发动条件：此卡因效果被送去墓地。
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(r,REASON_EFFECT)~=0
end
-- 过滤条件：自己墓地中「魔龙将 迪亚波利卡」以外的、可以加入手卡的恶魔族怪兽。
function s.thfilter(c)
	return c:IsRace(RACE_FIEND) and c:IsAbleToHand() and not c:IsCode(id)
end
-- ②效果的发动准备：选择自己墓地1只满足条件的恶魔族怪兽作为对象。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.thfilter(chkc) end
	-- 检查自己墓地是否存在可以加入手卡的恶魔族怪兽。
	if chk==0 then return Duel.IsExistingTarget(s.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择自己墓地1只满足条件的恶魔族怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,s.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置连锁信息，表明该效果包含将选中的卡加入手牌的操作。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- ②效果的处理：将作为对象的怪兽加入手卡。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中作为效果对象的卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽因效果加入手卡。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
