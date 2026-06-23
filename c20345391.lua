--空牙団の参謀 シール
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己主要阶段才能发动。从手卡把「空牙团的参谋 西尔」以外的1只「空牙团」怪兽特殊召唤。
-- ②：这张卡已在怪兽区域存在的状态，自己场上有这张卡以外的「空牙团」怪兽特殊召唤的场合，以自己墓地1只「空牙团」怪兽为对象才能发动。那只怪兽加入手卡。
function c20345391.initial_effect(c)
	-- ①：自己主要阶段才能发动。从手卡把「空牙团的参谋 西尔」以外的1只「空牙团」怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(20345391,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1,20345391)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(c20345391.sptg)
	e1:SetOperation(c20345391.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡已在怪兽区域存在的状态，自己场上有这张卡以外的「空牙团」怪兽特殊召唤的场合，以自己墓地1只「空牙团」怪兽为对象才能发动。那只怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(20345391,1))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,20345392)
	e2:SetCondition(c20345391.thcon)
	e2:SetTarget(c20345391.thtg)
	e2:SetOperation(c20345391.thop)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于判断手卡中是否满足条件的「空牙团」怪兽（不包括西尔自身）
function c20345391.spfilter(c,e,tp)
	return c:IsSetCard(0x114) and not c:IsCode(20345391) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动时的处理函数，用于判断是否满足发动条件
function c20345391.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断场上是否有足够的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断手卡中是否存在满足条件的「空牙团」怪兽
		and Duel.IsExistingMatchingCard(c20345391.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置效果发动时的操作信息，表示将要特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果发动时的处理函数，用于执行特殊召唤操作
function c20345391.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断场上是否有足够的怪兽区域
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的1只怪兽
	local g=Duel.SelectMatchingCard(tp,c20345391.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤函数，用于判断场上是否有满足条件的「空牙团」怪兽
function c20345391.cfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0x114) and c:IsControler(tp)
end
-- 触发效果的条件函数，判断是否满足发动条件
function c20345391.thcon(e,tp,eg,ep,ev,re,r,rp)
	return not eg:IsContains(e:GetHandler()) and eg:IsExists(c20345391.cfilter,1,nil,tp)
end
-- 过滤函数，用于判断墓地中是否满足条件的「空牙团」怪兽
function c20345391.thfilter(c)
	return c:IsSetCard(0x114) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 效果发动时的处理函数，用于判断是否满足发动条件并选择目标
function c20345391.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c20345391.thfilter(chkc) end
	-- 判断墓地中是否存在满足条件的「空牙团」怪兽
	if chk==0 then return Duel.IsExistingTarget(c20345391.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要加入手牌的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的1只怪兽作为目标
	local sg=Duel.SelectTarget(tp,c20345391.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置效果发动时的操作信息，表示将要将1只怪兽加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,sg,sg:GetCount(),0,0)
end
-- 效果发动时的处理函数，用于执行将怪兽加入手牌的操作
function c20345391.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽加入手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
