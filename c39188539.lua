--ストーム・シューター
-- 效果：
-- 1回合只有1次，可以从下面的效果选择1个发动。
-- ●移动到没有使用的相邻的怪兽卡区域。
-- ●这张卡的正对面存在的1张对方的怪兽·魔法·陷阱卡回到持有者手卡。
function c39188539.initial_effect(c)
	-- 移动到没有使用的相邻的怪兽卡区域。
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
	-- 这张卡的正对面存在的1张对方的怪兽·魔法·陷阱卡回到持有者手卡。
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
-- 移动效果的发动条件：自身必须在主要怪兽区，且左侧或右侧相邻的主要怪兽区存在空位；若在额外怪兽区则不能发动。
function c39188539.seqcon(e,tp,eg,ep,ev,re,r,rp)
	local seq=e:GetHandler():GetSequence()
	if seq>4 then return false end
	-- 自身不在最左列时，检查左侧相邻格子是否为空位。
	return (seq>0 and Duel.CheckLocation(tp,LOCATION_MZONE,seq-1))
		-- 自身不在最右列时，检查右侧相邻格子是否为空位。
		or (seq<4 and Duel.CheckLocation(tp,LOCATION_MZONE,seq+1))
end
-- 该效果无实际代价，仅向对方提示自己发动了哪个效果；chk==0时直接返回true表示代价检查通过。
function c39188539.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 向对方玩家提示本次选择发动的效果（显示效果描述），便于对方确认。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
-- 移动效果发动时处理：根据自身位置计算左右相邻的空位并将这些可用格用位标记表示，然后让玩家选择一个目标格，把目标格序号存入Label并展示选择区域。
function c39188539.seqtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local seq=e:GetHandler():GetSequence()
	local flag=0
	-- 如果左侧有空格，则将左侧格加入可选区域标记（按位左移对应格数）。
	if seq>0 and Duel.CheckLocation(tp,LOCATION_MZONE,seq-1) then flag=flag|(1<<(seq-1)) end
	-- 如果右侧有空格，则将右侧格加入可选区域标记（按位左移对应格数）。
	if seq<4 and Duel.CheckLocation(tp,LOCATION_MZONE,seq+1) then flag=flag|(1<<(seq+1)) end
	-- 向玩家发送提示：请选择要移动到的位置。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOZONE)  --"请选择要移动到的位置"
	-- 让玩家从除可用格以外的区域中选出1个可移动到的格子，返回该格的位置标记s；~flag表示只允许选择未被禁用的空格。
	local s=Duel.SelectDisableField(tp,1,LOCATION_MZONE,0,~flag)
	local nseq=math.log(s,2)
	e:SetLabel(nseq)
	-- 向双方展示所选择的格子区域，用于界面高亮反馈。
	Duel.Hint(HINT_ZONE,tp,s)
end
-- 移动效果处理：先进行安全校验，若怪兽仍与效果关联、控制权未变、仍在主要怪兽区且目标格仍为空，则将怪兽移动到目标格。
function c39188539.seqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local seq=e:GetLabel()
	-- 安全校验：怪兽与效果失去联系、控制权被夺走、不在主要怪兽区或目标格已被占用，任一情况均不处理。
	if not c:IsRelateToEffect(e) or c:IsControler(1-tp) or c:GetSequence()>4 or not Duel.CheckLocation(tp,LOCATION_MZONE,seq) then return end
	-- 把怪兽移动到目标格序号seq。
	Duel.MoveSequence(c,seq)
end
-- 回手效果的取对象过滤器：这张卡必须位于风暴射手的同一纵列（正对面），并且是能够加入手卡的卡。
function c39188539.filter(c,g)
	return g:IsContains(c) and c:IsAbleToHand()
end
-- 回手效果发动时处理：获取与自身同一纵列的所有卡，检查其中是否存在对方的、可回手的卡；若有则选择1张作为对象，并设置回手牌的操作信息。
function c39188539.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local cg=e:GetHandler():GetColumnGroup()
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and c39188539.filter(chkc,cg) end
	-- 发动合法性检查：对方场上是否存在至少1张满足同纵列且可回手条件的卡。
	if chk==0 then return Duel.IsExistingTarget(c39188539.filter,tp,0,LOCATION_ONFIELD,1,nil,cg) end
	-- 向玩家发送提示：请选择要返回手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 让玩家从对方场上选择1张同纵列且可回手的卡作为效果对象，并自动登记为连锁对象。
	local g=Duel.SelectTarget(tp,c39188539.filter,tp,0,LOCATION_ONFIELD,1,1,nil,cg)
	-- 设置本次连锁的操作信息：处理分类为回手牌，对象为选择的卡（1张）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 回手效果处理：取得效果对象，若对象仍与效果关联，则将其送回持有者手卡。
function c39188539.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得这个效果发动时所选择的对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 以效果原因将对象卡送回持有者手卡。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
