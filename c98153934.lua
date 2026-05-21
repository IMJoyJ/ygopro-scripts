--幻影死槍
-- 效果：
-- ①：只要这张卡在魔法与陷阱区域存在，每次以自己场上的「幻影骑士团」怪兽为对象的对方的效果发动给与对方500伤害。
-- ②：自己场上的暗属性怪兽被战斗或者对方的效果破坏的场合，可以作为代替把墓地的这张卡除外。
function c98153934.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：只要这张卡在魔法与陷阱区域存在，每次以自己场上的「幻影骑士团」怪兽为对象的对方的效果发动给与对方500伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCondition(c98153934.regcon)
	e2:SetOperation(c98153934.regop)
	c:RegisterEffect(e2)
	-- ②：自己场上的暗属性怪兽被战斗或者对方的效果破坏的场合，可以作为代替把墓地的这张卡除外。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EFFECT_DESTROY_REPLACE)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetTarget(c98153934.reptg)
	e3:SetValue(c98153934.repval)
	e3:SetOperation(c98153934.repop)
	c:RegisterEffect(e3)
end
-- 过滤自己场上表侧表示的「幻影骑士团」怪兽。
function c98153934.filter(c)
	return c:IsFaceup() and c:IsLocation(LOCATION_MZONE) and c:IsSetCard(0x10db)
end
-- 判断对方发动的效果是否以自己场上的「幻影骑士团」怪兽为对象。
function c98153934.regcon(e,tp,eg,ep,ev,re,r,rp)
	if not re or not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	-- 获取当前发动效果的对象卡片组。
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	return g and g:IsExists(c98153934.filter,1,nil) and 1-tp==rp
end
-- 注册一个在当前连锁处理时触发的单次效果，用于在效果处理时给予对方伤害。
function c98153934.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 给与对方500伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_CHAIN_SOLVING)
	e1:SetRange(LOCATION_SZONE)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetLabelObject(re)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET+RESET_CHAIN)
	e1:SetCondition(c98153934.damcon)
	e1:SetOperation(c98153934.damop)
	c:RegisterEffect(e1)
end
-- 判断当前正在处理的效果是否为之前注册的那个以「幻影骑士团」为对象的效果。
function c98153934.damcon(e,tp,eg,ep,ev,re,r,rp)
	return re==e:GetLabelObject()
end
-- 展示卡片并给与对方500点伤害。
function c98153934.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 在画面上展示卡片发动的动画提示。
	Duel.Hint(HINT_CARD,0,98153934)
	-- 给与对方500点效果伤害。
	Duel.Damage(1-tp,500,REASON_EFFECT)
end
-- 过滤自己场上因战斗或对方效果被破坏的表侧表示暗属性怪兽。
function c98153934.repfilter(c,tp)
	return c:IsFaceup() and c:IsLocation(LOCATION_MZONE) and c:IsControler(tp) and c:IsAttribute(ATTRIBUTE_DARK)
		and (c:IsReason(REASON_BATTLE) or (c:IsReason(REASON_EFFECT) and c:GetReasonPlayer()==1-tp)) and not c:IsReason(REASON_REPLACE)
end
-- 判断墓地的这张卡是否可以除外，并询问玩家是否使用代替破坏效果。
function c98153934.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemove() and eg:IsExists(c98153934.repfilter,1,nil,tp) end
	-- 询问玩家是否发动代替破坏的效果。
	return Duel.SelectEffectYesNo(tp,e:GetHandler(),96)
end
-- 确定需要代替破坏的怪兽符合过滤条件。
function c98153934.repval(e,c)
	return c98153934.repfilter(c,e:GetHandlerPlayer())
end
-- 执行代替破坏的处理，将墓地的这张卡除外。
function c98153934.repop(e,tp,eg,ep,ev,re,r,rp)
	-- 将墓地的这张卡除外。
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_EFFECT)
end
