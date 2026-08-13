--キラーチューン・トラックメイカー
-- 效果：
-- 「杀手级调整曲」调整＋调整1只以上
-- 场上的这张卡为素材作同调召唤的场合，手卡1只调整也能作为同调素材。这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡特殊召唤的场合才能发动。从卡组把1张「杀手级调整曲」卡加入手卡。
-- ②：这张卡作为同调素材送去墓地的场合才能发动。对方场上1张卡回到手卡。
local s,id,o=GetID()
-- 初始化此卡的全部效果：注册混合同调素材手续（「杀手级调整曲」调整+调整1只以上）、苏生限制、手牌调整作为同调素材的规则效果、特殊召唤时检索的①效果、作为同调素材送去墓地时让对方卡回手的②效果，以及防止上述规则效果被无效/复制的保护效果。
function s.initial_effect(c)
	-- 为此卡添加混合同调召唤手续：素材组合为1只「杀手级调整曲」字段的调整怪兽 + 1只以上调整怪兽（数量总和1~99），其中至少包含1只调整。
	aux.AddSynchroMixProcedure(c,aux.FilterBoolFunction(Card.IsSetCard,0x1d5),nil,nil,aux.Tuner(nil),1,99)
	c:EnableReviveLimit()
	-- 对应效果原文：「场上的这张卡为素材作同调召唤的场合，手卡1只调整也能作为同调素材。」（实现为EFFECT_HAND_SYNCHRO，且该规则效果不可被无效、不可被复制，并限定此卡在场上时适用）。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SPSUM_PARAM)
	e1:SetCondition(s.syncon)
	e1:SetCode(EFFECT_HAND_SYNCHRO)
	e1:SetTargetRange(0,1)
	e1:SetTarget(s.tfilter)
	c:RegisterEffect(e1)
	-- 对应效果原文：「①：这张卡特殊召唤的场合才能发动。从卡组把1张「杀手级调整曲」卡加入手卡。」
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))  --"检索效果"
	e2:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	-- 对应效果原文：「②：这张卡作为同调素材送去墓地的场合才能发动。对方场上1张卡回到手卡。」
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"回手效果"
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_BE_MATERIAL)
	e3:SetCountLimit(1,id+o)
	e3:SetCondition(s.rthcon)
	e3:SetTarget(s.rthtg)
	e3:SetOperation(s.rthop)
	c:RegisterEffect(e3)
	s.killer_tune_be_material_effect=e3
	-- 对应上述规则效果的保护性注册（效果外文本实现）：使「场上的这张卡为素材作同调召唤的场合，手卡1只调整也能作为同调素材」这一规则效果不会被无效化或复制，并作为内部标记。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e4:SetCode(21142671)
	c:RegisterEffect(e4)
end
-- 过滤函数：判定某张卡是否拥有调整怪兽类型（用于限定可作为同调素材的手牌调整怪兽）。
function s.tfilter(e,c)
	return c:IsSynchroType(TYPE_TUNER)
end
-- 规则效果的条件：只有当此卡在场上的主要怪兽区时，手牌调整怪兽才能作为同调素材使用。
function s.syncon(e)
	return e:GetHandler():IsLocation(LOCATION_MZONE)
end
-- 检索用过滤条件：卡名含有「杀手级调整曲」字段，并且可以被加入手卡。
function s.thfilter(c)
	return c:IsSetCard(0x1d5) and c:IsAbleToHand()
end
-- ①效果的发动条件与处理预告：卡组中存在满足s.thfilter的卡时才可发动，并声明本次操作会将1张卡从卡组加入手卡。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查：确认自己卡组存在至少1张满足检索条件的「杀手级调整曲」卡片。
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 登记操作信息：此效果处理的分类为检索并加入手卡，目标卡组，数量1。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ①效果的实际处理：从卡组筛选并选择1张「杀手级调整曲」卡加入手卡，然后向对方展示该卡。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 发动时向玩家显示选择提示，提示内容为“请选择要加入手牌的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从己方卡组中选出1张满足s.thfilter的卡片作为检索对象。
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将检索到的卡片加入其持有者的手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对方确认被加入手卡的卡片。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- ②效果的发动条件：此卡作为同调素材被送去墓地时（当前位于墓地，且素材原因包含REASON_SYNCHRO）才能发动。
function s.rthcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and r==REASON_SYNCHRO
end
-- ②效果的发动条件与处理预告：对方场上有可以返回手卡的卡时才可发动，并声明本次操作会选对方场上1张卡返回手卡。
function s.rthtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查：确认对方场上存在至少1张能够返回手卡的卡片。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 登记操作信息：此效果处理的分类为返回手卡，目标为对方场上，数量1。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,1-tp,LOCATION_ONFIELD)
end
-- ②效果的实际处理：选择对方场上1张可返回手卡的卡，播放选中动画并将其返回手卡。
function s.rthop(e,tp,eg,ep,ev,re,r,rp)
	-- 发动时向玩家显示选择提示，提示内容为“请选择要返回手牌的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 从对方场上选择1张满足CanAbleToHand的卡片作为返回手卡的对象。
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,1,1,nil)
	if g:GetCount()>0 then
		-- 为所选卡片播放被选择为对象的动画，并记录其成为对象。
		Duel.HintSelection(g)
		-- 将选中的卡片返回其持有者的手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
	end
end
