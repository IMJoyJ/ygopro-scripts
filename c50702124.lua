--シンクロ・マグネーター
-- 效果：
-- 这张卡不能通常召唤。自己对同调怪兽的同调召唤成功时，这张卡可以从手卡特殊召唤。
function c50702124.initial_effect(c)
	c:EnableReviveLimit()
	-- 创建一个诱发选发效果，当自己对同调怪兽的同调召唤成功时，这张卡可以从手卡特殊召唤。
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
-- 效果条件：确认发动时只有一张怪兽被特殊召唤，且该怪兽是自己的同调怪兽。
function c50702124.spcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	return eg:GetCount()==1 and tc:IsControler(tp) and tc:IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- 效果处理判断：检查玩家场上是否有空位，并确认此卡可以被特殊召唤。
function c50702124.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断玩家场上主怪兽区域是否有空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,true,false) end
	-- 设置连锁操作信息为特殊召唤，用于发动检测和效果处理。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理：将此卡从手牌特殊召唤到场上，并完成正规召唤手续。
function c50702124.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 执行特殊召唤操作，若成功则完成召唤手续。
	if Duel.SpecialSummon(c,0,tp,tp,true,false,POS_FACEUP)~=0 then
		c:CompleteProcedure()
	end
end
