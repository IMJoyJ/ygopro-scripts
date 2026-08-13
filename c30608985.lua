--マジカル・アンダーテイカー
-- 效果：
-- ①：这张卡反转的场合，以自己墓地1只4星以下的魔法师族怪兽为对象才能发动。那只魔法师族怪兽特殊召唤。
function c30608985.initial_effect(c)
	-- ①：这张卡反转的场合，以自己墓地1只4星以下的魔法师族怪兽为对象才能发动。那只魔法师族怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(30608985,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetTarget(c30608985.target)
	e1:SetOperation(c30608985.operation)
	c:RegisterEffect(e1)
end
-- 作为该效果的对象筛选条件：对象须是魔法师族、等级4以下，且目前能够被特殊召唤（正常检查召唤条件与苏生限制）。
function c30608985.spfilter(c,e,tp)
	return c:IsRace(RACE_SPELLCASTER) and c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 发动判定与取对象：若指定对象，则验证其是否在己方墓地且满足筛选条件；若为发动判定，则检查己方怪兽区域有空位且墓地存在符合条件的对象。
function c30608985.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c30608985.spfilter(chkc,e,tp) end
	-- 发动条件之一：确认己方怪兽区域有可用的空格，以保证后续特殊召唤能进行。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 发动条件之二：确认己方墓地存在至少1只满足spfilter（魔法师族·4星以下·可特殊召唤）的怪兽，可作为效果对象。
		and Duel.IsExistingTarget(c30608985.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向操作玩家显示选择提示：‘请选择要特殊召唤的卡’（HINTMSG_SPSUMMON），用于后续选择卡片的界面文本。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让操作玩家从自己墓地选择1只满足spfilter条件的怪兽作为效果对象（同时通过SelectTarget建立该卡与当前连锁的关联）。
	local g=Duel.SelectTarget(tp,c30608985.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 登记当前连锁的操作信息：效果将特殊召唤对象怪兽1只（category为CATEGORY_SPECIAL_SUMMON），供系统及后续效果检测使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理：取得步骤中选定的对象，若该对象仍与效果关联且仍是魔法师族怪兽，则将其特殊召唤；否则不处理。
function c30608985.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的1张对象卡（通常为墓地里的魔法师族怪兽）。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsRace(RACE_SPELLCASTER) then
		-- 将对象怪兽以表侧表示特殊召唤到己方怪兽区域（按正常召唤条件与苏生限制进行特殊召唤）。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
