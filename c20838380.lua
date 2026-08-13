--シャーク・サッカー
-- 效果：
-- 自己场上有鱼族·海龙族·水族怪兽召唤·特殊召唤时，这张卡可以从手卡特殊召唤。这张卡不能作为同调素材。
function c20838380.initial_effect(c)
	-- 自己场上有鱼族·海龙族·水族怪兽召唤·特殊召唤时，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(20838380,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetRange(LOCATION_HAND)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c20838380.spcon)
	e1:SetTarget(c20838380.sptg)
	e1:SetOperation(c20838380.spop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- 这张卡不能作为同调素材。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e3:SetValue(1)
	c:RegisterEffect(e3)
end
-- 筛选条件：卡须为表侧表示、控制者为我方、且种族为鱼族·海龙族·水族之一。
function c20838380.cfilter(c,tp)
	return c:IsFaceup() and c:IsControler(tp) and c:IsRace(RACE_FISH+RACE_SEASERPENT+RACE_AQUA)
end
-- 判定本次召唤/特殊召唤成功的怪兽群中是否存在至少1只满足cfilter的怪兽，即是否满足诱发条件。
function c20838380.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c20838380.cfilter,1,nil,tp)
end
-- 发动合法性检查：我方主要怪兽区有空位，且这张卡自身能够被特殊召唤。
function c20838380.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查我方主要怪兽区是否有可用的空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置本次连锁的操作信息：确定要特殊召唤的对象为此卡，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理时，若此卡仍与效果关联，则将其特殊召唤；否则不处理。
function c20838380.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 以表侧表示将这张卡特殊召唤到我方场上。
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
