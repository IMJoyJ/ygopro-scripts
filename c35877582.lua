--法典の守護者アイワス
-- 效果：
-- 「大贤者」怪兽＋魔法师族怪兽
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：自己·对方的主要阶段，以这张卡以外的场上1只表侧表示怪兽为对象才能发动。自己场上的这张卡当作装备卡使用给那只怪兽装备。这个效果把这张卡给对方怪兽装备的场合，装备怪兽的效果不能发动，得到那个控制权。
-- ②：有这张卡装备的怪兽的攻击力·守备力上升1000。
function c35877582.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加融合召唤手续，使用1只「大贤者」怪兽和1只魔法师族怪兽作为融合素材进行融合召唤
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
-- 效果发动时的条件判断，只有在主要阶段1或主要阶段2才能发动
function c35877582.eqcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前游戏阶段
	local ph=Duel.GetCurrentPhase()
	return ph==PHASE_MAIN1 or ph==PHASE_MAIN2
end
-- 设置效果的发动条件，判断是否满足发动条件
function c35877582.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() and chkc~=c end
	-- 判断玩家场上是否有足够的魔法陷阱区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 判断场上是否存在满足条件的怪兽作为目标
		and Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,c) end
	-- 提示玩家选择要装备的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择目标怪兽
	local g=Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,c)
	-- 设置连锁操作信息，指定装备效果的目标
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,c,1,0,0)
	-- 设置连锁操作信息，指定控制权变更效果的目标
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,0,0,0)
end
-- 处理装备效果的执行逻辑
function c35877582.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or c:IsFacedown() or not c:IsControler(tp) then return end
	-- 获取当前连锁中的目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 判断是否满足装备条件，包括魔法陷阱区域是否足够、目标怪兽是否合法
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 or tc:IsFacedown() or not tc:IsRelateToEffect(e) then
		-- 若不满足条件则将装备卡送入墓地
		Duel.SendtoGrave(c,REASON_EFFECT)
		return
	end
	-- 尝试将装备卡装备给目标怪兽
	if not Duel.Equip(tp,c,tc) then return end
	-- 设置装备限制效果，防止其他卡装备到同一怪兽
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EQUIP_LIMIT)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetLabelObject(tc)
	e1:SetValue(c35877582.eqlimit)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e1)
	if tc:IsControler(1-tp) then
		-- 设置装备怪兽无法发动效果
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_EQUIP)
		e2:SetCode(EFFECT_CANNOT_TRIGGER)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e2)
		-- 设置装备怪兽的控制权转移效果
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_EQUIP)
		e3:SetCode(EFFECT_SET_CONTROL)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD)
		e3:SetOwnerPlayer(tp)
		e3:SetValue(c35877582.ctval)
		c:RegisterEffect(e3)
	end
end
-- 装备限制效果的判断函数，确保只能装备到指定怪兽
function c35877582.eqlimit(e,c)
	return c==e:GetLabelObject()
end
-- 控制权变更效果的判断函数，将控制权转移给装备者
function c35877582.ctval(e,c)
	return e:GetHandlerPlayer()
end
