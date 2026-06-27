--マジマジ☆マジシャンギャル
-- 效果：
-- 魔法师族6星怪兽×2
-- 1回合1次，可以把这张卡1个超量素材取除，把1张手卡从游戏中除外从以下效果选择1个发动。
-- ●选择对方场上1只怪兽直到这个回合的结束阶段时得到控制权。
-- ●选择对方墓地1只怪兽在自己场上特殊召唤。
function c10000030.initial_effect(c)
	-- 超量召唤：魔法师族6星怪兽×2
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsRace,RACE_SPELLCASTER),6,2)
	c:EnableReviveLimit()
	-- 1回合1次，可以把这张卡1个超量素材取除，把1张手卡从游戏中除外从以下效果选择1个发动：对方场上1只怪兽直到结束阶段得到控制权；或者对方墓地1只怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(c10000030.cost)
	e1:SetTarget(c10000030.target1)
	e1:SetOperation(c10000030.operation1)
	c:RegisterEffect(e1)
end
-- 效果发动的Cost：检查超量素材并除外手卡
function c10000030.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST)
		-- 检查手卡中是否存在可以除外的卡
		and Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,LOCATION_HAND,0,1,nil) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
	-- 提示选择要除外的手卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从手卡中选择1张卡进行除外
	local rg=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,LOCATION_HAND,0,1,1,nil)
	-- 将选中的手卡作为发动Cost除外
	Duel.Remove(rg,POS_FACEUP,REASON_COST)
end
-- 过滤可夺取控制权的怪兽（必须是能转移控制权的怪兽）
function c10000030.filter1(c)
	return c:IsControlerCanBeChanged()
end
-- 过滤可特殊召唤的怪兽（必须能被特殊召唤）
function c10000030.filter2(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果目标选择：根据选择的分支进行目标锁定
function c10000030.target1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		if e:GetLabel()==0 then
			return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c10000030.filter1(chkc)
		else
			return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(1-tp) and c10000030.filter2(chkc,e,tp)
		end
	end
	-- 检查是否存在可夺取控制权的对方场上怪兽
	local b1=Duel.IsExistingTarget(c10000030.filter1,tp,0,LOCATION_MZONE,1,nil)
	-- 检查自己场上是否有空位且对方墓地存在可特殊召唤的怪兽
	local b2=Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingTarget(c10000030.filter2,tp,0,LOCATION_GRAVE,1,nil,e,tp)
	if chk==0 then return b1 or b2 end
	local op=0
	if b1 and b2 then
		-- 让玩家选择发动哪一个分支效果
		op=Duel.SelectOption(tp,aux.Stringid(10000030,1),aux.Stringid(10000030,2))  --"对方场上1只怪兽得到控制权/对方墓地1只怪兽特殊召唤"
	elseif b1 then
		-- 选择夺取对方怪兽控制权的分支
		op=Duel.SelectOption(tp,aux.Stringid(10000030,1))  --"对方场上1只怪兽得到控制权"
	else
		-- 选择从对方墓地特召怪兽的分支
		op=Duel.SelectOption(tp,aux.Stringid(10000030,2))+1  --"对方墓地1只怪兽特殊召唤"
	end
	e:SetLabel(op)
	if op==0 then
		e:SetCategory(CATEGORY_CONTROL)
		-- 提示选择要改变控制权的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
		-- 选择对方场上的1只怪兽作为效果对象
		local g=Duel.SelectTarget(tp,c10000030.filter1,tp,0,LOCATION_MZONE,1,1,nil)
		-- 声明控制权转移的操作信息
		Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,0,0)
	else
		e:SetCategory(CATEGORY_SPECIAL_SUMMON)
		-- 提示选择要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 选择对方墓地的1只怪兽作为效果对象
		local g=Duel.SelectTarget(tp,c10000030.filter2,tp,0,LOCATION_GRAVE,1,1,nil,e,tp)
		-- 声明特殊召唤的操作信息
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
	end
end
-- 效果的实际处理：执行控制权转移或特殊召唤
function c10000030.operation1(e,tp,eg,ep,ev,re,r,rp)
	-- 获取选定的效果对象怪兽
	local tc=Duel.GetFirstTarget()
	if e:GetLabel()==0 then
		if tc:IsRelateToEffect(e) then
			-- 得到目标怪兽的控制权直到回合结束阶段
			Duel.GetControl(tc,tp,PHASE_END,1)
		end
	else
		if tc:IsRelateToEffect(e) then
			-- 将目标怪兽在自己场上特殊召唤
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
