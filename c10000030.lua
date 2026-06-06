--マジマジ☆マジシャンギャル
-- 效果：
-- 魔法师族6星怪兽×2
-- 1回合1次，可以把这张卡1个超量素材取除，把1张手卡从游戏中除外从以下效果选择1个发动。
-- ●选择对方场上1只怪兽直到这个回合的结束阶段时得到控制权。
-- ●选择对方墓地1只怪兽在自己场上特殊召唤。
function c10000030.initial_effect(c)
	-- 魔法师族6星怪兽×2
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsRace,RACE_SPELLCASTER),6,2)
	c:EnableReviveLimit()
	-- 1回合1次，可以把这张卡1个超量素材取除，把1张手卡从游戏中除外从以下效果选择1个发动。●选择对方场上1只怪兽直到这个回合的结束阶段时得到控制权。●选择对方墓地1只怪兽在自己场上特殊召唤。
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
-- 代价的处理：检查并取除这卡1个超量素材，把1张手卡从游戏中除外
function c10000030.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST)
		-- 检查玩家手卡中是否存在可以被除外的卡
		and Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,LOCATION_HAND,0,1,nil) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
	-- 向玩家发送提示信息：请选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从手卡中选择1张要除外的卡
	local rg=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,LOCATION_HAND,0,1,1,nil)
	-- 将选取的卡作为发动代价表侧表示除外
	Duel.Remove(rg,POS_FACEUP,REASON_COST)
end
-- 过滤条件：可以改变控制权的怪兽
function c10000030.filter1(c)
	return c:IsControlerCanBeChanged()
end
-- 过滤条件：可以以玩家tp的身份在玩家tp场上特殊召唤的怪兽
function c10000030.filter2(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果目标的确定：判断是哪一个分支效果，然后让玩家选择对应的目标，并设置操作信息
function c10000030.target1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		if e:GetLabel()==0 then
			return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c10000030.filter1(chkc)
		else
			return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(1-tp) and c10000030.filter2(chkc,e,tp)
		end
	end
	-- 检查对方场上是否存在可以被改变控制权的怪兽
	local b1=Duel.IsExistingTarget(c10000030.filter1,tp,0,LOCATION_MZONE,1,nil)
	-- 检查自己场上是否有空怪兽位且对方墓地里是否存在可以被特殊召唤的怪兽
	local b2=Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingTarget(c10000030.filter2,tp,0,LOCATION_GRAVE,1,nil,e,tp)
	if chk==0 then return b1 or b2 end
	local op=0
	if b1 and b2 then
		-- 两个效果均可发动时：让玩家选择得到控制权效果或特殊召唤效果
		op=Duel.SelectOption(tp,aux.Stringid(10000030,1),aux.Stringid(10000030,2))  --"对方场上1只怪兽得到控制权/对方墓地1只怪兽特殊召唤"
	elseif b1 then
		-- 只有得到控制权效果可发动时：让玩家确认选择该效果
		op=Duel.SelectOption(tp,aux.Stringid(10000030,1))  --"对方场上1只怪兽得到控制权"
	else
		-- 只有特殊召唤效果可发动时：让玩家确认选择该效果
		op=Duel.SelectOption(tp,aux.Stringid(10000030,2))+1  --"对方墓地1只怪兽特殊召唤"
	end
	e:SetLabel(op)
	if op==0 then
		e:SetCategory(CATEGORY_CONTROL)
		-- 向玩家发送提示信息：请选择要改变控制权的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
		-- 让玩家选择对方场上1只怪兽作为得到控制权的对象
		local g=Duel.SelectTarget(tp,c10000030.filter1,tp,0,LOCATION_MZONE,1,1,nil)
		-- 设置操作信息：得到所选怪兽的控制权
		Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,0,0)
	else
		e:SetCategory(CATEGORY_SPECIAL_SUMMON)
		-- 向玩家发送提示信息：请选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 让玩家选择对方墓地1只怪兽作为特殊召唤的对象
		local g=Duel.SelectTarget(tp,c10000030.filter2,tp,0,LOCATION_GRAVE,1,1,nil,e,tp)
		-- 设置操作信息：特殊召唤所选的墓地怪兽
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
	end
end
-- 效果的执行：根据所选择的分支效果，执行得到对方场上怪兽的控制权或者特殊召唤对方墓地的怪兽
function c10000030.operation1(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前效果选择的对象卡片
	local tc=Duel.GetFirstTarget()
	if e:GetLabel()==0 then
		if tc:IsRelateToEffect(e) then
			-- ●选择对方场上1只怪兽直到这个回合的结束阶段时得到控制权。
			Duel.GetControl(tc,tp,PHASE_END,1)
		end
	else
		if tc:IsRelateToEffect(e) then
			-- ●选择对方墓地1只怪兽在自己场上特殊召唤。
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
