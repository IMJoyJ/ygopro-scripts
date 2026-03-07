--十二獣ヴァイパー
-- 效果：
-- ①：以自己场上1只兽战士族超量怪兽为对象才能发动。把自己的手卡·场上的这张卡在那只怪兽下面重叠作为超量素材。这个效果在对方回合也能发动。
-- ②：持有这张卡作为素材中的原本种族是兽战士族的超量怪兽得到以下效果。
-- ●这张卡和对方怪兽进行战斗的伤害计算后发动。那只对方怪兽除外。
function c31755044.initial_effect(c)
	-- 效果原文：①：以自己场上1只兽战士族超量怪兽为对象才能发动。把自己的手卡·场上的这张卡在那只怪兽下面重叠作为超量素材。这个效果在对方回合也能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(31755044,0))  --"这张卡重叠作为超量素材"
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_HAND+LOCATION_MZONE)
	e1:SetTarget(c31755044.mattg)
	e1:SetOperation(c31755044.matop)
	c:RegisterEffect(e1)
	-- 效果原文：②：持有这张卡作为素材中的原本种族是兽战士族的超量怪兽得到以下效果。●这张卡和对方怪兽进行战斗的伤害计算后发动。那只对方怪兽除外。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(31755044,1))  --"进行战斗的对方怪兽除外（十二兽 蛇笞）"
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_XMATERIAL+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_BATTLED)
	e2:SetCondition(c31755044.rmcon)
	e2:SetTarget(c31755044.rmtg)
	e2:SetOperation(c31755044.rmop)
	c:RegisterEffect(e2)
end
-- 规则层面：定义过滤器函数，用于判断目标怪兽是否为正面表示的兽战士族超量怪兽。
function c31755044.matfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_BEASTWARRIOR) and c:IsType(TYPE_XYZ)
end
-- 规则层面：判断是否满足发动条件，包括不能处于连锁状态、场上存在符合条件的目标怪兽、自身可以作为超量素材。
function c31755044.mattg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c31755044.matfilter(chkc) end
	if chk==0 then return not e:GetHandler():IsStatus(STATUS_CHAINING)
		-- 规则层面：检查场上是否存在符合条件的兽战士族超量怪兽作为目标。
		and Duel.IsExistingTarget(c31755044.matfilter,tp,LOCATION_MZONE,0,1,nil)
		and e:GetHandler():IsCanOverlay() end
	-- 规则层面：向玩家发送提示信息，提示选择效果的对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 规则层面：选择一个符合条件的场上怪兽作为效果对象。
	Duel.SelectTarget(tp,c31755044.matfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 规则层面：执行将自身作为超量素材叠放至目标怪兽下的操作。
function c31755044.matop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 规则层面：获取当前连锁中被选择的目标怪兽。
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and not tc:IsImmuneToEffect(e) and c:IsCanOverlay() then
		-- 规则层面：将自身叠放至目标怪兽下方作为超量素材。
		Duel.Overlay(tc,Group.FromCards(c))
	end
end
-- 规则层面：判断是否满足发动条件，包括自身种族为兽战士族、对方怪兽正在战斗中且处于战斗状态。
function c31755044.rmcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	e:SetLabelObject(bc)
	return c:GetOriginalRace()==RACE_BEASTWARRIOR
		and bc and bc:IsStatus(STATUS_OPPO_BATTLE) and bc:IsRelateToBattle()
end
-- 规则层面：设置发动时的操作信息，包括将对方怪兽除外。
function c31755044.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 规则层面：向对方玩家提示发动了该效果。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 规则层面：设置操作信息，表示将要除外对方怪兽。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,e:GetLabelObject(),1,0,0)
end
-- 规则层面：执行将对方怪兽除外的操作。
function c31755044.rmop(e,tp,eg,ep,ev,re,r,rp)
	local bc=e:GetLabelObject()
	if bc:IsRelateToBattle() and bc:IsControler(1-tp) then
		-- 规则层面：以效果原因将对方怪兽除外。
		Duel.Remove(bc,POS_FACEUP,REASON_EFFECT)
	end
end
