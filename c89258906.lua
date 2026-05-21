--BF－そよ風のブリーズ
-- 效果：
-- 这张卡被魔法·陷阱·效果怪兽的效果从自己卡组加入手卡的场合，这张卡可以在自己场上特殊召唤。把这张卡作为同调素材的场合，不是名字带有「黑羽」的怪兽的同调召唤不能使用。
function c89258906.initial_effect(c)
	-- 这张卡被魔法·陷阱·效果怪兽的效果从自己卡组加入手卡的场合，这张卡可以在自己场上特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(89258906,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_TO_HAND)
	e1:SetCondition(c89258906.condition)
	e1:SetTarget(c89258906.target)
	e1:SetOperation(c89258906.operation)
	c:RegisterEffect(e1)
	-- 把这张卡作为同调素材的场合，不是名字带有「黑羽」的怪兽的同调召唤不能使用。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetValue(c89258906.synlimit)
	c:RegisterEffect(e2)
end
-- 限制同调素材：若同调怪兽不是名字带有「黑羽」（0x33）的怪兽，则不能将这张卡作为同调素材
function c89258906.synlimit(e,c)
	if not c then return false end
	return not c:IsSetCard(0x33)
end
-- 检查触发条件：是否因卡的效果从自己的卡组加入手卡
function c89258906.condition(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(r,REASON_EFFECT)~=0 and e:GetHandler():IsPreviousLocation(LOCATION_DECK) and e:GetHandler():IsPreviousControler(tp)
end
-- 特殊召唤效果的发动准备：检查自身是否可以特殊召唤，并设置特殊召唤的操作信息
function c89258906.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动阶段，检查自身是否仍与效果相关联，且自己场上的主要怪兽区域是否有空位
	if chk==0 then return e:GetHandler():IsRelateToEffect(e) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁的操作信息：将自身特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 特殊召唤效果的处理：若自身仍与效果相关联，则将自身以表侧表示特殊召唤
function c89258906.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将自身以表侧表示特殊召唤到自己场上
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
