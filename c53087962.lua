--ベアルクティ－セプテン＝トリオン
-- 效果：
-- 这张卡不能同调召唤，等级差直到7为止从自己场上把8星以上的调整1只和调整以外的同调怪兽1只送去墓地的场合才能特殊召唤。这个卡名的②的效果1回合只能使用1次。
-- ①：只要这张卡在怪兽区域存在，从额外卡组特殊召唤的不持有等级的表侧表示怪兽的效果无效化。
-- ②：对方把怪兽特殊召唤的场合才能发动。从卡组把1张「北极天熊」卡加入手卡。
function c53087962.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡不能同调召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- 等级差直到7为止从自己场上把8星以上的调整1只和调整以外的同调怪兽1只送去墓地的场合才能特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_EXTRA)
	e2:SetCondition(c53087962.sprcon)
	e2:SetTarget(c53087962.sprtg)
	e2:SetOperation(c53087962.sprop)
	c:RegisterEffect(e2)
	-- ①：只要这张卡在怪兽区域存在，从额外卡组特殊召唤的不持有等级的表侧表示怪兽的效果无效化。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_DISABLE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e3:SetTarget(c53087962.distg)
	c:RegisterEffect(e3)
	-- 这个卡名的②的效果1回合只能使用1次。②：对方把怪兽特殊召唤的场合才能发动。从卡组把1张「北极天熊」卡加入手卡。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(53087962,0))
	e4:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCountLimit(1,53087962)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCondition(c53087962.thcon)
	e4:SetTarget(c53087962.thtg)
	e4:SetOperation(c53087962.thop)
	c:RegisterEffect(e4)
end
-- 筛选特殊召唤的素材候选：表侧表示且等级1以上且可以作为COST送去墓地的怪兽。
function c53087962.tgrfilter(c)
	return c:IsFaceup() and c:IsLevelAbove(1) and c:IsAbleToGraveAsCost()
end
-- 筛选素材中的调整：8星以上的调整怪兽。
function c53087962.tgrfilter1(c)
	return c:IsType(TYPE_TUNER) and c:IsLevelAbove(8)
end
-- 筛选素材中的非调整：调整以外的同调怪兽。
function c53087962.tgrfilter2(c)
	return not c:IsType(TYPE_TUNER) and c:IsType(TYPE_SYNCHRO)
end
-- 判断一组素材中是否存在另一只怪兽与当前候选c的等级差为7。
function c53087962.mnfilter(c,g)
	return g:IsExists(c53087962.mnfilter2,1,c,c)
end
-- 比较两只怪兽的等级差是否等于7（c的等级减去mc的等级为7）。
function c53087962.mnfilter2(c,mc)
	return c:GetLevel()-mc:GetLevel()==7
end
-- 判定选中的2张素材是否满足特殊召唤条件：包含1只8星以上调整和1只调整以外的同调怪兽，二者等级差为7，且从额外卡组特殊召唤此卡时有空位。
function c53087962.fselect(g,tp,sc)
	return g:GetCount()==2
		and g:IsExists(c53087962.tgrfilter1,1,nil) and g:IsExists(c53087962.tgrfilter2,1,nil)
		and g:IsExists(c53087962.mnfilter,1,nil,g)
		-- 确认把这些素材送去墓地后，额外卡组的此卡仍能特殊召唤到场上（有可用空格）。
		and Duel.GetLocationCountFromEx(tp,tp,g,sc)>0
end
-- 特殊召唤手续的条件：当c为空时视为可发动；否则检索自己场上候选素材，检查是否能选出满足条件的2张并确保额外卡组召唤区有空位。
function c53087962.sprcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 取得自己场上满足素材候选条件的怪兽群，用于后续选择素材。
	local g=Duel.GetMatchingGroup(c53087962.tgrfilter,tp,LOCATION_MZONE,0,nil)
	return g:CheckSubGroup(c53087962.fselect,2,2,tp,c)
end
-- 选择特殊召唤COST的素材：提示玩家从候选怪兽中选择满足条件的2张，选定后保存到效果标签并返回true。
function c53087962.sprtg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 取得自己场上满足素材候选条件的怪兽群，供玩家选择素材。
	local g=Duel.GetMatchingGroup(c53087962.tgrfilter,tp,LOCATION_MZONE,0,nil)
	-- 向玩家显示“请选择要送去墓地的卡”的提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	local sg=g:SelectSubGroup(tp,c53087962.fselect,true,2,2,tp,c)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 特殊召唤手续的执行：取出之前选定的素材组，将其送去墓地并清除该组对象。
function c53087962.sprop(e,tp,eg,ep,ev,re,r,rp,c)
	local tg=e:GetLabelObject()
	-- 将选定的2张素材怪兽作为特殊召唤代价送去墓地，原因记为特殊召唤。
	Duel.SendtoGrave(tg,REASON_SPSUMMON)
	tg:DeleteGroup()
end
-- ①效果的无效对象判定：该怪兽的召唤位置是额外卡组，且等级为0（即不持有等级）。
function c53087962.distg(e,c)
	return c:GetSummonLocation()==LOCATION_EXTRA and c:IsLevel(0)
end
-- ②效果的发动条件：本次特殊召唤成功的怪兽中存在由对方玩家（1-tp）特殊召唤的怪兽。
function c53087962.thcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsSummonPlayer,1,e:GetHandler(),1-tp)
end
-- ②效果检索卡组的筛选条件：卡名含有「北极天熊」字段且可以被加入手卡的卡。
function c53087962.thfilter(c)
	return c:IsSetCard(0x163) and c:IsAbleToHand()
end
-- ②效果的发动检查与操作信息设置：若卡组存在符合条件的「北极天熊」卡则可发动，并设置效果处理为从卡组把1张卡加入手卡。
function c53087962.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时合法性检查：卡组中必须存在至少1张符合条件的「北极天熊」卡，否则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c53087962.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：本次效果处理将从卡组把1张卡加入手卡，用于连锁判定。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ②效果处理：玩家从卡组选择1张「北极天熊」卡加入手卡，并让对方确认加入的卡。
function c53087962.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家显示“请选择要加入手牌的卡”的提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组选择1张满足条件的「北极天熊」卡（必须选1张，若没有则发动时已排除）。
	local g=Duel.SelectMatchingCard(tp,c53087962.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入其持有者的手卡，原因记为效果。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手卡的卡展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
	end
end
