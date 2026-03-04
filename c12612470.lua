--童妖 茶壺
-- 效果：
-- 这个卡名的②③的效果1回合各能使用1次。
-- ①：只要这张卡在怪兽区域存在，和这张卡相同纵列的，里侧守备表示怪兽不能把表示形式变更，魔法与陷阱区域盖放的卡不能发动。
-- ②：自己主要阶段才能发动。这张卡向相邻的主要怪兽区域移动。
-- ③：怪兽区域的这张卡向其他的怪兽区域移动的场合发动。和这张卡相同纵列的其他怪兽全部变成里侧守备表示。
function c12612470.initial_effect(c)
	-- ①：只要这张卡在怪兽区域存在，和这张卡相同纵列的，里侧守备表示怪兽不能把表示形式变更，魔法与陷阱区域盖放的卡不能发动。
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
-- 判断目标怪兽是否为里侧守备表示且与效果持有者在同一纵列
function c12612470.target(e,c)
	return c:IsPosition(POS_FACEDOWN_DEFENSE) and e:GetHandler():GetColumnGroup():IsContains(c)
end
-- 判断目标卡是否为里侧表示且与效果持有者在同一纵列
function c12612470.target2(e,c)
	return c:IsPosition(POS_FACEDOWN) and e:GetHandler():GetColumnGroup():IsContains(c)
end
-- 判断是否满足移动条件：当前怪兽区域序号不为4且前方有空位，或当前怪兽区域序号不为0且后方有空位
function c12612470.seqcon(e,tp,eg,ep,ev,re,r,rp)
	local seq=e:GetHandler():GetSequence()
	if seq>4 then return false end
	-- 判断前方是否有空位
	return (seq>0 and Duel.CheckLocation(tp,LOCATION_MZONE,seq-1))
		-- 判断后方是否有空位
		or (seq<4 and Duel.CheckLocation(tp,LOCATION_MZONE,seq+1))
end
-- 执行移动操作：选择目标位置并移动卡片
function c12612470.seqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or c:IsControler(1-tp) then return end
	local seq=c:GetSequence()
	if seq>4 then return end
	-- 判断前方是否有空位
	if (seq>0 and Duel.CheckLocation(tp,LOCATION_MZONE,seq-1))
		-- 判断后方是否有空位
		or (seq<4 and Duel.CheckLocation(tp,LOCATION_MZONE,seq+1)) then
		local flag=0
		-- 若前方有空位，则将前方位置标记到flag中
		if seq>0 and Duel.CheckLocation(tp,LOCATION_MZONE,seq-1) then flag=bit.replace(flag,0x1,seq-1) end
		-- 若后方有空位，则将后方位置标记到flag中
		if seq<4 and Duel.CheckLocation(tp,LOCATION_MZONE,seq+1) then flag=bit.replace(flag,0x1,seq+1) end
		flag=bit.bxor(flag,0xff)
		-- 提示玩家选择要移动到的位置
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOZONE)
		-- 选择一个满足条件的空位
		local s=Duel.SelectDisableField(tp,1,LOCATION_MZONE,0,flag)
		local nseq=0
		if s==1 then nseq=0
		elseif s==2 then nseq=1
		elseif s==4 then nseq=2
		elseif s==8 then nseq=3
		else nseq=4 end
		-- 将卡片移动到指定位置
		Duel.MoveSequence(c,nseq)
	end
end
-- 判断是否满足触发条件：卡片从怪兽区域移出且当前仍在怪兽区域，且位置或控制权发生变化
function c12612470.poscon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsLocation(LOCATION_MZONE)
		and (c:GetPreviousSequence()~=c:GetSequence() or c:GetPreviousControler()~=tp)
end
-- 判断目标怪兽是否可以变为里侧守备表示且与效果持有者在同一纵列
function c12612470.posfilter(c,e)
	return c:IsCanTurnSet() and e:GetHandler():GetColumnGroup():IsContains(c)
end
-- 设置连锁操作信息：准备将符合条件的怪兽变为里侧守备表示
function c12612470.postg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return true end
	-- 获取所有符合条件的怪兽
	local g=Duel.GetMatchingGroup(c12612470.posfilter,tp,LOCATION_MZONE,LOCATION_MZONE,e:GetHandler(),e)
	-- 设置连锁操作信息：准备将符合条件的怪兽变为里侧守备表示
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,g:GetCount(),0,0)
end
-- 执行效果：将符合条件的怪兽变为里侧守备表示
function c12612470.posop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取所有符合条件的怪兽
	local g=Duel.GetMatchingGroup(c12612470.posfilter,tp,LOCATION_MZONE,LOCATION_MZONE,e:GetHandler(),e)
	-- 将符合条件的怪兽变为里侧守备表示
	Duel.ChangePosition(g,POS_FACEDOWN_DEFENSE)
end
