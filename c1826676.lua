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
-- 特殊召唤规则的条件：若c为空则视为可特殊召唤；否则检查我方主要怪兽区有空位，且对方场上怪兽数量多于我方场上怪兽数量。
function c1826676.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查我方主要怪兽区是否存在可用空格。
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查对方场上怪兽数量是否多于我方场上怪兽数量。
		and Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)<Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)
end
-- 过滤条件：卡名为「玩具骑士」（卡号1826676）且能够被特殊召唤。
function c1826676.filter(c,e,tp)
	return c:IsCode(1826676) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 发动条件判定：需要我方主要怪兽区有空位，且手牌存在1张以上可特殊召唤的「玩具骑士」。
function c1826676.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动的条件确认（chk==0）时，先检查我方主要怪兽区是否有空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 同时检查手牌中是否存在至少1张满足c1826676.filter的「玩具骑士」。
		and Duel.IsExistingMatchingCard(c1826676.filter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 登记操作信息：本效果将从手卡把1只怪兽特殊召唤，用于连锁检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果处理：若我方主要怪兽区仍有空位，则从手牌选择1只符合条件的「玩具骑士」，表侧表示特殊召唤到我的场上。
function c1826676.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次确认我方主要怪兽区是否有空位，没有空位则终止处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向操作玩家显示“请选择要特殊召唤的卡”的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手牌中选择1张满足c1826676.filter的「玩具骑士」作为这次特殊召唤的卡。
	local g=Duel.SelectMatchingCard(tp,c1826676.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的「玩具骑士」以表侧攻击表示特殊召唤到当前玩家tp的场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
