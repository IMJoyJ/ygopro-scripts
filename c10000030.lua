--マジマジ☆マジシャンギャル
-- 效果：
-- 魔法师族6星怪兽×2
-- 1回合1次，可以把这张卡1个超量素材取除，把1张手卡从游戏中除外从以下效果选择1个发动。
-- ●选择对方场上1只怪兽直到这个回合的结束阶段时得到控制权。
-- ●选择对方墓地1只怪兽在自己场上特殊召唤。
function c10000030.initial_effect(c)
	-- 为这张卡添加超量召唤条件：魔法师族6星怪兽×2
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsRace,RACE_SPELLCASTER),6,2)
	c:EnableReviveLimit()
	-- 1回合1次，可以把这张卡1个超量素材取除，把1张手卡从游戏中除外从以下效果选择1个发动。
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
-- 效果发动代价函数：检查是否能够移除1个超量素材以及手牌中是否存在可以除外的卡片
function c10000030.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST)
		-- 检查自己手牌中是否有可除外的卡
		and Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,LOCATION_HAND,0,1,nil) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
	-- 提示控制者玩家选择要除外的手牌
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从手卡中选择1张需要被除外的卡
	local rg=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,LOCATION_HAND,0,1,1,nil)
	-- 将选中的手卡表侧表示除外作为效果的发动代价
	Duel.Remove(rg,POS_FACEUP,REASON_COST)
end
-- 过滤函数：筛选出可改变控制权的怪兽
function c10000030.filter1(c)
	return c:IsControlerCanBeChanged()
end
-- 过滤函数：筛选出满足特殊召唤条件的怪兽
function c10000030.filter2(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果目标选择函数：根据玩家所选择的分支效果（获得对方怪兽控制权或特召对方墓地怪兽），对目标合法性进行验证并将其设为效果对象
function c10000030.target1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		if e:GetLabel()==0 then
			return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c10000030.filter1(chkc)
		else
			return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(1-tp) and c10000030.filter2(chkc,e,tp)
		end
	end
	-- 检查对方场上是否存在可以被夺取控制权的怪兽
	local b1=Duel.IsExistingTarget(c10000030.filter1,tp,0,LOCATION_MZONE,1,nil)
	-- 检查自己场上是否有空余怪兽区域，以及对方墓地是否存在可以被特殊召唤的怪兽
	local b2=Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingTarget(c10000030.filter2,tp,0,LOCATION_GRAVE,1,nil,e,tp)
	if chk==0 then return b1 or b2 end
	local op=0
	if b1 and b2 then
		-- 当两个分支效果均可发动时，提供选择菜单供控制者玩家决定发动哪个效果
		op=Duel.SelectOption(tp,aux.Stringid(10000030,1),aux.Stringid(10000030,2))  --"对方场上1只怪兽得到控制权/对方墓地1只怪兽特殊召唤"
	elseif b1 then
		-- 当只有夺取控制权效果可发动时，将其强制设定为玩家所选效果
		op=Duel.SelectOption(tp,aux.Stringid(10000030,1))  --"对方场上1只怪兽得到控制权"
	else
		-- 当只有特殊召唤效果可发动时，将其强制设定为玩家所选效果
		op=Duel.SelectOption(tp,aux.Stringid(10000030,2))+1  --"对方墓地1只怪兽特殊召唤"
	end
	e:SetLabel(op)
	if op==0 then
		e:SetCategory(CATEGORY_CONTROL)
		-- 提示玩家选择要夺取控制权的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
		-- 让玩家选择对方场上的1只怪兽作为改变控制权的对象
		local g=Duel.SelectTarget(tp,c10000030.filter1,tp,0,LOCATION_MZONE,1,1,nil)
		-- 设置改变控制权的效果类别与目标信息
		Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,0,0)
	else
		e:SetCategory(CATEGORY_SPECIAL_SUMMON)
		-- 提示玩家选择要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 让玩家选择对方墓地的1只怪兽作为特殊召唤的对象
		local g=Duel.SelectTarget(tp,c10000030.filter2,tp,0,LOCATION_GRAVE,1,1,nil,e,tp)
		-- 设置特殊召唤的效果类别与目标信息
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
	end
end
-- 效果操作函数：根据玩家选择的效果分支，执行“获得目标怪兽控制权直到结束阶段”或者“特殊召唤目标怪兽”的操作
function c10000030.operation1(e,tp,eg,ep,ev,re,r,rp)
	-- 获取被选择为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	if e:GetLabel()==0 then
		if tc:IsRelateToEffect(e) then
			-- 夺取目标怪兽的控制权直到结束阶段
			Duel.GetControl(tc,tp,PHASE_END,1)
		end
	else
		if tc:IsRelateToEffect(e) then
			-- 在自己场上特殊召唤目标怪兽
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
