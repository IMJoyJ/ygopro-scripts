--二重露光
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：以场上2只6星以下的同名怪兽为对象才能发动。那些怪兽的等级变成2倍。
-- ②：自己·对方的战斗阶段开始时，以自己场上1只「光波」怪兽为对象才能发动。选那只怪兽以外的场上1只表侧表示怪兽，直到结束阶段那个卡名当作和作为对象的「光波」怪兽同名卡使用。
function c81881839.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：以场上2只6星以下的同名怪兽为对象才能发动。那些怪兽的等级变成2倍。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(81881839,0))  --"等级变成2倍"
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,81881839)
	e2:SetTarget(c81881839.lvtg)
	e2:SetOperation(c81881839.lvop)
	c:RegisterEffect(e2)
	-- ②：自己·对方的战斗阶段开始时，以自己场上1只「光波」怪兽为对象才能发动。选那只怪兽以外的场上1只表侧表示怪兽，直到结束阶段那个卡名当作和作为对象的「光波」怪兽同名卡使用。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(81881839,1))  --"改变卡名"
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_PHASE+PHASE_BATTLE_START)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,81881840)
	e3:SetTarget(c81881839.nametg)
	e3:SetOperation(c81881839.nameop)
	c:RegisterEffect(e3)
end
-- 过滤场上表侧表示、等级在6星以下且可以成为效果对象的怪兽
function c81881839.lvfilter(c,e)
	return c:IsFaceup() and c:IsLevelBelow(6) and c:IsCanBeEffectTarget(e)
end
-- 检查选取的卡片组中的怪兽是否为同名怪兽
function c81881839.fselect(g)
	return g:GetClassCount(Card.GetCode)==1
end
-- 效果①的靶向处理，寻找场上2只6星以下的同名怪兽并设为效果对象
function c81881839.lvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 获取双方场上所有满足等级6以下且能成为效果对象的表侧表示怪兽
	local g=Duel.GetMatchingGroup(c81881839.lvfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,e)
	if chkc then return false end
	if chk==0 then return g:CheckSubGroup(c81881839.fselect,2,2) end
	-- 提示玩家选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	local sg=g:SelectSubGroup(tp,c81881839.fselect,false,2,2)
	-- 将选择的2只怪兽设置为当前效果的对象
	Duel.SetTargetCard(sg)
end
-- 过滤出仍存在于场上且对当前效果有效的对象怪兽
function c81881839.tgfilter(c,e)
	return c:IsFaceup() and c:IsRelateToEffect(e)
end
-- 效果①的操作处理，将作为对象的怪兽的等级变成2倍
function c81881839.lvop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中仍适用于此效果的对象怪兽
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(c81881839.tgfilter,nil,e)
	if g:GetCount()<=0 then return end
	-- 遍历所有符合条件的对象怪兽
	for tc in aux.Next(g) do
		-- 那些怪兽的等级变成2倍。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetValue(tc:GetLevel()*2)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
-- 过滤场上表侧表示且卡名不等于指定卡名的怪兽
function c81881839.namefilter(c,code)
	return c:IsFaceup() and not c:IsCode(code)
end
-- 过滤自己场上表侧表示的「光波」怪兽，且场上存在至少1只与其不同名的表侧表示怪兽
function c81881839.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xe5)
		-- 检查场上是否存在至少1只与该「光波」怪兽不同名的表侧表示怪兽
		and Duel.IsExistingMatchingCard(c81881839.namefilter,0,LOCATION_MZONE,LOCATION_MZONE,1,c,c:GetCode())
end
-- 效果②的靶向处理，选择自己场上1只「光波」怪兽作为对象
function c81881839.nametg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c81881839.cfilter(chkc) end
	-- 检查自己场上是否存在符合条件的「光波」怪兽作为可选对象
	if chk==0 then return Duel.IsExistingTarget(c81881839.cfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择自己场上的「光波」怪兽
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(81881839,2))  --"请选择自己的「光波」怪兽"
	-- 玩家选择自己场上1只「光波」怪兽并设为效果对象
	Duel.SelectTarget(tp,c81881839.cfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果②的操作处理，选择另一只表侧表示怪兽，使其卡名直到结束阶段当作与作为对象的「光波」怪兽同名
function c81881839.nameop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的「光波」怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		local code=tc:GetCode()
		-- 提示玩家选择要改变卡名的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(81881839,3))  --"请选择要改变卡名的怪兽"
		-- 玩家选择1只作为对象以外的、且与对象怪兽不同名的表侧表示怪兽
		local g=Duel.SelectMatchingCard(tp,c81881839.namefilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,tc,code)
		local sc=g:GetFirst()
		if sc then
			-- 闪烁显示被选中的怪兽
			Duel.HintSelection(g)
			-- 直到结束阶段那个卡名当作和作为对象的「光波」怪兽同名卡使用。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CHANGE_CODE)
			e1:SetValue(tc:GetCode())
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			sc:RegisterEffect(e1)
		end
	end
end
