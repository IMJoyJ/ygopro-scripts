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
	-- ①：只要这张卡在场地区域存在，自己的互相连接状态的怪兽的战斗发生的对自己的战斗伤害变成0。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(c25163979.efilter)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	-- ②：1回合1次，自己主要阶段可以从以下效果选择1个发动。●选自己场上1只「幻崩」怪兽，那个位置向其他的自己的主要怪兽区域移动。●选自己的主要怪兽区域2只「幻崩」怪兽，那些位置交换。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(25163979,0))
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCountLimit(1)
	e3:SetTarget(c25163979.mvtg)
	e3:SetOperation(c25163979.mvop)
	c:RegisterEffect(e3)
end
-- 判断c是否处于互相连接状态：与c互相连接的怪兽数量大于0。
function c25163979.efilter(e,c)
	return c:GetMutualLinkedGroupCount()>0
end
-- 过滤条件：表侧表示且属于「幻崩」系列（字段0x112）的怪兽。
function c25163979.mvfilter1(c)
	return c:IsFaceup() and c:IsSetCard(0x112)
end
-- 过滤条件：c为表侧「幻崩」怪兽、位于主要怪兽区域（序列0-4），且自己场上还存在另一只可交换的「幻崩」怪兽。
function c25163979.mvfilter2(c,tp)
	return c:IsFaceup() and c:IsSetCard(0x112) and c:GetSequence()<5
		-- 在自己场上检查是否存在至少1只满足mvfilter3（表侧「幻崩」且在主要怪兽区域）且不是c的怪兽。
		and Duel.IsExistingMatchingCard(c25163979.mvfilter3,tp,LOCATION_MZONE,0,1,c)
end
-- 过滤条件：表侧表示、属于「幻崩」系列且位于主要怪兽区域（序列0-4）。
function c25163979.mvfilter3(c)
	return c:IsFaceup() and c:IsSetCard(0x112) and c:GetSequence()<5
end
-- 发动条件判定与分支选择：b1表示移动分支是否可用，b2表示交换分支是否可用；两者任一成立即可发动。若两个分支都可用，则用SelectOption让玩家选择移动或交换，并把结果存入Label。
function c25163979.mvtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在至少1只表侧「幻崩」怪兽（移动分支的前提）。
	local b1=Duel.IsExistingMatchingCard(c25163979.mvfilter1,tp,LOCATION_MZONE,0,1,nil)
		-- 检查自己是否有空余的主要怪兽区域可移动（移动分支需要有空位）。
		and Duel.GetLocationCount(tp,LOCATION_MZONE,PLAYER_NONE,0)>0
	-- 检查自己主要怪兽区域是否存在至少2只表侧「幻崩」怪兽（交换分支的前提）。
	local b2=Duel.IsExistingMatchingCard(c25163979.mvfilter2,tp,LOCATION_MZONE,0,1,nil,tp)
	if chk==0 then return b1 or b2 end
	local op=0
	-- 当移动与交换分支都可用时，让玩家在‘位置移动’和‘位置交换’之间选择，并记录选择结果。
	if b1 and b2 then op=Duel.SelectOption(tp,aux.Stringid(25163979,1),aux.Stringid(25163979,2))  --"位置移动/位置交换"
	-- 当只有移动分支可用时，直接选择该分支，记录为0。
	elseif b1 then op=Duel.SelectOption(tp,aux.Stringid(25163979,1))  --"位置移动"
	-- 当只有交换分支可用时，选择该分支并将SelectOption的返回值0加1，记录为1。
	else op=Duel.SelectOption(tp,aux.Stringid(25163979,2))+1 end  --"位置交换"
	e:SetLabel(op)
end
-- 按Label中记录的分支执行：0为移动1只「幻崩」怪兽到选定的空位；1为选择2只「幻崩」怪兽并交换它们的位置。
function c25163979.mvop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==0 then
		-- 执行移动分支前再次确认存在空余的主要怪兽区域，否则直接终止本次移动。
		if Duel.GetLocationCount(tp,LOCATION_MZONE,PLAYER_NONE,0)<=0 then return end
		-- 提示玩家选择要移动位置的怪兽（写入选择提示信息）。
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(25163979,3))  --"请选择要移动位置的怪兽"
		-- 从自己场上选择1只满足mvfilter1的表侧「幻崩」怪兽作为要移动的怪兽。
		local g=Duel.SelectMatchingCard(tp,c25163979.mvfilter1,tp,LOCATION_MZONE,0,1,1,nil)
		if g:GetCount()>0 then
			-- 提示玩家选择要移动到的位置（HINTMSG_TOZONE）。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOZONE)  --"请选择要移动到的位置"
			-- 让玩家从自己的主要怪兽区域中选择1个可用空格，返回该格子的位标记。
			local s=Duel.SelectDisableField(tp,1,LOCATION_MZONE,0,0)
			local nseq=math.log(s,2)
			-- 将选中的「幻崩」怪兽移动到玩家选择的目标格子。
			Duel.MoveSequence(g:GetFirst(),nseq)
		end
	else
		-- 提示玩家选择要移动（交换）位置的第一只「幻崩」怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(25163979,3))  --"请选择要移动位置的怪兽"
		-- 选择1只满足mvfilter2的「幻崩」怪兽作为交换的第一只（须在主要怪兽区域且存在另一只可交换对象）。
		local g1=Duel.SelectMatchingCard(tp,c25163979.mvfilter2,tp,LOCATION_MZONE,0,1,1,nil,tp)
		local tc1=g1:GetFirst()
		if not tc1 then return end
		-- 将第一只被选中的「幻崩」怪兽显示为已选中状态（播放选择动画并记录选择）。
		Duel.HintSelection(g1)
		-- 提示玩家选择要交换位置的第二只「幻崩」怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(25163979,3))  --"请选择要移动位置的怪兽"
		-- 选择1只满足mvfilter3且不是tc1的「幻崩」怪兽，作为交换的第二只。
		local g2=Duel.SelectMatchingCard(tp,c25163979.mvfilter3,tp,LOCATION_MZONE,0,1,1,tc1)
		-- 将第二只被选中的「幻崩」怪兽显示为已选中状态（播放选择动画并记录选择）。
		Duel.HintSelection(g2)
		local tc2=g2:GetFirst()
		-- 交换tc1与tc2所在的位置，完成‘位置交换’。
		Duel.SwapSequence(tc1,tc2)
	end
end
