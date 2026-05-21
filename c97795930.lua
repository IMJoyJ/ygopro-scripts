--幻煌龍の天渦
-- 效果：
-- 场上有「海」存在的场合，这张卡的发动从手卡也能用。
-- ①：以自己场上1只「幻煌龙 螺旋」为对象才能发动。那只怪兽用有「幻煌龙」装备魔法卡3种类以上装备的状态战斗破坏对方3只效果怪兽时，自己决斗胜利。
-- ②：自己场上的通常怪兽被战斗·效果破坏的场合，可以作为代替把墓地的这张卡除外。
function c97795930.initial_effect(c)
	-- 注册卡片关联密码，表示这张卡的效果记有「海」的卡名
	aux.AddCodeList(c,22702055)
	-- ①：以自己场上1只「幻煌龙 螺旋」为对象才能发动。那只怪兽用有「幻煌龙」装备魔法卡3种类以上装备的状态战斗破坏对方3只效果怪兽时，自己决斗胜利。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c97795930.target)
	e1:SetOperation(c97795930.activate)
	c:RegisterEffect(e1)
	-- 场上有「海」存在的场合，这张卡的发动从手卡也能用。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(97795930,1))  --"适用「幻煌龙的天涡」的效果来发动"
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	e2:SetCondition(c97795930.handcon)
	c:RegisterEffect(e2)
	-- ②：自己场上的通常怪兽被战斗·效果破坏的场合，可以作为代替把墓地的这张卡除外。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EFFECT_DESTROY_REPLACE)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetTarget(c97795930.reptg)
	e3:SetValue(c97795930.repval)
	e3:SetOperation(c97795930.repop)
	c:RegisterEffect(e3)
end
-- 过滤条件：自己场上表侧表示的「幻煌龙 螺旋」
function c97795930.filter(c)
	return c:IsFaceup() and c:IsCode(56649609)
end
-- 效果①的发动准备与对象选择
function c97795930.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c97795930.filter(chkc) end
	-- 检查自己场上是否存在可以作为对象的「幻煌龙 螺旋」
	if chk==0 then return Duel.IsExistingTarget(c97795930.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 给玩家发送提示信息：请选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择自己场上1只「幻煌龙 螺旋」作为效果的对象
	Duel.SelectTarget(tp,c97795930.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果①的发动处理：为目标怪兽注册战斗破坏怪兽时触发的特殊胜利效果
function c97795930.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本次效果发动的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:GetFlagEffect(97795931)>0 then return end
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		tc:RegisterFlagEffect(97795931,RESET_EVENT+RESETS_STANDARD,0,0)
		-- 那只怪兽用有「幻煌龙」装备魔法卡3种类以上装备的状态战斗破坏对方3只效果怪兽时，自己决斗胜利。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
		e1:SetCode(EVENT_BATTLE_DESTROYING)
		e1:SetCondition(c97795930.wincon)
		e1:SetOperation(c97795930.winop)
		e1:SetOwnerPlayer(tp)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
-- 过滤条件：属于「幻煌龙」系列的装备魔法卡
function c97795930.winfilter(c)
	return c:IsSetCard(0xfa) and c:IsType(TYPE_EQUIP)
end
-- 检查特殊胜利的条件：战斗破坏对方怪兽、装备有3种以上「幻煌龙」装备魔法、且被破坏的是效果怪兽
function c97795930.wincon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=c:GetEquipGroup():Filter(c97795930.winfilter,nil)
	-- 检查是否因战斗破坏了对方怪兽、装备的「幻煌龙」装备魔法卡是否达到3种以上、且被破坏的怪兽是否为效果怪兽
	return aux.bdocon(e,tp,eg,ep,ev,re,r,rp) and g:GetClassCount(Card.GetCode)>2 and c:GetBattleTarget():IsType(TYPE_EFFECT)
		and c:GetControler()==e:GetOwnerPlayer()
end
-- 特殊胜利效果的处理：累计破坏次数，达到3次时宣告决斗胜利
function c97795930.winop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	c:RegisterFlagEffect(97795930,RESET_EVENT+RESETS_STANDARD,0,0)
	if c:GetFlagEffect(97795930)>2 then
		local WIN_REASON_CELESTIAL_WHIRLPOOL=0x1c
		-- 宣告当前玩家因「幻煌龙的天涡」的效果获得决斗胜利
		Duel.Win(tp,WIN_REASON_CELESTIAL_WHIRLPOOL)
	end
end
-- 手牌发动条件：检查场上是否存在「海」
function c97795930.handcon(e)
	-- 检查场上（或视为场上）是否存在卡名为「海」的卡
	return Duel.IsEnvironment(22702055)
end
-- 过滤条件：自己场上因战斗或效果被破坏的表侧表示通常怪兽
function c97795930.repfilter(c,tp)
	return c:IsFaceup() and c:IsType(TYPE_NORMAL) and c:IsLocation(LOCATION_MZONE)
		and c:IsControler(tp) and c:IsReason(REASON_EFFECT+REASON_BATTLE) and not c:IsReason(REASON_REPLACE)
end
-- 代替破坏效果的触发与询问：检查墓地的这张卡是否可以除外，并询问玩家是否适用代替效果
function c97795930.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemove() and eg:IsExists(c97795930.repfilter,1,nil,tp) end
	-- 询问玩家是否适用代替破坏的效果
	return Duel.SelectEffectYesNo(tp,e:GetHandler(),96)
end
-- 代替破坏的价值判定：确定被破坏的怪兽是否符合代替条件
function c97795930.repval(e,c)
	return c97795930.repfilter(c,e:GetHandlerPlayer())
end
-- 代替破坏的具体操作：将墓地的这张卡除外
function c97795930.repop(e,tp,eg,ep,ev,re,r,rp)
	-- 将墓地的这张卡因效果表侧表示除外
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_EFFECT)
end
