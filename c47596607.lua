--摩天楼2－ヒーローシティ
-- 效果：
-- 1回合1次，自己的主要阶段时，选择被战斗破坏送去自己墓地的1只名字带有「元素英雄」的怪兽才能发动。选择的怪兽从墓地特殊召唤。
function c47596607.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 对应效果原文：“1回合1次，自己的主要阶段时，选择被战斗破坏送去自己墓地的1只名字带有「元素英雄」的怪兽才能发动。选择的怪兽从墓地特殊召唤。”
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(47596607,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(c47596607.sptg)
	e2:SetOperation(c47596607.spop)
	c:RegisterEffect(e2)
end
-- 筛选符合条件的墓地怪兽：必须为名字带有「元素英雄」的怪兽、是因战斗破坏而被送去墓地的，并且能够以这个效果特殊召唤。
function c47596607.filter(c,e,tp)
	return c:IsSetCard(0x3008) and bit.band(c:GetReason(),REASON_BATTLE)~=0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 发动条件与取目标处理：连锁处理时检查指定对象是否位于自己墓地且满足筛选条件；发动时确认需要自己主要怪兽区有空位，并且墓地存在至少1只符合条件的「元素英雄」怪兽作为取对象目标。
function c47596607.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c47596607.filter(chkc,e,tp) end
	-- 在效果发动判定（chk==0）时，确认我方主要怪兽区有空位可供后续特殊召唤使用。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 同时确认墓地中是否存在至少1只满足筛选条件的「元素英雄」怪兽，且该怪兽能成为此效果的对象。
		and Duel.IsExistingTarget(c47596607.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 给当前玩家显示选择提示，提示文字为“请选择要特殊召唤的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己墓地选择1只满足条件的「元素英雄」怪兽作为效果对象（取对象），并建立与该连锁的关联。
	local g=Duel.SelectTarget(tp,c47596607.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 向系统登记本连锁将进行的特殊召唤操作信息：对象为刚选择的怪兽，数量为1，用于后续效果互动和时点检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理阶段：取出此效果选择的对象，若对象仍与效果相关联，则将其特殊召唤；否则不处理。
function c47596607.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前效果处理连锁中记录的对象卡（即发动时选择的墓地怪兽）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽以表侧表示特殊召唤到当前玩家（tp）的场上，经过正规召唤条件和苏生限制的检查。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
