--エルシャドール・ミドラーシュ
-- 效果：
-- 「影依」怪兽＋暗属性怪兽
-- 这张卡用融合召唤才能从额外卡组特殊召唤。
-- ①：场上的这张卡不会被对方的效果破坏。
-- ②：只要这张卡在怪兽区域存在，那个期间双方1回合只能有1次把怪兽特殊召唤。
-- ③：这张卡被送去墓地的场合，以自己墓地1张「影依」魔法·陷阱卡为对象才能发动。那张卡加入手卡。
function c94977269.initial_effect(c)
	-- 开启全局特殊召唤次数限制的标记（用于限制双方玩家的特殊召唤次数）。
	Duel.EnableGlobalFlag(GLOBALFLAG_SPSUMMON_COUNT)
	c:EnableReviveLimit()
	-- 设定融合素材为「影依」怪兽＋暗属性怪兽。
	aux.AddFusionProcShaddoll(c,ATTRIBUTE_DARK)
	-- 这张卡用融合召唤才能从额外卡组特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetCode(EFFECT_SPSUMMON_CONDITION)
	e2:SetRange(LOCATION_EXTRA)
	e2:SetValue(c94977269.splimit)
	c:RegisterEffect(e2)
	-- ①：场上的这张卡不会被对方的效果破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e3:SetRange(LOCATION_MZONE)
	-- 设定不会被破坏的效果来源为对方玩家（即不会被对方的效果破坏）。
	e3:SetValue(aux.indoval)
	c:RegisterEffect(e3)
	-- ②：只要这张卡在怪兽区域存在，那个期间双方1回合只能有1次把怪兽特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_SPSUMMON_COUNT_LIMIT)
	e4:SetRange(LOCATION_MZONE)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetTargetRange(1,1)
	e4:SetValue(1)
	c:RegisterEffect(e4)
	-- ③：这张卡被送去墓地的场合，以自己墓地1张「影依」魔法·陷阱卡为对象才能发动。那张卡加入手卡。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(94977269,0))  --"加入手卡"
	e5:SetCategory(CATEGORY_TOHAND)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e5:SetCode(EVENT_TO_GRAVE)
	e5:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e5:SetTarget(c94977269.thtg)
	e5:SetOperation(c94977269.thop)
	c:RegisterEffect(e5)
end
-- 限制特殊召唤方式的过滤函数，仅允许融合召唤。
function c94977269.splimit(e,se,sp,st)
	return bit.band(st,SUMMON_TYPE_FUSION)==SUMMON_TYPE_FUSION
end
-- 过滤自己墓地中「影依」品牌的魔法·陷阱卡，且该卡能加入手卡。
function c94977269.thfilter(c)
	return c:IsSetCard(0x9d) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- 效果③（回收墓地「影依」魔陷）的发动条件与对象选择处理。
function c94977269.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c94977269.thfilter(chkc) end
	-- 检查自己墓地是否存在至少1张满足条件的「影依」魔法·陷阱卡。
	if chk==0 then return Duel.IsExistingTarget(c94977269.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要加入手牌的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择自己墓地1张满足条件的「影依」魔法·陷阱卡作为效果对象。
	local g=Duel.SelectTarget(tp,c94977269.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置效果处理信息，表示该连锁的操作分类为将选中的1张卡加入手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果③（回收墓地「影依」魔陷）的效果处理函数。
function c94977269.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在发动时选择的作为效果对象的卡片。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将作为效果对象的卡片加入持有者的手牌。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
