--パペット・プラント
-- 效果：
-- 把这张卡从手卡丢弃去墓地。直到这个回合的结束阶段时，得到对方场上表侧表示存在的1只战士族或者魔法师族怪兽的控制权。
function c51119924.initial_effect(c)
	-- 卡片效果原文：把这张卡从手卡丢弃去墓地。直到这个回合的结束阶段时，得到对方场上表侧表示存在的1只战士族或者魔法师族怪兽的控制权。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(51119924,0))  --"获取控制权"
	e1:SetCategory(CATEGORY_CONTROL)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCost(c51119924.cost)
	e1:SetTarget(c51119924.target)
	e1:SetOperation(c51119924.operation)
	c:RegisterEffect(e1)
end
-- 定义发动代价：检查手卡中的这张卡是否可以作为代价丢弃去墓地；若可以则返回真，否则不满足发动条件。
function c51119924.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 丢弃手卡的这张卡作为发动代价（REASON_COST+REASON_DISCARD）。
	Duel.SendtoGrave(e:GetHandler(),REASON_COST+REASON_DISCARD)
end
-- 定义可选对象条件：对方场上的表侧表示怪兽，种族为战士族或魔法师族，且控制权可以被变更。
function c51119924.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_WARRIOR+RACE_SPELLCASTER) and c:IsControlerCanBeChanged()
end
-- 取对象效果的发动处理：在发动时确定对象（对方怪兽区1张符合条件的怪兽），设置选择提示并设定操作信息。
function c51119924.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c51119924.filter(chkc) end
	-- 发动条件确认：对方场上有至少1只满足filter条件的怪兽可作为对象（且能成为效果对象）。
	if chk==0 then return Duel.IsExistingTarget(c51119924.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 弹出发动者选择要改变控制权的怪兽的提示（选择框提示信息）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
	-- 从对方怪兽区选择1张满足条件的表侧怪兽作为效果对象（同时与当前连锁建立关联）。
	local g=Duel.SelectTarget(tp,c51119924.filter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置本次连锁的操作信息：效果分类为改变控制权（CATEGORY_CONTROL），涉及1张卡。
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,0,0)
end
-- 效果处理：取得之前选择的目标怪兽，若目标仍与效果关联且仍为表侧、符合条件的战士族/魔法师族怪兽，则转移其控制权直到回合结束。
function c51119924.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁中记录的目标对象怪兽（即发动时选择的那张卡）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsRace(RACE_WARRIOR+RACE_SPELLCASTER) then
		-- 让tp获得该目标怪兽的控制权，直到结束阶段（PHASE_END）时归还。
		Duel.GetControl(tc,tp,PHASE_END,1)
	end
end
