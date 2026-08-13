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
-- 筛选手牌中满足以下条件的怪兽：属于「空牙团」字段、不是「空牙团的参谋 西尔」自身、且能够被当前效果特殊召唤。
function c20345391.spfilter(c,e,tp)
	return c:IsSetCard(0x114) and not c:IsCode(20345391) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 发动时点检查：自己主要怪兽区有空位，并且手牌中存在满足特殊召唤条件的「空牙团」怪兽。
function c20345391.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上主要怪兽区是否有可用的空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手牌中是否存在至少1只满足spfilter条件的「空牙团」怪兽。
		and Duel.IsExistingMatchingCard(c20345391.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置本次效果处理时要从手牌特殊召唤1只怪兽的操作信息，使其他卡能正确连锁或检测该效果。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果处理：从手牌选择1只符合条件的「空牙团」怪兽，以表侧表示特殊召唤到自己场上。
function c20345391.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 若自己主要怪兽区没有空位，则效果处理直接终止。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家显示“请选择要特殊召唤的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手牌中选择1只满足条件的「空牙团」怪兽。
	local g=Duel.SelectMatchingCard(tp,c20345391.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧表示特殊召唤到自己的主要怪兽区。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 判断一张卡是否是表侧表示、属于「空牙团」字段且由自己控制。
function c20345391.cfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0x114) and c:IsControler(tp)
end
-- 触发条件：特殊召唤成功的怪兽中不包含这张卡自身，且其中存在至少1只表侧表示、由自己控制的「空牙团」怪兽，即自己场上有本卡以外的「空牙团」怪兽被特殊召唤。
function c20345391.thcon(e,tp,eg,ep,ev,re,r,rp)
	return not eg:IsContains(e:GetHandler()) and eg:IsExists(c20345391.cfilter,1,nil,tp)
end
-- 筛选墓地的怪兽：属于「空牙团」字段、是怪兽卡且能够加入手牌。
function c20345391.thfilter(c)
	return c:IsSetCard(0x114) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 发动时点选择自己墓地1只符合条件的「空牙团」怪兽作为对象，并设置将其加入手牌的操作信息。
function c20345391.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c20345391.thfilter(chkc) end
	-- 检查自己墓地是否存在至少1只满足条件的「空牙团」怪兽。
	if chk==0 then return Duel.IsExistingTarget(c20345391.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 向玩家显示“请选择要加入手牌的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让自己从墓地选择1只符合条件的「空牙团」怪兽作为效果对象。
	local sg=Duel.SelectTarget(tp,c20345391.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置本次效果处理时要把已选择的怪兽加入手牌的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,sg,sg:GetCount(),0,0)
end
-- 效果处理：取得之前选择的墓地怪兽，若该卡仍与效果有关联则将其加入手牌。
function c20345391.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁中以此效果为对象的卡片（墓地中选择的「空牙团」怪兽）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象卡以效果原因加入其持有者的手牌。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
