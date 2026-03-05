--エルシャドール・アノマリリス
-- 效果：
-- 「影依」怪兽＋水属性怪兽
-- 这张卡用融合召唤才能从额外卡组特殊召唤。
-- ①：只要这张卡在怪兽区域存在，双方不能用魔法·陷阱卡的效果从手卡·墓地把怪兽特殊召唤。
-- ②：这张卡被送去墓地的场合，以自己墓地1张「影依」魔法·陷阱卡为对象才能发动。那张卡加入手卡。
function c19261966.initial_effect(c)
	c:EnableReviveLimit()
	-- 设置融合召唤所需的属性为水属性
	aux.AddFusionProcShaddoll(c,ATTRIBUTE_WATER)
	-- 这张卡用融合召唤才能从额外卡组特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetCode(EFFECT_SPSUMMON_CONDITION)
	e2:SetRange(LOCATION_EXTRA)
	e2:SetValue(c19261966.splimit)
	c:RegisterEffect(e2)
	-- 只要这张卡在怪兽区域存在，双方不能用魔法·陷阱卡的效果从手卡·墓地把怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetTargetRange(1,1)
	e3:SetTarget(c19261966.sumlimit)
	c:RegisterEffect(e3)
	-- 这张卡被送去墓地的场合，以自己墓地1张「影依」魔法·陷阱卡为对象才能发动。那张卡加入手卡。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(19261966,0))  --"加入手卡"
	e4:SetCategory(CATEGORY_TOHAND)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e4:SetTarget(c19261966.thtg)
	e4:SetOperation(c19261966.thop)
	c:RegisterEffect(e4)
end
-- 限制只能通过融合召唤特殊召唤
function c19261966.splimit(e,se,sp,st)
	return bit.band(st,SUMMON_TYPE_FUSION)==SUMMON_TYPE_FUSION
end
-- 阻止双方使用魔法或陷阱卡的效果从手牌或墓地特殊召唤怪兽
function c19261966.sumlimit(e,c,sump,sumtype,sumpos,targetp,se)
	return se:IsActiveType(TYPE_SPELL+TYPE_TRAP) and se:IsHasType(EFFECT_TYPE_ACTIONS)
		and c:IsLocation(LOCATION_GRAVE+LOCATION_HAND) and c:IsType(TYPE_MONSTER)
end
-- 筛选墓地中的影依魔法或陷阱卡
function c19261966.thfilter(c)
	return c:IsSetCard(0x9d) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- 设置效果发动时的选择目标和处理信息
function c19261966.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c19261966.thfilter(chkc) end
	-- 检查是否有符合条件的墓地卡片可选
	if chk==0 then return Duel.IsExistingTarget(c19261966.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择目标卡片
	local g=Duel.SelectTarget(tp,c19261966.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置效果处理信息，指定将卡片送入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 执行效果，将目标卡片送入手牌
function c19261966.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果的目标卡片
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡片送入手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
