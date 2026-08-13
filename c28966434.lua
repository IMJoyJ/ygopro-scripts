--ソリテア・マジカル
-- 效果：
-- 选择自己场上表侧表示存在的1只名字带有「命运女郎」的怪兽和场上表侧表示存在的1只怪兽发动。选择的名字带有「命运女郎」的怪兽的等级下降3星，选择的另1只怪兽破坏。这个效果1回合只能使用1次。
function c28966434.initial_effect(c)
	-- 选择自己场上表侧表示存在的1只名字带有「命运女郎」的怪兽和场上表侧表示存在的1只怪兽发动。选择的名字带有「命运女郎」的怪兽的等级下降3星，选择的另1只怪兽破坏。这个效果1回合只能使用1次。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(28966434,0))  --"破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c28966434.destg)
	e1:SetOperation(c28966434.desop)
	c:RegisterEffect(e1)
end
-- 过滤条件：选出自己场上表侧表示且名字带有「命运女郎」、等级不低于4的怪兽，作为等级下降的对象（等级4以上可保证下降3星后仍不低于1星）。
function c28966434.filter1(c)
	return c:IsFaceup() and c:IsSetCard(0x31) and c:IsLevelAbove(4)
end
-- 过滤条件：选出场上表侧表示存在的任意怪兽，作为另一只被破坏的对象（选择时会排除已选的命运女郎）。
function c28966434.filter2(c)
	return c:IsFaceup()
end
-- 目标选择函数：先处理chkc连锁对象检查（直接判定不合法，因此不响应外部指定对象），再在chk==0时判断是否存在两个满足条件的对象可供选择。
function c28966434.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 在效果发动合法性检查阶段（chk==0），确认自己场上存在至少1只表侧表示、名字带有「命运女郎」且等级4以上的怪兽。
	if chk==0 then return Duel.IsExistingTarget(c28966434.filter1,tp,LOCATION_MZONE,0,1,nil)
		-- 同时确认双方场上存在至少1只表侧表示怪兽，可以作为“另一只怪兽”的对象（实际选择时排除已选的第一只）。
		and Duel.IsExistingTarget(c28966434.filter2,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 设置选择提示：向玩家显示“请选择等级下降的怪兽”的提示，用于接下来的选择操作。
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(28966434,1))  --"请选择等级下降的怪兽"
	-- 让玩家从自己场上符合条件的「命运女郎」怪兽中选择1只，并登记为连锁对象（等级下降对象）。
	local g1=Duel.SelectTarget(tp,c28966434.filter1,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置选择提示：向玩家显示“请选择要破坏的卡”的提示，用于接下来的选择操作。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家从双方场上表侧表示怪兽中选择1只（排除已选的第一只）作为破坏对象，并登记为连锁对象。
	local g2=Duel.SelectTarget(tp,c28966434.filter2,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,g1:GetFirst())
	e:SetLabelObject(g1:GetFirst())
	-- 登记操作信息：本次效果将破坏对象卡组g2中的1张卡，供“破坏”相关卡的效果检测使用。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g2,1,0,0)
end
-- 效果处理阶段：获取最初选定的命运女郎c1和全部对象；若c1已不合法（等级不超过3、里侧表示或与效果失去关联）则整个效果不处理；否则给c1附加等级下降3星的效果；再检查破坏对象tc是否合法，合法则将其破坏。
function c28966434.desop(e,tp,eg,ep,ev,re,r,rp)
	local c1=e:GetLabelObject()
	-- 获取当前连锁处理时的对象卡组（即发动时选择的两张对象卡）。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local tc=g:GetFirst()
	if tc==c1 then tc=g:GetNext() end
	if c1:IsLevelBelow(3) or c1:IsFacedown() or not c1:IsRelateToEffect(e) then return end
	-- 选择的名字带有「命运女郎」的怪兽的等级下降3星。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_LEVEL)
	e1:SetValue(-3)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	c1:RegisterEffect(e1)
	if tc:IsFacedown() or not tc:IsRelateToEffect(e) then return end
	-- 以效果原因将另一只选择的对象怪兽tc破坏。
	Duel.Destroy(tc,REASON_EFFECT)
end
