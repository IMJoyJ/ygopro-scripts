--紅姫チルビメ
-- 效果：
-- 只要这张卡在场上表侧表示存在，对方不能选择其他的植物族怪兽作为攻击对象。此外，这张卡被对方送去墓地的场合，可以从卡组把「红姬 知流姬」以外的1只植物族怪兽特殊召唤。
function c87294988.initial_effect(c)
	-- 只要这张卡在场上表侧表示存在，对方不能选择其他的植物族怪兽作为攻击对象。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetValue(c87294988.bttg)
	c:RegisterEffect(e1)
	-- 此外，这张卡被对方送去墓地的场合，可以从卡组把「红姬 知流姬」以外的1只植物族怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(87294988,0))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCondition(c87294988.spcon)
	e2:SetTarget(c87294988.sptg)
	e2:SetOperation(c87294988.spop)
	c:RegisterEffect(e2)
end
-- 定义不能被选择为攻击对象的怪兽：自身以外的表侧表示植物族怪兽
function c87294988.bttg(e,c)
	return c~=e:GetHandler() and c:IsFaceup() and c:IsRace(RACE_PLANT)
end
-- 检查发动条件：此卡因对方被送去墓地，且送去墓地前由我方控制
function c87294988.spcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and e:GetHandler():IsPreviousControler(tp)
end
-- 过滤卡组中「红姬 知流姬」以外的、可以特殊召唤的植物族怪兽
function c87294988.filter(c,e,tp)
	return c:IsRace(RACE_PLANT) and not c:IsCode(87294988) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动的目标与合法性检测：检查怪兽区域空位以及卡组中是否存在可特殊召唤的怪兽
function c87294988.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查我方场上是否有可用于特殊召唤的怪兽区域空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在至少1张满足过滤条件的怪兽
		and Duel.IsExistingMatchingCard(c87294988.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置连锁处理的操作信息：从卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：从卡组选择1只满足条件的植物族怪兽特殊召唤到我方场上
function c87294988.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查我方场上是否有可用的怪兽区域空位，若无则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家发送提示信息：请选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从卡组中选择1张满足过滤条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c87294988.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤到我方场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
