--ダイナレスラー・エスクリマメンチ
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：自己场上有「恐龙摔跤手」怪兽存在的场合，这张卡可以不用解放作召唤。
-- ②：这张卡在墓地存在，自己回合对方对怪兽的特殊召唤成功的场合，以自己墓地1只4星以下的「恐龙摔跤手」怪兽为对象才能发动。那只怪兽特殊召唤。那之后，墓地的这张卡加入手卡。
function c48372950.initial_effect(c)
	-- ①：自己场上有「恐龙摔跤手」怪兽存在的场合，这张卡可以不用解放作召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(48372950,0))  --"不用解放作召唤"
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SUMMON_PROC)
	e1:SetCondition(c48372950.ntcon)
	c:RegisterEffect(e1)
	-- 这个卡名的②的效果1回合只能使用1次。②：这张卡在墓地存在，自己回合对方对怪兽的特殊召唤成功的场合，以自己墓地1只4星以下的「恐龙摔跤手」怪兽为对象才能发动。那只怪兽特殊召唤。那之后，墓地的这张卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(48372950,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,48372950)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(c48372950.spcon)
	e2:SetTarget(c48372950.sptg)
	e2:SetOperation(c48372950.spop)
	c:RegisterEffect(e2)
end
-- 筛选自己场上表侧表示且属于「恐龙摔跤手」系列的怪兽，用于①的无解放召唤条件检查。
function c48372950.ntfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x11a)
end
-- 无解放召唤的条件：c为nil时返回true（用于规则确认），否则要求无需解放、这张卡等级为5以上，且自己场上存在表侧表示的「恐龙摔跤手」怪兽。
function c48372950.ntcon(e,c,minc)
	if c==nil then return true end
	return minc==0 and c:IsLevelAbove(5)
		-- 检查这张卡的控制者自己的主要怪兽区是否存在至少1只满足ntfilter的「恐龙摔跤手」怪兽。
		and Duel.IsExistingMatchingCard(c48372950.ntfilter,c:GetControler(),LOCATION_MZONE,0,1,nil)
end
-- 判断eg中的怪兽是否由对方（即1-tp）特殊召唤而来，用于②的诱发条件。
function c48372950.cfilter(c,tp)
	return c:IsSummonPlayer(1-tp)
end
-- ②的发动条件：当前回合为自己回合，且本次特殊召唤成功的怪兽中至少1只由对方特殊召唤。
function c48372950.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 具体判断：自己回合且eg中存在由对方特殊召唤的怪兽。
	return Duel.GetTurnPlayer()==tp and eg:IsExists(c48372950.cfilter,1,nil,tp)
end
-- 筛选自己墓地中等级4以下、属于「恐龙摔跤手」系列、且可以被特殊召唤的怪兽，作为②的对象候选。
function c48372950.spfilter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsSetCard(0x11a) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②的发动时点处理：若为检查对象chkc，则必须是持有者为自己、位于墓地且满足spfilter；若为发动合法性检查，需满足本卡可加入手卡、自己场上有空位、墓地存在可选择的对象。
function c48372950.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c48372950.spfilter(chkc,e,tp) end
	-- 发动合法性检查之一：本卡（墓地中的这张卡）能够加入手卡，并且自己主要怪兽区有空余格子。
	if chk==0 then return e:GetHandler():IsAbleToHand() and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 发动合法性检查之二：墓地中存在至少1只满足spfilter并能成为效果对象的「恐龙摔跤手」怪兽。
		and Duel.IsExistingTarget(c48372950.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向操作者提示选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己墓地选择1只满足spfilter的恐龙摔跤手怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,c48372950.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置操作信息：本效果将特殊召唤对象怪兽，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
	-- 设置操作信息：本效果会将效果持有者（此卡本身）加入手卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- 效果处理：若对象仍与效果关联，将其表侧特殊召唤；特殊召唤成功且此卡仍与效果关联时，先中断连锁，再将此卡加入手卡。
function c48372950.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得效果处理时的对象卡（即被选择的那只墓地怪兽）。
	local tc=Duel.GetFirstTarget()
	-- 判断对象卡仍与效果相关且特殊召唤成功（实际特殊召唤数量>0）。
	if tc:IsRelateToEffect(e) and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)>0
		and c:IsRelateToEffect(e) then
		-- 中断当前效果的处理，使后续加入手卡的操作视为不同时点，以体现‘那之后’的时点分隔。
		Duel.BreakEffect()
		-- 将此卡从墓地加入手卡，完成②的后续处理。
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end
