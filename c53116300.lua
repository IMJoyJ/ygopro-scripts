--インヴェルズを呼ぶ者
-- 效果：
-- 把这张卡解放对名字带有「侵入魔鬼」的怪兽的上级召唤成功时，可以从自己卡组把1只4星以下的名字带有「侵入魔鬼」的怪兽特殊召唤。
function c53116300.initial_effect(c)
	-- 创建一个诱发选发效果，当此卡作为上级召唤的素材时发动
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(53116300,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BE_MATERIAL)
	e1:SetCondition(c53116300.spcon)
	e1:SetTarget(c53116300.sptg)
	e1:SetOperation(c53116300.spop)
	c:RegisterEffect(e1)
end
-- 效果发动条件：此卡在墓地且因上级召唤被送入墓地
function c53116300.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsLocation(LOCATION_GRAVE) and r==REASON_SUMMON and c:GetReasonCard():IsSetCard(0x100a)
end
-- 过滤函数：检索满足名字带有「侵入魔鬼」且等级4以下且可特殊召唤的怪兽
function c53116300.filter(c,e,tp)
	return c:IsSetCard(0x100a) and c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果处理条件判断：确认场上是否有空位且卡组是否存在符合条件的怪兽
function c53116300.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断卡组中是否存在满足条件的怪兽
		and Duel.IsExistingMatchingCard(c53116300.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置连锁操作信息为特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理函数：若场上有空位则从卡组选择1只符合条件的怪兽特殊召唤
function c53116300.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断场上是否还有空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组选择1只符合条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c53116300.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽正面表示特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
