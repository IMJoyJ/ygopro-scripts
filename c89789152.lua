--タキオン・ギャラクシースパイラル
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。自己场上有「银河眼时空龙」怪兽存在的场合，这张卡的发动从手卡也能用。
-- ①：以自己场上1只龙族「银河」怪兽为对象才能发动。那只表侧表示怪兽直到回合结束时不会被战斗破坏，不受自身以外的卡的效果影响。
function c89789152.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：以自己场上1只龙族「银河」怪兽为对象才能发动。那只表侧表示怪兽直到回合结束时不会被战斗破坏，不受自身以外的卡的效果影响。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,89789152+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c89789152.target)
	e1:SetOperation(c89789152.activate)
	c:RegisterEffect(e1)
	-- 自己场上有「银河眼时空龙」怪兽存在的场合，这张卡的发动从手卡也能用。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(89789152,0))
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	e2:SetCondition(c89789152.handcon)
	c:RegisterEffect(e2)
end
-- 过滤条件：自己场上表侧表示的龙族「银河」怪兽
function c89789152.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x7b) and c:IsRace(RACE_DRAGON)
end
-- 效果①的发动准备与对象选择判定
function c89789152.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c89789152.filter(chkc) end
	-- 检查自己场上是否存在至少1只满足过滤条件的龙族「银河」怪兽作为合法的效果对象
	if chk==0 then return Duel.IsExistingTarget(c89789152.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 在客户端显示提示信息：请选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择自己场上1只表侧表示的龙族「银河」怪兽作为效果对象
	Duel.SelectTarget(tp,c89789152.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果①的发动处理：使作为对象的怪兽直到回合结束时获得战破抗性和不受自身以外卡片效果影响的抗性
function c89789152.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取本次效果发动的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 那只表侧表示怪兽直到回合结束时不会被战斗破坏
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 不受自身以外的卡的效果影响
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_IMMUNE_EFFECT)
		e2:SetValue(c89789152.efilter)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
	end
end
-- 免疫效果的过滤函数，判定效果来源是否非自身（即不受自身以外的卡的效果影响）
function c89789152.efilter(e,re)
	return e:GetHandler()~=re:GetOwner()
end
-- 过滤条件：自己场上表侧表示的「银河眼时空龙」怪兽
function c89789152.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x307b)
end
-- 手牌发动条件判定：检查自己场上是否存在「银河眼时空龙」怪兽
function c89789152.handcon(e)
	-- 检查自己场上是否存在至少1只表侧表示的「银河眼时空龙」怪兽
	return Duel.IsExistingMatchingCard(c89789152.cfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
