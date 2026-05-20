--孤炎星－ロシシン
-- 效果：
-- 把这张卡作为同调素材的场合，不是炎属性怪兽的同调召唤不能使用。这张卡被战斗破坏送去墓地时，可以从卡组把「孤炎星-鲁猪深」以外的1只名字带有「炎星」的4星怪兽特殊召唤。1回合1次，这张卡在场上存在的场合名字带有「炎星」的怪兽从自己的额外卡组特殊召唤时，可以从卡组选1张名字带有「炎舞」的魔法卡在自己场上盖放。
function c66762372.initial_effect(c)
	-- 这张卡被战斗破坏送去墓地时，可以从卡组把「孤炎星-鲁猪深」以外的1只名字带有「炎星」的4星怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(66762372,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetCondition(c66762372.spcon)
	e1:SetTarget(c66762372.sptg)
	e1:SetOperation(c66762372.spop)
	c:RegisterEffect(e1)
	-- 1回合1次，这张卡在场上存在的场合名字带有「炎星」的怪兽从自己的额外卡组特殊召唤时，可以从卡组选1张名字带有「炎舞」的魔法卡在自己场上盖放。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(66762372,1))  --"盖放"
	e2:SetCategory(CATEGORY_SSET)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c66762372.setcon)
	e2:SetTarget(c66762372.settg)
	e2:SetOperation(c66762372.setop)
	c:RegisterEffect(e2)
	-- 把这张卡作为同调素材的场合，不是炎属性怪兽的同调召唤不能使用。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e3:SetValue(c66762372.synlimit)
	c:RegisterEffect(e3)
end
-- 判断此卡是否因战斗破坏而送去墓地，作为特殊召唤效果的发动条件
function c66762372.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and e:GetHandler():IsReason(REASON_BATTLE)
end
-- 过滤卡组中除「孤炎星-鲁猪深」以外的4星「炎星」怪兽，且该怪兽可以特殊召唤
function c66762372.spfilter(c,e,tp)
	return c:IsSetCard(0x79) and c:IsLevel(4) and not c:IsCode(66762372) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 特殊召唤效果的发动目标检查与操作信息设置
function c66762372.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在至少1张满足过滤条件的怪兽
		and Duel.IsExistingMatchingCard(c66762372.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置连锁处理的操作信息，表示此效果包含从卡组特殊召唤1只怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 特殊召唤效果的执行函数，从卡组选择1只符合条件的「炎星」怪兽特殊召唤到场上
function c66762372.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否仍有可用的怪兽区域空位，若无则结束处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从卡组中选择1张满足过滤条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c66762372.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤从自己额外卡组特殊召唤的表侧表示「炎星」怪兽
function c66762372.cfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0x79) and c:IsSummonLocation(LOCATION_EXTRA) and c:IsPreviousControler(tp)
end
-- 判断是否有符合条件的「炎星」怪兽从额外卡组特殊召唤成功，作为盖放效果的发动条件
function c66762372.setcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c66762372.cfilter,1,nil,tp)
end
-- 过滤卡组中可以盖放的「炎舞」魔法卡
function c66762372.filter(c)
	return c:IsSetCard(0x7c) and c:IsType(TYPE_SPELL) and c:IsSSetable()
end
-- 盖放效果的发动目标检查
function c66762372.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1张满足过滤条件的「炎舞」魔法卡
	if chk==0 then return Duel.IsExistingMatchingCard(c66762372.filter,tp,LOCATION_DECK,0,1,nil) end
end
-- 盖放效果的执行函数，从卡组选择1张「炎舞」魔法卡在自己场上盖放
function c66762372.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要盖放的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 让玩家从卡组中选择1张满足过滤条件的「炎舞」魔法卡
	local g=Duel.SelectMatchingCard(tp,c66762372.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的魔法卡在自己场上盖放
		Duel.SSet(tp,g:GetFirst())
	end
end
-- 同调素材限制函数，若同调召唤的怪兽不是炎属性，则此卡不能作为同调素材
function c66762372.synlimit(e,c)
	if not c then return false end
	return not c:IsAttribute(ATTRIBUTE_FIRE)
end
