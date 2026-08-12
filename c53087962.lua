--ベアルクティ－セプテン＝トリオン
-- 效果：
-- 这张卡不能同调召唤，等级差直到7为止从自己场上把8星以上的调整1只和调整以外的同调怪兽1只送去墓地的场合才能特殊召唤。这个卡名的②的效果1回合只能使用1次。
-- ①：只要这张卡在怪兽区域存在，从额外卡组特殊召唤的不持有等级的表侧表示怪兽的效果无效化。
-- ②：对方把怪兽特殊召唤的场合才能发动。从卡组把1张「北极天熊」卡加入手卡。
function c53087962.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡不能同调召唤
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- 等级差直到7为止从自己场上把8星以上的调整1只和调整以外的同调怪兽1只送去墓地的场合才能特殊召唤
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_EXTRA)
	e2:SetCondition(c53087962.sprcon)
	e2:SetTarget(c53087962.sprtg)
	e2:SetOperation(c53087962.sprop)
	c:RegisterEffect(e2)
	-- 从额外卡组特殊召唤的不持有等级的表侧表示怪兽的效果无效化
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_DISABLE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e3:SetTarget(c53087962.distg)
	c:RegisterEffect(e3)
	-- 对方把怪兽特殊召唤的场合才能发动。从卡组把1张「北极天熊」卡加入手卡
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
-- 过滤场上满足条件的怪兽（表侧表示、等级1以上、可送入墓地）
function c53087962.tgrfilter(c)
	return c:IsFaceup() and c:IsLevelAbove(1) and c:IsAbleToGraveAsCost()
end
-- 过滤场上满足条件的调整怪兽（等级8以上）
function c53087962.tgrfilter1(c)
	return c:IsType(TYPE_TUNER) and c:IsLevelAbove(8)
end
-- 过滤场上满足条件的同调怪兽（非调整）
function c53087962.tgrfilter2(c)
	return not c:IsType(TYPE_TUNER) and c:IsType(TYPE_SYNCHRO)
end
-- 检查组中是否存在满足条件的怪兽（与当前怪兽等级差为7）
function c53087962.mnfilter(c,g)
	return g:IsExists(c53087962.mnfilter2,1,c,c)
end
-- 计算两个怪兽等级差是否等于7
function c53087962.mnfilter2(c,mc)
	return c:GetLevel()-mc:GetLevel()==7
end
-- 组合筛选函数：检查组中是否有2张卡、是否包含调整和同调怪兽、是否满足等级差条件、是否满足召唤位置空位条件
function c53087962.fselect(g,tp,sc)
	return g:GetCount()==2
		and g:IsExists(c53087962.tgrfilter1,1,nil) and g:IsExists(c53087962.tgrfilter2,1,nil)
		and g:IsExists(c53087962.mnfilter,1,nil,g)
		-- 判断额外卡组特殊召唤时是否有足够的召唤位置
		and Duel.GetLocationCountFromEx(tp,tp,g,sc)>0
end
-- 特殊召唤条件函数：检查场上是否存在满足条件的2张怪兽组合
function c53087962.sprcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取场上所有满足条件的怪兽（表侧表示、等级1以上、可送入墓地）
	local g=Duel.GetMatchingGroup(c53087962.tgrfilter,tp,LOCATION_MZONE,0,nil)
	return g:CheckSubGroup(c53087962.fselect,2,2,tp,c)
end
-- 特殊召唤目标选择函数：从满足条件的怪兽中选择2张符合条件的怪兽
function c53087962.sprtg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取场上所有满足条件的怪兽（表侧表示、等级1以上、可送入墓地）
	local g=Duel.GetMatchingGroup(c53087962.tgrfilter,tp,LOCATION_MZONE,0,nil)
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	local sg=g:SelectSubGroup(tp,c53087962.fselect,true,2,2,tp,c)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 特殊召唤处理函数：将选中的怪兽送去墓地并清除组对象
function c53087962.sprop(e,tp,eg,ep,ev,re,r,rp,c)
	local tg=e:GetLabelObject()
	-- 将目标怪兽以特殊召唤原因送入墓地
	Duel.SendtoGrave(tg,REASON_SPSUMMON)
	tg:DeleteGroup()
end
-- 无效化效果的目标筛选函数：从额外卡组特殊召唤且等级为0的怪兽
function c53087962.distg(e,c)
	return c:GetSummonLocation()==LOCATION_EXTRA and c:IsLevel(0)
end
-- 检索效果发动条件：对方有怪兽特殊召唤成功时
function c53087962.thcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsSummonPlayer,1,e:GetHandler(),1-tp)
end
-- 过滤卡组中满足条件的「北极天熊」卡（可加入手牌）
function c53087962.thfilter(c)
	return c:IsSetCard(0x163) and c:IsAbleToHand()
end
-- 检索效果处理函数：设置要处理的卡为卡组中的1张「北极天熊」卡
function c53087962.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1张满足条件的「北极天熊」卡
	if chk==0 then return Duel.IsExistingMatchingCard(c53087962.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：将要加入手牌的卡数量设为1，位置为卡组
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 检索效果处理函数：选择并把1张「北极天熊」卡加入手牌
function c53087962.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择1张满足条件的「北极天熊」卡
	local g=Duel.SelectMatchingCard(tp,c53087962.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡以效果原因送入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认所选的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
