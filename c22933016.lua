--Aiドリング・ボーン
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：以自己墓地1只「@火灵天星」怪兽为对象才能发动。那只怪兽特殊召唤。这张卡的发动后，直到回合结束时自己不是电子界族怪兽不能特殊召唤。
-- ②：怪兽之间进行战斗的攻击宣言时，把墓地的这张卡和1张手卡除外，从自己墓地的卡以及除外的自己的卡之中以「“艾”闲者苏生」以外的1张「“艾”」魔法·陷阱卡为对象才能发动。那张卡加入手卡。
function c22933016.initial_effect(c)
	-- ①：以自己墓地1只「@火灵天星」怪兽为对象才能发动。那只怪兽特殊召唤。这张卡的发动后，直到回合结束时自己不是电子界族怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,22933016)
	e1:SetTarget(c22933016.target)
	e1:SetOperation(c22933016.activate)
	c:RegisterEffect(e1)
	-- ②：怪兽之间进行战斗的攻击宣言时，把墓地的这张卡和1张手卡除外，从自己墓地的卡以及除外的自己的卡之中以「“艾”闲者苏生」以外的1张「“艾”」魔法·陷阱卡为对象才能发动。那张卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(22933016,0))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,22933017)
	e2:SetCondition(c22933016.thcon)
	e2:SetCost(c22933016.thcost)
	e2:SetTarget(c22933016.thtg)
	e2:SetOperation(c22933016.thop)
	c:RegisterEffect(e2)
end
-- 过滤函数：选择自己墓地中属于「@火灵天星」系列且可以特殊召唤的怪兽。
function c22933016.filter(c,e,tp)
	return c:IsSetCard(0x135) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①效果的发动判定与对象选择处理：先检查对象卡是否合法（自己墓地且符合filter），再确认场上是否有特殊召唤空位且墓地存在符合条件的对象。
function c22933016.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c22933016.filter(chkc,e,tp) end
	-- 检查自己主要怪兽区是否存在可用空格，以准备特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 确认自己墓地存在至少1只满足「@火灵天星」且可特殊召唤的怪兽可作为对象。
		and Duel.IsExistingTarget(c22933016.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 给玩家显示“请选择要特殊召唤的卡”的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己墓地选择1只符合条件的「@火灵天星」怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,c22933016.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置本次连锁将进行1只怪兽的特殊召唤的操作信息，供后续效果检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- ①效果处理：将对象怪兽特殊召唤；若此卡是作为魔法卡发动，则给自己附加直到回合结束只能特殊召唤电子界族怪兽的自肃效果。
function c22933016.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果处理时选择的第1张对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽以表侧表示特殊召唤到自己的主要怪兽区。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		-- 这张卡的发动后，直到回合结束时自己不是电子界族怪兽不能特殊召唤。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e1:SetTargetRange(1,0)
		e1:SetTarget(c22933016.splimit)
		e1:SetReset(RESET_PHASE+PHASE_END)
		-- 将自肃效果注册给当前玩家，使其在回合结束前受到“不能特殊召唤电子界族以外怪兽”的限制。
		Duel.RegisterEffect(e1,tp)
	end
end
-- 自肃效果的过滤条件：不是电子界族怪兽的怪兽不能被特殊召唤。
function c22933016.splimit(e,c)
	return not c:IsRace(RACE_CYBERSE)
end
-- ②效果的发动条件：存在攻击怪兽和攻击对象，即怪兽之间进行战斗的攻击宣言时。
function c22933016.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前时点是否为怪兽之间的攻击宣言（攻击怪兽和攻击对象都存在）。
	return Duel.GetAttacker() and Duel.GetAttackTarget()
end
-- ②效果的代价处理：从墓地除外自身，并从手卡选择1张卡除外；检查代价是否可支付。
function c22933016.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToRemoveAsCost()
		-- 确认手卡中至少存在1张可以作为代价除外的卡。
		and Duel.IsExistingMatchingCard(Card.IsAbleToRemoveAsCost,tp,LOCATION_HAND,0,1,nil) end
	-- 给玩家显示“请选择要除外的卡”的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从手卡选择1张卡作为②效果的代价（将与此卡一起除外）。
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToRemoveAsCost,tp,LOCATION_HAND,0,1,1,nil)
	g:AddCard(c)
	-- 将选择的1张手卡和墓地的这张卡以表侧表示除外，作为发动代价。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 过滤函数：选择位于自己墓地或除外区表侧表示、属于「“艾”」系列且不是「“艾”闲者苏生」的魔法·陷阱卡，且该卡可加入手牌。
function c22933016.thfilter(c)
	return (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup()) and c:IsSetCard(0x136) and c:IsType(TYPE_SPELL+TYPE_TRAP) and not c:IsCode(22933016) and c:IsAbleToHand()
end
-- ②效果的发动条件与对象选择：确认存在符合条件的「“艾”」魔法·陷阱卡可作为对象；提示玩家选择1张并设为对象，同时设置回手牌的操作信息。
function c22933016.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and chkc:IsControler(tp) and c22933016.thfilter(chkc) end
	-- 确认自己墓地或除外区存在至少1张符合条件的「“艾”」魔法·陷阱卡可作为对象。
	if chk==0 then return Duel.IsExistingTarget(c22933016.thfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,e:GetHandler()) end
	-- 给玩家显示“请选择要加入手牌的卡”的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从自己墓地或除外区选择1张符合条件的「“艾”」魔法·陷阱卡作为效果对象。
	local g=Duel.SelectTarget(tp,c22933016.thfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,e:GetHandler())
	-- 设置本次连锁将进行1张卡加入手牌的操作信息，供后续检测。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- ②效果处理：将作为对象的「“艾”」魔法·陷阱卡加入手牌。
function c22933016.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果处理时选择的对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象卡加入其持有者的手牌。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
