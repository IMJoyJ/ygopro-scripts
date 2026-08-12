--ストーム・シューター
-- 效果：
-- 1回合只有1次，可以从下面的效果选择1个发动。
-- ●移动到没有使用的相邻的怪兽卡区域。
-- ●这张卡的正对面存在的1张对方的怪兽·魔法·陷阱卡回到持有者手卡。
function c39188539.initial_effect(c)
	-- ●移动到没有使用的相邻的怪兽卡区域
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(39188539,0))  --"移动到没有使用的相邻的怪兽卡区域"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,EFFECT_COUNT_CODE_SINGLE)
	e1:SetCondition(c39188539.seqcon)
	e1:SetCost(c39188539.cost)
	e1:SetTarget(c39188539.seqtg)
	e1:SetOperation(c39188539.seqop)
	c:RegisterEffect(e1)
	-- ●这张卡的正对面存在的1张对方的怪兽·魔法·陷阱卡回到持有者手卡
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(39188539,1))  --"正对面的1张对方的卡回到手卡"
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,EFFECT_COUNT_CODE_SINGLE)
	e2:SetCost(c39188539.cost)
	e2:SetTarget(c39188539.thtg)
	e2:SetOperation(c39188539.thop)
	c:RegisterEffect(e2)
end
-- 检查当前怪兽卡是否可以移动到相邻的空怪兽区域
function c39188539.seqcon(e,tp,eg,ep,ev,re,r,rp)
	local seq=e:GetHandler():GetSequence()
	if seq>4 then return false end
	-- 检查当前怪兽卡左侧是否有空怪兽区域
	return (seq>0 and Duel.CheckLocation(tp,LOCATION_MZONE,seq-1))
		-- 检查当前怪兽卡右侧是否有空怪兽区域
		or (seq<4 and Duel.CheckLocation(tp,LOCATION_MZONE,seq+1))
end
-- 设置效果发动时的费用，向对方提示效果发动
function c39188539.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 向对方提示效果发动
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
-- 设置选择移动位置的处理流程
function c39188539.seqtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local seq=e:GetHandler():GetSequence()
	local flag=0
	-- 如果当前怪兽卡左侧有空区域，则将该位置标记为不可选
	if seq>0 and Duel.CheckLocation(tp,LOCATION_MZONE,seq-1) then flag=flag|(1<<(seq-1)) end
	-- 如果当前怪兽卡右侧有空区域，则将该位置标记为不可选
	if seq<4 and Duel.CheckLocation(tp,LOCATION_MZONE,seq+1) then flag=flag|(1<<(seq+1)) end
	-- 提示玩家选择要移动到的位置
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOZONE)  --"请选择要移动到的位置"
	-- 选择一个不可用的怪兽区域作为移动目标
	local s=Duel.SelectDisableField(tp,1,LOCATION_MZONE,0,~flag)
	local nseq=math.log(s,2)
	e:SetLabel(nseq)
	-- 提示玩家选择的区域
	Duel.Hint(HINT_ZONE,tp,s)
end
-- 设置效果发动后的处理流程
function c39188539.seqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local seq=e:GetLabel()
	-- 检查目标怪兽是否仍然有效并满足移动条件
	if not c:IsRelateToEffect(e) or c:IsControler(1-tp) or c:GetSequence()>4 or not Duel.CheckLocation(tp,LOCATION_MZONE,seq) then return end
	-- 将目标怪兽移动到指定位置
	Duel.MoveSequence(c,seq)
end
-- 定义用于筛选目标卡的过滤函数
function c39188539.filter(c,g)
	return g:IsContains(c) and c:IsAbleToHand()
end
-- 设置选择目标卡的处理流程
function c39188539.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local cg=e:GetHandler():GetColumnGroup()
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and c39188539.filter(chkc,cg) end
	-- 检查是否存在满足条件的目标卡
	if chk==0 then return Duel.IsExistingTarget(c39188539.filter,tp,0,LOCATION_ONFIELD,1,nil,cg) end
	-- 提示玩家选择要返回手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择满足条件的目标卡
	local g=Duel.SelectTarget(tp,c39188539.filter,tp,0,LOCATION_ONFIELD,1,1,nil,cg)
	-- 设置操作信息，表示将要将卡送回手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 设置效果发动后的处理流程
function c39188539.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中选择的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡以效果原因送回手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
