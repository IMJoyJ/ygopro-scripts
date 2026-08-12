--転生炎獣サンライトウルフ
-- 效果：
-- 炎属性效果怪兽2只
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡所连接区有怪兽召唤·特殊召唤的场合才能发动。从自己墓地把1只炎属性怪兽加入手卡。这个回合，自己不能把这个效果加入手卡的怪兽以及那些同名怪兽通常召唤·特殊召唤。
-- ②：这张卡是已用「转生炎兽 日光狼」为素材作连接召唤的场合才能发动。从自己墓地把1张「转生炎兽」魔法·陷阱卡加入手卡。
function c87871125.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡添加连接召唤手续，需要2只满足过滤条件的怪兽作为素材。
	aux.AddLinkProcedure(c,c87871125.matfilter,2,2)
	-- ①：这张卡所连接区有怪兽召唤·特殊召唤的场合才能发动。从自己墓地把1只炎属性怪兽加入手卡。这个回合，自己不能把这个效果加入手卡的怪兽以及那些同名怪兽通常召唤·特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(87871125,0))  --"墓地怪兽回收"
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,87871125)
	e1:SetCondition(c87871125.thcon1)
	e1:SetTarget(c87871125.thtg1)
	e1:SetOperation(c87871125.thop1)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：这张卡是已用「转生炎兽 日光狼」为素材作连接召唤的场合才能发动。从自己墓地把1张「转生炎兽」魔法·陷阱卡加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(87871125,1))  --"墓地魔陷回收"
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,87871126)
	e3:SetCondition(c87871125.thcon2)
	e3:SetTarget(c87871125.thtg2)
	e3:SetOperation(c87871125.thop2)
	c:RegisterEffect(e3)
	-- 这张卡是已用「转生炎兽 日光狼」为素材作连接召唤的场合（素材检查部分）
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_MATERIAL_CHECK)
	e4:SetValue(c87871125.valcheck)
	c:RegisterEffect(e4)
	-- 这张卡是已用「转生炎兽 日光狼」为素材作连接召唤的场合（召唤成功时注册标记部分）
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e5:SetCode(EVENT_SPSUMMON_SUCCESS)
	e5:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e5:SetCondition(c87871125.regcon)
	e5:SetOperation(c87871125.regop)
	c:RegisterEffect(e5)
	e4:SetLabelObject(e5)
end
-- 过滤条件：炎属性的效果怪兽。
function c87871125.matfilter(c)
	return c:IsLinkType(TYPE_EFFECT) and c:IsLinkAttribute(ATTRIBUTE_FIRE)
end
-- 过滤条件：检查怪兽是否被召唤·特殊召唤到这张卡的所连接区（包含场上判定及离场前的区域判定）。
function c87871125.cfilter(c,ec)
	if c:IsLocation(LOCATION_MZONE) then
		return ec:GetLinkedGroup():IsContains(c)
	else
		return bit.band(ec:GetLinkedZone(c:GetPreviousControler()),bit.lshift(0x1,c:GetPreviousSequence()))~=0
	end
end
-- 效果①的发动条件：有怪兽召唤·特殊召唤到这张卡的所连接区。
function c87871125.thcon1(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c87871125.cfilter,1,nil,e:GetHandler())
end
-- 过滤条件：自己墓地的炎属性怪兽且能加入手牌。
function c87871125.thfilter1(c)
	return c:IsAttribute(ATTRIBUTE_FIRE) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 效果①的靶向处理：检查自己墓地是否存在炎属性怪兽，并设置回收手牌的操作信息。
function c87871125.thtg1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己墓地是否存在至少1只满足条件的炎属性怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c87871125.thfilter1,tp,LOCATION_GRAVE,0,1,nil) end
	-- 设置操作信息：从自己墓地将1张卡加入手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
-- 效果①的运行处理：选择自己墓地1只炎属性怪兽加入手牌，并对该怪兽及其同名怪兽施加本回合不能通常召唤·特殊召唤的限制。
function c87871125.thop1(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 玩家选择自己墓地1只满足条件的炎属性怪兽（受王家长眠之谷影响）。
	local tc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c87871125.thfilter1),tp,LOCATION_GRAVE,0,1,1,nil):GetFirst()
	-- 若成功将选中的怪兽加入手牌。
	if tc and Duel.SendtoHand(tc,nil,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_HAND) then
		-- 给对方玩家确认加入手牌的卡。
		Duel.ConfirmCards(1-tp,tc)
		-- 这个回合，自己不能把这个效果加入手卡的怪兽以及那些同名怪兽通常召唤·特殊召唤。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CANNOT_SUMMON)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetTargetRange(1,0)
		e1:SetTarget(c87871125.sumlimit)
		e1:SetLabel(tc:GetCode())
		e1:SetReset(RESET_PHASE+PHASE_END)
		-- 注册不能通常召唤该同名怪兽的玩家效果。
		Duel.RegisterEffect(e1,tp)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		-- 注册不能特殊召唤该同名怪兽的玩家效果。
		Duel.RegisterEffect(e2,tp)
		local e3=e1:Clone()
		e3:SetCode(EFFECT_CANNOT_MSET)
		-- 注册不能盖放（通常召唤）该同名怪兽的玩家效果。
		Duel.RegisterEffect(e3,tp)
	end
end
-- 召唤限制的靶向过滤：判定是否为被加入手牌的同名怪兽。
function c87871125.sumlimit(e,c)
	return c:IsCode(e:GetLabel())
end
-- 效果②的发动条件：这张卡带有曾用「转生炎兽 日光狼」作为素材进行连接召唤的标记。
function c87871125.thcon2(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(87871125)~=0
end
-- 过滤条件：自己墓地的「转生炎兽」魔法·陷阱卡且能加入手牌。
function c87871125.thfilter2(c)
	return c:IsSetCard(0x119) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- 效果②的靶向处理：检查自己墓地是否存在「转生炎兽」魔法·陷阱卡，并设置回收手牌的操作信息。
function c87871125.thtg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己墓地是否存在至少1张满足条件的「转生炎兽」魔法·陷阱卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c87871125.thfilter2,tp,LOCATION_GRAVE,0,1,nil) end
	-- 设置操作信息：从自己墓地将1张卡加入手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
-- 效果②的运行处理：选择自己墓地1张「转生炎兽」魔法·陷阱卡加入手牌。
function c87871125.thop2(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 玩家选择自己墓地1张满足条件的「转生炎兽」魔法·陷阱卡。
	local g=Duel.SelectMatchingCard(tp,c87871125.thfilter2,tp,LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		-- 将选中的卡加入手牌。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手牌的卡。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 检查连接素材中是否包含「转生炎兽 日光狼」，并向注册效果传递标记。
function c87871125.valcheck(e,c)
	local g=c:GetMaterial()
	if g:IsExists(Card.IsLinkCode,1,nil,87871125) then
		e:GetLabelObject():SetLabel(1)
	else
		e:GetLabelObject():SetLabel(0)
	end
end
-- 注册标记的条件：这张卡是连接召唤成功，且素材检查标记为1。
function c87871125.regcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK) and e:GetLabel()==1
end
-- 注册标记的处理：给这张卡注册一个特定的Flag效果，用于判定是否曾用同名卡作为素材。
function c87871125.regop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(87871125,RESET_EVENT+RESETS_STANDARD,0,1)
end
