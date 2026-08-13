--童妖 茶壺
-- 效果：
-- 这个卡名的②③的效果1回合各能使用1次。
-- ①：只要这张卡在怪兽区域存在，和这张卡相同纵列的，里侧守备表示怪兽不能把表示形式变更，魔法与陷阱区域盖放的卡不能发动。
-- ②：自己主要阶段才能发动。这张卡向相邻的主要怪兽区域移动。
-- ③：怪兽区域的这张卡向其他的怪兽区域移动的场合发动。和这张卡相同纵列的其他怪兽全部变成里侧守备表示。
function c12612470.initial_effect(c)
	-- ①：只要这张卡在怪兽区域存在，和这张卡相同纵列的，里侧守备表示怪兽不能把表示形式变更。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
	e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1:SetTarget(c12612470.target)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_TRIGGER)
	e2:SetTargetRange(LOCATION_SZONE,LOCATION_SZONE)
	e2:SetTarget(c12612470.target2)
	c:RegisterEffect(e2)
	-- ②：自己主要阶段才能发动。这张卡向相邻的主要怪兽区域移动。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(12612470,0))  --"移动"
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,12612470)
	e3:SetCondition(c12612470.seqcon)
	e3:SetOperation(c12612470.seqop)
	c:RegisterEffect(e3)
	-- ③：怪兽区域的这张卡向其他的怪兽区域移动的场合发动。和这张卡相同纵列的其他怪兽全部变成里侧守备表示。
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_POSITION+CATEGORY_MSET)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e4:SetCode(EVENT_MOVE)
	e4:SetCountLimit(1,12612470+1)
	e4:SetCondition(c12612470.poscon)
	e4:SetTarget(c12612470.postg)
	e4:SetOperation(c12612470.posop)
	c:RegisterEffect(e4)
end
-- 作为①效果限制对象的怪兽需满足：里侧守备表示，且与效果持有者处于同一纵列。
function c12612470.target(e,c)
	return c:IsPosition(POS_FACEDOWN_DEFENSE) and e:GetHandler():GetColumnGroup():IsContains(c)
end
-- 作为①效果中魔法与陷阱区域限制对象的卡需满足：里侧盖放状态，且与效果持有者处于同一纵列。
function c12612470.target2(e,c)
	return c:IsPosition(POS_FACEDOWN) and e:GetHandler():GetColumnGroup():IsContains(c)
end
-- ②效果的发动条件：这张卡在主要怪兽区域，且左侧或右侧相邻的主要怪兽区域至少有一个空位可用。
function c12612470.seqcon(e,tp,eg,ep,ev,re,r,rp)
	local seq=e:GetHandler():GetSequence()
	if seq>4 then return false end
	-- 检查左侧相邻的主要怪兽区域是否为空位（仅当当前不在最左列时）。
	return (seq>0 and Duel.CheckLocation(tp,LOCATION_MZONE,seq-1))
		-- 检查右侧相邻的主要怪兽区域是否为空位（仅当当前不在最右列时）。
		or (seq<4 and Duel.CheckLocation(tp,LOCATION_MZONE,seq+1))
end
-- ②效果处理：确认这张卡仍能被效果处理且控制权未变更后，从相邻可用主要怪兽区域中选择一个位置，将这张卡移动到该位置。
function c12612470.seqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or c:IsControler(1-tp) then return end
	local seq=c:GetSequence()
	if seq>4 then return end
	-- 如果左侧相邻区域为空位（且不在最左列），将其作为可选移动目标。
	if (seq>0 and Duel.CheckLocation(tp,LOCATION_MZONE,seq-1))
		-- 如果右侧相邻区域为空位（且不在最右列），也将其作为可选移动目标。
		or (seq<4 and Duel.CheckLocation(tp,LOCATION_MZONE,seq+1)) then
		local flag=0
		-- 在位置掩码中将左侧相邻格子的对应位标记为1，表示该位置可选。
		if seq>0 and Duel.CheckLocation(tp,LOCATION_MZONE,seq-1) then flag=bit.replace(flag,0x1,seq-1) end
		-- 在位置掩码中将右侧相邻格子的对应位标记为1，表示该位置可选。
		if seq<4 and Duel.CheckLocation(tp,LOCATION_MZONE,seq+1) then flag=bit.replace(flag,0x1,seq+1) end
		flag=bit.bxor(flag,0xff)
		-- 向玩家显示“请选择要移动到的位置”的选择提示信息。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOZONE)  --"请选择要移动到的位置"
		-- 调用区域选择接口，让玩家从当前可用的相邻主要怪兽区域中选择1个格子（其余位置被过滤掉），返回所选位置的标记。
		local s=Duel.SelectDisableField(tp,1,LOCATION_MZONE,0,flag)
		local nseq=0
		if s==1 then nseq=0
		elseif s==2 then nseq=1
		elseif s==4 then nseq=2
		elseif s==8 then nseq=3
		else nseq=4 end
		-- 将这张卡的序号移动到玩家选择的格子，即实现向相邻主要怪兽区域的移动。
		Duel.MoveSequence(c,nseq)
	end
end
-- ③效果的发动条件：这张卡在怪兽区域从原来的怪兽区域移动到了另一个怪兽区域（位置序号发生改变，或控制者发生变化）。
function c12612470.poscon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsLocation(LOCATION_MZONE)
		and (c:GetPreviousSequence()~=c:GetSequence() or c:GetPreviousControler()~=tp)
end
-- ③效果处理时选择的对象：与这张卡同一纵列的其他怪兽，且该怪兽可以转为里侧表示。
function c12612470.posfilter(c,e)
	return c:IsCanTurnSet() and e:GetHandler():GetColumnGroup():IsContains(c)
end
-- ③效果发动时，先搜索符合条件的同列怪兽，并将操作信息设置为改变这些怪兽的表示形式（数量为搜索到的怪兽数量）。
function c12612470.postg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return true end
	-- 获取与这张卡同一纵列、且可以转为里侧守备表示的其他怪兽（不包含这张卡自身）的集合。
	local g=Duel.GetMatchingGroup(c12612470.posfilter,tp,LOCATION_MZONE,LOCATION_MZONE,e:GetHandler(),e)
	-- 设置当前连锁的操作信息：将要对上述怪兽集合进行表示形式变更，数量为集合中的怪兽数。
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,g:GetCount(),0,0)
end
-- ③效果处理：再次获取符合条件的同列怪兽，并将它们全部变为里侧守备表示。
function c12612470.posop(e,tp,eg,ep,ev,re,r,rp)
	-- 再次获取与这张卡同一纵列、且可以转为里侧守备表示的其他怪兽（效果处理时确定对象）。
	local g=Duel.GetMatchingGroup(c12612470.posfilter,tp,LOCATION_MZONE,LOCATION_MZONE,e:GetHandler(),e)
	-- 将选中的所有怪兽变为里侧守备表示。
	Duel.ChangePosition(g,POS_FACEDOWN_DEFENSE)
end
