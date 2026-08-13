--法典の守護者アイワス
-- 效果：
-- 「大贤者」怪兽＋魔法师族怪兽
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：自己·对方的主要阶段，以这张卡以外的场上1只表侧表示怪兽为对象才能发动。自己场上的这张卡当作装备卡使用给那只怪兽装备。这个效果把这张卡给对方怪兽装备的场合，装备怪兽的效果不能发动，得到那个控制权。
-- ②：有这张卡装备的怪兽的攻击力·守备力上升1000。
function c35877582.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡添加融合召唤手续：以卡名含有「大贤者」的怪兽和魔法师族怪兽各1只为融合素材才能融合召唤。
	aux.AddFusionProcFun2(c,aux.FilterBoolFunction(Card.IsFusionSetCard,0x150),aux.FilterBoolFunction(Card.IsRace,RACE_SPELLCASTER),true)
	-- ①：自己·对方的主要阶段，以这张卡以外的场上1只表侧表示怪兽为对象才能发动。自己场上的这张卡当作装备卡使用给那只怪兽装备。这个效果把这张卡给对方怪兽装备的场合，装备怪兽的效果不能发动，得到那个控制权。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(35877582,0))
	e1:SetCategory(CATEGORY_EQUIP+CATEGORY_CONTROL)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e1:SetCountLimit(1,35877582)
	e1:SetCondition(c35877582.eqcon)
	e1:SetTarget(c35877582.eqtg)
	e1:SetOperation(c35877582.eqop)
	c:RegisterEffect(e1)
	-- ②：有这张卡装备的怪兽的攻击力·守备力上升1000。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(1000)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e3)
end
-- ①效果的发动条件：当前阶段为主要阶段1或主要阶段2，即自己·对方的主要阶段才能发动。
function c35877582.eqcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前游戏阶段并存入局部变量ph，用于判断是否处于主要阶段。
	local ph=Duel.GetCurrentPhase()
	return ph==PHASE_MAIN1 or ph==PHASE_MAIN2
end
-- ①效果的发动合法性与目标选择函数：先检查对象是否为这张卡以外的场上表侧表示怪兽且自己魔陷区有空位；若满足则让玩家选择1只对象，并设置“装备”和“获得控制权”的操作信息。
function c35877582.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() and chkc~=c end
	-- 检查自己魔陷区是否有空位，以确定能否将这张卡作为装备卡装备上去（装备卡需占用魔陷区）。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查场上双方怪兽区是否存在这张卡以外的表侧表示怪兽，可作为取对象的目标。
		and Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,c) end
	-- 给玩家显示“请选择要装备的卡”的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 让玩家从场上表侧表示怪兽中选择1只作为效果对象，并将该卡登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,c)
	-- 设置操作信息：这张卡将被用作装备卡，便于后续进行装备相关效果检测。
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,c,1,0,0)
	-- 设置操作信息：对象怪兽的控制权将被获得，便于后续进行控制权相关效果检测。
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,0,0,0)
end
-- ①效果处理：若条件满足则将这张卡装备给对象怪兽；若对象是对方怪兽，则额外附加“装备怪兽不能发动效果”和“获得其控制权”的效果；若处理时条件不满足，则将这张卡送去墓地。
function c35877582.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or c:IsFacedown() or not c:IsControler(tp) then return end
	-- 取得当前连锁登记的对象怪兽（即选择的装备对象）。
	local tc=Duel.GetFirstTarget()
	-- 处理时判定：若自己魔陷区已无空位、对象怪兽变为里侧表示或对象怪兽与效果失去关联，则不能继续装备。
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 or tc:IsFacedown() or not tc:IsRelateToEffect(e) then
		-- 装备不能进行时，将这张卡以效果原因送去墓地。
		Duel.SendtoGrave(c,REASON_EFFECT)
		return
	end
	-- 执行装备动作，把这张卡作为装备卡装备给对象怪兽；若装备失败则直接结束处理。
	if not Duel.Equip(tp,c,tc) then return end
	-- 自己场上的这张卡当作装备卡使用给那只怪兽装备（装备对象限定为原选择的对象怪兽）。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EQUIP_LIMIT)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetLabelObject(tc)
	e1:SetValue(c35877582.eqlimit)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e1)
	if tc:IsControler(1-tp) then
		-- 装备怪兽的效果不能发动。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_EQUIP)
		e2:SetCode(EFFECT_CANNOT_TRIGGER)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e2)
		-- 得到那个控制权。
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_EQUIP)
		e3:SetCode(EFFECT_SET_CONTROL)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD)
		e3:SetOwnerPlayer(tp)
		e3:SetValue(c35877582.ctval)
		c:RegisterEffect(e3)
	end
end
-- 装备限制函数的判定：仅当尝试装备的卡是原选择的对象怪兽时才允许，防止这张卡被错误装备到其他怪兽上。
function c35877582.eqlimit(e,c)
	return c==e:GetLabelObject()
end
-- 获得控制权效果的Value函数：返回这张装备卡当前的控制者，使装备怪兽的控制权转移给艾华斯的控制者，实现“得到那个控制权”。
function c35877582.ctval(e,c)
	return e:GetHandlerPlayer()
end
