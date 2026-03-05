--マジマジ☆マジシャンギャル
-- 效果：
-- 魔法师族6星怪兽×2
-- 1回合1次，可以把这张卡1个超量素材取除，把1张手卡从游戏中除外从以下效果选择1个发动。
-- ●选择对方场上1只怪兽直到这个回合的结束阶段时得到控制权。
-- ●选择对方墓地1只怪兽在自己场上特殊召唤。
function c10000030.initial_effect(c)
	-- 为卡片添加魔法师族6星且叠放数量为2的XYZ召唤手续
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
-- 定义效果的费用处理函数
function c10000030.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST)
		-- 检查是否满足费用条件：自身是否有1个超量素材可取除，手牌中是否有卡可除外
		and Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,LOCATION_HAND,0,1,nil) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
	-- 提示玩家选择要除外的手卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	-- 选择1张手牌从游戏中除外作为费用
	local rg=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,LOCATION_HAND,0,1,1,nil)
	-- 将选中的手牌从游戏中除外
	Duel.Remove(rg,POS_FACEUP,REASON_COST)
end
-- 定义选择对方场上怪兽时的过滤条件
function c10000030.filter1(c)
	return c:IsControlerCanBeChanged()
end
-- 定义选择对方墓地怪兽时的过滤条件
function c10000030.filter2(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 定义效果的目标选择处理函数
function c10000030.target1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		if e:GetLabel()==0 then
			return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c10000030.filter1(chkc)
		else
			return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(1-tp) and c10000030.filter2(chkc,e,tp)
		end
	end
	-- 检查对方场上是否存在可改变控制权的怪兽
	local b1=Duel.IsExistingTarget(c10000030.filter1,tp,0,LOCATION_MZONE,1,nil)
	-- 检查对方墓地是否存在可特殊召唤的怪兽且自己场上存在空位
	local b2=Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingTarget(c10000030.filter2,tp,0,LOCATION_GRAVE,1,nil,e,tp)
	if chk==0 then return b1 or b2 end
	local op=0
	if b1 and b2 then
		-- 当两个效果都可用时，让玩家选择发动哪个效果
		op=Duel.SelectOption(tp,aux.Stringid(10000030,1),aux.Stringid(10000030,2))  --"对方场上1只怪兽得到控制权" / "对方墓地1只怪兽特殊召唤"
	elseif b1 then
		-- 当只有第一个效果可用时，直接选择第一个效果
		op=Duel.SelectOption(tp,aux.Stringid(10000030,1))  --"对方场上1只怪兽得到控制权"
	else
		-- 当只有第二个效果可用时，直接选择第二个效果
		op=Duel.SelectOption(tp,aux.Stringid(10000030,2))+1  --"对方墓地1只怪兽特殊召唤"
	end
	e:SetLabel(op)
	if op==0 then
		e:SetCategory(CATEGORY_CONTROL)
		-- 提示玩家选择要改变控制权的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)
		-- 选择对方场上1只怪兽作为目标
		local g=Duel.SelectTarget(tp,c10000030.filter1,tp,0,LOCATION_MZONE,1,1,nil)
		-- 设置操作信息为改变控制权效果
		Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,0,0)
	else
		e:SetCategory(CATEGORY_SPECIAL_SUMMON)
		-- 提示玩家选择要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		-- 选择对方墓地1只怪兽作为目标
		local g=Duel.SelectTarget(tp,c10000030.filter2,tp,0,LOCATION_GRAVE,1,1,nil,e,tp)
		-- 设置操作信息为特殊召唤效果
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
	end
end
-- 定义效果的发动处理函数
function c10000030.operation1(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if e:GetLabel()==0 then
		if tc:IsRelateToEffect(e) then
			-- 让玩家获得目标怪兽的控制权直到结束阶段
			Duel.GetControl(tc,tp,PHASE_END,1)
		end
	else
		if tc:IsRelateToEffect(e) then
			-- 将目标怪兽特殊召唤到自己场上
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
