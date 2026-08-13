--RR－ネクロ・ヴァルチャー
-- 效果：
-- ①：1回合1次，把自己场上1只「急袭猛禽」怪兽解放，以自己墓地1张「升阶魔法」魔法卡为对象才能发动。那张卡加入手卡。这个效果的发动后，直到回合结束时自己不用「升阶魔法」魔法卡的效果不能把怪兽超量召唤。
function c51814159.initial_effect(c)
	-- ①：1回合1次，把自己场上1只「急袭猛禽」怪兽解放，以自己墓地1张「升阶魔法」魔法卡为对象才能发动。那张卡加入手卡。这个效果的发动后，直到回合结束时自己不用「升阶魔法」魔法卡的效果不能把怪兽超量召唤。
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
-- 代价函数：检测并执行将我方场上1只「急袭猛禽」怪兽解放作为发动COST的操作。
function c51814159.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- cost检测：确认自己场上存在至少1只可解放的「急袭猛禽」怪兽，若没有则不能发动。
	if chk==0 then return Duel.CheckReleaseGroup(tp,Card.IsSetCard,1,nil,0xba) end
	-- 让玩家从自己场上选择1只「急袭猛禽」怪兽用于解放。
	local g=Duel.SelectReleaseGroup(tp,Card.IsSetCard,1,1,nil,0xba)
	-- 将选中的怪兽以代价（REASON_COST）解放。
	Duel.Release(g,REASON_COST)
end
-- 对象筛选：墓地中满足「升阶魔法」字段、魔法卡类型、且可加入手卡的卡。
function c51814159.thfilter(c)
	return c:IsSetCard(0x95) and c:IsType(TYPE_SPELL) and c:IsAbleToHand()
end
-- 目标函数：以自己墓地1张满足条件的「升阶魔法」魔法卡为对象；选择后设置加入手卡的操作信息。
function c51814159.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c51814159.thfilter(chkc) end
	-- 目标检测：确认自己墓地存在至少1张满足条件的「升阶魔法」魔法卡可作为对象，否则不能发动。
	if chk==0 then return Duel.IsExistingTarget(c51814159.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 显示选择提示：「请选择要加入手牌的卡」。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择自己墓地1张符合条件的「升阶魔法」魔法卡，并将其设为效果对象。
	local g=Duel.SelectTarget(tp,c51814159.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置操作信息：将选择的卡加入手牌（CATEGORY_TOHAND），数量1。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果处理：将对象卡加入手牌；然后给自己附加『不用「升阶魔法」效果不能超量召唤』的限制直到回合结束。
function c51814159.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果处理时对象卡（即目标墓地「升阶魔法」魔法卡）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象卡以效果原因加入持有者手牌。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
	-- 这个效果的发动后，直到回合结束时自己不用「升阶魔法」魔法卡的效果不能把怪兽超量召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c51814159.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将「不能用非升阶魔法效果超量召唤」的永续效果注册到该玩家，直到回合结束。
	Duel.RegisterEffect(e1,tp)
end
-- 限制条件：进行超量召唤时，若发动特殊召唤的效果卡不是「升阶魔法」字段，则不能进行该超量召唤。
function c51814159.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return bit.band(sumtype,SUMMON_TYPE_XYZ)==SUMMON_TYPE_XYZ and not se:GetHandler():IsSetCard(0x95)
end
