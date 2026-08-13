--サイバー・ダイナソー
-- 效果：
-- 对方从手卡特殊召唤怪兽时，可以从手卡特殊召唤这张卡。
function c39439590.initial_effect(c)
	-- 对方从手卡特殊召唤怪兽时，可以从手卡特殊召唤这张卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(39439590,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetRange(LOCATION_HAND)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c39439590.spcon)
	e1:SetTarget(c39439590.sptg)
	e1:SetOperation(c39439590.spop)
	c:RegisterEffect(e1)
end
-- 筛选函数：用于判断特殊召唤成功的怪兽是否满足“对方从手卡特殊召唤”这一条件，即召唤玩家是对方且怪兽之前位于手牌。
function c39439590.cfilter(c,tp)
	return c:IsSummonPlayer(1-tp) and c:IsPreviousLocation(LOCATION_HAND)
end
-- 诱发条件：若这次特殊召唤成功的事件中，存在至少一只对方从手卡特殊召唤的怪兽，则满足发动条件。
function c39439590.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c39439590.cfilter,1,nil,tp)
end
-- 发动时合法性检查：确认自己主要怪兽区有空位，且这张卡自身能够被特殊召唤，才能发动效果。
function c39439590.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的主要怪兽区空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 将本次连锁的操作信息设置为“特殊召唤”，对象为这张卡自身，以便其他卡牌进行连锁判定。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理：获取这张卡，确认其仍与效果相关后，将其从手卡特殊召唤。
function c39439590.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将电子恐龙以表侧表示特殊召唤到自己场上。
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
