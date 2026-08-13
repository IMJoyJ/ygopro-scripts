--ガーディアン・トライス
-- 效果：
-- 当自己场上存在「闪光之双剑-雷震」时才能召唤·反转召唤·特殊召唤。这张卡被破坏送去墓地时，将墓地里存在的这张卡祭牲召唤时作为祭品的怪兽特殊召唤到自己场上。
function c46037213.initial_effect(c)
	-- 当自己场上存在「闪光之双剑-雷震」时才能召唤·反转召唤·特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_SUMMON)
	e1:SetCondition(c46037213.sumcon)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_FLIP_SUMMON)
	c:RegisterEffect(e2)
	-- 当自己场上存在「闪光之双剑-雷震」时才能特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e3:SetCode(EFFECT_SPSUMMON_CONDITION)
	e3:SetValue(c46037213.sumlimit)
	c:RegisterEffect(e3)
	-- 这张卡被破坏送去墓地时，将墓地里存在的这张卡祭牲召唤时作为祭品的怪兽特殊召唤到自己场上。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(46037213,0))  --"特殊召唤"
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetCondition(c46037213.spcon)
	e4:SetTarget(c46037213.sptg)
	e4:SetOperation(c46037213.spop)
	c:RegisterEffect(e4)
end
-- 过滤条件：判断卡是否表侧表示且卡名为「闪光之双剑-雷震」(21900719)，用于检查召唤限制条件所需的卡是否在场。
function c46037213.cfilter(c)
	return c:IsFaceup() and c:IsCode(21900719)
end
-- 召唤限制的条件函数：当自己场上不存在表侧表示且卡名为「闪光之双剑-雷震」的卡时返回 true，使这张卡不能进行通常召唤/反转召唤。
function c46037213.sumcon(e)
	-- 检查自己场上是否存在符合条件的「闪光之双剑-雷震」，再用 not 取反，即不存在时条件成立，禁止通常召唤/反转召唤。
	return not Duel.IsExistingMatchingCard(c46037213.cfilter,e:GetHandlerPlayer(),LOCATION_ONFIELD,0,1,nil)
end
-- 特殊召唤限制的判断函数：当进行特殊召唤的玩家（sp）自己场上存在表侧表示的「闪光之双剑-雷震」时返回 true，允许这张卡特殊召唤。
function c46037213.sumlimit(e,se,sp,st,pos,tp)
	-- 检查进行特殊召唤的玩家（sp）是否存在符合条件的「闪光之双剑-雷震」，存在则返回 true，满足特殊召唤条件。
	return Duel.IsExistingMatchingCard(c46037213.cfilter,sp,LOCATION_ONFIELD,0,1,nil)
end
-- 触发条件：仅当这张卡是被破坏并被送去墓地时返回 true（REASON_DESTROY），从而触发后续的特殊召唤效果。
function c46037213.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_DESTROY)
end
-- 筛选特殊召唤对象的过滤器：要求卡在墓地、因作为这张卡的祭品召唤而被解放（REASON_SUMMON）、导致其进入墓地的原因是这张卡自身，且该卡能够被效果特殊召唤。
function c46037213.spfilter(c,e,tp,rc)
	return c:IsLocation(LOCATION_GRAVE) and c:IsReason(REASON_SUMMON) and c:GetReasonCard()==rc and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动时：从这张卡的祭品召唤素材（GetMaterial()）中筛选出满足 spfilter 的祭品怪兽，将其设为连锁对象并登记特殊召唤操作信息。
function c46037213.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local g=e:GetHandler():GetMaterial():Filter(c46037213.spfilter,nil,e,tp,e:GetHandler())
	-- 将筛选出的祭品怪兽组设为当前连锁的处理对象，使这些卡与本次效果建立关联，供效果处理时再次确认。
	Duel.SetTargetCard(g)
	-- 登记本连锁的特殊召唤操作信息：声明可能特殊召唤 g 中的怪兽，数量为 g:GetCount()，供相关卡进行效果检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,g:GetCount(),0,0)
end
-- 效果处理时：取出仍与本次效果关联的祭品怪兽；若数量大于 1 且「青眼精灵龙」的效果正在适用（双方不能同时特殊召唤 2 只以上怪兽），则不处理；否则在自己主要怪兽区空位足够时，将它们以表侧表示特殊召唤到自己场上。
function c46037213.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁登记的对象卡中，过滤出仍然与本次效果相关的卡（排除已离场或失去关联的卡），得到最终要特殊召唤的祭品怪兽组。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	local ct=g:GetCount()
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if ct>1 and Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 判定自己场上的主要怪兽区空位数量是否不少于要特殊召唤的怪兽数量，空位不足则无法进行特殊召唤。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>=ct then
		-- 将祭品怪兽组 g 以表侧表示特殊召唤到自己场上（sumtype=0，不检查召唤条件和苏生限制）。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
