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
	-- ①：把自己场上1只调整解放才能把这个效果发动。和解放的怪兽等级不同的1只「同调士」怪兽从卡组特殊召唤。
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
	-- ②：对方回合自己从额外卡组把同调怪兽特殊召唤的场合，以场上1张卡为对象发动。那张卡回到持有者卡组。
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
-- 过滤场上可解放作为代价的调整怪兽的过滤函数
function c1003840.cfilter(c,e,tp,ft)
	local lv=c:GetLevel()
	return lv>0 and c:IsType(TYPE_TUNER)
		and (ft>0 or (c:IsControler(tp) and c:GetSequence()<5)) and (c:IsControler(tp) or c:IsFaceup())
		-- 检查卡组中是否存在满足特殊召唤条件的「同调士」怪兽
		and Duel.IsExistingMatchingCard(c1003840.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp,lv)
end
-- 过滤卡组中卡名包含「同调士」且等级与解放怪兽不同并可以特殊召唤的怪兽的过滤函数
function c1003840.spfilter(c,e,tp,lv)
	return c:IsSetCard(0x1017) and not c:IsLevel(lv) and c:IsLevelAbove(1) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 特殊召唤效果的代价支付函数，解放自己场上1只调整怪兽
function c1003840.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取自己场上怪兽区域的可使用空位数
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 检查怪兽区域和场上可解放调整怪兽是否符合支付代价的要求
	if chk==0 then return ft>-1 and Duel.CheckReleaseGroup(tp,c1003840.cfilter,1,nil,e,tp,ft) end
	-- 让玩家选择解放1只自己场上的调整怪兽
	local g=Duel.SelectReleaseGroup(tp,c1003840.cfilter,1,1,nil,e,tp,ft)
	e:SetLabel(g:GetFirst():GetLevel())
	-- 解放选择的怪兽以支付发动代价
	Duel.Release(g,REASON_COST)
end
-- 特殊召唤效果的目标选择与发动检查函数
function c1003840.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置效果处理的信息，操作类型为特殊召唤，目标为卡组中的怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 特殊召唤效果的执行操作函数
function c1003840.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查这张场地魔法卡是否仍存在于场上，以及自己的怪兽区域是否存在空位，若不满足则不处理
	if not e:GetHandler():IsRelateToEffect(e) or Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local lv=e:GetLabel()
	-- 给玩家发送选择特殊召唤怪兽的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家选择卡组中1只满足特殊召唤条件的「同调士」怪兽
	local g=Duel.SelectMatchingCard(tp,c1003840.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,lv)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 判定是否满足对方回合从额外卡组特殊召唤同调怪兽的发动条件函数
function c1003840.thcon(e,tp,eg,ep,ev,re,r,rp)
	local ec=eg:GetFirst()
	-- 检查当前回合玩家是否为对方玩家
	return Duel.GetTurnPlayer()~=tp
		and ec:IsPreviousLocation(LOCATION_EXTRA) and ec:IsPreviousControler(tp) and ec:IsType(TYPE_SYNCHRO)
end
-- 弹卡回卡组效果的目标选择与发动检查函数
function c1003840.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsAbleToDeck() end
	if chk==0 then return true end
	-- 给玩家发送选择返回卡组卡片的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 让玩家选择场上1张卡作为效果对象
	local g=Duel.SelectTarget(tp,Card.IsAbleToDeck,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置效果处理的信息，操作类型为返回卡组，目标为选择的卡片
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,0)
end
-- 弹卡回卡组效果的处理操作函数
function c1003840.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取被选择为效果对象的卡片
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 将目标卡片送回持有者卡组并洗牌
		Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
