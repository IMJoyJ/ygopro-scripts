--真六武衆－シナイ
-- 效果：
-- 自己场上有「真六武众-瑞穂」表侧表示存在的场合，这张卡可以从手卡特殊召唤。场上存在的这张卡被解放的场合，选择自己墓地存在的「真六武众-竹刀」以外的1只名字带有「六武众」的怪兽加入手卡。
function c48505422.initial_effect(c)
	-- 自己场上有「真六武众-瑞穂」表侧表示存在的场合，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c48505422.spcon)
	c:RegisterEffect(e1)
	-- 场上存在的这张卡被解放的场合，选择自己墓地存在的「真六武众-竹刀」以外的1只名字带有「六武众」的怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(48505422,0))  --"墓地回收"
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_RELEASE)
	e2:SetCondition(c48505422.rlcon)
	e2:SetTarget(c48505422.rltg)
	e2:SetOperation(c48505422.rlop)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于判断场上是否存在「真六武众-瑞穂」（卡号74094021）且表侧表示的怪兽。
function c48505422.spfilter(c)
	return c:IsFaceup() and c:IsCode(74094021)
end
-- 判断是否满足特殊召唤条件：手牌的这张卡可以特殊召唤到场上，且自己场上有「真六武众-瑞穂」表侧表示存在。
function c48505422.spcon(e,c)
	if c==nil then return true end
	-- 检查当前玩家在主要怪兽区是否有空位。
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0 and
		-- 检查当前玩家场上是否存在至少1只「真六武众-瑞穂」（卡号74094021）且表侧表示的怪兽。
		Duel.IsExistingMatchingCard(c48505422.spfilter,c:GetControler(),LOCATION_ONFIELD,0,1,nil)
end
-- 判断该卡是否在解放前处于场上的位置。
function c48505422.rlcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 过滤函数，用于筛选墓地中的名字带有「六武众」（0x103d）且不是「真六武众-竹刀」（48505422）的怪兽。
function c48505422.filter(c)
	return c:IsSetCard(0x103d) and not c:IsCode(48505422) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 设置效果目标：选择自己墓地中满足条件的1只怪兽作为目标。
function c48505422.rltg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c48505422.filter(chkc) end
	-- 检查是否至少存在1只满足条件的墓地怪兽。
	if chk==0 then return Duel.IsExistingTarget(c48505422.filter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从玩家墓地中选择满足条件的1只怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,c48505422.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置连锁操作信息，表示将选择的怪兽送入手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 处理效果发动后的操作：将目标怪兽加入手牌并确认对方看到该卡。
function c48505422.rlop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前效果的目标卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽以效果原因送入手牌。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 向对方玩家确认该卡的加入手牌动作。
		Duel.ConfirmCards(1-tp,tc)
	end
end
