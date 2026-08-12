--クロス・ポーター
-- 效果：
-- ①：以自己场上1只怪兽为对象才能发动。那只自己怪兽送去墓地，从手卡把1只「新空间侠」怪兽特殊召唤。
-- ②：这张卡被送去墓地时才能发动。从卡组把1只「新空间侠」怪兽加入手卡。
function c73146473.initial_effect(c)
	-- ①：以自己场上1只怪兽为对象才能发动。那只自己怪兽送去墓地，从手卡把1只「新空间侠」怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(73146473,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(c73146473.sptg)
	e1:SetOperation(c73146473.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡被送去墓地时才能发动。从卡组把1只「新空间侠」怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(73146473,1))  --"检索"
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetTarget(c73146473.thtg)
	e2:SetOperation(c73146473.thop)
	c:RegisterEffect(e2)
end
-- 过滤条件：判断怪兽是否可以作为送去墓地的对象（若场上没有空位，则必须选择主要怪兽区域的怪兽以腾出格子）
function c73146473.cfilter(c,ft)
	return ft>0 or c:GetSequence()<5
end
-- 过滤条件：手卡中可以特殊召唤的「新空间侠」怪兽
function c73146473.filter(c,e,tp)
	return c:IsSetCard(0x1f) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果①的发动准备（检查怪兽区域空格、寻找合法对象、确认手卡有可特召的怪兽并进行取对象）
function c73146473.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 获取玩家自己场上可用怪兽区域的数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c73146473.cfilter(chkc,ft) end
	-- 步骤0：检查场上是否存在可以作为对象的怪兽（若怪兽区域已满，则必须选择主要怪兽区域的怪兽以腾出格子）
	if chk==0 then return ft>-1 and Duel.IsExistingTarget(c73146473.cfilter,tp,LOCATION_MZONE,0,1,nil,ft)
		-- 并且手卡中存在可以特殊召唤的「新空间侠」怪兽
		and Duel.IsExistingMatchingCard(c73146473.filter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择自己场上1只怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c73146473.cfilter,tp,LOCATION_MZONE,0,1,1,nil,ft)
	-- 设置连锁信息：将选中的怪兽送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,1,0,0)
	-- 设置连锁信息：从手卡特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果①的处理：将作为对象的怪兽送去墓地，并从手卡特殊召唤1只「新空间侠」怪兽
function c73146473.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果①的对象怪兽
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	-- 将对象怪兽因效果送去墓地
	Duel.SendtoGrave(tc,REASON_EFFECT)
	-- 检查对象怪兽是否成功送去墓地，以及自己场上是否有可用的怪兽区域，若不满足则结束处理
	if not tc:IsLocation(LOCATION_GRAVE) or Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡选择1只满足条件的「新空间侠」怪兽
	local g=Duel.SelectMatchingCard(tp,c73146473.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧表示特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤条件：卡组中可以加入手卡的「新空间侠」怪兽
function c73146473.sfilter(c)
	return c:IsSetCard(0x1f) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 效果②的发动准备（检查卡组中是否存在可检索的怪兽并设置连锁信息）
function c73146473.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 步骤0：检查卡组中是否存在可以加入手卡的「新空间侠」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c73146473.sfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁信息：从卡组将1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果②的处理：从卡组把1只「新空间侠」怪兽加入手卡并给对方确认
function c73146473.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组选择1只满足条件的「新空间侠」怪兽
	local g=Duel.SelectMatchingCard(tp,c73146473.sfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的怪兽加入手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手卡的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
