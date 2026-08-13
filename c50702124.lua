--シンクロ・マグネーター
-- 效果：
-- 这张卡不能通常召唤。自己对同调怪兽的同调召唤成功时，这张卡可以从手卡特殊召唤。
function c50702124.initial_effect(c)
	c:EnableReviveLimit()
	-- 对应效果原文：自己对同调怪兽的同调召唤成功时，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(50702124,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetRange(LOCATION_HAND)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c50702124.spcon)
	e1:SetTarget(c50702124.sptg)
	e1:SetOperation(c50702124.spop)
	c:RegisterEffect(e1)
end
-- 触发条件判定：特殊召唤成功时，从诱发事件中取得该怪兽，要求该次特殊召唤恰好只有1只怪兽，且该怪兽由己方控制、召唤类型为同调召唤，即符合“自己对同调怪兽的同调召唤成功时”的时点。
function c50702124.spcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	return eg:GetCount()==1 and tc:IsControler(tp) and tc:IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- 发动时点确认：己方场上主要怪兽区存在空位，且手牌中的这张卡能够被特殊召唤（不检查召唤条件，但检查苏生限制，确保可以以效果特殊召唤）。
function c50702124.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查己方的主要怪兽区是否有可用的空格，保证后续特殊召唤有足够的位置。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,true,false) end
	-- 将本次连锁的操作信息设置为“特殊召唤”，对象为这张卡自身，数量为1，供卡片发动判定、连锁处理等场合使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 特殊召唤处理：取得效果持有者，若该卡已与效果失去关联则直接终止；否则将其表侧表示特殊召唤到己方场上，成功后补完正规召唤手续。
function c50702124.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 执行特殊召唤：以不检查召唤条件但检查苏生限制的方式，将这张卡表侧表示特殊召唤到己方主要怪兽区；若召唤成功，则调用CompleteProcedure标记其已完成正规召唤手续。
	if Duel.SpecialSummon(c,0,tp,tp,true,false,POS_FACEUP)~=0 then
		c:CompleteProcedure()
	end
end
