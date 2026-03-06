--星遺物へ誘う悪夢
-- 效果：
-- ①：只要这张卡在场地区域存在，自己的互相连接状态的怪兽的战斗发生的对自己的战斗伤害变成0。
-- ②：1回合1次，自己主要阶段可以从以下效果选择1个发动。
-- ●选自己场上1只「幻崩」怪兽，那个位置向其他的自己的主要怪兽区域移动。
-- ●选自己的主要怪兽区域2只「幻崩」怪兽，那些位置交换。
function c25163979.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 效果原文内容：①：只要这张卡在场地区域存在，自己的互相连接状态的怪兽的战斗发生的对自己的战斗伤害变成0。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(c25163979.efilter)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	-- 效果原文内容：②：1回合1次，自己主要阶段可以从以下效果选择1个发动。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(25163979,0))
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCountLimit(1)
	e3:SetTarget(c25163979.mvtg)
	e3:SetOperation(c25163979.mvop)
	c:RegisterEffect(e3)
end
-- 规则层面操作：过滤出处于互相连接状态的怪兽
function c25163979.efilter(e,c)
	return c:GetMutualLinkedGroupCount()>0
end
-- 规则层面操作：过滤出场上正面表示的「幻崩」怪兽
function c25163979.mvfilter1(c)
	return c:IsFaceup() and c:IsSetCard(0x112)
end
-- 规则层面操作：过滤出场上正面表示且位于主要怪兽区域（0-4）的「幻崩」怪兽，并且该怪兽存在至少一只其他「幻崩」怪兽在主要怪兽区域
function c25163979.mvfilter2(c,tp)
	return c:IsFaceup() and c:IsSetCard(0x112) and c:GetSequence()<5
		-- 规则层面操作：检查是否存在满足条件的「幻崩」怪兽
		and Duel.IsExistingMatchingCard(c25163979.mvfilter3,tp,LOCATION_MZONE,0,1,c)
end
-- 规则层面操作：过滤出场上正面表示且位于主要怪兽区域（0-4）的「幻崩」怪兽
function c25163979.mvfilter3(c)
	return c:IsFaceup() and c:IsSetCard(0x112) and c:GetSequence()<5
end
-- 规则层面操作：判断是否可以发动效果，检查是否有满足条件的「幻崩」怪兽可移动或交换位置
function c25163979.mvtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 规则层面操作：检查是否存在满足条件的「幻崩」怪兽用于位置移动
	local b1=Duel.IsExistingMatchingCard(c25163979.mvfilter1,tp,LOCATION_MZONE,0,1,nil)
		-- 规则层面操作：检查场上是否有足够的空位用于位置移动
		and Duel.GetLocationCount(tp,LOCATION_MZONE,PLAYER_NONE,0)>0
	-- 规则层面操作：检查是否存在满足条件的「幻崩」怪兽用于位置交换
	local b2=Duel.IsExistingMatchingCard(c25163979.mvfilter2,tp,LOCATION_MZONE,0,1,nil,tp)
	if chk==0 then return b1 or b2 end
	local op=0
	-- 规则层面操作：选择位置移动或位置交换选项
	if b1 and b2 then op=Duel.SelectOption(tp,aux.Stringid(25163979,1),aux.Stringid(25163979,2))  --"位置移动/位置交换"
	-- 规则层面操作：选择位置移动选项
	elseif b1 then op=Duel.SelectOption(tp,aux.Stringid(25163979,1))  --"位置移动"
	-- 规则层面操作：选择位置交换选项
	else op=Duel.SelectOption(tp,aux.Stringid(25163979,2))+1 end  --"位置交换"
	e:SetLabel(op)
end
-- 规则层面操作：执行效果的处理逻辑，根据选择的选项进行位置移动或交换
function c25163979.mvop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==0 then
		-- 规则层面操作：检查场上是否有足够的空位用于位置移动
		if Duel.GetLocationCount(tp,LOCATION_MZONE,PLAYER_NONE,0)<=0 then return end
		-- 规则层面操作：提示玩家选择要移动位置的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(25163979,3))  --"请选择要移动位置的怪兽"
		-- 规则层面操作：选择满足条件的「幻崩」怪兽
		local g=Duel.SelectMatchingCard(tp,c25163979.mvfilter1,tp,LOCATION_MZONE,0,1,1,nil)
		if g:GetCount()>0 then
			-- 规则层面操作：提示玩家选择要移动到的位置
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOZONE)  --"请选择要移动到的位置"
			-- 规则层面操作：选择一个可用的怪兽区域
			local s=Duel.SelectDisableField(tp,1,LOCATION_MZONE,0,0)
			local nseq=math.log(s,2)
			-- 规则层面操作：将怪兽移动到指定区域
			Duel.MoveSequence(g:GetFirst(),nseq)
		end
	else
		-- 规则层面操作：提示玩家选择要交换位置的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(25163979,3))  --"请选择要移动位置的怪兽"
		-- 规则层面操作：选择满足条件的「幻崩」怪兽用于交换
		local g1=Duel.SelectMatchingCard(tp,c25163979.mvfilter2,tp,LOCATION_MZONE,0,1,1,nil,tp)
		local tc1=g1:GetFirst()
		if not tc1 then return end
		-- 规则层面操作：显示被选为对象的动画效果
		Duel.HintSelection(g1)
		-- 规则层面操作：提示玩家选择要交换位置的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(25163979,3))  --"请选择要移动位置的怪兽"
		-- 规则层面操作：选择另一只满足条件的「幻崩」怪兽用于交换
		local g2=Duel.SelectMatchingCard(tp,c25163979.mvfilter3,tp,LOCATION_MZONE,0,1,1,tc1)
		-- 规则层面操作：显示被选为对象的动画效果
		Duel.HintSelection(g2)
		local tc2=g2:GetFirst()
		-- 规则层面操作：交换两只怪兽的位置
		Duel.SwapSequence(tc1,tc2)
	end
end
