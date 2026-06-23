--ガーディアン・トライス
-- 效果：
-- 当自己场上存在「闪光之双剑-雷震」时才能召唤·反转召唤·特殊召唤。这张卡被破坏送去墓地时，将墓地里存在的这张卡祭牲召唤时作为祭品的怪兽特殊召唤到自己场上。
function c46037213.initial_effect(c)
	-- 当自己场上不存在「闪光之双剑-雷震」时不能召唤
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_SUMMON)
	e1:SetCondition(c46037213.sumcon)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_FLIP_SUMMON)
	c:RegisterEffect(e2)
	-- 当自己场上存在「闪光之双剑-雷震」时才能特殊召唤
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
-- 过滤函数，检查场上是否存在「闪光之双剑-雷震」（卡号21900719）
function c46037213.cfilter(c)
	return c:IsFaceup() and c:IsCode(21900719)
end
-- 判断是否满足召唤条件：自己场上不存在「闪光之双剑-雷震」
function c46037213.sumcon(e)
	-- 当自己场上不存在「闪光之双剑-雷震」时返回true
	return not Duel.IsExistingMatchingCard(c46037213.cfilter,e:GetHandlerPlayer(),LOCATION_ONFIELD,0,1,nil)
end
-- 判断是否满足特殊召唤条件：特殊召唤玩家场上存在「闪光之双剑-雷震」
function c46037213.sumlimit(e,se,sp,st,pos,tp)
	-- 当特殊召唤玩家场上存在「闪光之双剑-雷震」时返回true
	return Duel.IsExistingMatchingCard(c46037213.cfilter,sp,LOCATION_ONFIELD,0,1,nil)
end
-- 判断是否满足发动条件：此卡因破坏而进入墓地
function c46037213.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_DESTROY)
end
-- 过滤函数，用于筛选被祭品召唤的怪兽（在墓地中且因召唤而进入）
function c46037213.spfilter(c,e,tp,rc)
	return c:IsLocation(LOCATION_GRAVE) and c:IsReason(REASON_SUMMON) and c:GetReasonCard()==rc and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置连锁处理的目标卡片组，并设定操作信息为特殊召唤
function c46037213.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local g=e:GetHandler():GetMaterial():Filter(c46037213.spfilter,nil,e,tp,e:GetHandler())
	-- 将目标卡片组设置为当前效果要处理的对象
	Duel.SetTargetCard(g)
	-- 设置操作信息，表示本次连锁将进行特殊召唤操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,g:GetCount(),0,0)
end
-- 处理特殊召唤效果的函数，先筛选出有效目标，再判断是否满足召唤条件并执行召唤
function c46037213.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标卡片组，并过滤掉无效卡片
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	local ct=g:GetCount()
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if ct>1 and Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 判断场上是否有足够的空位来特殊召唤这些怪兽
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>=ct then
		-- 将符合条件的卡片以正面表示形式特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
