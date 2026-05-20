--機皇枢インフィニティ・コア
-- 效果：
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤成功的场合才能发动。从卡组把1张「机皇」魔法·陷阱卡加入手卡。
-- ②：这张卡1回合只有1次不会被战斗破坏。
-- ③：这张卡被效果破坏的场合才能发动。相同属性的怪兽不在自己场上存在的1只「机皇帝」怪兽从手卡·卡组无视召唤条件特殊召唤。这个效果的发动后，直到回合结束时自己只能用1只怪兽攻击宣言。
function c77710579.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤成功的场合才能发动。从卡组把1张「机皇」魔法·陷阱卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(77710579,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,77710579)
	e1:SetTarget(c77710579.thtg)
	e1:SetOperation(c77710579.thop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：这张卡1回合只有1次不会被战斗破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
	e3:SetCountLimit(1)
	e3:SetValue(c77710579.valcon)
	c:RegisterEffect(e3)
	-- ③：这张卡被效果破坏的场合才能发动。相同属性的怪兽不在自己场上存在的1只「机皇帝」怪兽从手卡·卡组无视召唤条件特殊召唤。这个效果的发动后，直到回合结束时自己只能用1只怪兽攻击宣言。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(77710579,1))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_DESTROYED)
	e4:SetCountLimit(1,77710579+100)
	e4:SetCondition(c77710579.spcon2)
	e4:SetTarget(c77710579.sptg2)
	e4:SetOperation(c77710579.spop2)
	c:RegisterEffect(e4)
end
-- 过滤条件：卡名含有「机皇」的魔法·陷阱卡且可以加入手卡
function c77710579.thfilter(c)
	return c:IsSetCard(0x13) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- 效果①的发动准备与效果处理信息设置
function c77710579.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在可检索的「机皇」魔法·陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(c77710579.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：从卡组将1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果①的效果处理：从卡组将1张「机皇」魔法·陷阱卡加入手卡
function c77710579.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1张满足过滤条件的「机皇」魔法·陷阱卡
	local g=Duel.SelectMatchingCard(tp,c77710579.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		-- 将选中的卡加入手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手卡的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 设置不会被破坏的类型为战斗破坏
function c77710579.valcon(e,re,r,rp)
	return bit.band(r,REASON_BATTLE)~=0
end
-- 检查这张卡是否因效果而被破坏
function c77710579.spcon2(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_EFFECT)
end
-- 过滤条件：自己场上表侧表示存在指定属性的怪兽
function c77710579.filter(c,att)
	return c:IsFaceup() and c:IsAttribute(att)
end
-- 过滤条件：卡名含有「机皇帝」的怪兽，可以特殊召唤，且其属性在自己场上不存在
function c77710579.spfilter(c,e,tp)
	return c:IsSetCard(0x3013) and c:IsType(TYPE_MONSTER) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
		-- 检查自己场上是否不存在与该怪兽相同属性的怪兽
		and not Duel.IsExistingMatchingCard(c77710579.filter,tp,LOCATION_MZONE,0,1,nil,c:GetAttribute())
end
-- 效果③的发动准备与效果处理信息设置
function c77710579.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡或卡组中是否存在满足特殊召唤条件的「机皇帝」怪兽
		and Duel.IsExistingMatchingCard(c77710579.spfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置操作信息：从手卡或卡组将1只怪兽特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_HAND)
end
-- 效果③的效果处理：特殊召唤「机皇帝」怪兽，并适用攻击宣言限制
function c77710579.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 如果自己场上有可用的怪兽区域
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 让玩家从手卡或卡组选择1只满足特殊召唤条件的「机皇帝」怪兽
		local g=Duel.SelectMatchingCard(tp,c77710579.spfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 将选中的怪兽无视召唤条件以表侧表示特殊召唤
			Duel.SpecialSummon(g,0,tp,tp,true,false,POS_FACEUP)
		end
	end
	local c=e:GetHandler()
	-- 这个效果的发动后，直到回合结束时自己只能用1只怪兽攻击宣言。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
	e2:SetReset(RESET_PHASE+PHASE_END)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetCondition(c77710579.atkcon)
	e2:SetTarget(c77710579.atktg)
	-- 注册限制攻击宣言的效果给玩家
	Duel.RegisterEffect(e2,tp)
	-- 这个效果的发动后，直到回合结束时自己只能用1只怪兽攻击宣言。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_ATTACK_ANNOUNCE)
	e3:SetReset(RESET_PHASE+PHASE_END)
	e3:SetOperation(c77710579.checkop)
	e3:SetLabelObject(e2)
	-- 注册用于记录攻击宣言怪兽的全局事件监听效果
	Duel.RegisterEffect(e3,tp)
end
-- 攻击限制效果的启用条件：已有怪兽进行了攻击宣言
function c77710579.atkcon(e)
	return e:GetLabel()~=0
end
-- 攻击限制效果的对象：除已进行攻击宣言的怪兽以外的所有怪兽
function c77710579.atktg(e,c)
	return c:GetFieldID()~=e:GetLabel()
end
-- 记录首次进行攻击宣言的怪兽的字段ID
function c77710579.checkop(e,tp,eg,ep,ev,re,r,rp)
	local fid=eg:GetFirst():GetFieldID()
	e:GetLabelObject():SetLabel(fid)
end
