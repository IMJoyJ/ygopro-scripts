--アンブラル・グール
-- 效果：
-- 1回合1次，自己的主要阶段时才能发动。这张卡的攻击力变成0，从手卡把1只攻击力0的名字带有「阴影」的怪兽特殊召唤。
function c7152333.initial_effect(c)
	-- 1回合1次，自己的主要阶段时才能发动。这张卡的攻击力变成0，从手卡把1只攻击力0的名字带有「阴影」的怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(7152333,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(c7152333.sptg)
	e1:SetOperation(c7152333.spop)
	c:RegisterEffect(e1)
end
-- 过滤手牌中满足攻击力为0且名字带有「阴影」的可特殊召唤怪兽
function c7152333.spfilter(c,e,tp)
	return c:IsSetCard(0x87) and c:IsAttack(0) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动的可行性检测，包括自身攻击力大于0、怪兽区域有空位以及手牌存在符合条件的怪兽
function c7152333.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查此卡攻击力是否大于0以及己方场上是否有可用的怪兽区域空格
	if chk==0 then return e:GetHandler():GetAttack()>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手牌中是否存在至少1只攻击力为0的名字带有「阴影」的怪兽
		and Duel.IsExistingMatchingCard(c7152333.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置特殊召唤的操作信息，声明将从手牌特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果处理：将自身攻击力变成0，并从手牌特殊召唤1只符合条件的怪兽
function c7152333.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFacedown() or not c:IsRelateToEffect(e) or c:IsAttack(0) then return end
	-- 这张卡的攻击力变成0
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SET_ATTACK_FINAL)
	e1:SetValue(0)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
	c:RegisterEffect(e1)
	-- 检查己方场上是否仍有可用的怪兽区域空格，若无则结束效果处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家发送选择特殊召唤卡片的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手牌中选择1只攻击力为0的名字带有「阴影」的怪兽
	local g=Duel.SelectMatchingCard(tp,c7152333.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤到己方场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
