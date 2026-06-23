--トイナイト
-- 效果：
-- 这张卡不能从卡组特殊召唤。对方场上的怪兽数量比自己场上的怪兽数量多的场合，这张卡可以从手卡特殊召唤。这张卡召唤·特殊召唤成功时，可以从手卡把1只「玩具骑士」特殊召唤。
function c1826676.initial_effect(c)
	-- 这张卡不能从卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_DECK)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- 对方场上的怪兽数量比自己场上的怪兽数量多的场合，这张卡可以从手卡特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(c1826676.spcon)
	c:RegisterEffect(e2)
	-- 这张卡召唤·特殊召唤成功时，可以从手卡把1只「玩具骑士」特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(1826676,0))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetTarget(c1826676.sptg)
	e3:SetOperation(c1826676.spop)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e4)
end
-- 检查特殊召唤条件：己方场上怪兽数量少于对方场上的怪兽数量且己方有空场。
function c1826676.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 己方场上存在空位。
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 己方场上怪兽数量少于对方场上的怪兽数量。
		and Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)<Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)
end
-- 过滤函数：筛选手牌中可特殊召唤的「玩具骑士」。
function c1826676.filter(c,e,tp)
	return c:IsCode(1826676) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置特殊召唤效果的目标：检查手牌中是否存在可特殊召唤的「玩具骑士」。
function c1826676.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查己方场上是否存在空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手牌中是否存在至少一张「玩具骑士」。
		and Duel.IsExistingMatchingCard(c1826676.filter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置连锁操作信息：准备特殊召唤一张手牌中的「玩具骑士」。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 执行特殊召唤操作：选择并特殊召唤手牌中的「玩具骑士」。
function c1826676.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 若己方场上无空位则不执行特殊召唤。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手牌中选择一张「玩具骑士」。
	local g=Duel.SelectMatchingCard(tp,c1826676.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的「玩具骑士」特殊召唤到己方场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
