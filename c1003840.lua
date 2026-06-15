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
-- 解放代价值的过滤条件：自己场上等级大于0的调整怪兽，且其解放后可腾出怪兽区以从卡组特召与之等级不同的「同调士」怪兽
function c1003840.cfilter(c,e,tp,ft)
	local lv=c:GetLevel()
	return lv>0 and c:IsType(TYPE_TUNER)
		and (ft>0 or (c:IsControler(tp) and c:GetSequence()<5)) and (c:IsControler(tp) or c:IsFaceup())
		-- 检查卡组中是否存在至少1只与被解放怪兽等级不同的「同调士」怪兽
		and Duel.IsExistingMatchingCard(c1003840.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp,lv)
end
-- 用于特殊召唤的「同调士」怪兽的过滤条件函数：属于「同调士」系列、等级不等于解放怪兽的等级、等级在1以上且可以特殊召唤
function c1003840.spfilter(c,e,tp,lv)
	return c:IsSetCard(0x1017) and not c:IsLevel(lv) and c:IsLevelAbove(1) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果①的发动代价（Cost）处理：检查并选择自己场上的1只调整解放，同时记录其等级
function c1003840.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取当前玩家场上可用的主要怪兽区域格数
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 在发动时点检查是否满足解放代价的条件，即怪兽区空位足够且有可解放的满足过滤条件的调整怪兽
	if chk==0 then return ft>-1 and Duel.CheckReleaseGroup(tp,c1003840.cfilter,1,nil,e,tp,ft) end
	-- 让玩家选择1只满足条件的调整怪兽作为解放代价
	local g=Duel.SelectReleaseGroup(tp,c1003840.cfilter,1,1,nil,e,tp,ft)
	e:SetLabel(g:GetFirst():GetLevel())
	-- 将选择的怪兽解放以支付发动代价
	Duel.Release(g,REASON_COST)
end
-- 效果①的发动效果目标（Target）处理：设置特殊召唤操作的效果分类信息
function c1003840.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置效果处理信息为从自己卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果①的效果处理（Operation）函数：从卡组特殊召唤1只与解放怪兽等级不同的「同调士」怪兽
function c1003840.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 若此卡已离场或当前玩家场上没有可用的主要怪兽区域，则效果不处理
	if not e:GetHandler():IsRelateToEffect(e) or Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local lv=e:GetLabel()
	-- 给玩家发送选择特殊召唤怪兽的系统提示
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己卡组选择1只满足特殊召唤条件的「同调士」怪兽
	local g=Duel.SelectMatchingCard(tp,c1003840.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,lv)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧表示特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 效果②的发动条件过滤函数：必须在对方回合，且自己从额外卡组将同调怪兽特殊召唤成功时
function c1003840.thcon(e,tp,eg,ep,ev,re,r,rp)
	local ec=eg:GetFirst()
	-- 检查当前回合玩家是否为对方玩家（即对方回合）
	return Duel.GetTurnPlayer()~=tp
		and ec:IsPreviousLocation(LOCATION_EXTRA) and ec:IsPreviousControler(tp) and ec:IsType(TYPE_SYNCHRO)
end
-- 效果②的发动效果目标（Target）处理：选择场上1张卡作为回到卡组的对象，并设定效果分类信息
function c1003840.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsAbleToDeck() end
	if chk==0 then return true end
	-- 给玩家发送选择要返回卡组的卡的系统提示
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择双方场上的1张可以回到卡组的卡作为效果的对象
	local g=Duel.SelectTarget(tp,Card.IsAbleToDeck,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置效果处理信息为将选中的卡送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,0)
end
-- 效果②的效果处理（Operation）函数：使选中的场上1张卡回到持有者卡组
function c1003840.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选为对象的目标卡片
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 将对象卡片送回持有者卡组并洗牌
		Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
