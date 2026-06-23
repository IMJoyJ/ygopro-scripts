--スターライト・ジャンクション
-- 效果：
-- 「星光立交桥」的①②的效果1回合各能使用1次。
-- ①：把自己场上1只调整解放才能把这个效果发动。和解放的怪兽等级不同的1只「同调士」怪兽从卡组特殊召唤。
-- ②：对方回合自己从额外卡组把同调怪兽特殊召唤的场合，以场上1张卡为对象发动。那张卡回到持有者卡组。
function c1003840.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 创建效果，用于激活卡片。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(1003840,0))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1,1003840)
	e2:SetCost(c1003840.spcost)
	e2:SetTarget(c1003840.sptg)
	e2:SetOperation(c1003840.spop)
	c:RegisterEffect(e2)
	-- 创建效果，用于特殊召唤怪兽。
-- ①：把自己场上1只调整解放才能把这个效果发动。和解放的怪兽等级不同的1只「同调士」怪兽从卡组特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_TODECK)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCountLimit(1,1003841)
	e3:SetCondition(c1003840.thcon)
	e3:SetTarget(c1003840.thtg)
	e3:SetOperation(c1003840.thop)
	c:RegisterEffect(e3)
end
-- 创建效果，用于将卡片送回卡组。
-- ②：对方回合自己从额外卡组把同调怪兽特殊召唤的场合，以场上1张卡为对象发动。那张卡回到持有者卡组。
function c1003840.cfilter(c,e,tp,ft)
	local lv=c:GetLevel()
	return lv>0 and c:IsType(TYPE_TUNER)
		and (ft>0 or (c:IsControler(tp) and c:GetSequence()<5)) and (c:IsControler(tp) or c:IsFaceup())
		-- 过滤函数，检查是否是调整怪兽且等级与待选怪兽不同
		and Duel.IsExistingMatchingCard(c1003840.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp,lv)
end
-- 过滤函数，用于筛选可以特殊召唤的同调士怪兽。
function c1003840.spfilter(c,e,tp,lv)
	return c:IsSetCard(0x1017) and not c:IsLevel(lv) and c:IsLevelAbove(1) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 定义特殊召唤效果的费用支付阶段。首先获取场上怪兽区数量，然后检查是否有满足条件的卡片可解放。
function c1003840.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取玩家场上的怪兽区域的数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 检查是否可以释放调整怪兽
	if chk==0 then return ft>-1 and Duel.CheckReleaseGroup(tp,c1003840.cfilter,1,nil,e,tp,ft) end
	-- 选择要解放的调整怪兽。
	local g=Duel.SelectReleaseGroup(tp,c1003840.cfilter,1,1,nil,e,tp,ft)
	e:SetLabel(g:GetFirst():GetLevel())
	-- 解放选定的调整怪兽。
	Duel.Release(g,REASON_COST)
end
-- 定义特殊召唤效果的目标选择阶段。设置操作信息为特殊召唤。
function c1003840.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置当前处理的连锁的操作信息，指示这是一个特殊召唤的效果。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 定义特殊召唤效果的处理阶段。检查卡片是否仍然有效以及场上是否有足够的怪兽区。获取解放怪兽的等级，提示玩家选择要特殊召唤的卡片，并进行特殊召唤。
function c1003840.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前处理的效果是否与这张卡相关联，或者场上是否存在可用的怪兽区域
	if not e:GetHandler():IsRelateToEffect(e) or Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local lv=e:GetLabel()
	-- 向玩家发送提示信息，要求其选择要特殊召唤的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组中选择满足条件的同调士怪兽进行特殊召唤。
	local g=Duel.SelectMatchingCard(tp,c1003840.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,lv)
	if g:GetCount()>0 then
		-- 将选定的同调士怪兽特殊召唤到场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 定义触发效果的条件。检查是否为对方回合，以及被特殊召唤的怪兽是否在额外卡组且属于同步怪兽。
function c1003840.thcon(e,tp,eg,ep,ev,re,r,rp)
	local ec=eg:GetFirst()
	-- 检查当前回合玩家是否不是发动者
	return Duel.GetTurnPlayer()~=tp
		and ec:IsPreviousLocation(LOCATION_EXTRA) and ec:IsPreviousControler(tp) and ec:IsType(TYPE_SYNCHRO)
end
-- 定义将卡片送回卡组的目标选择阶段。提示玩家选择要送回卡组的卡片，并设置操作信息。
function c1003840.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsAbleToDeck() end
	if chk==0 then return true end
	-- 向玩家发送提示信息，要求其选择要返回卡组的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 让玩家从场上选择一张可以送回卡组的卡片。
	local g=Duel.SelectTarget(tp,Card.IsAbleToDeck,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置当前处理的连锁的操作信息，指示这是一个将卡片送回卡组的效果。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,0)
end
-- 定义将卡片送回卡组的处理阶段。获取选定的目标卡片，并将其送回持有者的卡组。
function c1003840.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标卡片
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 将目标卡片送回卡组。
		Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
