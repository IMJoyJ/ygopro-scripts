--エルシャドール・ウェンディゴ
-- 效果：
-- 「影依」怪兽＋风属性怪兽
-- 这张卡用融合召唤才能从额外卡组特殊召唤。这个卡名的①的效果1回合只能使用1次。
-- ①：以自己场上1只怪兽为对象才能发动。这个回合，那只怪兽不会被和特殊召唤的对方怪兽的战斗破坏。这个效果在对方回合也能发动。
-- ②：这张卡被送去墓地的场合，以自己墓地1张「影依」魔法·陷阱卡为对象才能发动。那张卡加入手卡。
function c74009824.initial_effect(c)
	c:EnableReviveLimit()
	-- 设定融合素材为「影依」怪兽＋风属性怪兽
	aux.AddFusionProcShaddoll(c,ATTRIBUTE_WIND)
	-- 这张卡用融合召唤才能从额外卡组特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetCode(EFFECT_SPSUMMON_CONDITION)
	e2:SetRange(LOCATION_EXTRA)
	e2:SetValue(c74009824.splimit)
	c:RegisterEffect(e2)
	-- ①：以自己场上1只怪兽为对象才能发动。这个回合，那只怪兽不会被和特殊召唤的对方怪兽的战斗破坏。这个效果在对方回合也能发动。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(74009824,0))
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1,74009824)
	e3:SetTarget(c74009824.indtg)
	e3:SetOperation(c74009824.indop)
	c:RegisterEffect(e3)
	-- ②：这张卡被送去墓地的场合，以自己墓地1张「影依」魔法·陷阱卡为对象才能发动。那张卡加入手卡。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(74009824,1))
	e4:SetCategory(CATEGORY_TOHAND)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e4:SetTarget(c74009824.thtg)
	e4:SetOperation(c74009824.thop)
	c:RegisterEffect(e4)
end
-- 限制特殊召唤方式，判定是否为融合召唤
function c74009824.splimit(e,se,sp,st)
	return bit.band(st,SUMMON_TYPE_FUSION)==SUMMON_TYPE_FUSION
end
-- 效果①（战斗不破）的发动准备与目标选择
function c74009824.indtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) end
	-- 检查自己场上是否存在可以作为效果对象的怪兽
	if chk==0 then return Duel.IsExistingTarget(nil,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择自己场上1只怪兽作为效果对象
	Duel.SelectTarget(tp,nil,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果①（战斗不破）的效果处理
function c74009824.indop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 这个回合，那只怪兽不会被和特殊召唤的对方怪兽的战斗破坏。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(c74009824.indval)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
-- 判定进行战斗的对方怪兽是否为特殊召唤的怪兽
function c74009824.indval(e,c)
	return c:IsSummonType(SUMMON_TYPE_SPECIAL)
end
-- 过滤自己墓地中可以加入手牌的「影依」魔法·陷阱卡
function c74009824.thfilter(c)
	return c:IsSetCard(0x9d) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- 效果②（回收魔陷）的发动准备与目标选择
function c74009824.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c74009824.thfilter(chkc) end
	-- 检查自己墓地是否存在可以加入手牌的「影依」魔法·陷阱卡
	if chk==0 then return Duel.IsExistingTarget(c74009824.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择自己墓地1张「影依」魔法·陷阱卡作为效果对象
	local g=Duel.SelectTarget(tp,c74009824.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置连锁信息，表示该效果的处理为将选中的卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果②（回收魔陷）的效果处理
function c74009824.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的墓地卡片
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡片加入手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
