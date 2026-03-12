--RR－ヒール・イーグル
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己场上的怪兽只有「急袭猛禽」怪兽的场合才能发动。这张卡从手卡特殊召唤。
-- ②：把墓地的这张卡除外，以自己墓地1张「急袭猛禽」魔法·陷阱卡为对象才能发动。那张卡加入手卡。
function c51933043.initial_effect(c)
	-- ①：自己场上的怪兽只有「急袭猛禽」怪兽的场合才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(51933043,1))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,51933043)
	e1:SetCondition(c51933043.sscon)
	e1:SetTarget(c51933043.sstg)
	e1:SetOperation(c51933043.ssop)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外，以自己墓地1张「急袭猛禽」魔法·陷阱卡为对象才能发动。那张卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,51933044)
	-- 效果的发动费用为将此卡除外
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c51933043.thtg)
	e2:SetOperation(c51933043.thop)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于判断场上是否存在非「急袭猛禽」怪兽或表示朝下的怪兽
function c51933043.ssfilter(c)
	return not c:IsSetCard(0xba) or c:IsFacedown()
end
-- 条件函数，检查是否满足①效果的发动条件：场上存在怪兽且只有「急袭猛禽」怪兽
function c51933043.sscon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在怪兽
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)>0
		-- 检查自己场上是否存在非「急袭猛禽」怪兽或表示朝下的怪兽
		and not Duel.IsExistingMatchingCard(c51933043.ssfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 设置①效果的发动条件：场地上有空位且此卡可特殊召唤
function c51933043.sstg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场地上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁处理信息，表示将要特殊召唤此卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①效果的处理函数，执行特殊召唤操作
function c51933043.ssop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将此卡以正面表示形式特殊召唤到自己场上
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- 过滤函数，用于筛选墓地中的「急袭猛禽」魔法·陷阱卡
function c51933043.thfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSetCard(0xba) and c:IsAbleToHand()
end
-- ②效果的目标选择函数，选择一张可加入手牌的「急袭猛禽」魔法·陷阱卡
function c51933043.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c51933043.thfilter(chkc) end
	-- 检查自己墓地中是否存在至少一张「急袭猛禽」魔法·陷阱卡
	if chk==0 then return Duel.IsExistingTarget(c51933043.thfilter,tp,LOCATION_GRAVE,0,1,e:GetHandler()) end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择一张目标卡
	local g=Duel.SelectTarget(tp,c51933043.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置连锁处理信息，表示将要将目标卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- ②效果的处理函数，执行将目标卡加入手牌的操作
function c51933043.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡以效果原因送入玩家手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
