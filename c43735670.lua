--海晶乙女ブルースラッグ
-- 效果：
-- 4星以下的「海晶少女」怪兽1只
-- 自己对「海晶少女 青高海牛」1回合只能有1次连接召唤。
-- ①：这张卡连接召唤成功的场合，以「海晶少女 青高海牛」以外的自己墓地1只「海晶少女」怪兽为对象才能发动。那只怪兽加入手卡。这个效果的发动后，直到回合结束时自己不是水属性怪兽不能特殊召唤。
function c43735670.initial_effect(c)
	-- 添加连接召唤手续，要求使用1只4星以下的「海晶少女」怪兽作为连接素材
	aux.AddLinkProcedure(c,c43735670.mfilter,1,1)
	c:EnableReviveLimit()
	-- 这张卡连接召唤成功的场合，以「海晶少女 青高海牛」以外的自己墓地1只「海晶少女」怪兽为对象才能发动。那只怪兽加入手卡。这个效果的发动后，直到回合结束时自己不是水属性怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c43735670.regcon)
	e1:SetOperation(c43735670.regop)
	c:RegisterEffect(e1)
	-- ①：这张卡连接召唤成功的场合，以「海晶少女 青高海牛」以外的自己墓地1只「海晶少女」怪兽为对象才能发动。那只怪兽加入手卡。这个效果的发动后，直到回合结束时自己不是水属性怪兽不能特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(43735670,0))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCondition(c43735670.thcon)
	e2:SetTarget(c43735670.thtg)
	e2:SetOperation(c43735670.thop)
	c:RegisterEffect(e2)
end
-- 过滤满足条件的连接素材：4星以下且属于「海晶少女」系列的怪兽
function c43735670.mfilter(c)
	return c:IsLevelBelow(4) and c:IsLinkSetCard(0x12b)
end
-- 判断是否为连接召唤成功
function c43735670.regcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
-- 创建一个场上的效果，使自己不能特殊召唤怪兽
function c43735670.regop(e,tp,eg,ep,ev,re,r,rp)
	-- 创建一个场上的效果，使自己不能特殊召唤怪兽
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTarget(c43735670.splimit)
	-- 将效果注册到玩家的场上
	Duel.RegisterEffect(e1,tp)
end
-- 限制自己不能特殊召唤「海晶少女 青高海牛」的连接召唤
function c43735670.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return c:IsCode(43735670) and bit.band(sumtype,SUMMON_TYPE_LINK)==SUMMON_TYPE_LINK
end
-- 判断是否为连接召唤成功
function c43735670.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
-- 过滤满足条件的墓地怪兽：属于「海晶少女」系列、是怪兽、不是「海晶少女 青高海牛」且能加入手牌
function c43735670.thfilter(c)
	return c:IsSetCard(0x12b) and c:IsType(TYPE_MONSTER) and not c:IsCode(43735670) and c:IsAbleToHand()
end
-- 设置选择目标：从自己墓地选择1只满足条件的「海晶少女」怪兽
function c43735670.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c43735670.thfilter(chkc) end
	-- 检查是否有满足条件的墓地怪兽
	if chk==0 then return Duel.IsExistingTarget(c43735670.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的墓地怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c43735670.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置效果处理信息，指定将目标怪兽加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 处理效果：将选中的墓地怪兽加入手牌，并设置后续效果
function c43735670.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的效果对象卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象卡加入手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
	-- 创建一个场上的效果，使自己不能特殊召唤非水属性怪兽
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c43735670.splimit2)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将效果注册到玩家的场上
	Duel.RegisterEffect(e1,tp)
end
-- 限制自己不能特殊召唤非水属性怪兽
function c43735670.splimit2(e,c)
	return not c:IsAttribute(ATTRIBUTE_WATER)
end
