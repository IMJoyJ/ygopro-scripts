--転生炎獣ティガー
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：从手卡丢弃1张其他的「转生炎兽」卡才能发动。这张卡从手卡特殊召唤。
-- ②：把自己场上的这张卡作为炎属性同调怪兽的同调素材的场合，可以把这张卡当作调整以外的怪兽使用。
-- ③：1回合1次，自己主要阶段才能发动。这张卡的等级上升或下降1星。
local s,id,o=GetID()
-- 注册卡片效果：①手卡特召，②同调素材非调整，③等级升降
function s.initial_effect(c)
	-- ①：从手卡丢弃1张其他的「转生炎兽」卡才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：把自己场上的这张卡作为炎属性同调怪兽的同调素材的场合，可以把这张卡当作调整以外的怪兽使用。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_NONTUNER)
	e2:SetValue(s.tnval)
	c:RegisterEffect(e2)
	-- ③：1回合1次，自己主要阶段才能发动。这张卡的等级上升或下降1星。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetTarget(s.lvtg)
	e3:SetOperation(s.lvop)
	c:RegisterEffect(e3)
end
-- 过滤手牌中可丢弃的「转生炎兽」卡片
function s.costfilter(c)
	return c:IsSetCard(0x119) and c:IsDiscardable()
end
-- 特殊召唤效果的Cost：从手卡丢弃1张其他的「转生炎兽」卡
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手牌中是否存在除自身以外可丢弃的「转生炎兽」卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 从手卡丢弃1张其他的「转生炎兽」卡
	Duel.DiscardHand(tp,s.costfilter,1,1,REASON_COST+REASON_DISCARD,e:GetHandler())
end
-- 特殊召唤效果的Target：检查怪兽区域空位并确认自身是否可以特殊召唤
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤自身的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 特殊召唤效果的Operation：将自身特殊召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将自身以表侧表示特殊召唤
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- 限制作为炎属性同调怪兽的同调素材时，才能当作非调整怪兽使用
function s.tnval(e,c)
	return e:GetHandler():IsControler(c:GetControler()) and c:IsAttribute(ATTRIBUTE_FIRE)
end
-- 等级升降效果的Target：检查自身等级是否大于0
function s.lvtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:GetLevel()>0 end
end
-- 等级升降效果的Operation：选择上升或下降1星并适用等级变化
function s.lvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToChain() or c:IsFacedown() then return end
	local down=c:IsLevelAbove(2)
	local lv=aux.SelectFromOptions(tp,{true,aux.Stringid(id,2)},{down,aux.Stringid(id,3),-1})  --"等级上升/等级下降"
	-- 这张卡的等级上升或下降1星。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_LEVEL)
	e1:SetValue(lv)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
	c:RegisterEffect(e1)
end
