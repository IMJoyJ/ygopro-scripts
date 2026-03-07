--水精鱗－リードアビス
-- 效果：
-- 自己的主要阶段时，从手卡把这张卡以外的3只水属性怪兽丢弃去墓地才能发动。这张卡从手卡特殊召唤。这个效果特殊召唤成功时，可以从自己墓地选择1张名字带有「深渊」的魔法·陷阱卡加入手卡。此外，可以通过把这张卡以外的自己场上表侧攻击表示存在的1只名字带有「水精鳞」的怪兽解放，对方手卡随机1张送去墓地。「水精鳞-利兹深渊鱼」的这个效果1回合只能使用1次。
function c37781520.initial_effect(c)
	-- 自己主要阶段时，从手卡把这张卡以外的3只水属性怪兽丢弃去墓地才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(37781520,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCost(c37781520.spcost)
	e1:SetTarget(c37781520.sptg)
	e1:SetOperation(c37781520.spop)
	c:RegisterEffect(e1)
	-- 这个效果特殊召唤成功时，可以从自己墓地选择1张名字带有「深渊」的魔法·陷阱卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(37781520,1))  --"魔陷回收"
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(c37781520.thcon)
	e2:SetTarget(c37781520.thtg)
	e2:SetOperation(c37781520.thop)
	c:RegisterEffect(e2)
	-- 此外，可以通过把这张卡以外的自己场上表侧攻击表示存在的1只名字带有「水精鳞」的怪兽解放，对方手卡随机1张送去墓地。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(37781520,2))  --"手牌送墓"
	e3:SetCategory(CATEGORY_TOGRAVE)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,37781520)
	e3:SetCost(c37781520.hdcost)
	e3:SetTarget(c37781520.hdtg)
	e3:SetOperation(c37781520.hdop)
	c:RegisterEffect(e3)
end
-- 检索满足条件的水属性可丢弃怪兽组
function c37781520.cfilter(c)
	return c:IsAttribute(ATTRIBUTE_WATER) and c:IsDiscardable() and c:IsAbleToGraveAsCost()
end
-- 检查是否满足丢弃3张水属性手牌的条件并执行丢弃操作
function c37781520.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足丢弃3张水属性手牌的条件
	if chk==0 then return Duel.IsExistingMatchingCard(c37781520.cfilter,tp,LOCATION_HAND,0,3,e:GetHandler()) end
	-- 执行丢弃3张水属性手牌的操作
	Duel.DiscardHand(tp,c37781520.cfilter,3,3,REASON_COST+REASON_DISCARD,e:GetHandler())
end
-- 检查特殊召唤的条件是否满足
function c37781520.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查目标玩家场上是否有足够的召唤区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤的连锁操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 执行特殊召唤操作
function c37781520.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将卡片特殊召唤到场上
	Duel.SpecialSummon(c,SUMMON_VALUE_SELF,tp,tp,false,false,POS_FACEUP)
end
-- 判断该卡是否为特殊召唤成功
function c37781520.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetSummonType()==SUMMON_TYPE_SPECIAL+SUMMON_VALUE_SELF
end
-- 检索满足条件的「深渊」魔法·陷阱卡
function c37781520.thfilter(c)
	return c:IsSetCard(0x75) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- 设置选择墓地「深渊」魔法·陷阱卡的处理信息
function c37781520.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c37781520.thfilter(chkc) end
	-- 检查是否存在满足条件的墓地「深渊」魔法·陷阱卡
	if chk==0 then return Duel.IsExistingTarget(c37781520.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要返回手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择满足条件的墓地「深渊」魔法·陷阱卡
	local g=Duel.SelectTarget(tp,c37781520.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置将卡返回手牌的连锁操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 执行将卡返回手牌的操作
function c37781520.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡送入手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 确认对方查看送入手牌的卡
		Duel.ConfirmCards(1-tp,tc)
	end
end
-- 检索满足条件的「水精鳞」攻击表示怪兽
function c37781520.costfilter(c)
	return c:IsPosition(POS_FACEUP_ATTACK) and c:IsSetCard(0x74)
end
-- 设置解放「水精鳞」怪兽的处理信息
function c37781520.hdcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足解放1只「水精鳞」怪兽的条件
	if chk==0 then return Duel.CheckReleaseGroup(tp,c37781520.costfilter,1,e:GetHandler()) end
	-- 选择满足条件的「水精鳞」怪兽进行解放
	local sg=Duel.SelectReleaseGroup(tp,c37781520.costfilter,1,1,e:GetHandler())
	-- 执行解放操作
	Duel.Release(sg,REASON_COST)
end
-- 设置对方手牌送去墓地的处理信息
function c37781520.hdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方手牌是否存在
	if chk==0 then return Duel.GetFieldGroupCount(1-tp,LOCATION_HAND,0)~=0 end
	-- 设置将对方手牌送去墓地的连锁操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,1-tp,LOCATION_HAND)
end
-- 执行将对方手牌送去墓地的操作
function c37781520.hdop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方手牌组
	local g=Duel.GetFieldGroup(1-tp,LOCATION_HAND,0)
	if g:GetCount()==0 then return end
	local sg=g:RandomSelect(1-tp,1)
	-- 将选择的对方手牌送去墓地
	Duel.SendtoGrave(sg,REASON_EFFECT)
end
