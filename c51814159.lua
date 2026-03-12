--RR－ネクロ・ヴァルチャー
-- 效果：
-- ①：1回合1次，把自己场上1只「急袭猛禽」怪兽解放，以自己墓地1张「升阶魔法」魔法卡为对象才能发动。那张卡加入手卡。这个效果的发动后，直到回合结束时自己不用「升阶魔法」魔法卡的效果不能把怪兽超量召唤。
function c51814159.initial_effect(c)
	-- 效果原文内容：①：1回合1次，把自己场上1只「急袭猛禽」怪兽解放，以自己墓地1张「升阶魔法」魔法卡为对象才能发动。那张卡加入手卡。这个效果的发动后，直到回合结束时自己不用「升阶魔法」魔法卡的效果不能把怪兽超量召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(51814159,0))
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(c51814159.thcost)
	e1:SetTarget(c51814159.thtg)
	e1:SetOperation(c51814159.thop)
	c:RegisterEffect(e1)
end
-- 检查玩家场上是否存在至少1只可解放的「急袭猛禽」怪兽，并选择其中1只进行解放。
function c51814159.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足条件：玩家场上是否存在至少1只可解放的「急袭猛禽」怪兽。
	if chk==0 then return Duel.CheckReleaseGroup(tp,Card.IsSetCard,1,nil,0xba) end
	-- 从玩家场上选择1只满足条件的「急袭猛禽」怪兽作为解放对象。
	local g=Duel.SelectReleaseGroup(tp,Card.IsSetCard,1,1,nil,0xba)
	-- 以REASON_COST原因将所选怪兽进行解放。
	Duel.Release(g,REASON_COST)
end
-- 过滤函数：判断卡片是否为「升阶魔法」魔法卡且能加入手牌。
function c51814159.thfilter(c)
	return c:IsSetCard(0x95) and c:IsType(TYPE_SPELL) and c:IsAbleToHand()
end
-- 设置效果目标：选择玩家墓地中的1张「升阶魔法」魔法卡作为对象。
function c51814159.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c51814159.thfilter(chkc) end
	-- 判断是否满足条件：玩家墓地中是否存在至少1张「升阶魔法」魔法卡。
	if chk==0 then return Duel.IsExistingTarget(c51814159.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从玩家墓地中选择1张「升阶魔法」魔法卡作为效果对象。
	local g=Duel.SelectTarget(tp,c51814159.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置操作信息：将所选卡加入手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果处理函数：将目标卡加入手牌，并设置后续限制效果。
function c51814159.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的效果对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡以REASON_EFFECT原因送入手牌。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
	-- 效果原文内容：这个效果的发动后，直到回合结束时自己不用「升阶魔法」魔法卡的效果不能把怪兽超量召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c51814159.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将限制效果注册给玩家，使其在回合结束前无法使用「升阶魔法」魔法卡的效果进行超量召唤。
	Duel.RegisterEffect(e1,tp)
end
-- 限制函数：判断是否为超量召唤且召唤所用的卡不是「升阶魔法」魔法卡。
function c51814159.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return bit.band(sumtype,SUMMON_TYPE_XYZ)==SUMMON_TYPE_XYZ and not se:GetHandler():IsSetCard(0x95)
end
