--水精鱗－リードアビス
-- 效果：
-- 自己的主要阶段时，从手卡把这张卡以外的3只水属性怪兽丢弃去墓地才能发动。这张卡从手卡特殊召唤。这个效果特殊召唤成功时，可以从自己墓地选择1张名字带有「深渊」的魔法·陷阱卡加入手卡。此外，可以通过把这张卡以外的自己场上表侧攻击表示存在的1只名字带有「水精鳞」的怪兽解放，对方手卡随机1张送去墓地。「水精鳞-利兹深渊鱼」的这个效果1回合只能使用1次。
function c37781520.initial_effect(c)
	-- 自己的主要阶段时，从手卡把这张卡以外的3只水属性怪兽丢弃去墓地才能发动。这张卡从手卡特殊召唤。
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
	-- 此外，可以通过把这张卡以外的自己场上表侧攻击表示存在的1只名字带有「水精鳞」的怪兽解放，对方手卡随机1张送去墓地。「水精鳞-利兹深渊鱼」的这个效果1回合只能使用1次。
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
-- 定义代价筛选函数：判断手卡中的怪兽是否为水属性、可丢弃且可作为代价送去墓地。
function c37781520.cfilter(c)
	return c:IsAttribute(ATTRIBUTE_WATER) and c:IsDiscardable() and c:IsAbleToGraveAsCost()
end
-- 特殊召唤效果的代价函数：发动前检查手卡是否存在3只满足条件的水属性怪兽（本卡除外），发动时选择丢弃其中3张作为代价。
function c37781520.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检查：确认手卡中存在至少3张满足筛选条件的水属性怪兽（排除本卡）。
	if chk==0 then return Duel.IsExistingMatchingCard(c37781520.cfilter,tp,LOCATION_HAND,0,3,e:GetHandler()) end
	-- 实际执行代价：从手卡选择3张满足条件的水属性怪兽，以代价和丢弃的理由送去墓地。
	Duel.DiscardHand(tp,c37781520.cfilter,3,3,REASON_COST+REASON_DISCARD,e:GetHandler())
end
-- 特殊召唤效果的目标函数：确认自己主要怪兽区有空位且此卡可以被特殊召唤。
function c37781520.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 确认自己场上存在可用的主要怪兽区空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置本次连锁的操作信息：表示将要把此卡特殊召唤（1张）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 特殊召唤效果的处理函数：若此卡仍与效果关联，则将其特殊召唤。
function c37781520.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将这张卡以表侧攻击表示特殊召唤到自己的主要怪兽区，并以自身效果作为召唤类型标记。
	Duel.SpecialSummon(c,SUMMON_VALUE_SELF,tp,tp,false,false,POS_FACEUP)
end
-- 该效果的特殊召唤成功时点触发条件：本卡是通过自身效果特殊召唤成功。
function c37781520.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetSummonType()==SUMMON_TYPE_SPECIAL+SUMMON_VALUE_SELF
end
-- 筛选墓地中名字带有「深渊」的魔法·陷阱卡且能够加入手卡的卡。
function c37781520.thfilter(c)
	return c:IsSetCard(0x75) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- 回收效果的目标函数：从自己墓地选择1张满足条件的「深渊」魔法·陷阱卡作为取对象目标，并设置回手牌操作。
function c37781520.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c37781520.thfilter(chkc) end
	-- 目标检查：确认自己墓地存在至少1张满足条件的「深渊」魔法·陷阱卡。
	if chk==0 then return Duel.IsExistingTarget(c37781520.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 向操作者显示选择提示，文本为“请选择要返回手牌的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 令操作者从自己墓地选择1张满足条件的「深渊」魔法·陷阱卡，并将其登记为效果对象。
	local g=Duel.SelectTarget(tp,c37781520.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置操作信息：将所选对象加入手牌（1张）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 回收效果的处理函数：将对象卡加入手牌，并让对方确认该卡。
function c37781520.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前处理的效果对象中的第一张卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将效果对象卡加入其持有者的手牌。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 将加入手牌的那张卡展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,tc)
	end
end
-- 定义解放代价筛选函数：自己场上表侧攻击表示且名字带有「水精鳞」的怪兽（本卡除外）。
function c37781520.costfilter(c)
	return c:IsPosition(POS_FACEUP_ATTACK) and c:IsSetCard(0x74)
end
-- 第三个效果的代价函数：发动前检查是否存在1只可解放的「水精鳞」怪兽（本卡除外），发动时选择并解放该怪兽。
function c37781520.hdcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检查：确认自己场上存在至少1只满足条件的可解放的「水精鳞」怪兽（排除本卡）。
	if chk==0 then return Duel.CheckReleaseGroup(tp,c37781520.costfilter,1,e:GetHandler()) end
	-- 令操作者选择1只满足条件的「水精鳞」怪兽作为解放代价。
	local sg=Duel.SelectReleaseGroup(tp,c37781520.costfilter,1,1,e:GetHandler())
	-- 解放所选怪兽，作为发动效果的费用。
	Duel.Release(sg,REASON_COST)
end
-- 第三个效果的目标函数：确认对方手牌存在卡，并设置将对方手牌随机1张送去墓地的操作信息。
function c37781520.hdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 确认对方手卡不为空（至少1张）。
	if chk==0 then return Duel.GetFieldGroupCount(1-tp,LOCATION_HAND,0)~=0 end
	-- 设置操作信息：将对方手牌中1张卡送去墓地，目标玩家为对方，目标位置为手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,1-tp,LOCATION_HAND)
end
-- 效果处理：从对方手牌中随机选择1张卡送去墓地。
function c37781520.hdop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方手牌中的所有卡构成的组。
	local g=Duel.GetFieldGroup(1-tp,LOCATION_HAND,0)
	if g:GetCount()==0 then return end
	local sg=g:RandomSelect(1-tp,1)
	-- 将随机选出的1张对方手牌送去墓地。
	Duel.SendtoGrave(sg,REASON_EFFECT)
end
