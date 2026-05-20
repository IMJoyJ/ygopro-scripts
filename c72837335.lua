--先史遺産ゴルディアス・ユナイト
-- 效果：
-- 这张卡召唤成功时，可以从手卡把1只名字带有「先史遗产」的怪兽特殊召唤。这张卡的等级变成和这个效果特殊召唤的怪兽的等级相同。
function c72837335.initial_effect(c)
	-- 这张卡召唤成功时，可以从手卡把1只名字带有「先史遗产」的怪兽特殊召唤。这张卡的等级变成和这个效果特殊召唤的怪兽的等级相同。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(72837335,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c72837335.sptg)
	e1:SetOperation(c72837335.spop)
	c:RegisterEffect(e1)
end
-- 过滤手牌中可以特殊召唤的名字带有「先史遗产」的怪兽
function c72837335.filter(c,e,tp)
	return c:IsSetCard(0x70) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动的目标检查函数，检查怪兽区域空位及手牌中是否存在可特殊召唤的「先史遗产」怪兽
function c72837335.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手牌中是否存在至少1只可以特殊召唤的「先史遗产」怪兽
		and Duel.IsExistingMatchingCard(c72837335.filter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置特殊召唤的操作信息，表示将从手牌特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果运行函数，执行从手牌特殊召唤「先史遗产」怪兽并改变自身等级的处理
function c72837335.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否有空余的怪兽区域，若无则不处理效果
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local c=e:GetHandler()
	-- 提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手牌选择1只满足条件的「先史遗产」怪兽
	local g=Duel.SelectMatchingCard(tp,c72837335.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		if c:IsRelateToEffect(e) and c:IsFaceup() then
			-- 这张卡的等级变成和这个效果特殊召唤的怪兽的等级相同。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CHANGE_LEVEL)
			e1:SetValue(g:GetFirst():GetLevel())
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
			c:RegisterEffect(e1)
		end
	end
end
