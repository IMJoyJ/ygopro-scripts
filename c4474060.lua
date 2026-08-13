--SPYRAL GEAR－ドローン
-- 效果：
-- ①：这张卡召唤·特殊召唤成功的场合才能发动。从对方卡组上面把3张卡确认，用喜欢的顺序回到卡组上面。
-- ②：把这张卡解放，以自己场上1只「秘旋谍」怪兽为对象才能发动。那只怪兽的攻击力上升对方场上的卡数量×500。这个效果在对方回合也能发动。
-- ③：从自己墓地把这张卡和1张「秘旋谍」卡除外，以自己墓地1只「秘旋谍-花公子」为对象才能发动。那张卡加入手卡。
function c4474060.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤成功的场合才能发动。从对方卡组上面把3张卡确认，用喜欢的顺序回到卡组上面。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(4474060,0))  --"确认对方卡组上方3张卡"
	e1:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c4474060.sttg)
	e1:SetOperation(c4474060.stop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：把这张卡解放，以自己场上1只「秘旋谍」怪兽为对象才能发动。那只怪兽的攻击力上升对方场上的卡数量×500。这个效果在对方回合也能发动。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(4474060,1))  --"攻击力上升"
	e3:SetCategory(CATEGORY_ATKCHANGE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetHintTiming(TIMING_DAMAGE_STEP)
	-- 设置伤害步骤条件限制：只能在伤害步骤且伤害计算前（即尚未进行伤害计算时）发动，不能在进行伤害计算后的伤害步骤时点发动。
	e3:SetCondition(aux.dscon)
	e3:SetCost(c4474060.atkcost)
	e3:SetTarget(c4474060.atktg)
	e3:SetOperation(c4474060.atkop)
	c:RegisterEffect(e3)
	-- ③：从自己墓地把这张卡和1张「秘旋谍」卡除外，以自己墓地1只「秘旋谍-花公子」为对象才能发动。那张卡加入手卡。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(4474060,2))  --"墓地回收"
	e4:SetCategory(CATEGORY_TOHAND)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetRange(LOCATION_GRAVE)
	e4:SetCost(c4474060.thcost)
	e4:SetTarget(c4474060.thtg)
	e4:SetOperation(c4474060.thop)
	c:RegisterEffect(e4)
end
-- 效果①的发动条件判定函数：确认对方卡组最上方至少有3张卡可供确认并排序。
function c4474060.sttg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果①的发动条件：对方卡组剩余卡数大于2（即至少3张）。
	if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_DECK)>2 end
end
-- 效果①的处理操作函数：把对方卡组最上方3张卡按喜欢的顺序放回卡组上方。
function c4474060.stop(e,tp,eg,ep,ev,re,r,rp)
	-- 由自己（tp）对对方（1-tp）卡组最上方3张卡进行排序，最先选择的卡放在最上面，依次放回。
	Duel.SortDecktop(tp,1-tp,3)
end
-- 效果②的发动代价函数：确认此卡当前可以解放，然后将自身解放作为代价发动。
function c4474060.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 将此卡（效果持有者）解放，作为效果发动的代价（REASON_COST）。
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 定义效果②可选目标的过滤条件：表侧表示且属于「秘旋谍」字段（0xee）的怪兽。
function c4474060.atkfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xee)
end
-- 效果②的发动目标判定函数：需要以自己场上1只表侧表示「秘旋谍」怪兽为对象，且对方场上有卡存在时才能发动。
function c4474060.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c4474060.atkfilter(chkc) end
	-- 效果②的发动条件之一：对方场上的卡数量大于0。
	if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_ONFIELD)>0 and
		-- 确认自己场上存在1只表侧表示且属于「秘旋谍」字段的怪兽可以作为效果对象。
		Duel.IsExistingTarget(c4474060.atkfilter,tp,LOCATION_MZONE,0,1,e:GetHandler()) end
	-- 给当前玩家提示“请选择表侧表示的卡”，将选择提示写入缓存。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让当前玩家从自己场上选择1只表侧表示「秘旋谍」怪兽作为效果对象，并自动记录为连锁对象。
	Duel.SelectTarget(tp,c4474060.atkfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果②的处理函数：对象怪兽仍与效果关联且表侧表示时，其攻击力上升对方场上卡数×500；该攻击力变化在其离场等标准重置条件下消失。
function c4474060.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果②选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 计算对方场上卡的数量乘以500，作为攻击力上升的数值。
		local atk=Duel.GetFieldGroupCount(tp,0,LOCATION_ONFIELD)*500
		-- 那只怪兽的攻击力上升对方场上的卡数量×500。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(atk)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
-- 定义③的代价格外筛选条件：该卡是「秘旋谍」字段、可作为代价除外，并且墓地存在可以加入手卡的「秘旋谍-花公子」。
function c4474060.cfilter(c,tp)
	return c:IsSetCard(0xee) and c:IsAbleToRemoveAsCost()
		-- 确认墓地存在至少1只满足条件的「秘旋谍-花公子」可作为回收对象（保证除外代价后能达到目的）。
		and Duel.IsExistingTarget(c4474060.thfilter,tp,LOCATION_GRAVE,0,1,c)
end
-- 定义效果③的对象筛选条件：卡名是「秘旋谍-花公子」（41091257）且可以加入手卡。
function c4474060.thfilter(c)
	return c:IsCode(41091257) and c:IsAbleToHand()
end
-- 效果③的代价判定函数：本卡可从墓地除外，且墓地存在另一张可作为代价除外的「秘旋谍」卡，同时存在可回收的花公子对象。
function c4474060.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToRemoveAsCost()
		-- 确认墓地存在至少1张可作为代价除外的「秘旋谍」卡（排除自身），且不排除花公子对象的存在。
		and Duel.IsExistingMatchingCard(c4474060.cfilter,tp,LOCATION_GRAVE,0,1,c,tp) end
	-- 提示当前玩家选择要除外的卡（用于③的代价）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从自己墓地选择1张满足cfilter条件的「秘旋谍」卡作为代价除外的对象（不取对象，因为它是代价）。
	local g=Duel.SelectMatchingCard(tp,c4474060.cfilter,tp,LOCATION_GRAVE,0,1,1,c,tp)
	g:AddCard(c)
	-- 将选中的「秘旋谍」卡和此卡自身一起以表侧表示除外，作为效果③发动的代价。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 效果③的目标选择函数：选择自己墓地1只「秘旋谍-花公子」作为对象，并设置将对象加入手卡的操作信息。
function c4474060.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c4474060.thfilter(chkc) end
	if chk==0 then return true end
	-- 提示当前玩家选择要加入手卡的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从自己墓地选择1只「秘旋谍-花公子」作为效果对象，并建立连锁联系。
	local g=Duel.SelectTarget(tp,c4474060.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置本次连锁的操作信息：将选中的对象卡加入手卡（CATEGORY_TOHAND），供其他效果检测。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果③处理函数：取得对象卡，若仍与效果关联则将其加入持有者手卡。
function c4474060.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果③选择的对象「秘旋谍-花公子」。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象卡送去持有者的手卡，原因记为效果处理（REASON_EFFECT）。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
