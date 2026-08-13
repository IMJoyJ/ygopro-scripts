--真魔六武衆－キザン
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 这个卡名的②③的效果1回合各能使用1次。
-- ①：自己场上的「六武众」怪兽的攻击力·守备力只在战斗阶段内上升600。
-- ②：对方主要阶段，从自己墓地把1张「六武式」卡除外，以场上1张卡为对象才能发动。那张卡破坏。
-- ③：自己场上有「六武众」怪兽2只以上存在的场合才能发动。这张卡从墓地特殊召唤。
local s,id,o=GetID()
-- 为卡片注册同调召唤手续、苏生限制以及①②③三个效果：①为对己方场上「六武众」怪兽的攻击力·守备力战斗阶段增益永续效果，②为对方主要阶段除外墓地「六武式」取对象破坏的诱发即时效果，③为墓地满足条件特殊召唤自身的起动效果。
function s.initial_effect(c)
	-- 为这张卡添加同调召唤手续：调整＋调整以外的怪兽1只以上（调整不限，调整以外不限种族，数量1只以上）。
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ①：自己场上的「六武众」怪兽的攻击力·守备力只在战斗阶段内上升600。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	-- 将该攻击力增益效果的作用对象限定为己方场上属于「六武众」系列的怪兽。
	e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x103d))
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(600)
	e1:SetCondition(s.atkcon)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e2)
	-- ②：对方主要阶段，从自己墓地把1张「六武式」卡除外，以场上1张卡为对象才能发动。那张卡破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"破坏"
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetHintTiming(0,TIMING_MAIN_END)
	e3:SetCountLimit(1,id)
	e3:SetCondition(s.descon)
	e3:SetCost(s.descost)
	e3:SetTarget(s.destg)
	e3:SetOperation(s.desop)
	c:RegisterEffect(e3)
	-- ③：自己场上有「六武众」怪兽2只以上存在的场合才能发动。这张卡从墓地特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))  --"特殊召唤"
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_GRAVE)
	e4:SetCountLimit(1,id+o)
	e4:SetCondition(s.spcon)
	e4:SetTarget(s.sptg)
	e4:SetOperation(s.spop)
	c:RegisterEffect(e4)
end
-- ①效果的适用条件：仅在战斗阶段内才让己方「六武众」怪兽攻击力·守备力上升600。
function s.atkcon(e)
	-- 返回当前是否为战斗阶段，作为①效果的发动/适用判定。
	return Duel.IsBattlePhase()
end
-- ②效果的发动条件：当前必须处于主要阶段，且回合玩家为对方的玩家（即对方主要阶段）。
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定是否满足“对方主要阶段”：当前为主要阶段且回合玩家是对方。
	return Duel.IsMainPhase() and Duel.GetTurnPlayer()==1-tp
end
-- 定义②效果代价的筛选条件：墓地中的「六武式」卡且可以作为代价除外。
function s.cfilter(c)
	return c:IsSetCard(0x203d) and c:IsAbleToRemoveAsCost()
end
-- ②效果的发动代价处理：从自己墓地选择1张「六武式」卡除外；包括检查墓地是否有可用代价、选择要除外的卡并除外。
function s.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检查：自己墓地是否存在至少1张满足条件的「六武式」卡可除外。
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 弹出选择提示“请选择要除外的卡”，并指定选择消息类型。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从自己墓地选择1张满足cfilter条件的「六武式」卡作为代价。
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将选中的「六武式」卡以表侧表示除外，作为这张卡②效果发动所需支付的代价。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- ②效果的目标指定：选择场上1张卡作为破坏对象，并设置对应的破坏操作信息。
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() end
	-- 目标检查：场上是否存在至少1张可以被选取为对象的卡（场上任意卡）。
	if chk==0 then return Duel.IsExistingTarget(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 弹出选择提示“请选择要破坏的卡”，并指定选择消息类型。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家从双方场上选择1张卡作为此效果的对象（取对象效果）。
	local g=Duel.SelectTarget(tp,nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置操作信息：本次效果将破坏对象卡1张，使其他卡可以响应此破坏。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- ②效果的处理：将发动时选择的对象卡破坏。
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得②效果发动时选择的1张对象卡。
	local tc=Duel.GetFirstTarget()
	-- 若对象卡仍与此效果关联（没有离场或失效），则将其以效果原因破坏。
	if tc:IsRelateToEffect(e) then Duel.Destroy(tc,REASON_EFFECT) end
end
-- ③效果的筛选条件：怪兽为表侧表示且属于「六武众」系列，用于统计自己场上满足条件的怪兽数量。
function s.spcfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x103d)
end
-- ③效果的发动条件：自己场上有至少2只表侧表示的「六武众」怪兽存在。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在至少2只表侧表示的「六武众」怪兽，满足③效果的发动条件。
	return Duel.IsExistingMatchingCard(s.spcfilter,tp,LOCATION_MZONE,0,2,nil)
end
-- ③效果发动时的目标确认：自己场上有空余的主要怪兽区域，且这张墓地的卡可以被特殊召唤；同时设置特殊召唤操作信息。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的主要怪兽区域空格，用于特殊召唤这张卡。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：本次效果将把这张卡特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ③效果的处理：在效果处理时，若这张卡仍在墓地且与效果关联、不受王家长眠之谷影响，则将其特殊召唤到己方场上。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判定这张卡仍与此效果关联（未被移离墓地等），并且不受王家长眠之谷的效果影响，才可继续特殊召唤。
	if c:IsRelateToEffect(e) and aux.NecroValleyFilter()(c) then
		-- 将这张卡以表侧表示特殊召唤到持有者（自己）的场上。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
