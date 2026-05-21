--鉄獣の邂逅
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：以自己场上的连接状态的兽族·兽战士族·鸟兽族怪兽任意数量为对象才能发动。那些怪兽的攻击力直到回合结束时上升700。
-- ②：自己场上的连接状态的兽族·兽战士族·鸟兽族怪兽被战斗·效果破坏的场合，可以作为代替把墓地的这张卡除外。
function c96378317.initial_effect(c)
	-- ①：以自己场上的连接状态的兽族·兽战士族·鸟兽族怪兽任意数量为对象才能发动。那些怪兽的攻击力直到回合结束时上升700。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(96378317,0))
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	e1:SetCountLimit(1,96378317)
	-- 限制该效果在伤害步骤中只能在伤害计算前发动
	e1:SetCondition(aux.dscon)
	e1:SetTarget(c96378317.target)
	e1:SetOperation(c96378317.activate)
	c:RegisterEffect(e1)
	-- ②：自己场上的连接状态的兽族·兽战士族·鸟兽族怪兽被战斗·效果破坏的场合，可以作为代替把墓地的这张卡除外。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(96378317,1))
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,96378318)
	e2:SetValue(c96378317.replaceval)
	e2:SetTarget(c96378317.replacetg)
	e2:SetOperation(c96378317.replaceop)
	c:RegisterEffect(e2)
end
-- 过滤出自己场上表侧表示的、处于连接状态的兽族·兽战士族·鸟兽族怪兽
function c96378317.atkfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_BEAST+RACE_BEASTWARRIOR+RACE_WINDBEAST) and c:IsLinkState()
end
-- 效果①的发动准备，检查场上是否存在符合条件的怪兽，并让玩家选择任意数量的符合条件的怪兽作为对象
function c96378317.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsController(tp) and c96378317.atkfilter(chkc) end
	-- 检查自己场上是否存在至少1只表侧表示且处于连接状态的兽族·兽战士族·鸟兽族怪兽
	if chk==0 then return Duel.IsExistingTarget(c96378317.atkfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 选择自己场上1到99只（任意数量）表侧表示且处于连接状态的兽族·兽战士族·鸟兽族怪兽作为效果对象
	Duel.SelectTarget(tp,c96378317.atkfilter,tp,LOCATION_MZONE,0,1,99,nil)
end
-- 效果①的处理，使作为对象的怪兽的攻击力直到回合结束时上升700
function c96378317.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中仍与效果相关且表侧表示的对象怪兽
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e):Filter(Card.IsFaceup,nil)
	local tc=g:GetFirst()
	while tc do
		-- 那些怪兽的攻击力直到回合结束时上升700。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(700)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		tc=g:GetNext()
	end
end
-- 过滤出自己场上因战斗或效果将被破坏的、表侧表示且处于连接状态的兽族·兽战士族·鸟兽族怪兽
function c96378317.replaceft(c,tp)
	return c:IsFaceup() and c:IsRace(RACE_BEAST+RACE_BEASTWARRIOR+RACE_WINDBEAST) and c:IsLinkState()
		and c:IsLocation(LOCATION_MZONE) and c:IsControler(tp) and c:IsReason(REASON_EFFECT+REASON_BATTLE) and not c:IsReason(REASON_REPLACE)
end
-- 检查墓地的这张卡是否可以除外，以及场上是否有符合代替破坏条件的怪兽，并询问玩家是否使用代替效果
function c96378317.replacetg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemove() and eg:IsExists(c96378317.replaceft,1,nil,tp) end
	-- 弹出提示框，询问玩家是否选择适用代替破坏效果
	return Duel.SelectEffectYesNo(tp,e:GetHandler(),96)
end
-- 判定指定的怪兽是否符合代替破坏的条件
function c96378317.replaceval(e,c)
	return c96378317.replaceft(c,e:GetHandlerPlayer())
end
-- 执行代替破坏的具体操作，将墓地的这张卡除外
function c96378317.replaceop(e,tp,eg,ep,ev,re,r,rp)
	-- 将墓地的这张卡因代替破坏的效果除外
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_EFFECT+REASON_REPLACE)
end
